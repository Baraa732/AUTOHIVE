<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class ApiResponseMiddleware
{
    public function handle(Request $request, Closure $next)
    {
        $response = $next($request);

        // Only modify JSON responses for API routes
        if ($request->is('api/*') && $response instanceof JsonResponse) {
            $data = $response->getData(true);
            
            // If response doesn't have our standard format, wrap it
            if (!isset($data['success'])) {
                $statusCode = $response->getStatusCode();
                $isSuccess = $statusCode >= 200 && $statusCode < 300;
                
                $standardResponse = [
                    'success' => $isSuccess,
                    'message' => $isSuccess ? 'Success' : 'Error',
                    'data' => $data,
                    'timestamp' => now()->toISOString()
                ];
                
                $response->setData($standardResponse);
            }
        }

        return $response;
    }
}