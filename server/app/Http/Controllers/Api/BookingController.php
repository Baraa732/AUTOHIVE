<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use App\Models\Apartment;
use App\Models\BookingRequest;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class BookingController extends Controller
{
    public function index(Request $request)
    {
        $query = Booking::with(['apartment.user', 'user'])
            ->where('user_id', $request->user()->id);

        // Filter by status
        if ($request->status) {
            if ($request->status === 'active') {
                $query->whereIn('status', ['pending', 'approved']);
            } else {
                $query->where('status', $request->status);
            }
        }

        // Filter by date range
        if ($request->from_date) {
            $query->where('check_in', '>=', $request->from_date);
        }
        if ($request->to_date) {
            $query->where('check_out', '<=', $request->to_date);
        }

        $bookings = $query->orderBy('created_at', 'desc')
            ->paginate($request->get('per_page', 10));

        return response()->json([
            'success' => true,
            'data' => $bookings,
            'message' => 'Bookings retrieved successfully'
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'apartment_id' => 'required|exists:apartments,id',
            'check_in' => 'required|date|after:today',
            'check_out' => 'required|date|after:check_in',
            'payment_details' => 'required|array',
            'payment_details.method' => 'required|string|in:card,cash,bank_transfer',
        ]);

        $apartment = Apartment::findOrFail($request->apartment_id);

        // CRITICAL: Check if apartment is approved and available
        if (!$apartment->is_approved || $apartment->status !== 'approved') {
            return response()->json([
                'success' => false,
                'message' => 'This apartment is not available for booking.',
                'errors' => ['apartment_id' => ['Apartment not approved yet']]
            ], 403);
        }

        if (!$apartment->is_available) {
            return response()->json([
                'success' => false,
                'message' => 'This apartment is currently unavailable.',
                'errors' => ['apartment_id' => ['Apartment unavailable']]
            ], 422);
        }

        // Allow users to book any apartment except their own
        if ($apartment->user_id === $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'You cannot book your own apartment.',
                'errors' => ['apartment_id' => ['Cannot book own apartment']]
            ], 422);
        }

        DB::beginTransaction();
        try {
            // Lock the apartment record to prevent race conditions
            $apartment = Apartment::lockForUpdate()->findOrFail($request->apartment_id);

            // Check if apartment is booked for the dates
            // IMPORTANT: Only check CONFIRMED bookings, not pending ones
            if ($apartment->isBookedForDates($request->check_in, $request->check_out)) {
                DB::rollBack();
                return response()->json([
                    'success' => false,
                    'message' => 'Apartment is not available for selected dates.',
                    'errors' => ['dates' => ['Dates not available']]
                ], 422);
            }

            $checkIn = \Carbon\Carbon::parse($request->check_in);
            $checkOut = \Carbon\Carbon::parse($request->check_out);
            $nights = $checkIn->diffInDays($checkOut);
            $totalPrice = $nights * $apartment->price_per_night;

            $booking = Booking::create([
                'user_id' => $request->user()->id,
                'apartment_id' => $request->apartment_id,
                'check_in' => $request->check_in,
                'check_out' => $request->check_out,
                'total_price' => $totalPrice,
                'payment_details' => $request->payment_details,
                'status' => 'pending',
            ]);

            DB::commit();

            // Send notification to apartment owner
            $this->notifyApartmentOwner($booking);

            return response()->json([
                'success' => true,
                'message' => 'Booking request created successfully. Waiting for owner approval.',
                'data' => $booking->load(['apartment.user', 'user'])
            ], 201);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Failed to create booking',
                'errors' => ['general' => [$e->getMessage()]]
            ], 500);
        }
    }

    private function notifyApartmentOwner($booking)
    {
        // Create notification for apartment owner
        \App\Models\Notification::create([
            'user_id' => $booking->apartment->user_id,
            'type' => 'booking_request',
            'title' => 'New Booking Request',
            'message' => "You have a new booking request for {$booking->apartment->title}",
            'data' => ['booking_id' => $booking->id]
        ]);
    }

    public function update(Request $request, $id)
    {
        $booking = Booking::where('user_id', $request->user()->id)
            ->whereIn('status', ['pending', 'approved'])
            ->findOrFail($id);

        // Check if booking can be modified (not within 24 hours of check-in)
        if ($booking->check_in->diffInHours(now()) < 24) {
            return response()->json([
                'success' => false,
                'message' => 'Cannot modify booking within 24 hours of check-in',
                'errors' => ['timing' => ['Too close to check-in date']]
            ], 422);
        }

        $request->validate([
            'check_in' => 'date|after:today',
            'check_out' => 'date|after:check_in',
            'payment_details' => 'array',
        ]);

        DB::beginTransaction();
        try {
            $updateData = [];
            $recalculatePrice = false;

            if ($request->check_in || $request->check_out) {
                $checkIn = $request->check_in ?? $booking->check_in->format('Y-m-d');
                $checkOut = $request->check_out ?? $booking->check_out->format('Y-m-d');

                // Check availability for new dates
                if ($booking->apartment->isBookedForDates($checkIn, $checkOut, $booking->id)) {
                    DB::rollBack();
                    return response()->json([
                        'success' => false,
                        'message' => 'Apartment is not available for selected dates.',
                        'errors' => ['dates' => ['Dates not available']]
                    ], 422);
                }

                $updateData['check_in'] = $checkIn;
                $updateData['check_out'] = $checkOut;
                $recalculatePrice = true;
            }

            if ($request->payment_details) {
                $updateData['payment_details'] = $request->payment_details;
            }

            if ($recalculatePrice) {
                $nights = \Carbon\Carbon::parse($updateData['check_in'])->diffInDays($updateData['check_out']);
                $updateData['total_price'] = $nights * $booking->apartment->price_per_night;
            }

            // Reset status to pending if dates changed and booking was approved
            if (($request->check_in || $request->check_out) && $booking->status === 'approved') {
                $updateData['status'] = 'pending';
            }

            $booking->update($updateData);
            DB::commit();

            // Notify owner if dates changed
            if ($request->check_in || $request->check_out) {
                $this->notifyOwnerOfModification($booking);
            }

            return response()->json([
                'success' => true,
                'message' => 'Booking updated successfully',
                'data' => $booking->fresh(['apartment.user', 'user'])
            ]);
            
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Failed to update booking',
                'errors' => ['general' => [$e->getMessage()]]
            ], 500);
        }
    }

    private function notifyOwnerOfModification($booking)
    {
        \App\Models\Notification::create([
            'user_id' => $booking->apartment->user_id,
            'type' => 'booking_modified',
            'title' => 'Booking Modified',
            'message' => "Booking for {$booking->apartment->title} has been modified",
            'data' => ['booking_id' => $booking->id]
        ]);
    }

    public function destroy(Request $request, $id)
    {
        try {
            // First, find the booking regardless of status
            $booking = Booking::where('user_id', $request->user()->id)
                ->find($id);

            if (!$booking) {
                return response()->json([
                    'success' => false,
                    'message' => 'Booking not found or you do not have permission to cancel it'
                ], 404);
            }

            // Check if booking can be cancelled
            if ($booking->status === 'cancelled') {
                return response()->json([
                    'success' => false,
                    'message' => 'This booking is already cancelled'
                ], 422);
            }

            if ($booking->status === 'completed') {
                return response()->json([
                    'success' => false,
                    'message' => 'Completed bookings cannot be cancelled'
                ], 422);
            }

            if (!in_array($booking->status, ['pending', 'approved'])) {
                return response()->json([
                    'success' => false,
                    'message' => 'Only pending or approved bookings can be cancelled',
                    'debug' => [
                        'current_status' => $booking->status
                    ]
                ], 422);
            }

            // Rest of your existing cancellation logic...
            $hoursUntilCheckIn = $booking->check_in->diffInHours(now());
            $cancellationFee = 0;

            if ($hoursUntilCheckIn < 24) {
                $cancellationFee = $booking->total_price * 0.5;
            } elseif ($hoursUntilCheckIn < 48) {
                $cancellationFee = $booking->total_price * 0.25;
            }

            $oldStatus = $booking->status;
            $booking->update([
                'status' => 'cancelled',
                'payment_details' => array_merge($booking->payment_details ?? [], [
                    'cancellation_fee' => $cancellationFee,
                    'cancelled_at' => now()->toISOString()
                ])
            ]);

            // Make apartment available again if it was approved booking
            if ($oldStatus === 'approved') {
                $booking->apartment()->update(['is_available' => true]);
            }

            // Fire event for notification
            event(new \App\Events\BookingStatusChanged($booking->load('apartment'), $oldStatus, 'cancelled'));

            return response()->json([
                'success' => true,
                'message' => 'Booking cancelled successfully',
                'data' => [
                    'cancellation_fee' => $cancellationFee,
                    'refund_amount' => $booking->total_price - $cancellationFee,
                    'booking_status' => 'cancelled'
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to cancel booking: ' . $e->getMessage()
            ], 500);
        }
    }


    public function myApartmentBookings(Request $request)
    {
        $bookings = Booking::with(['apartment', 'user'])
            ->whereHas('apartment', function($query) use ($request) {
                $query->where('user_id', $request->user()->id);
            })
            ->orderBy('created_at', 'desc')
            ->paginate(10);

        return response()->json([
            'success' => true,
            'data' => $bookings,
            'message' => 'Apartment bookings retrieved successfully'
        ]);
    }

    public function show(Request $request, $id)
    {
        $booking = Booking::with(['apartment.user', 'user'])
            ->where('user_id', $request->user()->id)
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $booking,
            'message' => 'Booking details retrieved successfully'
        ]);
    }

    public function apartmentBookingShow(Request $request, $id)
    {
        $booking = Booking::with(['apartment', 'user'])
            ->whereHas('apartment', function($query) use ($request) {
                $query->where('user_id', $request->user()->id);
            })
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $booking,
            'message' => 'Booking details retrieved successfully'
        ]);
    }

    public function approve(Request $request, $id)
    {
        try {
            Log::info('Attempting to approve booking', [
                'booking_id' => $id,
                'owner_id' => $request->user()->id,
                'owner_name' => $request->user()->first_name . ' ' . $request->user()->last_name
            ]);

            $booking = Booking::with('apartment')
                ->whereHas('apartment', function ($query) use ($request) {
                    $query->where('user_id', $request->user()->id);
                })
                ->where('status', 'pending')
                ->findOrFail($id);

            Log::info('Booking found', [
                'booking_id' => $booking->id,
                'apartment_id' => $booking->apartment_id,
                'apartment_title' => $booking->apartment->title,
                'current_status' => $booking->status
            ]);

            DB::beginTransaction();

            $oldStatus = $booking->status;
            $booking->update(['status' => 'confirmed']);

            Log::info('Booking status updated', ['new_status' => 'confirmed']);

            // Make apartment unavailable
            $booking->apartment->update(['is_available' => false]);

            Log::info('Apartment availability updated', [
                'apartment_id' => $booking->apartment_id,
                'new_availability' => false
            ]);

            // AUTO-REJECT OTHER PENDING BOOKINGS
            $rejectedCount = Booking::where('apartment_id', $booking->apartment_id)
                ->where('id', '!=', $booking->id)
                ->where('status', 'pending')
                ->where(function ($query) use ($booking) {
                    $query->whereBetween('check_in', [$booking->check_in, $booking->check_out])
                        ->orWhereBetween('check_out', [$booking->check_in, $booking->check_out])
                        ->orWhere(function ($q) use ($booking) {
                            $q->where('check_in', '<=', $booking->check_in)
                                ->where('check_out', '>=', $booking->check_out);
                        });
                })
                ->update(['status' => 'cancelled']);

            Log::info('Auto-rejected other bookings', ['count' => $rejectedCount]);

            DB::commit();

            event(new \App\Events\BookingStatusChanged($booking->load('apartment'), $oldStatus, 'confirmed'));

            Log::info('Booking approved successfully', ['booking_id' => $booking->id]);

            return response()->json([
                'success' => true,
                'message' => 'Booking approved successfully',
                'data' => $booking
            ]);
        } catch (\Exception $e) {
            DB::rollBack();

            Log::error('Failed to approve booking', [
                'booking_id' => $id,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Failed to approve booking: ' . $e->getMessage() // Show error for debugging
            ], 500);
        }
    }

    public function reject(Request $request, $id)
    {
        $booking = Booking::with('apartment')
            ->whereHas('apartment', function ($query) use ($request) {
                $query->where('user_id', $request->user()->id);
            })
            ->where('status', 'pending')
            ->findOrFail($id);

        DB::beginTransaction();
        try {
            $oldStatus = $booking->status;
            $booking->update(['status' => 'cancelled']);

            // Make apartment available again since booking was rejected
            $booking->apartment->update(['is_available' => true]);

            DB::commit();

            event(new \App\Events\BookingStatusChanged($booking->load('apartment'), $oldStatus, 'cancelled'));

            return response()->json([
                'success' => true,
                'message' => 'Booking rejected successfully',
                'data' => $booking
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Failed to reject booking'
            ], 500);
        }
    }

    public function completeBooking($bookingId)
    {
        $booking = Booking::with('apartment')->findOrFail($bookingId);

        DB::beginTransaction();
        try {
            $booking->update(['status' => 'completed']);

            // Make apartment available again
            $booking->apartment->update(['is_available' => true]);

            DB::commit();

            // Notify user that booking is completed
            \App\Models\Notification::create([
                'user_id' => $booking->user_id,
                'type' => 'booking_completed',
                'title' => 'Booking Completed',
                'message' => "Your booking for {$booking->apartment->title} has been completed.",
                'data' => ['booking_id' => $booking->id]
            ]);

            return true;
        } catch (\Exception $e) {
            DB::rollBack();
            return false;
        }
    }

    public function history(Request $request)
    {
        $query = Booking::with(['apartment.user', 'user'])
            ->where('user_id', $request->user()->id);

        // Filter by type
        $type = $request->get('type', 'all');
        switch ($type) {
            case 'completed':
                $query->where('status', 'completed');
                break;
            case 'cancelled':
                $query->where('status', 'cancelled');
                break;
            case 'past':
                $query->whereIn('status', ['completed', 'cancelled'])
                      ->where('check_out', '<', now());
                break;
            case 'current':
                $query->where('status', 'approved')
                      ->where('check_in', '<=', now())
                      ->where('check_out', '>=', now());
                break;
            default:
                // All bookings
                break;
        }

        // Date range filter
        if ($request->from_date) {
            $query->where('check_in', '>=', $request->from_date);
        }
        if ($request->to_date) {
            $query->where('check_out', '<=', $request->to_date);
        }

        $bookings = $query->orderBy('created_at', 'desc')
            ->paginate($request->get('per_page', 10));

        // Add additional info for each booking
        $bookings->getCollection()->transform(function ($booking) {
            $booking->can_review = $booking->status === 'completed' && 
                                 !$booking->reviews()->where('user_id', $booking->user_id)->exists();
            $booking->can_cancel = in_array($booking->status, ['pending', 'approved']) && 
                                 $booking->check_in->isFuture();
            $booking->can_modify = in_array($booking->status, ['pending', 'approved']) && 
                                 $booking->check_in->diffInHours(now()) > 24;
            return $booking;
        });

        return response()->json([
            'success' => true,
            'data' => $bookings,
            'message' => 'Booking history retrieved successfully'
        ]);
    }

    public function upcoming(Request $request)
    {
        $bookings = Booking::with(['apartment.user', 'user'])
            ->where('user_id', $request->user()->id)
            ->whereIn('status', ['pending', 'approved'])
            ->where('check_in', '>=', now())
            ->orderBy('check_in', 'asc')
            ->paginate($request->get('per_page', 10));

        // Add action flags
        $bookings->getCollection()->transform(function ($booking) {
            $booking->can_cancel = $booking->check_in->isFuture();
            $booking->can_modify = $booking->check_in->diffInHours(now()) > 24;
            $booking->days_until_checkin = $booking->check_in->diffInDays(now());
            return $booking;
        });

        return response()->json([
            'success' => true,
            'data' => $bookings,
            'message' => 'Upcoming bookings retrieved successfully'
        ]);
    }

    public function checkAvailability(Request $request, $apartmentId)
    {
        $request->validate([
            'check_in' => 'required|date|after:today',
            'check_out' => 'required|date|after:check_in',
        ]);

        $apartment = Apartment::findOrFail($apartmentId);
        
        $isAvailable = !$apartment->isBookedForDates($request->check_in, $request->check_out);
        
        $checkIn = \Carbon\Carbon::parse($request->check_in);
        $checkOut = \Carbon\Carbon::parse($request->check_out);
        $nights = $checkIn->diffInDays($checkOut);
        $totalPrice = $nights * $apartment->price_per_night;

        // Get conflicting bookings if any
        $conflicts = [];
        if (!$isAvailable) {
            $conflicts = $apartment->bookings()
                ->where('status', 'confirmed')
                ->where(function ($query) use ($request) {
                    $query->where(function ($q) use ($request) {
                        $q->where('check_in', '<=', $request->check_in)
                          ->where('check_out', '>', $request->check_in);
                    })
                    ->orWhere(function ($q) use ($request) {
                        $q->where('check_in', '<', $request->check_out)
                          ->where('check_out', '>=', $request->check_out);
                    })
                    ->orWhere(function ($q) use ($request) {
                        $q->where('check_in', '>=', $request->check_in)
                          ->where('check_out', '<=', $request->check_out);
                    });
                })
                ->select(['check_in', 'check_out'])
                ->get();
        }

        return response()->json([
            'success' => true,
            'data' => [
                'available' => $isAvailable,
                'nights' => $nights,
                'total_price' => $totalPrice,
                'price_per_night' => $apartment->price_per_night,
                'conflicts' => $conflicts
            ],
            'message' => $isAvailable ? 'Apartment is available' : 'Apartment is not available for selected dates'
        ]);
    }


    public function requestBooking(Request $request)
    {
        $request->validate([
            'apartment_id' => 'required|exists:apartments,id',
            'check_in' => 'required|date|after:today',
            'check_out' => 'required|date|after:check_in',
            'guests' => 'required|integer|min:1',
            'message' => 'nullable|string|max:500',
        ]);

        $apartment = Apartment::findOrFail($request->apartment_id);

        // Check if apartment is approved by admin
        if (!$apartment->is_approved || $apartment->status !== 'approved') {
            return response()->json([
                'success' => false,
                'message' => 'This apartment is not available for booking yet.',
            ], 403);
        }

        // Check if user is the apartment owner
        if ($apartment->user_id === $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'You cannot request to rent your own property.',
                'errors' => ['apartment_id' => ['Cannot request to rent own property']]
            ], 422);
        }

        // Check if user already has pending request for these dates
        $existingRequest = BookingRequest::where('user_id', $request->user()->id)
            ->where('apartment_id', $request->apartment_id)
            ->where('status', 'pending')
            ->where(function ($query) use ($request) {
                $query->whereBetween('check_in', [$request->check_in, $request->check_out])
                    ->orWhereBetween('check_out', [$request->check_in, $request->check_out])
                    ->orWhere(function ($q) use ($request) {
                        $q->where('check_in', '<=', $request->check_in)
                            ->where('check_out', '>=', $request->check_out);
                    });
            })
            ->first();

        if ($existingRequest) {
            return response()->json([
                'success' => false,
                'message' => 'You already have a pending request for this apartment.',
            ], 422);
        }

        // Check if dates are available (considering approved bookings)
        $conflictingRequests = BookingRequest::where('apartment_id', $request->apartment_id)
            ->where('status', 'approved')
            ->where(function ($query) use ($request) {
                $query->whereBetween('check_in', [$request->check_in, $request->check_out])
                    ->orWhereBetween('check_out', [$request->check_in, $request->check_out])
                    ->orWhere(function ($q) use ($request) {
                        $q->where('check_in', '<=', $request->check_in)
                            ->where('check_out', '>=', $request->check_out);
                    });
            })
            ->exists();

        if ($conflictingRequests) {
            return response()->json([
                'success' => false,
                'message' => 'These dates are no longer available.',
            ], 422);
        }

        // Calculate price
        $nights = \Carbon\Carbon::parse($request->check_in)->diffInDays($request->check_out);
        $totalPrice = $nights * $apartment->price_per_night;

        // Create booking request
        $bookingRequest = BookingRequest::create([
            'user_id' => $request->user()->id,
            'apartment_id' => $request->apartment_id,
            'check_in' => $request->check_in,
            'check_out' => $request->check_out,
            'guests' => $request->guests,
            'total_price' => $totalPrice,
            'message' => $request->message,
            'status' => 'pending',
        ]);

        // Notify apartment owner
        $this->notifyOwnerOfBookingRequest($bookingRequest);

        return response()->json([
            'success' => true,
            'message' => 'Booking request sent successfully.',
            'data' => $bookingRequest->load(['user', 'apartment'])
        ], 201);
    }

    private function notifyOwnerOfBookingRequest($bookingRequest)
    {
        \App\Models\Notification::create([
            'user_id' => $bookingRequest->apartment->user_id,
            'type' => 'booking_request',
            'title' => 'New Booking Request',
            'message' => "You have a new booking request for {$bookingRequest->apartment->title} from {$bookingRequest->user->first_name}",
            'data' => [
                'booking_request_id' => $bookingRequest->id,
                'apartment_id' => $bookingRequest->apartment_id,
                'user_id' => $bookingRequest->user_id
            ]
        ]);
    }
}
