<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\DepositWithdrawalRequest;
use App\Models\Wallet;
use App\Services\WalletService;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class DepositWithdrawalController extends Controller
{
    private $walletService;

    public function __construct(WalletService $walletService)
    {
        $this->walletService = $walletService;
    }

    /**
     * Submit a deposit request
     */
    public function submitDepositRequest(Request $request)
    {
        try {
            $validated = $request->validate([
                'amount_usd' => 'required|numeric|min:0.01',
            ]);

            $user = $request->user();
            $amountSpy = $this->walletService->convertUsdToSpy($validated['amount_usd']);

            $depositRequest = DepositWithdrawalRequest::create([
                'user_id' => $user->id,
                'type' => 'deposit',
                'amount_spy' => $amountSpy,
                'status' => 'pending',
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Deposit request submitted successfully',
                'data' => [
                    'id' => $depositRequest->id,
                    'type' => $depositRequest->type,
                    'amount_usd' => $depositRequest->amount_usd,
                    'amount_spy' => intval($depositRequest->amount_spy),
                    'status' => $depositRequest->status,
                    'created_at' => $depositRequest->created_at,
                ]
            ], 201);
        } catch (ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error creating deposit request: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Submit a withdrawal request
     */
    public function submitWithdrawalRequest(Request $request)
    {
        try {
            $validated = $request->validate([
                'amount_usd' => 'required|numeric|min:0.01',
            ]);

            $user = $request->user();
            $wallet = $user->wallet;

            if (!$wallet) {
                return response()->json([
                    'success' => false,
                    'message' => 'Wallet not found'
                ], 404);
            }

            $amountSpy = $this->walletService->convertUsdToSpy($validated['amount_usd']);

            if (intval($wallet->balance_spy) < intval($amountSpy)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Insufficient balance',
                    'data' => [
                        'balance_usd' => $wallet->balance_usd,
                        'balance_spy' => intval($wallet->balance_spy),
                        'requested_amount_usd' => $validated['amount_usd'],
                        'requested_amount_spy' => intval($amountSpy),
                    ]
                ], 422);
            }

            $withdrawalRequest = DepositWithdrawalRequest::create([
                'user_id' => $user->id,
                'type' => 'withdrawal',
                'amount_spy' => $amountSpy,
                'status' => 'pending',
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Withdrawal request submitted successfully',
                'data' => [
                    'id' => $withdrawalRequest->id,
                    'type' => $withdrawalRequest->type,
                    'amount_usd' => $withdrawalRequest->amount_usd,
                    'amount_spy' => intval($withdrawalRequest->amount_spy),
                    'status' => $withdrawalRequest->status,
                    'created_at' => $withdrawalRequest->created_at,
                ]
            ], 201);
        } catch (ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error creating withdrawal request: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get user's own requests
     */
    public function getMyRequests(Request $request)
    {
        try {
            $user = $request->user();
            $page = $request->get('page', 1);
            $perPage = 50;

            $requests = DepositWithdrawalRequest::where('user_id', $user->id)
                ->orderBy('created_at', 'desc')
                ->paginate($perPage, ['*'], 'page', $page);

            $data = $requests->map(function ($req) {
                return [
                    'id' => $req->id,
                    'type' => $req->type,
                    'amount_usd' => $req->amount_usd,
                    'amount_spy' => intval($req->amount_spy),
                    'status' => $req->status,
                    'reason' => $req->reason,
                    'approved_by' => $req->approved_by,
                    'approved_at' => $req->approved_at,
                    'created_at' => $req->created_at,
                ];
            });

            return response()->json([
                'success' => true,
                'data' => $data,
                'pagination' => [
                    'current_page' => $requests->currentPage(),
                    'per_page' => $requests->perPage(),
                    'total' => $requests->total(),
                    'last_page' => $requests->lastPage(),
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error retrieving requests: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get all requests (admin only)
     */
    public function getAllRequests(Request $request)
    {
        try {
            $user = $request->user();

            if (!$user->isAdmin()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized'
                ], 403);
            }

            $page = $request->get('page', 1);
            $status = $request->get('status'); // Filter by status
            $perPage = 50;

            $query = DepositWithdrawalRequest::query();

            if ($status) {
                $query->where('status', $status);
            }

            $requests = $query->orderBy('created_at', 'desc')
                ->paginate($perPage, ['*'], 'page', $page);

            $data = $requests->map(function ($req) {
                return [
                    'id' => $req->id,
                    'user_id' => $req->user_id,
                    'user_name' => $req->user->first_name . ' ' . $req->user->last_name,
                    'user_phone' => $req->user->phone,
                    'type' => $req->type,
                    'amount_usd' => $req->amount_usd,
                    'amount_spy' => intval($req->amount_spy),
                    'status' => $req->status,
                    'reason' => $req->reason,
                    'approved_by' => $req->approved_by,
                    'approved_by_name' => $req->approver ? $req->approver->first_name . ' ' . $req->approver->last_name : null,
                    'approved_at' => $req->approved_at,
                    'created_at' => $req->created_at,
                ];
            });

            return response()->json([
                'success' => true,
                'data' => $data,
                'pagination' => [
                    'current_page' => $requests->currentPage(),
                    'per_page' => $requests->perPage(),
                    'total' => $requests->total(),
                    'last_page' => $requests->lastPage(),
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error retrieving requests: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Approve a deposit/withdrawal request
     */
    public function approveRequest($id, Request $request)
    {
        try {
            $user = $request->user();

            if (!$user->isAdmin()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized'
                ], 403);
            }

            $depositRequest = DepositWithdrawalRequest::find($id);

            if (!$depositRequest) {
                return response()->json([
                    'success' => false,
                    'message' => 'Request not found'
                ], 404);
            }

            if (!$depositRequest->isPending()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Request is not pending. Current status: ' . $depositRequest->status
                ], 422);
            }

            $targetUser = $depositRequest->user;
            $amountSpy = intval($depositRequest->amount_spy);

            if ($depositRequest->type === 'deposit') {
                $this->walletService->addFunds(
                    $targetUser->id,
                    $amountSpy,
                    'deposit',
                    "Admin approved deposit request of {$depositRequest->amount_usd} USD"
                );
            } else if ($depositRequest->type === 'withdrawal') {
                if (!$this->walletService->validateSufficientBalance($targetUser->id, $amountSpy)) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Insufficient balance for withdrawal approval',
                        'data' => [
                            'requested_amount_usd' => $depositRequest->amount_usd,
                            'user_balance_usd' => $targetUser->wallet->balance_usd,
                        ]
                    ], 422);
                }

                $this->walletService->deductFunds(
                    $targetUser->id,
                    $amountSpy,
                    'withdrawal',
                    "Admin approved withdrawal request of {$depositRequest->amount_usd} USD"
                );
            }

            $depositRequest->update([
                'status' => 'approved',
                'approved_by' => $user->id,
                'approved_at' => now(),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Request approved successfully',
                'data' => [
                    'id' => $depositRequest->id,
                    'type' => $depositRequest->type,
                    'status' => $depositRequest->status,
                    'approved_at' => $depositRequest->approved_at,
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error approving request: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Reject a deposit/withdrawal request
     */
    public function rejectRequest($id, Request $request)
    {
        try {
            $user = $request->user();

            if (!$user->isAdmin()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized'
                ], 403);
            }

            $validated = $request->validate([
                'reason' => 'required|string|max:255',
            ]);

            $depositRequest = DepositWithdrawalRequest::find($id);

            if (!$depositRequest) {
                return response()->json([
                    'success' => false,
                    'message' => 'Request not found'
                ], 404);
            }

            if (!$depositRequest->isPending()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Request is not pending. Current status: ' . $depositRequest->status
                ], 422);
            }

            $depositRequest->update([
                'status' => 'rejected',
                'reason' => $validated['reason'],
                'approved_by' => $user->id,
                'approved_at' => now(),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Request rejected successfully',
                'data' => [
                    'id' => $depositRequest->id,
                    'type' => $depositRequest->type,
                    'status' => $depositRequest->status,
                    'reason' => $depositRequest->reason,
                ]
            ]);
        } catch (ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error rejecting request: ' . $e->getMessage()
            ], 500);
        }
    }
}
