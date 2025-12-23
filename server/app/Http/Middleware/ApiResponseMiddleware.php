<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Log;

class ApiResponseMiddleware
{
    public function handle(Request $request, Closure $next)
    {
        Log::info('ApiResponseMiddleware: Request to ' . $request->path());
        Log::info('ApiResponseMiddleware: Full URL ' . $request->fullUrl());

        $response = $next($request);

        Log::info('ApiResponseMiddleware: Response type: ' . get_class($response));
        Log::info('ApiResponseMiddleware: Status code: ' . $response->getStatusCode());

        // Check content type
        $contentType = $response->headers->get('Content-Type');
        Log::info('ApiResponseMiddleware: Content-Type: ' . $contentType);

        // Check if it's HTML
        $content = $response->getContent();
        if (strpos($content, '<!DOCTYPE html>') === 0 || strpos($content, '<html>') === 0) {
            Log::error('ApiResponseMiddleware: Response is HTML!');
            Log::error('ApiResponseMiddleware: HTML starts with: ' . substr($content, 0, 200));

            // For API routes, we should always return JSON, even for errors
            if ($request->is('api/*')) {
                Log::info('ApiResponseMiddleware: Converting HTML error to JSON');

                $statusCode = $response->getStatusCode();
                $message = 'API endpoint not found';

                if ($statusCode === 404) {
                    $message = 'Endpoint not found: ' . $request->path();
                } elseif ($statusCode === 405) {
                    $message = 'Method not allowed for endpoint: ' . $request->path();
                }

                return response()->json([
                    'success' => false,
                    'message' => $message,
                    'error' => [
                        'code' => $statusCode,
                        'type' => 'HTTP Error'
                    ],
                    'path' => $request->path(),
                    'method' => $request->method(),
                    'timestamp' => now()->toISOString()
                ], $statusCode);
            }
        }

        // Only modify JSON responses for API routes
        if ($request->is('api/*') && $response instanceof JsonResponse) {
            $data = $response->getData(true);

            Log::info('ApiResponseMiddleware: Original data:', $data);

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

                Log::info('ApiResponseMiddleware: Wrapped response:', $standardResponse);
            }
        }

        Log::info('ApiResponseMiddleware: Finished processing');
        return $response;
    }
}
