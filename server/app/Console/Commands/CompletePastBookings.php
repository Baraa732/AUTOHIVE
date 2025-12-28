<?php

// app/Console/Commands/CompletePastBookings.php
namespace App\Console\Commands;

use App\Models\Booking;
use Illuminate\Console\Command;
use Carbon\Carbon;

class CompletePastBookings extends Command
{
   protected $signature = 'bookings:complete-past';
   protected $description = 'Mark past bookings as completed and make apartments available';

   public function handle()
   {
      $bookings = Booking::where('status', 'approved')
         ->where('check_out', '<', Carbon::now())
         ->with('apartment')
         ->get();

      foreach ($bookings as $booking) {
         $booking->update(['status' => 'completed']);
         $booking->apartment->update(['is_available' => true]);

         // Send notification to user
         \App\Models\Notification::create([
            'user_id' => $booking->user_id,
            'type' => 'booking_completed',
            'title' => 'Booking Completed',
            'message' => "Your booking for {$booking->apartment->title} has been completed.",
            'data' => ['booking_id' => $booking->id]
         ]);
      }

      $this->info("Completed {$bookings->count()} past bookings.");
      return 0;
   }
}
