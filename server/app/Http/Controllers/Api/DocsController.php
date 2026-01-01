<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;

class DocsController extends Controller
{
    public function index()
    {
        return response()->json([
            'app' => 'AUTOHIVE API',
            'version' => '1.0.0',
            'base_url' => url('/api'),
            'documentation' => url('/api/docs'),
            
            'authentication' => [
                'type' => 'Bearer Token (Laravel Sanctum)',
                'header' => 'Authorization: Bearer {token}',
                'obtain_token' => 'POST /api/login or POST /api/register',
                'note' => 'Include token in Authorization header for protected routes'
            ],

            'endpoints' => [
                
                // Authentication
                'auth' => [
                    [
                        'method' => 'POST',
                        'endpoint' => '/register',
                        'description' => 'Register new user',
                        'auth_required' => false,
                        'body' => [
                            'first_name' => 'string (required)',
                            'last_name' => 'string (required)',
                            'phone' => 'string (required, unique)',
                            'password' => 'string (required, min:8)',
                            'password_confirmation' => 'string (required)',
                            'city' => 'string (required)',
                            'governorate' => 'string (required)',
                            'birth_date' => 'date (optional, format: Y-m-d)',
                            'profile_image' => 'file (optional, image)',
                            'id_image' => 'file (optional, image)'
                        ],
                        'response' => [
                            'success' => true,
                            'message' => 'Registration successful',
                            'data' => ['user' => '...', 'token' => '...']
                        ]
                    ],
                    [
                        'method' => 'POST',
                        'endpoint' => '/login',
                        'description' => 'Login user',
                        'auth_required' => false,
                        'body' => [
                            'phone' => 'string (required)',
                            'password' => 'string (required)',
                            'device_name' => 'string (optional)'
                        ],
                        'response' => [
                            'success' => true,
                            'data' => ['user' => '...', 'token' => '...']
                        ]
                    ],
                    [
                        'method' => 'POST',
                        'endpoint' => '/logout',
                        'description' => 'Logout user',
                        'auth_required' => true
                    ],
                    [
                        'method' => 'POST',
                        'endpoint' => '/change-password',
                        'description' => 'Change user password',
                        'auth_required' => true,
                        'body' => [
                            'current_password' => 'string (required)',
                            'new_password' => 'string (required, min:8)',
                            'new_password_confirmation' => 'string (required)'
                        ]
                    ]
                ],

                // Profile
                'profile' => [
                    [
                        'method' => 'GET',
                        'endpoint' => '/profile',
                        'description' => 'Get authenticated user profile',
                        'auth_required' => true
                    ],
                    [
                        'method' => 'PUT',
                        'endpoint' => '/profile',
                        'description' => 'Update user profile',
                        'auth_required' => true,
                        'body' => [
                            'first_name' => 'string (optional)',
                            'last_name' => 'string (optional)',
                            'phone' => 'string (optional)',
                            'profile_image' => 'file (optional)'
                        ]
                    ]
                ],

                // Dashboard
                'dashboard' => [
                    [
                        'method' => 'GET',
                        'endpoint' => '/dashboard',
                        'description' => 'Get user dashboard data (apartments, bookings, stats)',
                        'auth_required' => true,
                        'response' => [
                            'success' => true,
                            'data' => [
                                'apartments' => [],
                                'bookings' => [],
                                'stats' => []
                            ]
                        ]
                    ]
                ],

                // Apartments - Public
                'apartments_public' => [
                    [
                        'method' => 'GET',
                        'endpoint' => '/apartments/public',
                        'description' => 'Get public apartments list (available only)',
                        'auth_required' => false,
                        'query_params' => [
                            'search' => 'string (optional)',
                            'available' => 'boolean (optional, default: 1)'
                        ]
                    ],
                    [
                        'method' => 'GET',
                        'endpoint' => '/apartments/{id}/public',
                        'description' => 'Get public apartment details',
                        'auth_required' => false
                    ],
                    [
                        'method' => 'GET',
                        'endpoint' => '/apartments/features/available',
                        'description' => 'Get available apartment features',
                        'auth_required' => true
                    ]
                ],

                // Apartments - Authenticated
                'apartments' => [
                    [
                        'method' => 'GET',
                        'endpoint' => '/apartments',
                        'description' => 'Get apartments list',
                        'auth_required' => true,
                        'query_params' => [
                            'search' => 'string (optional)'
                        ]
                    ],
                    [
                        'method' => 'GET',
                        'endpoint' => '/apartments/{id}',
                        'description' => 'Get apartment details with owner info',
                        'auth_required' => true
                    ],
                    [
                        'method' => 'POST',
                        'endpoint' => '/apartments',
                        'description' => 'Create new apartment',
                        'auth_required' => true,
                        'content_type' => 'multipart/form-data',
                        'body' => [
                            'title' => 'string (required)',
                            'description' => 'string (required)',
                            'price' => 'numeric (required)',
                            'bedrooms' => 'integer (required)',
                            'bathrooms' => 'integer (required)',
                            'area' => 'numeric (required)',
                            'address' => 'string (required)',
                            'city' => 'string (required)',
                            'governorate' => 'string (required)',
                            'latitude' => 'numeric (optional)',
                            'longitude' => 'numeric (optional)',
                            'features' => 'array (optional)',
                            'images[0]' => 'file (required, at least 1 image)',
                            'images[1]' => 'file (optional)',
                            'available' => 'boolean (optional, default: true)'
                        ]
                    ],
                    [
                        'method' => 'PUT',
                        'endpoint' => '/apartments/{id}',
                        'description' => 'Update apartment',
                        'auth_required' => true,
                        'content_type' => 'multipart/form-data',
                        'body' => 'Same as create apartment'
                    ],
                    [
                        'method' => 'DELETE',
                        'endpoint' => '/apartments/{id}',
                        'description' => 'Delete apartment',
                        'auth_required' => true
                    ],
                    [
                        'method' => 'GET',
                        'endpoint' => '/my-apartments',
                        'description' => 'Get authenticated user apartments',
                        'auth_required' => true
                    ],
                    [
                        'method' => 'POST',
                        'endpoint' => '/apartments/{id}/toggle-availability',
                        'description' => 'Toggle apartment availability',
                        'auth_required' => true
                    ]
                ],

                // Bookings
                'bookings' => [
                    [
                        'method' => 'POST',
                        'endpoint' => '/booking-requests',
                        'description' => 'Create booking request',
                        'auth_required' => true,
                        'body' => [
                            'apartment_id' => 'string (required)',
                            'check_in' => 'date (required, format: Y-m-d)',
                            'check_out' => 'date (required, format: Y-m-d)',
                            'guests' => 'integer (required)',
                            'message' => 'string (optional)'
                        ]
                    ],
                    [
                        'method' => 'GET',
                        'endpoint' => '/bookings',
                        'description' => 'Get user bookings',
                        'auth_required' => true
                    ],
                    [
                        'method' => 'GET',
                        'endpoint' => '/my-apartment-bookings',
                        'description' => 'Get bookings for user apartments (landlord)',
                        'auth_required' => true
                    ],
                    [
                        'method' => 'GET',
                        'endpoint' => '/my-booking-requests',
                        'description' => 'Get user booking requests',
                        'auth_required' => true
                    ],
                    [
                        'method' => 'GET',
                        'endpoint' => '/my-apartment-booking-requests',
                        'description' => 'Get booking requests for user apartments',
                        'auth_required' => true
                    ],
                    [
                        'method' => 'POST',
                        'endpoint' => '/booking-requests/{id}/approve',
                        'description' => 'Approve booking request (landlord)',
                        'auth_required' => true
                    ],
                    [
                        'method' => 'POST',
                        'endpoint' => '/booking-requests/{id}/reject',
                        'description' => 'Reject booking request (landlord)',
                        'auth_required' => true
                    ],
                    [
                        'method' => 'DELETE',
                        'endpoint' => '/bookings/{id}',
                        'description' => 'Cancel booking',
                        'auth_required' => true
                    ],
                    [
                        'method' => 'GET',
                        'endpoint' => '/bookings/check-availability/{apartmentId}',
                        'description' => 'Check apartment availability',
                        'auth_required' => true,
                        'query_params' => [
                            'check_in' => 'date (required, format: Y-m-d)',
                            'check_out' => 'date (required, format: Y-m-d)'
                        ]
                    ]
                ],

                // Rental Applications
                'rental_applications' => [
                    [
                        'method' => 'POST',
                        'endpoint' => '/rental-applications',
                        'description' => 'Submit rental application',
                        'auth_required' => true,
                        'body' => [
                            'apartment_id' => 'string (required)',
                            'check_in' => 'date (required, format: Y-m-d)',
                            'check_out' => 'date (required, format: Y-m-d)',
                            'message' => 'string (optional)'
                        ]
                    ],
                    [
                        'method' => 'GET',
                        'endpoint' => '/rental-applications/my-applications',
                        'description' => 'Get user rental applications',
                        'auth_required' => true
                    ],
                    [
                        'method' => 'GET',
                        'endpoint' => '/rental-applications/incoming',
                        'description' => 'Get incoming rental applications (landlord)',
                        'auth_required' => true
                    ],
                    [
                        'method' => 'GET',
                        'endpoint' => '/rental-applications/{id}',
                        'description' => 'Get rental application details',
                        'auth_required' => true
                    ],
                    [
                        'method' => 'POST',
                        'endpoint' => '/rental-applications/{id}/approve',
                        'description' => 'Approve rental application (landlord)',
                        'auth_required' => true
                    ],
                    [
                        'method' => 'POST',
                        'endpoint' => '/rental-applications/{id}/reject',
                        'description' => 'Reject rental application (landlord)',
                        'auth_required' => true,
                        'body' => [
                            'rejected_reason' => 'string (optional)'
                        ]
                    ],
                    [
                        'method' => 'POST',
                        'endpoint' => '/rental-applications/{id}/modify',
                        'description' => 'Modify rental application (tenant)',
                        'auth_required' => true,
                        'body' => [
                            'check_in' => 'date (required, format: Y-m-d)',
                            'check_out' => 'date (required, format: Y-m-d)',
                            'message' => 'string (optional)'
                        ]
                    ],
                    [
                        'method' => 'GET',
                        'endpoint' => '/rental-applications/{id}/modifications',
                        'description' => 'Get modification history',
                        'auth_required' => true
                    ],
                    [
                        'method' => 'POST',
                        'endpoint' => '/rental-applications/{id}/modifications/{modificationId}/approve',
                        'description' => 'Approve modification (landlord)',
                        'auth_required' => true
                    ],
                    [
                        'method' => 'POST',
                        'endpoint' => '/rental-applications/{id}/modifications/{modificationId}/reject',
                        'description' => 'Reject modification (landlord)',
                        'auth_required' => true,
                        'body' => [
                            'rejection_reason' => 'string (optional)'
                        ]
                    ]
                ],

                // Favorites
                'favorites' => [
                    [
                        'method' => 'GET',
                        'endpoint' => '/favorites',
                        'description' => 'Get user favorites',
                        'auth_required' => true
                    ],
                    [
                        'method' => 'POST',
                        'endpoint' => '/favorites',
                        'description' => 'Add apartment to favorites',
                        'auth_required' => true,
                        'body' => [
                            'apartment_id' => 'string (required)'
                        ]
                    ],
                    [
                        'method' => 'DELETE',
                        'endpoint' => '/favorites/{id}',
                        'description' => 'Remove from favorites',
                        'auth_required' => true
                    ]
                ],

                // Notifications
                'notifications' => [
                    [
                        'method' => 'GET',
                        'endpoint' => '/notifications',
                        'description' => 'Get user notifications',
                        'auth_required' => true
                    ],
                    [
                        'method' => 'POST',
                        'endpoint' => '/notifications/{id}/read',
                        'description' => 'Mark notification as read',
                        'auth_required' => true
                    ]
                ]
            ],

            'response_format' => [
                'success_response' => [
                    'success' => true,
                    'message' => 'Success message',
                    'data' => 'Response data'
                ],
                'error_response' => [
                    'success' => false,
                    'message' => 'Error message',
                    'errors' => 'Validation errors (if applicable)'
                ]
            ],

            'status_codes' => [
                '200' => 'Success',
                '201' => 'Created',
                '400' => 'Bad Request',
                '401' => 'Unauthorized',
                '403' => 'Forbidden',
                '404' => 'Not Found',
                '422' => 'Validation Error',
                '500' => 'Server Error'
            ]
        ]);
    }

    public function status()
    {
        return response()->json([
            'status' => 'online',
            'timestamp' => now()->toISOString(),
            'version' => '1.0.0',
            'environment' => app()->environment()
        ]);
    }
}
