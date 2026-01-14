<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Apartment;
use App\Models\Booking;
use Illuminate\Http\Request;

class ApartmentAvailabilityController extends Controller
{
    public function getBookedDates($apartmentId)
    {
        $apartment = Apartment::findOrFail($apartmentId);
        
        // Only return CONFIRMED bookings as blocked dates
        // PENDING bookings should not block the calendar since multiple users can request the same dates
        $bookedDates = Booking::where('apartment_id', $apartmentId)
            ->where('status', Booking::STATUS_CONFIRMED)
            ->select(['check_in', 'check_out'])
            ->get()
            ->map(function ($booking) {
                return [
                    'check_in' => $booking->check_in->format('Y-m-d'),
                    'check_out' => $booking->check_out->format('Y-m-d'),
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $bookedDates,
            'message' => 'Booked dates retrieved successfully'
        ]);
    }
}
