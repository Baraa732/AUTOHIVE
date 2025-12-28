<?php

namespace App\Services;

use App\Models\User;
use App\Models\Apartment;
use App\Models\Booking;
use App\Models\AdminActivity;
use Illuminate\Support\Facades\DB;
use App\Services\NotificationService;
use Carbon\Carbon;
use Illuminate\Support\Facades\Auth;


class AdminService
{
    public function getDashboardStats()
    {
        return [
            'total_users' => User::count(),
            'pending_approvals' => User::where('is_approved', false)->count(),
            'total_apartments' => Apartment::count(),
            'available_apartments' => Apartment::where('is_available', true)->count(),
            'total_bookings' => Booking::count(),
            'pending_bookings' => Booking::where('status', 'pending')->count(),
            'confirmed_bookings' => Booking::where('status', 'confirmed')->count(),
            'completed_bookings' => Booking::where('status', 'completed')->count(),
            'total_revenue' => Booking::where('status', 'completed')->sum('total_price') ?? 0,
            'monthly_revenue' => Booking::where('status', 'completed')
                ->whereMonth('created_at', Carbon::now()->month)
                ->sum('total_price') ?? 0,
        ];
    }

    public function getRecentActivities($limit = 10)
    {
        return \App\Models\Activity::with('admin')
            ->latest()
            ->take($limit)
            ->get();
    }

    public function getAdminStats()
    {
        return [
            'total_admins' => 1, // Only one admin in simplified system
            'active_today' => \App\Models\Activity::whereDate('created_at', Carbon::today())
                ->distinct('admin_id')
                ->count(),
            'active_this_week' => \App\Models\Activity::whereBetween('created_at', [
                Carbon::now()->startOfWeek(),
                Carbon::now()->endOfWeek()
            ])->distinct('admin_id')->count(),
        ];
    }

    public function getUsers($filters = [])
    {
        $query = User::query();

        if (isset($filters['status'])) {
            if ($filters['status'] === 'approved') {
                $query->where('is_approved', true);
            } elseif ($filters['status'] === 'pending') {
                $query->where('is_approved', false);
            }
        }

        if (isset($filters['search'])) {
            $search = $filters['search'];
            $query->where(function($q) use ($search) {
                $q->where('first_name', 'like', "%{$search}%")
                  ->orWhere('last_name', 'like', "%{$search}%")
                  ->orWhere('phone', 'like', "%{$search}%");
            });
        }

        return $query->latest()->paginate(20);
    }

    public function approveUser($userId)
    {
        return DB::transaction(function () use ($userId) {
            $user = User::findOrFail($userId);
            $user->update(['is_approved' => true]);

            AdminActivity::log('user_approved', "Approved user: {$user->first_name} {$user->last_name}", [
                'user_id' => $user->id,
                'user_phone' => $user->phone,
            ]);

            NotificationService::send(
                $user->id,
                'success',
                'Account Approved',
                'Your AUTOHIVE account has been approved! You can now access all features.'
            );

            return $user;
        });
    }

    public function rejectUser($userId)
    {
        return DB::transaction(function () use ($userId) {
            $user = User::findOrFail($userId);
            
            AdminActivity::log('user_rejected', "Rejected user: {$user->first_name} {$user->last_name}", [
                'user_id' => $user->id,
                'user_phone' => $user->phone,
            ]);

            $user->forceDelete();
            return true;
        });
    }

    public function getApartments($filters = [])
    {
        $query = Apartment::with(['user']);

        if (isset($filters['status'])) {
            // Change from availability to approval status
            if ($filters['status'] === 'pending') {
                $query->where('status', 'pending');
            } elseif ($filters['status'] === 'approved') {
                $query->where('status', 'approved');
            } elseif ($filters['status'] === 'rejected') {
                $query->where('status', 'rejected');
            } elseif ($filters['status'] === 'available') {
                $query->where('is_available', true);
            } elseif ($filters['status'] === 'occupied') {
                $query->where('is_available', false);
            }
        }

        if (isset($filters['search'])) {
            $search = $filters['search'];
            $query->where(function ($q) use ($search) {
                $q->where('title', 'like', "%{$search}%")
                    ->orWhere('city', 'like', "%{$search}%")
                    ->orWhere('governorate', 'like', "%{$search}%")
                    ->orWhereHas('user', function ($q) use ($search) {
                        $q->where('first_name', 'like', "%{$search}%")
                            ->orWhere('last_name', 'like', "%{$search}%");
                    });
            });
        }

        return $query->latest()->paginate(10); // Changed from 20 to 10 for better display
    }

