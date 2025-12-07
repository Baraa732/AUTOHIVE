<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class LandlordMiddleware
{
    public function handle(Request $request, Closure $next)
    {
        if (!in_array($request->user()->role, ['landlord', 'admin'])) {
            return response()->json([
                'success' => false,
                'message' => 'Access denied. Landlord role required.',
                'errors' => ['role' => ['Insufficient permissions']]
            ], 403);
        }

        return $next($request);
    }
}