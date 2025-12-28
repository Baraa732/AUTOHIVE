<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class RentalApplication extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'apartment_id',
        'check_in',
        'check_out',
        'message',
        'submission_attempt',
        'status',
        'rejected_reason',
        'submitted_at',
        'responded_at',
    ];

    protected $casts = [
        'check_in' => 'date',
        'check_out' => 'date',
        'submitted_at' => 'datetime',
        'responded_at' => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function apartment()
    {
        return $this->belongsTo(Apartment::class, 'apartment_id');
    }
}
