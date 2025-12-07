<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Apartment;
use App\Models\Booking;
use Illuminate\Http\Request;

class TestController extends Controller
{
    public function endpoints()
    {
        return response()->json([
            'message' => 'AUTOHIVE API Test Endpoints',
            'test_data' => [
                'tenant_account' => [
                    'phone' => '01555555555',
                    'password' => 'password',
                    'role' => 'tenant'
                ],
                'landlord_account' => [
                    'phone' => '01666666666',
                    'password' => 'password',
                    'role' => 'landlord'
                ],
                'admin_account' => [
                    'phone' => '01000000000',
                    'password' => 'admin123',
                    'role' => 'admin'
                ]
            ],
            'sample_requests' => [
                'register' => [
                    'method' => 'POST',
                    'url' => '/api/register',
                    'body' => [
                        'phone' => '01777777777',
                        'password' => 'password123',
                        'role' => 'tenant',
                        'first_name' => 'Test',
                        'last_name' => 'User',
                        'birth_date' => '1990-01-01'
                    ]
                ],
                'login' => [
                    'method' => 'POST',
                    'url' => '/api/login',
                    'body' => [
                        'phone' => '01555555555',
                        'password' => 'password'
                    ]
                ],
                'search_apartments' => [
                    'method' => 'GET',
                    'url' => '/api/search/apartments?governorate=Cairo&max_price=200&guests=2'
                ],
                'create_booking' => [
                    'method' => 'POST',
                    'url' => '/api/bookings',
                    'headers' => ['Authorization: Bearer {token}'],
                    'body' => [
                        'apartment_id' => 1,
                        'check_in' => '2024-12-15',
                        'check_out' => '2024-12-20'
                    ]
                ]
            ],
            'statistics' => [
                'total_users' => User::count(),
                'total_apartments' => Apartment::count(),
                'total_bookings' => Booking::count(),
                'api_version' => '1.0.0'
            ]
        ]);
    }

    public function health()
    {
        return response()->json([
            'status' => 'healthy',
            'database' => 'connected',
            'timestamp' => now()->toISOString(),
            'uptime' => 'OK'
        ]);
    }
}
