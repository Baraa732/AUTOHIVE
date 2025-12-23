<?php

// app/Models/BookingRequest.php
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class BookingRequest extends Model
{
    protected $fillable = [
        'user_id',
        'apartment_id',
        'check_in',
        'check_out',
        'guests',
        'total_price',
        'message',
        'status' // pending, approved, rejected
    ];

    protected $casts = [
        'check_in' => 'date',
        'check_out' => 'date',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function apartment()
    {
        return $this->belongsTo(Apartment::class);
    }

    public function booking()
    {
        return $this->hasOne(Booking::class, 'booking_request_id');
    }
}
