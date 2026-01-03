<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class WalletTransaction extends Model
{
    use HasFactory;

    protected $fillable = [
        'wallet_id',
        'user_id',
        'type',
        'amount_spy',
        'description',
        'related_user_id',
        'related_booking_id',
    ];

    protected $casts = [
        'amount_spy' => 'string',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    protected $appends = ['amount_usd'];

    public function wallet()
    {
        return $this->belongsTo(Wallet::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function relatedUser()
    {
        return $this->belongsTo(User::class, 'related_user_id');
    }

    public function booking()
    {
        return $this->belongsTo(Booking::class, 'related_booking_id');
    }

    public function getAmountUsdAttribute()
    {
        return intval($this->amount_spy) / 110;
    }
}
