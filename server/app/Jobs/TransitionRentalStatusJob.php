<?php

namespace App\Jobs;

use App\Services\RentalStatusTransitionService;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class TransitionRentalStatusJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function handle(RentalStatusTransitionService $service): void
    {
        $count = $service->transitionExpiredRentals();
        
        \Log::info('Rental status transition job completed', [
            'transitioned_users' => $count,
        ]);
    }
}
