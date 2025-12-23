<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Notification;
use Illuminate\Http\Request;

class UserApprovalController extends Controller
{
    public function getPendingUsers(Request $request)
    {
        $pendingUsers = User::whereIn('role', ['tenant', 'landlord'])
            ->where('is_approved', false)
            ->where('status', 'pending')
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'pending_users' => $pendingUsers,
                'count' => $pendingUsers->count()
            ],
            'message' => 'Pending users retrieved successfully'
        ]);
    }

    public function getUserDetails(Request $request, $userId)
    {
        $user = User::find($userId);

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'User not found'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'user' => $user,
                'can_approve' => !$user->is_approved,
                'registration_date' => $user->created_at->format('Y-m-d H:i:s'),
                'days_pending' => $user->created_at->diffInDays(now())
            ],
            'message' => 'User details retrieved successfully'
        ]);
    }

    public function approveUser(Request $request, $userId)
    {
        $user = User::find($userId);

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'User not found'
            ], 404);
        }

        if ($user->status === 'approved') {
            return response()->json([
                'success' => false,
                'message' => 'User is already approved'
            ], 400);
        }

        // Approve the user
        $user->update([
            'is_approved' => true,
            'status' => 'approved'
        ]);

        // Create approval notification for user
        $notification = Notification::create([
            'user_id' => $user->id,
            'type' => 'account_approved',
            'title' => 'Account Approved',
            'message' => 'Your account has been approved! You can now login and use the app.',
            'data' => ['approved_at' => now()->toISOString()],
            'read_at' => null
        ]);

        // Broadcast real-time notification to user
        broadcast(new \App\Events\UserNotification($user->id, $notification));

        // Log activity
        \App\Models\Activity::log('user_approved', "Approved user {$user->first_name} {$user->last_name} ({$user->role})", ['user_id' => $user->id]);

        return response()->json([
            'success' => true,
            'data' => $user->makeHidden(['password']),
            'message' => 'User approved successfully'
        ]);
    }

    public function rejectUser(Request $request, $userId)
    {
        $user = User::find($userId);

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'User not found'
            ], 404);
        }

        // Prevent rejecting admin accounts
        if ($user->role === 'admin') {
            return response()->json([
                'success' => false,
                'message' => 'Cannot reject admin accounts'
            ], 400);
        }

        // Prevent admin from rejecting themselves
        if ($user->id === auth()->id()) {
            return response()->json([
                'success' => false,
                'message' => 'Cannot reject your own account'
            ], 400);
        }

        if ($user->status === 'approved') {
            return response()->json([
                'success' => false,
                'message' => 'Cannot reject an approved user'
            ], 400);
        }

        $userName = "{$user->first_name} {$user->last_name}";

        // Update user status to rejected (soft delete)
        $user->update([
            'status' => 'rejected',
            'is_approved' => false
        ]);

        // Create rejection notification for user
        $notification = Notification::create([
            'user_id' => $user->id,
            'type' => 'account_rejected',
            'title' => 'Account Rejected',
            'message' => 'Your account registration has been rejected. You can register again with updated information.',
            'data' => ['rejected_at' => now()->toISOString()],
            'read_at' => null
        ]);

        // Broadcast real-time notification to user
        broadcast(new \App\Events\UserNotification($user->id, $notification));

        // Log activity
        \App\Models\Activity::log('user_rejected', "Rejected user {$user->first_name} {$user->last_name} ({$user->role})", ['user_id' => $user->id]);

        // Soft delete the user (allows re-registration)
        $user->delete();

        return response()->json([
            'success' => true,
            'message' => "User {$userName} has been rejected. They can register again."
        ]);
    }

    public function getNotificationsWithActions(Request $request)
    {
        // Get unique pending users directly instead of notifications (exclude admins)
        $pendingUsers = User::whereIn('role', ['tenant', 'landlord'])
            ->where('status', 'pending')
            ->whereNull('deleted_at')
            ->orderBy('created_at', 'desc')
            ->get();

        // Create notification-like structure for each pending user
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
                    'email' => $user->email ?? 'N/A',
                    'role' => $user->role,
                    'phone' => $user->phone,
                    'status' => $user->status
                ]
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $processedNotifications->values(),
            'message' => 'Notifications retrieved successfully'
        ]);
    }
}
