<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DepositWithdrawalRequest extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'type',
        'amount_spy',
        'status',
        'reason',
        'approved_by',
        'approved_at',
    ];

    protected $casts = [
        'amount_spy' => 'string',
        'approved_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    protected $appends = ['amount_usd'];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function approver()
    {
        return $this->belongsTo(User::class, 'approved_by');
    }

    public function getAmountUsdAttribute()
    {
        return intval($this->amount_spy) / 110;
    }

    public function isPending()
    {
        return $this->status === 'pending';
    }

    public function isApproved()
    {
        return $this->status === 'approved';
    }

    public function isRejected()
    {
        return $this->status === 'rejected';
    }
}
