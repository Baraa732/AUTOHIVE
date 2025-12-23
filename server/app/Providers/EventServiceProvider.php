<?php

namespace App\Providers;

use Illuminate\Foundation\Support\Providers\EventServiceProvider as ServiceProvider;

class EventServiceProvider extends ServiceProvider
{
    protected $listen = [
        // Events are broadcast directly, no listeners needed
    ];

    public function boot()
    {
        //
    }
}
