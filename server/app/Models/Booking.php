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
        'booking_request_id',
        'guests',
        'message',
    ];

    protected $casts = [
        'check_in' => 'date',
        'check_out' => 'date',
        'total_price' => 'decimal:2',
        'payment_details' => 'array',
    ];

    protected $appends = ['type', 'can_approve', 'can_reject'];

    // Statuses: pending, approved, confirmed, rejected, cancelled, completed
    const STATUS_PENDING = 'pending';
    const STATUS_APPROVED = 'approved';
    const STATUS_CONFIRMED = 'confirmed';
    const STATUS_REJECTED = 'rejected';
    const STATUS_CANCELLED = 'cancelled';
    const STATUS_COMPLETED = 'completed';

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

    public function bookingRequest()
    {
        return $this->belongsTo(BookingRequest::class);
    }

    // Accessors
    public function getTypeAttribute()
    {
        return 'booking';
    }

    public function getCanApproveAttribute()
    {
        return $this->status === self::STATUS_PENDING;
    }

    public function getCanRejectAttribute()
    {
        return $this->status === self::STATUS_PENDING;
    }

    // Calculate number of nights
    public function nights()
    {
        return $this->check_in->diffInDays($this->check_out);
    }

    // Scopes
    public function scopePending($query)
    {
        return $query->where('status', self::STATUS_PENDING);
    }

    public function scopeApproved($query)
    {
        return $query->where('status', self::STATUS_APPROVED);
    }

    public function scopeConfirmed($query)
    {
        return $query->where('status', self::STATUS_CONFIRMED);
    }

    public function scopeRejected($query)
    {
        return $query->where('status', self::STATUS_REJECTED);
    }

    public function scopeCancelled($query)
    {
        return $query->where('status', self::STATUS_CANCELLED);
    }

    public function scopeCompleted($query)
    {
        return $query->where('status', self::STATUS_COMPLETED);
    }

    public function scopeActive($query)
    {
        return $query->whereIn('status', [
            self::STATUS_PENDING,
            self::STATUS_APPROVED,
            self::STATUS_CONFIRMED
        ]);
    }
}
