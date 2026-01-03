<?php

namespace App\Providers;

use Illuminate\Foundation\Support\Providers\EventServiceProvider as ServiceProvider;
use App\Events\BookingStatusChanged;
use App\Listeners\SendBookingNotification;

class EventServiceProvider extends ServiceProvider
{
    protected $listen = [
        BookingStatusChanged::class => [
            SendBookingNotification::class,
        ],
    ];

    public function boot()
    {
        //
    }
}
