<?php

namespace App\Console\Commands;

use App\Models\Booking;
use App\Events\BookingStatusChanged;
use Illuminate\Console\Command;
use Carbon\Carbon;

class MarkCompletedBookings extends Command
{
    protected $signature = 'bookings:mark-completed';
    protected $description = 'Mark bookings as completed after check-out date';

    public function handle()
    {
        $bookings = Booking::where('status', 'approved')
            ->where('check_out', '<', Carbon::today())
            ->get();

        foreach ($bookings as $booking) {
            $oldStatus = $booking->status;
            $booking->update(['status' => 'completed']);
            
            event(new BookingStatusChanged($booking->load('apartment'), $oldStatus, 'completed'));
        }

        $this->info("Marked {$bookings->count()} bookings as completed.");
    }
}