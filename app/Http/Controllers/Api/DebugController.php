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
}