    public function approveApartment($apartmentId)
    {
        return DB::transaction(function () use ($apartmentId) {
            $apartment = Apartment::findOrFail($apartmentId);

            $apartment->update([
                'is_approved' => true,
                'status' => 'approved',
                'is_available' => true, // Make it available for booking
                'rejection_reason' => null,
                'approved_at' => now(),
                'approved_by' => Auth::id()
            ]);

            // Log activity
            \App\Models\Activity::log(
                'apartment_approved',
                "Approved apartment: {$apartment->title}",
                ['apartment_id' => $apartment->id, 'admin_id' => Auth::id()]
            );

            // Notify user
            NotificationService::send(
                $apartment->user_id,
                'success',
                'Apartment Approved',
                "Your apartment '{$apartment->title}' has been approved and is now live!"
            );

            return $apartment;
        });
    }

    public function rejectApartment($apartmentId, $reason)
    {
        return DB::transaction(function () use ($apartmentId, $reason) {
            $apartment = Apartment::findOrFail($apartmentId);

            $apartment->update([
                'is_approved' => false,
                'status' => 'rejected',
                'is_available' => false, // Keep it unavailable
                'rejection_reason' => $reason,
                'rejected_at' => now(),
                'rejected_by' => Auth::id()
            ]);

            // Log activity
            \App\Models\Activity::log(
                'apartment_rejected',
                "Rejected apartment: {$apartment->title}",
                ['apartment_id' => $apartment->id, 'admin_id' => Auth::id(), 'reason' => $reason]
            );

            // Notify user
            NotificationService::send(
                $apartment->user_id,
                'error',
                'Apartment Rejected',
                "Your apartment '{$apartment->title}' has been rejected. Reason: {$reason}"
            );

            return $apartment;
        });
    }

    public function deleteApartment($apartmentId)
    {
        return DB::transaction(function () use ($apartmentId) {
            $apartment = Apartment::findOrFail($apartmentId);
            
            // Check for active bookings
            $activeBookings = Booking::where('apartment_id', $apartmentId)
                ->whereIn('status', ['pending', 'confirmed'])
                ->count();

            if ($activeBookings > 0) {
                throw new \Exception('Cannot delete apartment with active bookings');
            }

            AdminActivity::log('apartment_deleted', "Deleted apartment: {$apartment->title}", [
                'apartment_id' => $apartment->id,
                'user_id' => $apartment->user_id,
            ]);

            $apartment->delete();
            return true;
        });
    }

    public function getBookings($filters = [])
    {
        $query = Booking::with(['user', 'apartment']);

        if (isset($filters['status'])) {
            $query->where('status', $filters['status']);
        }

        if (isset($filters['search'])) {
            $search = $filters['search'];
            $query->whereHas('user', function($q) use ($search) {
                $q->where('first_name', 'like', "%{$search}%")
                  ->orWhere('last_name', 'like', "%{$search}%");
            });
        }

        return $query->latest()->paginate(20);
    }

    public function approveBooking($bookingId)
    {
        return DB::transaction(function () use ($bookingId) {
            $booking = Booking::with(['user', 'apartment'])->findOrFail($bookingId);
            $booking->update(['status' => 'confirmed']);

            AdminActivity::log('booking_approved', "Approved booking for {$booking->apartment->title}", [
                'booking_id' => $booking->id,
                'user_id' => $booking->user_id,
            ]);

            NotificationService::send(
                $booking->user_id,
                'success',
                'Booking Confirmed',
                "Your booking for {$booking->apartment->title} has been confirmed!"
            );

            return $booking;
        });
    }

    public function rejectBooking($bookingId)
    {
        return DB::transaction(function () use ($bookingId) {
            $booking = Booking::with(['user', 'apartment'])->findOrFail($bookingId);
            
            AdminActivity::log('booking_rejected', "Rejected booking for {$booking->apartment->title}", [
                'booking_id' => $booking->id,
                'user_id' => $booking->user_id,
            ]);

            $booking->update(['status' => 'cancelled']);

            NotificationService::send(
                $booking->user_id,
                'error',
                'Booking Cancelled',
                "Your booking for {$booking->apartment->title} has been cancelled."
            );

            return $booking;
        });
    }

    public function getActivities($filters = [])
    {
        $query = AdminActivity::with('admin');

        if (isset($filters['action'])) {
            $query->where('action', $filters['action']);
        }

        if (isset($filters['admin_id'])) {
            $query->where('admin_id', $filters['admin_id']);
        }

        if (isset($filters['date'])) {
            $query->whereDate('created_at', $filters['date']);
        }

        return $query->latest()->paginate(50);
    }
}
