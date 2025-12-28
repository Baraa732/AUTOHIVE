<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Apartment;
use App\Models\Booking;
use App\Models\Review;
use App\Models\User;
use Illuminate\Http\Request;
use Carbon\Carbon;

class DashboardController extends Controller
{
    public function userDashboard(Request $request)
    {
        $user = $request->user();
        
        // Get user statistics
        $stats = [
            'total_bookings' => Booking::where('tenant_id', $user->id)->count(),
            'active_bookings' => Booking::where('tenant_id', $user->id)
                ->whereIn('status', ['pending', 'approved'])
                ->count(),
            'completed_bookings' => Booking::where('tenant_id', $user->id)
                ->where('status', 'completed')
                ->count(),
            'total_spent' => Booking::where('tenant_id', $user->id)
                ->where('status', 'completed')
                ->sum('total_price'),
        ];

        // Get recent bookings
        $recentBookings = Booking::with(['apartment.landlord'])
            ->where('tenant_id', $user->id)
            ->orderBy('created_at', 'desc')
            ->limit(5)
            ->get();

        // Get upcoming bookings
        $upcomingBookings = Booking::with(['apartment.landlord'])
            ->where('tenant_id', $user->id)
            ->whereIn('status', ['pending', 'approved'])
            ->where('check_in', '>=', now())
            ->orderBy('check_in', 'asc')
            ->limit(3)
            ->get();

        // Get favorite apartments
        $favorites = $user->favorites()
            ->with(['apartment.landlord'])
            ->limit(5)
            ->get()
            ->pluck('apartment');

        // Get pending reviews
        $pendingReviews = Booking::with(['apartment'])
            ->where('tenant_id', $user->id)
            ->where('status', 'completed')
            ->whereDoesntHave('reviews', function($query) use ($user) {
                $query->where('tenant_id', $user->id);
            })
            ->where('check_out', '>=', now()->subDays(30))
            ->limit(5)
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'user' => $user,
                'statistics' => $stats,
                'recent_bookings' => $recentBookings,
                'upcoming_bookings' => $upcomingBookings,
                'favorite_apartments' => $favorites,
                'pending_reviews' => $pendingReviews,
            ],
            'message' => 'Dashboard data retrieved successfully'
        ]);
    }

    public function landlordDashboard(Request $request)
    {
        $user = $request->user();
        
        // Get landlord statistics
        $stats = [
            'total_apartments' => Apartment::where('landlord_id', $user->id)->count(),
            'active_apartments' => Apartment::where('landlord_id', $user->id)
                ->where('is_available', true)
                ->count(),
            'total_bookings' => Booking::whereHas('apartment', function($query) use ($user) {
                $query->where('landlord_id', $user->id);
            })->count(),
            'pending_bookings' => Booking::whereHas('apartment', function($query) use ($user) {
                $query->where('landlord_id', $user->id);
            })->where('status', 'pending')->count(),
            'total_earnings' => Booking::whereHas('apartment', function($query) use ($user) {
                $query->where('landlord_id', $user->id);
            })->where('status', 'completed')->sum('total_price'),
            'this_month_earnings' => Booking::whereHas('apartment', function($query) use ($user) {
                $query->where('landlord_id', $user->id);
            })
            ->where('status', 'completed')
            ->whereMonth('check_out', now()->month)
            ->whereYear('check_out', now()->year)
            ->sum('total_price'),
        ];

        // Get recent bookings
        $recentBookings = Booking::with(['apartment', 'tenant'])
            ->whereHas('apartment', function($query) use ($user) {
                $query->where('landlord_id', $user->id);
            })
            ->orderBy('created_at', 'desc')
            ->limit(5)
            ->get();

        // Get pending bookings
        $pendingBookings = Booking::with(['apartment', 'tenant'])
            ->whereHas('apartment', function($query) use ($user) {
                $query->where('landlord_id', $user->id);
            })
            ->where('status', 'pending')
            ->orderBy('created_at', 'desc')
            ->limit(5)
            ->get();

        // Get apartments performance
        $apartmentsPerformance = Apartment::where('landlord_id', $user->id)
            ->withCount(['bookings', 'reviews'])
            ->withAvg('reviews', 'rating')
            ->with(['bookings' => function($query) {
                $query->where('status', 'completed');
            }])
            ->get()
            ->map(function($apartment) {
                $apartment->total_earnings = $apartment->bookings->sum('total_price');
                $apartment->occupancy_rate = $this->calculateOccupancyRate($apartment);
                return $apartment;
            });

        // Get monthly earnings chart data
        $monthlyEarnings = $this->getMonthlyEarnings($user->id);

        return response()->json([
            'success' => true,
            'data' => [
                'user' => $user,
                'statistics' => $stats,
                'recent_bookings' => $recentBookings,
                'pending_bookings' => $pendingBookings,
                'apartments_performance' => $apartmentsPerformance,
                'monthly_earnings' => $monthlyEarnings,
            ],
            'message' => 'Landlord dashboard data retrieved successfully'
        ]);
    }

    private function calculateOccupancyRate($apartment)
    {
        $totalDays = Carbon::now()->diffInDays(Carbon::parse($apartment->created_at));
        if ($totalDays == 0) return 0;

        $bookedDays = Booking::where('apartment_id', $apartment->id)
            ->where('status', 'completed')
            ->get()
            ->sum(fn($booking) => $booking->check_in->diffInDays($booking->check_out));

        return round(($bookedDays / $totalDays) * 100, 2);
    }

    private function getMonthlyEarnings($landlordId)
    {
        $earnings = [];
        for ($i = 11; $i >= 0; $i--) {
            $date = now()->subMonths($i);
            $monthEarnings = Booking::whereHas('apartment', function($query) use ($landlordId) {
                $query->where('landlord_id', $landlordId);
            })
            ->where('status', 'completed')
            ->whereMonth('check_out', $date->month)
            ->whereYear('check_out', $date->year)
            ->sum('total_price');

            $earnings[] = [
                'month' => $date->format('M Y'),
                'earnings' => $monthEarnings
            ];
        }
        return $earnings;
    }
}
