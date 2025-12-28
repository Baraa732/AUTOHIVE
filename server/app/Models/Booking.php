<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Booking extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'apartment_id',
        'check_in',
        'check_out',
        'total_price',
        'payment_details',
        'status',
    ];

    protected $casts = [
        'check_in' => 'date',
        'check_out' => 'date',
        'total_price' => 'decimal:2',
        'payment_details' => 'array',
    ];

    // Relationships
    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function apartment()
    {
        return $this->belongsTo(Apartment::class);
    }

    public function reviews()
    {
        return $this->hasMany(Review::class);
    }

    // Calculate number of nights
    public function nights()
    {
        return $this->check_in->diffInDays($this->check_out);
    }


    // Add to Booking model
    public function bookingRequest()
    {
        return $this->belongsTo(BookingRequest::class);
    }
}
