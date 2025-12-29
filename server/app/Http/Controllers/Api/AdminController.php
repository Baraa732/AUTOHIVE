<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Apartment;
use App\Models\Booking;
use App\Models\AdminActivity;
use Illuminate\Http\Request;

class AdminController extends Controller
{
    public function dashboard()
    {
        $stats = [
            'total_users' => User::count(),
            'pending_approvals' => User::where('is_approved', false)->count(),
            'total_apartments' => Apartment::count(),
            'total_bookings' => Booking::count(),
            'pending_bookings' => Booking::where('status', Booking::STATUS_PENDING)->count(),
            'total_revenue' => Booking::where('status', Booking::STATUS_COMPLETED)->sum('total_price')
        ];

        $recentActivities = AdminActivity::with('admin')
            ->latest()
            ->take(10)
            ->get();

        $adminStats = [
            'total_admins' => 1, // Simplified system has only one admin
            'active_today' => AdminActivity::whereDate('created_at', today())
                ->distinct('admin_id')
                ->count()
        ];

        return response()->json([
            'success' => true,
            'data' => [
                'stats' => $stats,
                'recent_activities' => $recentActivities,
                'admin_stats' => $adminStats
            ],
            'message' => 'Dashboard data retrieved successfully'
        ]);
    }

    public function users(Request $request)
    {
        $query = User::query();
        
        // Status filtering
        if ($request->has('status') && $request->status !== 'all') {
            if ($request->status === 'pending') {
                $query->where('is_approved', false);
            } elseif ($request->status === 'approved') {
                $query->where('is_approved', true);
            }
        }
        
        // Search functionality
        if ($request->has('search') && !empty($request->search)) {
            $search = trim($request->search);
            $query->where(function($q) use ($search) {
                $q->where('first_name', 'like', "%{$search}%")
                  ->orWhere('last_name', 'like', "%{$search}%")
                  ->orWhere('phone', 'like', "%{$search}%")
                  ->orWhereRaw("CONCAT(first_name, ' ', last_name) LIKE ?", ["%{$search}%"]);
            });
        }
        
        // Date range filtering
        if ($request->has('date_from') && !empty($request->date_from)) {
            $query->whereDate('created_at', '>=', $request->date_from);
        }
        
        if ($request->has('date_to') && !empty($request->date_to)) {
            $query->whereDate('created_at', '<=', $request->date_to);
        }
        
        // Sorting
        $sortBy = $request->get('sort_by', 'created_at');
        $sortOrder = $request->get('sort_order', 'desc');
        
        if (in_array($sortBy, ['first_name', 'last_name', 'phone', 'created_at', 'is_approved'])) {
            $query->orderBy($sortBy, $sortOrder === 'asc' ? 'asc' : 'desc');
        } else {
            $query->latest();
        }

        $perPage = $request->get('per_page', 20);
        $perPage = in_array($perPage, [10, 20, 50, 100]) ? $perPage : 20;
        
        $users = $query->paginate($perPage);
        
        // Add summary statistics
        $stats = [
            'total' => User::count(),
            'approved' => User::where('is_approved', true)->count(),
            'pending' => User::where('is_approved', false)->count(),
            'with_apartments' => User::whereHas('apartments')->count(),
            'with_bookings' => User::whereHas('bookings')->count(),
        ];

        return response()->json([
            'success' => true,
            'data' => $users,
            'stats' => $stats,
            'filters' => [
                'status' => $request->get('status', 'all'),
                'role' => $request->get('role', 'all'),
                'search' => $request->get('search', ''),
                'sort_by' => $sortBy,
                'sort_order' => $sortOrder,
                'per_page' => $perPage
            ],
            'message' => 'Users retrieved successfully'
        ]);
    }

    public function approveUser(int $id)
    {
        $user = User::findOrFail($id);
        $user->update(['is_approved' => true]);

        // Send real-time notification to user
        $this->notifyUserOfApprovalStatus($user, true);

        AdminActivity::log('user_approved', "Approved user: {$user->first_name} {$user->last_name}", [
            'user_id' => $user->id,
            'user_phone' => $user->phone,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'User approved successfully',
            'data' => $user
        ]);
    }

    public function rejectUser(int $id)
    {
        $user = User::findOrFail($id);
        
        // Prevent admin from rejecting themselves
        if ($user->id === auth('api')->user()?->id) {
            return response()->json([
                'success' => false,
                'message' => 'Cannot reject your own account'
            ], 400);
        }
        
        // Prevent rejecting admin accounts
        if ($user->role === 'admin') {
            return response()->json([
                'success' => false,
                'message' => 'Cannot reject admin accounts'
            ], 400);
        }
        
        // Send real-time notification to user before deletion
        $this->notifyUserOfApprovalStatus($user, false);
        
        AdminActivity::log('user_rejected', "Rejected user: {$user->first_name} {$user->last_name}", [
            'user_id' => $user->id,
            'user_phone' => $user->phone,
        ]);

        $user->delete();

        return response()->json([
            'success' => true,
            'message' => 'User rejected successfully'
        ]);
    }

