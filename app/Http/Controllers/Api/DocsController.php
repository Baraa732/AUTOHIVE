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
            'endpoints' => [
                'auth' => [
                    'POST /register' => 'Register new user',
                    'POST /login' => 'Login user',
                    'POST /logout' => 'Logout user (auth required)',
                    'POST /change-password' => 'Change password (auth required)',
                    'DELETE /delete-account' => 'Delete account (auth required)',
                ],
                'profile' => [
                    'GET /profile' => 'Get user profile',
                    'PUT /profile' => 'Update profile',
                    'POST /upload-id' => 'Upload ID image',
                ],
                'files' => [
                    'POST /files/profile-image' => 'Upload profile image',
                    'POST /files/apartment-images' => 'Upload apartment images',
                    'DELETE /files/image' => 'Delete image',
                    'GET /files/image-url/{path}' => 'Get image URL',
                ],
                'locations' => [
                    'GET /locations/governorates' => 'Get all governorates',
                    'GET /locations/cities/{governorate?}' => 'Get cities by governorate',
                    'GET /locations/features' => 'Get available features',
                ],
                'search' => [
                    'GET /search/apartments' => 'Search apartments with filters',
                    'GET /search/suggestions' => 'Get search suggestions',
                    'GET /search/nearby' => 'Find nearby apartments',
                ],
                'apartments' => [
                    'GET /apartments' => 'List apartments with filters',
                    'GET /apartments/{id}' => 'Get apartment details',
                    'POST /apartments' => 'Create apartment (landlord only)',
                    'PUT /apartments/{id}' => 'Update apartment (landlord only)',
                    'DELETE /apartments/{id}' => 'Delete apartment (landlord only)',
                    'GET /my-apartments' => 'Get landlord apartments (landlord only)',
                    'POST /apartments/{id}/toggle-availability' => 'Toggle availability (landlord only)',
                ],
                'bookings' => [
                    'GET /bookings' => 'Get user bookings',
                    'GET /bookings/{id}' => 'Get booking details',
                    'POST /bookings' => 'Create booking',
                    'PUT /bookings/{id}' => 'Update booking',
                    'DELETE /bookings/{id}' => 'Cancel booking',
                    'GET /bookings/history' => 'Get booking history',
                    'GET /bookings/upcoming' => 'Get upcoming bookings',
                    'GET /landlord/bookings' => 'Get landlord bookings (landlord only)',
                    'GET /landlord/bookings/{id}' => 'Get landlord booking details (landlord only)',
                    'POST /bookings/{id}/approve' => 'Approve booking (landlord only)',
                    'POST /bookings/{id}/reject' => 'Reject booking (landlord only)',
                ],
                'reviews' => [
                    'GET /apartments/{id}/reviews' => 'Get apartment reviews',
                    'POST /reviews' => 'Create review',
                ],
                'favorites' => [
                    'GET /favorites' => 'Get user favorites',
                    'POST /favorites' => 'Add to favorites',
                    'DELETE /favorites/{id}' => 'Remove from favorites',
                ],
                'messages' => [
                    'GET /messages/{user_id}' => 'Get conversation',
                    'POST /messages' => 'Send message',
                    'POST /messages/{user_id}/read' => 'Mark messages as read',
                ],
                'notifications' => [
                    'GET /notifications' => 'Get notifications',
                    'POST /notifications/read' => 'Mark notifications as read',
                ],
                'statistics' => [
                    'GET /stats/user' => 'Get user statistics',
                    'GET /stats/apartment/{id}' => 'Get apartment statistics',
                ],
                'settings' => [
                    'GET /settings' => 'Get user settings',
                    'PUT /settings' => 'Update settings',
                ],
            ],
            'authentication' => [
                'type' => 'Bearer Token',
                'header' => 'Authorization: Bearer {token}',
                'note' => 'Required for all protected routes'
            ],
            'response_format' => [
                'success' => '200-299 status codes with JSON data',
                'error' => '400+ status codes with error message',
                'pagination' => 'Includes meta data for paginated results'
            ],
            'admin_panel' => '/admin/login',
            'test_accounts' => [
                'admin' => 'phone: 0912345678, password: admin123',
                'note' => 'Create tenant/landlord accounts via /register endpoint'
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
