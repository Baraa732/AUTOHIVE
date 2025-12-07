<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Notification;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $request)
    {
        $query = Notification::where('user_id', $request->user()->id);
        
        // Filter by read status if requested
        if ($request->has('unread_only') && $request->unread_only) {
            $query->whereNull('read_at');
        }
        
        $notifications = $query->orderBy('created_at', 'desc')
            ->paginate($request->get('per_page', 20));

        // Get unread count
        $unreadCount = Notification::where('user_id', $request->user()->id)
            ->whereNull('read_at')
            ->count();

        return response()->json([
            'success' => true,
            'data' => $notifications,
            'unread_count' => $unreadCount,
            'message' => 'Notifications retrieved successfully'
        ]);
    }

    public function markAsRead(Request $request)
    {
        if ($request->has('notification_ids')) {
            $request->validate([
                'notification_ids' => 'array',
                'notification_ids.*' => 'exists:notifications,id',
            ]);

            Notification::whereIn('id', $request->notification_ids)
                ->where('user_id', $request->user()->id)
                ->update(['read_at' => now()]);
        } else {
            // Mark all as read
            Notification::where('user_id', $request->user()->id)
                ->whereNull('read_at')
                ->update(['read_at' => now()]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Notifications marked as read'
        ]);
    }

    public function getUnreadCount(Request $request)
    {
        $count = Notification::where('user_id', $request->user()->id)
            ->whereNull('read_at')
            ->count();

        return response()->json([
            'success' => true,
            'data' => ['unread_count' => $count],
            'message' => 'Unread count retrieved successfully'
        ]);
    }

    public function markSingleAsRead(Request $request, $id)
    {
        $notification = Notification::where('id', $id)
            ->where('user_id', $request->user()->id)
            ->first();

        if (!$notification) {
            return response()->json([
                'success' => false,
                'message' => 'Notification not found'
            ], 404);
        }

        $notification->update(['read_at' => now()]);

        return response()->json([
            'success' => true,
            'message' => 'Notification marked as read'
        ]);
    }
}
