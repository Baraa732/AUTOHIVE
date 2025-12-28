<?php

namespace App\Listeners;

use App\Events\BookingStatusChanged;
use App\Models\Notification;

class SendBookingNotification
{
    public function handle(BookingStatusChanged $event)
    {
        $booking = $event->booking;
        $status = $event->newStatus;

        $messages = [
            'approved' => 'Your booking for ' . $booking->apartment->title . ' has been approved!',
            'cancelled' => 'Your booking for ' . $booking->apartment->title . ' has been cancelled.',
            'completed' => 'Your booking for ' . $booking->apartment->title . ' is now completed. Please leave a review!',
        ];

        if (isset($messages[$status])) {
            Notification::create([
                'user_id' => $booking->user_id,
                'type' => 'booking_' . $status,
                'message' => $messages[$status],
            ]);
        }
    }
}