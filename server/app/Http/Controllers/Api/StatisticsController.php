<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Apartment;
use App\Models\Booking;
use App\Models\Review;
use Illuminate\Http\Request;

class StatisticsController extends Controller
{
    public function userStats(Request $request)
    {
        $user = $request->user();
        
        if ($user->role === 'landlord') {
            return $this->landlordStats($user);
        } else {
            return $this->tenantStats($user);
        }
    }

    private function landlordStats($user)
    {
        $apartments = Apartment::where('landlord_id', $user->id);
        $bookings = Booking::whereHas('apartment', function($q) use ($user) {
            $q->where('landlord_id', $user->id);
        });

        return response()->json([
            'total_apartments' => $apartments->count(),
            'available_apartments' => $apartments->where('is_available', true)->count(),
            'total_bookings' => $bookings->count(),
            'pending_bookings' => $bookings->where('status', 'pending')->count(),
            'approved_bookings' => $bookings->where('status', 'approved')->count(),
            'completed_bookings' => $bookings->where('status', 'completed')->count(),
            'total_revenue' => $bookings->where('status', 'completed')->sum('total_price'),
            'average_rating' => Review::whereHas('apartment', function($q) use ($user) {
                $q->where('landlord_id', $user->id);
            })->avg('rating'),
        ]);
    }

    private function tenantStats($user)
    {
        $bookings = Booking::where('tenant_id', $user->id);

        return response()->json([
            'total_bookings' => $bookings->count(),
            'pending_bookings' => $bookings->where('status', 'pending')->count(),
            'approved_bookings' => $bookings->where('status', 'approved')->count(),
            'completed_bookings' => $bookings->where('status', 'completed')->count(),
            'cancelled_bookings' => $bookings->where('status', 'cancelled')->count(),
            'total_spent' => $bookings->where('status', 'completed')->sum('total_price'),
            'favorite_apartments' => $user->favorites()->count(),
            'reviews_given' => Review::where('tenant_id', $user->id)->count(),
        ]);
    }

    public function apartmentStats($id)
    {
        $apartment = Apartment::findOrFail($id);
        
        return response()->json([
            'total_bookings' => $apartment->bookings()->count(),
            'completed_bookings' => $apartment->bookings()->where('status', 'completed')->count(),
            'total_revenue' => $apartment->bookings()->where('status', 'completed')->sum('total_price'),
            'average_rating' => $apartment->reviews()->avg('rating'),
            'total_reviews' => $apartment->reviews()->count(),
            'occupancy_rate' => $this->calculateOccupancyRate($apartment),
        ]);
    }

    private function calculateOccupancyRate($apartment)
    {
        $totalDays = now()->diffInDays($apartment->created_at);
        $bookedDays = $apartment->bookings()
            ->where('status', 'completed')
            ->get()
            ->sum(function($booking) {
                return $booking->check_in->diffInDays($booking->check_out);
            });

        return $totalDays > 0 ? round(($bookedDays / $totalDays) * 100, 2) : 0;
    }
}
