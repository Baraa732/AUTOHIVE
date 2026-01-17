<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\DB;

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

    protected $casts = [
        'rating' => 'integer',
        'cleanliness_rating' => 'integer',
        'location_rating' => 'integer',
        'value_rating' => 'integer',
        'communication_rating' => 'integer',
    ];

    protected static function boot()
    {
        parent::boot();

        // Update apartment average rating when review is created
        // Commented out because average_rating and total_ratings columns don't exist in apartments table
        // static::created(function ($review) {
        //     $review->apartment->updateAverageRating();
        // });

        // Update apartment average rating when review is updated
        // static::updated(function ($review) {
        //     $review->apartment->updateAverageRating();
        // });

        // Update apartment average rating when review is deleted
        // static::deleted(function ($review) {
        //     $review->apartment->updateAverageRating();
        // });
    }

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

    // Check if user can review this booking
    public static function canReviewBooking($userId, $bookingId)
    {
        $booking = Booking::find($bookingId);

        if (!$booking || $booking->user_id != $userId) {
            return false;
        }

        // Can only review completed bookings
        if ($booking->status !== Booking::STATUS_COMPLETED) {
            return false;
        }

        // Check if already reviewed
        return !self::where('booking_id', $bookingId)->exists();
    }

    // Get overall rating as percentage
    public function getRatingPercentageAttribute()
    {
        return ($this->rating / 5) * 100;
    }
}
