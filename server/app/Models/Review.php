<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Review extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'apartment_id',
        'booking_id',
        'rating',
        'comment',
        'cleanliness_rating',
        'location_rating',
        'value_rating',
        'communication_rating',
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

    public function booking()
    {
        return $this->belongsTo(Booking::class);
    }
}
