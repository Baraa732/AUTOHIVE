<?php

namespace App\Services;

use App\Models\Wallet;
use App\Models\WalletTransaction;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Exception;

class WalletService
{
    const EXCHANGE_RATE = 110;
    const INITIAL_BALANCE_USD = 100;
    const INITIAL_BALANCE_SPY = self::INITIAL_BALANCE_USD * self::EXCHANGE_RATE;

    /**
     * Create wallet for a new user
     */
    public function createWalletForUser(User $user)
    {
        return Wallet::create([
            'user_id' => $user->id,
            'balance_spy' => self::INITIAL_BALANCE_SPY,
            'currency' => 'SPY',
        ]);
    }

    /**
     * Convert USD to SPY
     */
    public function convertUsdToSpy($usd)
    {
        return intval($usd * self::EXCHANGE_RATE);
    }

    /**
     * Convert SPY to USD
     */
    public function convertSpyToUsd($spy)
    {
        return intval($spy) / self::EXCHANGE_RATE;
    }

    /**
     * Validate if user has sufficient balance
     */
    public function validateSufficientBalance($userId, $amountSpy)
    {
        $wallet = Wallet::where('user_id', $userId)->first();
        
        if (!$wallet) {
            throw new Exception('Wallet not found for user');
        }

        if (intval($wallet->balance_spy) < intval($amountSpy)) {
            return false;
        }

        return true;
    }

    /**
     * Add funds to user's wallet
     */
    public function addFunds($userId, $amountSpy, $transactionType, $description = null)
    {
        return DB::transaction(function () use ($userId, $amountSpy, $transactionType, $description) {
            $wallet = Wallet::where('user_id', $userId)->lockForUpdate()->first();
            
            if (!$wallet) {
                throw new Exception('Wallet not found for user');
            }

            $wallet->balance_spy = intval($wallet->balance_spy) + intval($amountSpy);
            $wallet->save();

            WalletTransaction::create([
                'wallet_id' => $wallet->id,
                'user_id' => $userId,
                'type' => $transactionType,
                'amount_spy' => $amountSpy,
                'description' => $description ?? "Added {$this->convertSpyToUsd($amountSpy)} USD",
            ]);

            return $wallet;
        });
    }

    /**
     * Deduct funds from user's wallet
     */
    public function deductFunds($userId, $amountSpy, $transactionType, $description = null)
    {
        return DB::transaction(function () use ($userId, $amountSpy, $transactionType, $description) {
            $wallet = Wallet::where('user_id', $userId)->lockForUpdate()->first();
            
            if (!$wallet) {
                throw new Exception('Wallet not found for user');
            }

            if (intval($wallet->balance_spy) < intval($amountSpy)) {
                throw new Exception('Insufficient balance');
            }

            $wallet->balance_spy = intval($wallet->balance_spy) - intval($amountSpy);
            $wallet->save();

            WalletTransaction::create([
                'wallet_id' => $wallet->id,
                'user_id' => $userId,
                'type' => $transactionType,
                'amount_spy' => $amountSpy,
                'description' => $description ?? "Deducted {$this->convertSpyToUsd($amountSpy)} USD",
            ]);

            return $wallet;
        });
    }

    /**
     * Atomic transfer from tenant to landlord
     */
    public function deductAndTransfer($tenantId, $landlordId, $amountSpy, $bookingId = null)
    {
        return DB::transaction(function () use ($tenantId, $landlordId, $amountSpy, $bookingId) {
            $tenantWallet = Wallet::where('user_id', $tenantId)->lockForUpdate()->first();
            $landlordWallet = Wallet::where('user_id', $landlordId)->lockForUpdate()->first();

            if (!$tenantWallet || !$landlordWallet) {
                throw new Exception('Wallet not found for tenant or landlord');
            }

            if (intval($tenantWallet->balance_spy) < intval($amountSpy)) {
                throw new Exception('Insufficient balance in tenant wallet');
            }

            $tenantWallet->balance_spy = intval($tenantWallet->balance_spy) - intval($amountSpy);
            $tenantWallet->save();

            $landlordWallet->balance_spy = intval($landlordWallet->balance_spy) + intval($amountSpy);
            $landlordWallet->save();

            WalletTransaction::create([
                'wallet_id' => $tenantWallet->id,
                'user_id' => $tenantId,
                'type' => 'rental_payment',
                'amount_spy' => $amountSpy,
                'related_user_id' => $landlordId,
                'related_booking_id' => $bookingId,
                'description' => "Rental payment of {$this->convertSpyToUsd($amountSpy)} USD",
            ]);

            WalletTransaction::create([
                'wallet_id' => $landlordWallet->id,
                'user_id' => $landlordId,
                'type' => 'rental_received',
                'amount_spy' => $amountSpy,
                'related_user_id' => $tenantId,
                'related_booking_id' => $bookingId,
                'description' => "Received rental payment of {$this->convertSpyToUsd($amountSpy)} USD",
            ]);

            return [
                'tenant_wallet' => $tenantWallet,
                'landlord_wallet' => $landlordWallet,
            ];
        });
    }
}
