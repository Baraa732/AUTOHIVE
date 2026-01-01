<?php

namespace App\Services;

use App\Models\User;
use App\Models\Notification;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class RentalStatusTransitionService
{
    public function transitionExpiredRentals()
    {
        $today = Carbon::now()->toDateString();

        $expiredRentals = User::where('rental_status', 'active')
            ->where('rental_end_date', '<=', $today)
            ->get();

        foreach ($expiredRentals as $user) {
            $this->markUserAsInactive($user);
        }

        return count($expiredRentals);
    }

    public function markUserAsInactive(User $user)
    {
        DB::beginTransaction();
        try {
            $previousStatus = $user->rental_status;
            $endDate = $user->rental_end_date;

            $user->update([
                'rental_status' => 'inactive',
            ]);

            Notification::create([
                'user_id' => $user->id,
                'type' => 'rental_status_changed',
                'title' => 'Rental Period Ended',
                'message' => "Your rental period ended on {$endDate}. Your status has been updated to inactive.",
                'data' => ['previous_status' => $previousStatus, 'end_date' => $endDate],
            ]);

            \Log::info('Rental status transitioned for user', [
                'user_id' => $user->id,
                'previous_status' => $previousStatus,
                'new_status' => 'inactive',
                'end_date' => $endDate,
            ]);

            DB::commit();
        } catch (\Exception $e) {
            DB::rollBack();
            \Log::error('Failed to transition rental status for user', [
                'user_id' => $user->id,
                'error' => $e->getMessage(),
            ]);
            throw $e;
        }
    }
}
