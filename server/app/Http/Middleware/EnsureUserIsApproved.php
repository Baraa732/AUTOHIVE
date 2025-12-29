<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class EnsureUserIsApproved
{
    public function handle(Request $request, Closure $next)
    {
        \Log::info('=== EnsureUserIsApproved middleware ===');
        if ($request->user()) {
            \Log::info('User ID: ' . $request->user()->id);
            \Log::info('User is_approved: ' . ($request->user()->is_approved ? 'true' : 'false'));
            
            if (!$request->user()->is_approved) {
                \Log::warning('User not approved, blocking request');
                return response()->json([
                    'success' => false,
                    'message' => 'Your account is pending approval. Please wait for admin approval to access this feature.',
                    'errors' => ['approval' => ['Account pending approval']]
                ], 403);
            }
        }

        \Log::info('User approved, allowing request');
        return $next($request);
    }
}