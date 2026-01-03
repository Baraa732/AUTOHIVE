<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\DepositWithdrawalRequest;
use App\Models\User;
use App\Services\WalletService;
use Illuminate\Http\Request;

class WalletController extends Controller
{
    private $walletService;

    public function __construct(WalletService $walletService)
    {
        $this->walletService = $walletService;
    }

    public function requests(Request $request)
    {
        $query = DepositWithdrawalRequest::with('user');

        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        $requests = $query->orderBy('created_at', 'desc')->paginate(20);

        return view('admin.wallet-requests', compact('requests'));
    }

    public function approve($id)
    {
        try {
            $request = DepositWithdrawalRequest::findOrFail($id);

            if ($request->status !== 'pending') {
                return back()->with('error', 'Request is not pending');
            }

            $user = $request->user;
            $amountSpy = intval($request->amount_spy);

            if ($request->type === 'deposit') {
                $this->walletService->addFunds(
                    $user->id,
                    $amountSpy,
                    'deposit',
                    "Admin approved deposit request of {$request->amount_usd} USD"
                );
            } else {
                if (!$this->walletService->validateSufficientBalance($user->id, $amountSpy)) {
                    return back()->with('error', 'User has insufficient balance for withdrawal');
                }

                $this->walletService->deductFunds(
                    $user->id,
                    $amountSpy,
                    'withdrawal',
                    "Admin approved withdrawal request of {$request->amount_usd} USD"
                );
            }

            $request->update([
                'status' => 'approved',
                'approved_by' => auth()->id(),
                'approved_at' => now(),
            ]);

            return back()->with('success', 'Request approved successfully');
        } catch (\Exception $e) {
            return back()->with('error', 'Failed to approve request: ' . $e->getMessage());
        }
    }

    public function reject(Request $request, $id)
    {
        $request->validate([
            'reason' => 'required|string|max:255',
        ]);

        try {
            $walletRequest = DepositWithdrawalRequest::findOrFail($id);

            if ($walletRequest->status !== 'pending') {
                return back()->with('error', 'Request is not pending');
            }

            $walletRequest->update([
                'status' => 'rejected',
                'reason' => $request->reason,
                'approved_by' => auth()->id(),
                'approved_at' => now(),
            ]);

            return back()->with('success', 'Request rejected successfully');
        } catch (\Exception $e) {
            return back()->with('error', 'Failed to reject request: ' . $e->getMessage());
        }
    }

    public function users(Request $request)
    {
        $query = User::with('wallet')->where('role', 'user');

        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('first_name', 'like', "%{$search}%")
                  ->orWhere('last_name', 'like', "%{$search}%")
                  ->orWhere('phone', 'like', "%{$search}%");
            });
        }

        $users = $query->orderBy('created_at', 'desc')->paginate(20);

        return view('admin.wallet-users', compact('users'));
    }
}
