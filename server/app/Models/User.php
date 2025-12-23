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
            // Delete all apartments if user is landlord
            if ($user->role === 'landlord') {
                $user->apartments()->each(function ($apartment) {
                    $apartment->forceDelete();
                });
            }

            // Delete all bookings if user is tenant
            if ($user->role === 'tenant') {
                $user->bookings()->each(function ($booking) {
                    $booking->forceDelete();
                });
            }

            // Delete related data for all users
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
        'role',
        'first_name',
        'last_name',
        'profile_image',
        'birth_date',
        'id_image',
        'is_approved',
        'status',
        'city',
        'governorate',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'birth_date' => 'date',
        'is_approved' => 'boolean',
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
        return $this->hasMany(Apartment::class, 'landlord_id');
    }

    public function bookings()
    {
        return $this->hasMany(Booking::class, 'tenant_id');
    }

    public function reviews()
    {
        return $this->hasMany(Review::class, 'tenant_id');
    }

    public function favorites()
    {
        return $this->hasMany(Favorite::class, 'tenant_id');
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

    // Scopes
    public function scopeTenants($query)
    {
        return $query->where('role', 'tenant');
    }

    public function scopeLandlords($query)
    {
        return $query->where('role', 'landlord');
    }

    public function scopePendingApproval($query)
    {
        return $query->where('is_approved', false);
    }

    public function scopeApproved($query)
    {
        return $query->where('is_approved', true);
    }
}
