<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Str;


class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable, SoftDeletes;

    // Generate display UUID for frontend
    protected $appends = ['display_id', 'profile_image_url', 'id_image_url'];

    protected static function boot()
    {
        parent::boot();

        static::deleting(function ($user) {
            // Delete all related data when user is deleted
            $user->apartments()->each(function ($apartment) {
                $apartment->forceDelete();
            });
            $user->bookings()->each(function ($booking) {
                $booking->forceDelete();
            });
            $user->reviews()->forceDelete();
            $user->favorites()->forceDelete();
            $user->sentMessages()->forceDelete();
            $user->receivedMessages()->forceDelete();
            $user->notifications()->forceDelete();
        });
    }

    public function getDisplayIdAttribute()
    {
        return 'USR-' . strtoupper(substr(md5($this->id . $this->phone), 0, 16));
    }

    protected $fillable = [
        'phone',
        'password',
        'first_name',
        'last_name',
        'role',
        'profile_image',
        'birth_date',
        'id_image',
        'is_approved',
        'status',
        'city',
        'governorate',
        'rental_status',
        'rental_end_date',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'birth_date' => 'date',
        'is_approved' => 'boolean',
        'rental_end_date' => 'date',
    ];

    // Profile image accessor
    public function getProfileImageUrlAttribute()
    {
        if ($this->profile_image) {
            return asset('storage/' . $this->profile_image);
        }
        return null;
    }

    // ID image accessor
    public function getIdImageUrlAttribute()
    {
        if ($this->id_image) {
            return asset('storage/' . $this->id_image);
        }
        return null;
    }

    // Relationships
    public function apartments()
    {
        return $this->hasMany(Apartment::class, 'user_id');
    }

    public function bookings()
    {
        return $this->hasMany(Booking::class, 'user_id');
    }

    public function reviews()
    {
        return $this->hasMany(Review::class, 'user_id');
    }

    public function favorites()
    {
        return $this->hasMany(Favorite::class, 'user_id');
    }

    public function sentMessages()
    {
        return $this->hasMany(Message::class, 'sender_id');
    }

    public function receivedMessages()
    {
        return $this->hasMany(Message::class, 'receiver_id');
    }

    public function notifications()
    {
        return $this->hasMany(Notification::class);
    }

    // Admin check
    public function isAdmin()
    {
        return $this->role === 'admin';
    }

    // Scopes

    public function scopePendingApproval($query)
    {
        return $query->where('is_approved', false);
    }

    public function scopeApproved($query)
    {
        return $query->where('is_approved', true);
    }
}
