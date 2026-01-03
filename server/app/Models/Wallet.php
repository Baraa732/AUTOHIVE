<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Wallet extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'balance_spy',
        'currency',
    ];

    protected $casts = [
        'balance_spy' => 'string',
    ];

    protected $appends = ['balance_usd'];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function transactions()
    {
        return $this->hasMany(WalletTransaction::class);
    }

    public function getBalanceUsdAttribute()
    {
        return intval($this->balance_spy) / 110;
    }

    public function canWithdraw($amountSpy)
    {
        return intval($this->balance_spy) >= intval($amountSpy);
    }

    public function addFunds($amountSpy)
    {
        $this->balance_spy = intval($this->balance_spy) + intval($amountSpy);
        return $this->save();
    }

    public function deductFunds($amountSpy)
    {
        if (!$this->canWithdraw($amountSpy)) {
            return false;
        }
        $this->balance_spy = intval($this->balance_spy) - intval($amountSpy);
        return $this->save();
    }
}
