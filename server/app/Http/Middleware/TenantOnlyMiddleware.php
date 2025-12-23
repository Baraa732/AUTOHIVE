<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class TenantOnlyMiddleware
{
    public function handle(Request $request, Closure $next)
    {
        if ($request->user()->role !== 'tenant') {
            return response()->json([
                'success' => false,
                'message' => 'Access denied. This feature is for tenants only.',
                'errors' => ['role' => ['Tenant access required']]
            ], 403);
        }

        return $next($request);
    }
}