<?php

namespace App\Console;

use App\Jobs\TransitionRentalStatusJob;
use Illuminate\Console\Scheduling\Schedule;
use Illuminate\Foundation\Console\Kernel as ConsoleKernel;

class Kernel extends ConsoleKernel
{
    protected function schedule(Schedule $schedule)
    {
        $schedule->job(new TransitionRentalStatusJob)
            ->daily()
            ->name('transition-rental-status')
            ->description('Transition expired rental statuses from active to inactive');
    }

    protected function commands()
    {
        $this->load(__DIR__ . '/Commands');

        require base_path('routes/console.php');
    }
}
