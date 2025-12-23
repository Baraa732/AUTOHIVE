<?php

// app/Http/Controllers/Api/BookingRequestController.php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\BookingRequest;
use App\Models\Booking;
use Illuminate\Http\Request;

class BookingRequestController extends Controller
{
    public function myRequests(Request $request)
    {
        $requests = BookingRequest::with(['apartment.landlord'])
            ->where('user_id', $request->user()->id)
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $requests,
            'message' => 'My booking requests retrieved successfully'
        ]);
    }

    public function landlordRequests(Request $request)
    {
        $requests = BookingRequest::with(['user', 'apartment'])
            ->whereHas('apartment', function ($query) use ($request) {
                $query->where('landlord_id', $request->user()->id);
            })
            ->where('status', 'pending')
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
        $bookingRequest = BookingRequest::with(['apartment', 'user'])
            ->whereHas('apartment', function ($query) use ($request) {
                $query->where('landlord_id', $request->user()->id);
            })
            ->where('status', 'pending')
            ->findOrFail($id);

        \DB::beginTransaction();
        try {
            // Update the approved request
            $bookingRequest->update(['status' => 'approved']);

            // Create actual booking
            $booking = Booking::create([
                'tenant_id' => $bookingRequest->user_id,
                'apartment_id' => $bookingRequest->apartment_id,
                'check_in' => $bookingRequest->check_in,
                'check_out' => $bookingRequest->check_out,
                'total_price' => $bookingRequest->total_price,
                'status' => 'confirmed',
                'booking_request_id' => $bookingRequest->id,
            ]);

            // Mark apartment as unavailable
            $bookingRequest->apartment->update(['is_available' => false]);

            // Reject all other pending requests for overlapping dates
            BookingRequest::where('apartment_id', $bookingRequest->apartment_id)
                ->where('id', '!=', $bookingRequest->id)
                ->where('status', 'pending')
                ->where(function ($query) use ($bookingRequest) {
                    $query->whereBetween('check_in', [$bookingRequest->check_in, $bookingRequest->check_out])
                        ->orWhereBetween('check_out', [$bookingRequest->check_in, $bookingRequest->check_out])
                        ->orWhere(function ($q) use ($bookingRequest) {
                            $q->where('check_in', '<=', $bookingRequest->check_in)
                                ->where('check_out', '>=', $bookingRequest->check_out);
                        });
                })
                ->update(['status' => 'rejected']);

            \DB::commit();

            // Notify the approved user
            \App\Models\Notification::create([
                'user_id' => $bookingRequest->user_id,
                'type' => 'booking_approved',
                'title' => 'Booking Approved',
                'message' => "Your booking request for {$bookingRequest->apartment->title} has been approved!",
                'data' => ['booking_id' => $booking->id]
            ]);

            // Notify rejected users
            $rejectedRequests = BookingRequest::where('apartment_id', $bookingRequest->apartment_id)
                ->where('status', 'rejected')
                ->where('updated_at', '>=', now()->subMinute())
                ->get();

            foreach ($rejectedRequests as $rejected) {
                \App\Models\Notification::create([
                    'user_id' => $rejected->user_id,
                    'type' => 'booking_rejected',
                    'title' => 'Booking Request Rejected',
                    'message' => "Your booking request for {$bookingRequest->apartment->title} was not approved.",
                    'data' => ['booking_request_id' => $rejected->id]
                ]);
            }

            return response()->json([
                'success' => true,
                'message' => 'Booking request approved successfully.',
                'data' => $booking
            ]);
        } catch (\Exception $e) {
            \DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Failed to approve booking request.'
            ], 500);
        }
    }

    public function rejectRequest(Request $request, $id)
    {
        $bookingRequest = BookingRequest::with(['apartment', 'user'])
            ->whereHas('apartment', function ($query) use ($request) {
                $query->where('landlord_id', $request->user()->id);
            })
            ->where('status', 'pending')
            ->findOrFail($id);

        $bookingRequest->update(['status' => 'rejected']);

        // Notify user
        \App\Models\Notification::create([
            'user_id' => $bookingRequest->user_id,
            'type' => 'booking_rejected',
            'title' => 'Booking Request Rejected',
            'message' => "Your booking request for {$bookingRequest->apartment->title} has been rejected.",
            'data' => ['booking_request_id' => $bookingRequest->id]
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Booking request rejected successfully.'
        ]);
    }
}
