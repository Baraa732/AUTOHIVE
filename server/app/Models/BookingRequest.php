<?php

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
        'status'
    ];

    protected $casts = [
        'check_in' => 'date',
        'check_out' => 'date',
    ];

    protected $appends = ['type', 'can_approve', 'can_reject'];

    const STATUS_PENDING = 'pending';
    const STATUS_APPROVED = 'approved';
    const STATUS_REJECTED = 'rejected';

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

    // Accessors
    public function getTypeAttribute()
    {
        return 'booking_request';
    }

    public function getCanApproveAttribute()
    {
        return $this->status === self::STATUS_PENDING;
    }

    public function getCanRejectAttribute()
    {
        return $this->status === self::STATUS_PENDING;
    }

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

    public function scopeRejected($query)
    {
        return $query->where('status', self::STATUS_REJECTED);
    }
}
