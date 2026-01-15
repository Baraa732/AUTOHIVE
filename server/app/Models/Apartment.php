<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Apartment extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'title',
        'description',
        'governorate',
        'city',
        'address',
        'price_per_night',
        'max_guests',
        'rooms',
        'bedrooms',
        'bathrooms',
        'area',
        'features',
        'images',
        'is_available',
        'is_approved',
        'status',
        'rejection_reason',
    ];

    protected $casts = [
        'features' => 'array',
        'images' => 'array',
        'is_available' => 'boolean',
        'is_approved' => 'boolean',
        'price_per_night' => 'decimal:2',
    ];
    
    protected $appends = ['image_urls'];
    
    public function getImageUrlsAttribute()
    {
        if (!$this->images) return [];
        
        return array_map(function($image) {
            return asset('storage/' . $image);
        }, $this->images);
    }

    // Relationships
    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function landlord()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function bookings()
    {
        return $this->hasMany(Booking::class);
    }

    public function reviews()
    {
        return $this->hasMany(Review::class);
    }

    public function favorites()
    {
        return $this->hasMany(Favorite::class);
    }

    // Calculate average rating
    public function averageRating()
    {
        return $this->reviews()->avg('rating');
    }

    // Check if apartment is booked for given dates
    // public function isBookedForDates($checkIn, $checkOut, $excludeBookingId = null)
    // {
    //     $query = $this->bookings()
    //         ->where('status', 'approved')
    //         ->where(function ($query) use ($checkIn, $checkOut) {
    //             $query->where(function ($q) use ($checkIn, $checkOut) {
    //                 $q->where('check_in', '<=', $checkIn)
    //                   ->where('check_out', '>', $checkIn);
    //             })
    //             ->orWhere(function ($q) use ($checkIn, $checkOut) {
    //                 $q->where('check_in', '<', $checkOut)
    //                   ->where('check_out', '>=', $checkOut);
    //             })
    //             ->orWhere(function ($q) use ($checkIn, $checkOut) {
    //                 $q->where('check_in', '>=', $checkIn)
    //                   ->where('check_out', '<=', $checkOut);
    //             });
    //         });

    //     if ($excludeBookingId) {
    //         $query->where('id', '!=', $excludeBookingId);
    //     }

    //     return $query->exists();
    // }
    public function isBookedForDates($checkIn, $checkOut, $excludeBookingId = null)
    {
        $query = Booking::where('apartment_id', $this->id)
            ->where('status', 'confirmed')
            ->where(function ($q) use ($checkIn, $checkOut) {
                $q->where(function ($inner) use ($checkIn, $checkOut) {
                    $inner->where('check_in', '<', $checkOut)
                        ->where('check_out', '>', $checkIn);
                });
            });

        if ($excludeBookingId) {
            $query->where('id', '!=', $excludeBookingId);
        }

        return $query->exists();
    }
}
