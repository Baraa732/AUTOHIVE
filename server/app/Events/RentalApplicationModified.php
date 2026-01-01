<?php

namespace App\Events;

use App\Models\RentalApplication;
use App\Models\RentalApplicationModification;
use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class RentalApplicationModified implements ShouldBroadcast
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $application;
    public $modification;

    public function __construct(RentalApplication $application, RentalApplicationModification $modification)
    {
        $this->application = $application;
        $this->modification = $modification;
    }

    public function broadcastOn()
    {
        return new PrivateChannel('user.' . $this->application->apartment->user_id);
    }

    public function broadcastAs()
    {
        return 'rental.application.modified';
    }
}
