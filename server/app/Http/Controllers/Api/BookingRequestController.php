<?php

// app/Http/Controllers/Api/BookingRequestController.php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\BookingRequest;
use App\Models\Booking;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class BookingRequestController extends Controller
{
    public function myRequests(Request $request)
    {
        // Load pending bookings created by the current user
        $requests = Booking::with(['apartment.user', 'user'])
            ->where('user_id', $request->user()->id)
            ->where('status', Booking::STATUS_PENDING)
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $requests,
            'message' => 'My booking requests retrieved successfully'
        ]);
    }

    public function myApartmentRequests(Request $request)
    {
        // Load pending bookings for apartments owned by the current user
        $requests = Booking::with(['user', 'apartment'])
            ->whereHas('apartment', function ($query) use ($request) {
                $query->where('user_id', $request->user()->id);
            })
            ->where('status', Booking::STATUS_PENDING)
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $requests,
            'message' => 'Booking requests retrieved successfully'
        ]);
    }

    public function approveRequest(Request $request, $id)
    {
        $booking = Booking::with(['apartment', 'user'])
            ->whereHas('apartment', function ($query) use ($request) {
                $query->where('user_id', $request->user()->id);
            })
            ->where('status', Booking::STATUS_PENDING)
            ->findOrFail($id);

        DB::beginTransaction();
        try {
            // Update booking status to confirmed
            $booking->update(['status' => Booking::STATUS_CONFIRMED]);

            // Mark apartment as unavailable
            $booking->apartment->update(['is_available' => false]);

            // Reject all other pending bookings for overlapping dates
            Booking::where('apartment_id', $booking->apartment_id)
                ->where('id', '!=', $booking->id)
                ->where('status', Booking::STATUS_PENDING)
                ->where(function ($query) use ($booking) {
                    $query->whereBetween('check_in', [$booking->check_in, $booking->check_out])
                        ->orWhereBetween('check_out', [$booking->check_in, $booking->check_out])
                        ->orWhere(function ($q) use ($booking) {
                            $q->where('check_in', '<=', $booking->check_in)
                                ->where('check_out', '>=', $booking->check_out);
                        });
                })
                ->update(['status' => Booking::STATUS_REJECTED]);

            DB::commit();

            // Notify the approved user
            \App\Models\Notification::create([
                'user_id' => $booking->user_id,
                'type' => 'booking_approved',
                'title' => 'Booking Approved',
                'message' => "Your booking request for {$booking->apartment->title} has been approved!",
                'data' => ['booking_id' => $booking->id]
            ]);

            // Notify rejected users
            $rejectedBookings = Booking::where('apartment_id', $booking->apartment_id)
                ->where('status', Booking::STATUS_REJECTED)
                ->where('updated_at', '>=', now()->subMinute())
                ->get();

            foreach ($rejectedBookings as $rejectedBooking) {
                \App\Models\Notification::create([
                    'user_id' => $rejectedBooking->user_id,
                    'type' => 'booking_rejected',
                    'title' => 'Booking Request Rejected',
                    'message' => "Your booking request for {$booking->apartment->title} was not approved.",
                    'data' => ['booking_id' => $rejectedBooking->id]
                ]);
            }

            return response()->json([
                'success' => true,
                'message' => 'Booking request approved successfully.',
                'data' => $booking
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Failed to approve booking request.'
            ], 500);
        }
    }

    public function rejectRequest(Request $request, $id)
    {
        $booking = Booking::with(['apartment', 'user'])
            ->whereHas('apartment', function ($query) use ($request) {
                $query->where('user_id', $request->user()->id);
            })
            ->where('status', Booking::STATUS_PENDING)
            ->findOrFail($id);

        $booking->update(['status' => Booking::STATUS_REJECTED]);

        // Notify user
        \App\Models\Notification::create([
            'user_id' => $booking->user_id,
            'type' => 'booking_rejected',
            'title' => 'Booking Request Rejected',
            'message' => "Your booking request for {$booking->apartment->title} has been rejected.",
            'data' => ['booking_id' => $booking->id]
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Booking request rejected successfully.'
        ]);
    }
}
