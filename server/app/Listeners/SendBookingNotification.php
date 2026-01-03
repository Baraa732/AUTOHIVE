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

        $titles = [
            'approved' => 'Booking Approved',
            'confirmed' => 'Booking Confirmed',
            'rejected' => 'Booking Rejected',
            'cancelled' => 'Booking Cancelled',
            'completed' => 'Booking Completed',
        ];

        $messages = [
            'approved' => 'Your booking for ' . $booking->apartment->title . ' has been approved!',
            'confirmed' => 'Your booking for ' . $booking->apartment->title . ' has been confirmed!',
            'rejected' => 'Your booking for ' . $booking->apartment->title . ' has been rejected.',
            'cancelled' => 'Your booking for ' . $booking->apartment->title . ' has been cancelled.',
            'completed' => 'Your booking for ' . $booking->apartment->title . ' is now completed. Please leave a review!',
        ];

        if (isset($messages[$status]) && isset($titles[$status])) {
            Notification::create([
                'user_id' => $booking->user_id,
                'type' => 'booking_' . $status,
                'title' => $titles[$status],
                'message' => $messages[$status],
            ]);
        }
    }
}