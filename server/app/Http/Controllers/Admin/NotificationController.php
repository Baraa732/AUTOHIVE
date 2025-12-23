<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Notification;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function check()
    {
        $notifications = Notification::where('user_id', auth()->id())
            ->where('read_at', null)
            ->latest()
            ->take(5)
            ->get()
            ->map(function ($notification) {
                return [
                    'id' => $notification->id,
                    'type' => $notification->type ?? 'info',
                    'title' => $notification->data['title'] ?? 'New Notification',
                    'message' => $notification->data['message'] ?? '',
                    'duration' => $notification->data['duration'] ?? 5000,
                ];
            });

        // Mark as read
        Notification::where('user_id', auth()->id())
            ->where('read_at', null)
            ->update(['read_at' => now()]);

        return response()->json([
            'notifications' => $notifications
        ]);
    }

    public function markAsRead($id)
    {
        $notification = Notification::where('user_id', auth()->id())
            ->where('id', $id)
            ->first();

        if ($notification) {
            $notification->update(['read_at' => now()]);
        }

        return response()->json(['success' => true]);
    }

    public function getAll()
    {
        return view('admin.notifications');
    }

    public function getPendingUsers()
    {
        $pendingUsers = \App\Models\User::whereIn('role', ['tenant', 'landlord'])
            ->where('status', 'pending')
            ->whereNull('deleted_at')
            ->orderBy('created_at', 'desc')
            ->get();

        $processedNotifications = $pendingUsers->map(function ($user) {
            return [
                'id' => 'pending_' . $user->id,
                'type' => 'new_user_registration',
                'title' => 'New User Registration',
                'message' => "{$user->first_name} {$user->last_name} ({$user->role}) has registered and needs approval",
                'created_at' => $user->created_at,
                'user' => [
                    'id' => $user->id,
                    'display_id' => $user->display_id,
                    'name' => $user->first_name . ' ' . $user->last_name,
                    'email' => $user->phone,
                    'role' => $user->role,
                    'phone' => $user->phone,
                    'status' => $user->status,
                    'profile_image_url' => $user->profile_image_url,
                    'id_image_url' => $user->id_image_url
                ]
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $processedNotifications->values(),
            'message' => 'Notifications retrieved successfully'
        ]);
    }

    public function markAllAsRead()
    {
        Notification::where('user_id', auth()->id())
            ->where('read_at', null)
            ->update(['read_at' => now()]);

        return response()->json(['success' => true]);
    }

    // API endpoint for mobile app
    public function apiCheck(Request $request)
    {
        $user = $request->user();
        
        $notifications = Notification::where('user_id', $user->id)
            ->where('read_at', null)
            ->latest()
            ->take(10)
            ->get()
            ->map(function ($notification) {
                return [
                    'id' => $notification->id,
                    'type' => $notification->type ?? 'info',
                    'title' => $notification->data['title'] ?? 'New Notification',
                    'message' => $notification->data['message'] ?? '',
                    'created_at' => $notification->created_at->toISOString(),
                    'data' => $notification->data,
                ];
            });

        return response()->json([
            'success' => true,
            'notifications' => $notifications,
            'unread_count' => $notifications->count()
        ]);
    }

    public function apiMarkAsRead(Request $request, $id)
    {
        $user = $request->user();
        
        $notification = Notification::where('user_id', $user->id)
            ->where('id', $id)
            ->first();

        if ($notification) {
            $notification->update(['read_at' => now()]);
            return response()->json(['success' => true]);
        }

        return response()->json(['success' => false, 'message' => 'Notification not found'], 404);
    }

    public function apiMarkAllAsRead(Request $request)
    {
        $user = $request->user();
        
        Notification::where('user_id', $user->id)
            ->where('read_at', null)
            ->update(['read_at' => now()]);

        return response()->json(['success' => true]);
    }

    public function approveUser($userId)
    {
        $user = \App\Models\User::find($userId);

        if (!$user) {
            return response()->json(['success' => false, 'message' => 'User not found'], 404);
        }

        $user->update(['is_approved' => true, 'status' => 'approved']);

        $notification = Notification::create([
            'user_id' => $user->id,
            'type' => 'account_approved',
            'title' => 'Account Approved',
            'message' => 'Your account has been approved! You can now login and use the app.',
            'data' => ['approved_at' => now()->toISOString()]
        ]);

        broadcast(new \App\Events\UserNotification($user->id, $notification));

        return response()->json(['success' => true, 'message' => 'User approved successfully']);
    }

    public function rejectUser($userId)
    {
        $user = \App\Models\User::find($userId);

        if (!$user) {
            return response()->json(['success' => false, 'message' => 'User not found'], 404);
        }

        $userName = $user->first_name . ' ' . $user->last_name;
        
        // Delete user permanently
        $user->forceDelete();

        return response()->json(['success' => true, 'message' => "User {$userName} rejected and deleted successfully"]);
    }
}