    private function notifyUserOfApprovalStatus($user, $approved)
    {
        $status = $approved ? 'approved' : 'rejected';
        $message = $approved 
            ? 'Your account has been approved. You can now login and use the app.' 
            : 'Your account registration has been rejected. Please contact support for more information.';
            
        $notification = \App\Models\Notification::create([
            'user_id' => $user->id,
            'type' => 'account_status',
            'title' => 'Account Status Update',
            'message' => $message,
            'data' => ['status' => $status]
        ]);
        
        // Broadcast to user if they're online
        broadcast(new \App\Events\UserNotification($user->id, $notification));
    }

    public function apartments(Request $request)
    {
        $query = Apartment::with(['user']);
        
        if ($request->has('status')) {
            $query->where('is_available', $request->status === 'available');
        }
        
        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('title', 'like', "%{$search}%")
                  ->orWhere('city', 'like', "%{$search}%")
                  ->orWhere('governorate', 'like', "%{$search}%");
            });
        }

        $apartments = $query->latest()->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $apartments,
            'message' => 'Apartments retrieved successfully'
        ]);
    }

    public function deleteApartment(int $id)
    {
        $apartment = Apartment::findOrFail($id);
        
        AdminActivity::log('apartment_deleted', "Deleted apartment: {$apartment->title}", [
            'apartment_id' => $apartment->id,
            'apartment_title' => $apartment->title,
        ]);

        $apartment->delete();

        return response()->json([
            'success' => true,
            'message' => 'Apartment deleted successfully'
        ]);
    }

    public function bookings(Request $request)
    {
        $query = Booking::with(['user', 'apartment']);
        
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }
        
        if ($request->has('search')) {
            $search = $request->search;
            $query->whereHas('user', function($q) use ($search) {
                $q->where('first_name', 'like', "%{$search}%")
                  ->orWhere('last_name', 'like', "%{$search}%");
            });
        }

        $bookings = $query->latest()->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $bookings,
            'message' => 'Bookings retrieved successfully'
        ]);
    }

    public function approveBooking(int $id)
    {
        $booking = Booking::with(['user', 'apartment'])->findOrFail($id);
        $booking->update(['status' => 'confirmed']);

        AdminActivity::log('booking_approved', "Approved booking for {$booking->apartment->title}", [
            'booking_id' => $booking->id,
            'user_id' => $booking->user_id,
        ]);

        return response()->json([
            'success' => true,
            'data' => $booking,
            'message' => 'Booking approved successfully'
        ]);
    }

    public function rejectBooking(int $id)
    {
        $booking = Booking::with(['user', 'apartment'])->findOrFail($id);
        
        AdminActivity::log('booking_rejected', "Rejected booking for {$booking->apartment->title}", [
            'booking_id' => $booking->id,
            'user_id' => $booking->user_id,
        ]);

        $booking->update(['status' => 'cancelled']);

        return response()->json([
            'success' => true,
            'data' => $booking,
            'message' => 'Booking rejected successfully'
        ]);
    }

    public function activities(Request $request)
    {
        $query = AdminActivity::with('admin');
        
        if ($request->has('action')) {
            $query->where('action', $request->action);
        }
        
        if ($request->has('admin_id')) {
            $query->where('admin_id', $request->admin_id);
        }
        
        if ($request->has('date')) {
            $query->whereDate('created_at', $request->date);
        }

        $activities = $query->latest()->paginate(50);

        return response()->json([
            'success' => true,
            'data' => $activities,
            'message' => 'Activities retrieved successfully'
        ]);
    }

    public function admins()
    {
        $admins = User::latest()->paginate(20);
        return response()->json([
            'success' => true,
            'data' => $admins,
            'message' => 'Admins retrieved successfully'
        ]);
    }

    public function createAdmin(Request $request)
    {
        $request->validate([
            'phone' => 'required|string|regex:/^[0-9]{10}$/|unique:users,phone',
            'password' => 'required|string|min:6|max:50',
            'first_name' => 'required|string|min:2|max:50',
            'last_name' => 'required|string|min:2|max:50',
            'birth_date' => 'required|date|before:today',
        ]);

        $admin = User::create([
            'phone' => $request->phone,
            'password' => bcrypt($request->password),
            'first_name' => trim($request->first_name),
            'last_name' => trim($request->last_name),
            'birth_date' => $request->birth_date,
            'is_approved' => true,
            'status' => 'approved',
        ]);

        AdminActivity::log('admin_created', "Created new admin: {$admin->first_name} {$admin->last_name}", [
            'admin_id' => $admin->id,
            'admin_phone' => $admin->phone,
        ]);

        return response()->json([
            'success' => true,
            'data' => $admin,
            'message' => 'Admin created successfully'
        ]);
    }

    public function deleteAdmin(int $id)
    {
        $admin = User::findOrFail($id);
        
        if ($admin->id === auth('api')->user()?->id) {
            return response()->json([
                'success' => false,
                'message' => 'Cannot delete your own account'
            ], 400);
        }

        $adminCount = User::count();
        if ($adminCount <= 1) {
            return response()->json([
                'success' => false,
                'message' => 'Cannot delete the last admin account'
            ], 400);
        }

        $adminName = "{$admin->first_name} {$admin->last_name}";
        
        AdminActivity::log('admin_deleted', "Deleted admin: {$adminName}", [
            'deleted_admin_id' => $admin->id,
            'deleted_admin_phone' => $admin->phone,
        ]);

        $admin->delete();

        return response()->json([
            'success' => true,
            'message' => 'Admin deleted successfully'
        ]);
    }
}
