<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Broadcasting\Broadcasters\PusherBroadcaster;
use Pusher\Pusher;

class BroadcastController extends Controller
{
    public function authenticate(Request $request)
    {
        $user = $request->user();
        
        if (!$user) {
            return response()->json(['error' => 'Unauthorized'], 401);
        }

        $channelName = $request->input('channel_name');
        $socketId = $request->input('socket_id');

        // Validate channel access
        if (str_starts_with($channelName, 'private-admin.')) {
            $adminId = str_replace('private-admin.', '', $channelName);
            if ($user->role !== 'admin' || $user->id != $adminId) {
                return response()->json(['error' => 'Forbidden'], 403);
            }
        } elseif (str_starts_with($channelName, 'private-user.')) {
            $userId = str_replace('private-user.', '', $channelName);
            if ($user->id != $userId) {
                return response()->json(['error' => 'Forbidden'], 403);
            }
        } elseif (str_starts_with($channelName, 'private-landlord.')) {
            $landlordId = str_replace('private-landlord.', '', $channelName);
            if ($user->role !== 'landlord' || $user->id != $landlordId) {
                return response()->json(['error' => 'Forbidden'], 403);
            }
        }

        // Use Pusher for authentication
        $pusher = new Pusher(
            config('broadcasting.connections.pusher.key'),
            config('broadcasting.connections.pusher.secret'),
            config('broadcasting.connections.pusher.app_id'),
            config('broadcasting.connections.pusher.options')
        );

        $auth = $pusher->authorizeChannel($channelName, $socketId);
        return response()->json(json_decode($auth, true));
    }

    public function testNotification(Request $request)
    {
        $user = $request->user();
        
        if ($user->role === 'admin') {
            // Test admin notification
            $notification = \App\Models\Notification::create([
                'user_id' => $user->id,
                'type' => 'test',
                'title' => 'Test Notification',
                'message' => 'This is a test notification sent at ' . now()->format('H:i:s'),
                'data' => ['test' => true]
            ]);
            
            broadcast(new \App\Events\AdminNotification($user->id, $notification));
            
            return response()->json([
                'success' => true,
                'message' => 'Test notification sent to admin channel'
            ]);
        }
        
        return response()->json([
            'success' => false,
            'message' => 'Only admins can test notifications'
        ], 403);
    }
}
