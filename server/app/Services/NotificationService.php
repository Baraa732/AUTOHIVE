<?php

namespace App\Services;

use App\Models\Notification;
use App\Models\User;

class NotificationService
{
    public static function send($userId, $type, $title, $message, $data = [])
    {
        return Notification::create([
            'user_id' => $userId,
            'type' => $type,
            'title' => $title,
            'message' => $message,
            'data' => $data,
        ]);
    }

    public static function sendToAllAdmins($type, $title, $message, $data = [])
    {
        $admins = User::where('role', 'admin')->get();
        
        foreach ($admins as $admin) {
            $notification = self::send($admin->id, $type, $title, $message, $data);
            
            // Broadcast real-time notificatio  n to admin
            broadcast(new \App\Events\AdminNotification($admin->id, $notification));
        }
    }

    public static function sendUserApprovalNotification($user)
    {
        self::sendToAllAdmins(
            'user_registration',
            'New User Registration',
            "{$user->first_name} {$user->last_name} ({$user->role}) has registered and needs approval.",
            [
                'user_id' => $user->id,
                'user_name' => $user->first_name . ' ' . $user->last_name,
                'user_role' => $user->role,
                'user_phone' => $user->phone,
                'action_required' => true,
                'actions' => ['approve', 'reject']
            ]
        );
    }

    public static function sendBookingNotification($booking)
    {
        self::sendToAllAdmins(
            'success',
            'New Booking',
            "New booking for {$booking->apartment->title} by {$booking->user->first_name} {$booking->user->last_name}.",
            [
                'booking_id' => $booking->id,
                'action_url' => route('admin.bookings'),
                'duration' => 6000
            ]
        );
    }

    public static function sendApartmentNotification($apartment)
    {
        self::sendToAllAdmins(
            'info',
            'New Apartment Listed',
            "New apartment '{$apartment->title}' has been listed.",
            [
                'apartment_id' => $apartment->id,
                'action_url' => route('admin.apartments'),
                'duration' => 5000
            ]
        );
    }

    public static function sendAdminActivityNotification($activity)
    {
        $admins = User::where('role', 'admin')
            ->where('id', '!=', $activity->admin_id)
            ->get();
        
        foreach ($admins as $admin) {
            self::send(
                $admin->id,
                'admin_activity',
                'Admin Activity',
                $activity->description,
                [
                    'activity_id' => $activity->id,
                    'admin_name' => $activity->admin->first_name . ' ' . $activity->admin->last_name
                ]
            );
        }
    }
}
