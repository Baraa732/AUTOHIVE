<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\WalletService;
use Illuminate\Http\Request;

class WalletController extends Controller
{
    private $walletService;

    public function __construct(WalletService $walletService)
    {
        $this->walletService = $walletService;
    }

    /**
     * Get current user's wallet
     */
    public function getWallet(Request $request)
    {
        try {
            $user = $request->user();
            $wallet = $user->wallet;

            if (!$wallet) {
                return response()->json([
                    'success' => false,
                    'message' => 'Wallet not found'
                ], 404);
            }

            return response()->json([
                'success' => true,
                'data' => [
                    'id' => $wallet->id,
                    'user_id' => $wallet->user_id,
                    'balance_spy' => intval($wallet->balance_spy),
                    'balance_usd' => $wallet->balance_usd,
                    'currency' => $wallet->currency,
                    'created_at' => $wallet->created_at,
                    'updated_at' => $wallet->updated_at,
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error retrieving wallet: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get wallet transaction history
     */
    public function getTransactions(Request $request)
    {
        try {
            $user = $request->user();
            $wallet = $user->wallet;

            if (!$wallet) {
                return response()->json([
                    'success' => false,
                    'message' => 'Wallet not found'
                ], 404);
            }

            $page = $request->get('page', 1);
            $perPage = 50;

            $transactions = $wallet->transactions()
                ->orderBy('created_at', 'desc')
                ->paginate($perPage, ['*'], 'page', $page);

            $data = $transactions->map(function ($transaction) {
                return [
                    'id' => $transaction->id,
                    'wallet_id' => $transaction->wallet_id,
                    'user_id' => $transaction->user_id,
                    'type' => $transaction->type,
                    'amount_spy' => intval($transaction->amount_spy),
                    'amount_usd' => $transaction->amount_usd,
                    'description' => $transaction->description,
                    'related_user_id' => $transaction->related_user_id,
                    'related_booking_id' => $transaction->related_booking_id,
                    'created_at' => $transaction->created_at,
                ];
            });

            return response()->json([
                'success' => true,
                'data' => $data,
                'pagination' => [
                    'current_page' => $transactions->currentPage(),
                    'per_page' => $transactions->perPage(),
                    'total' => $transactions->total(),
                    'last_page' => $transactions->lastPage(),
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error retrieving transactions: ' . $e->getMessage()
            ], 500);
        }
    }
}
