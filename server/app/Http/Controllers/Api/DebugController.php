<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Notification;
use App\Models\User;
use Illuminate\Http\Request;

class DebugController extends Controller
{
    public function checkNotifications(Request $request)
    {
        $user = $request->user();
        
        // Get all notifications for this user
        $notifications = Notification::where('user_id', $user->id)->get();
        
        // Get all users
        $users = User::all();
        
        // Get recent registrations
        $recentUsers = User::where('created_at', '>=', now()->subHours(1))->get();
        
        return response()->json([
            'success' => true,
            'data' => [
                'current_user' => $user,
                'notifications_count' => $notifications->count(),
                'notifications' => $notifications,
                'total_users' => $users->count(),
                'recent_users' => $recentUsers,
                'admin_count' => User::where('role', 'admin')->count()
            ],
            'message' => 'Debug info retrieved'
        ]);
    }
    
    public function forceCreateNotification(Request $request)
    {
        $user = $request->user();
        
        if ($user->role !== 'admin') {
            return response()->json(['error' => 'Admin only'], 403);
        }
        
        // Force create a notification
        $notification = Notification::create([
            'user_id' => $user->id,
            'type' => 'test_force',
            'title' => 'Force Created Notification',
            'message' => 'This notification was force created at ' . now(),
            'data' => ['forced' => true],
            'read_at' => null
        ]);
        
        return response()->json([
            'success' => true,
            'data' => $notification,
            'message' => 'Notification force created'
        ]);
    }

    public function checkRentalApplications(Request $request)
    {
        $user = $request->user();
        
        $rentalApps = \App\Models\RentalApplication::with(['user', 'apartment', 'apartment.user'])
            ->orderBy('created_at', 'desc')
            ->limit(50)
            ->get();
        
        $userApartments = \App\Models\Apartment::where('user_id', $user->id)->get();
        
        $incomingApps = \App\Models\RentalApplication::with(['user', 'apartment'])
            ->whereHas('apartment', function ($query) use ($user) {
                $query->where('user_id', $user->id);
            })
            ->where('status', 'pending')
            ->get();
        
        return response()->json([
            'success' => true,
            'data' => [
                'current_user' => $user,
                'user_apartments' => $userApartments,
                'incoming_applications_for_user' => $incomingApps,
                'all_recent_applications' => $rentalApps,
                'debug_info' => [
                    'user_id' => $user->id,
                    'user_apartments_count' => $userApartments->count(),
                    'incoming_count' => $incomingApps->count(),
                    'total_applications' => $rentalApps->count(),
                ]
            ],
            'message' => 'Debug info for rental applications'
        ]);
    }
}
