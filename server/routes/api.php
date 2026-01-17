<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ApartmentController;
use App\Http\Controllers\Api\ApartmentAvailabilityController;
use App\Http\Controllers\Api\BookingController;
use App\Http\Controllers\Api\BookingRequestController;
use App\Http\Controllers\Api\RentalApplicationController;
use App\Http\Controllers\Api\ReviewController;
use App\Http\Controllers\Api\RatingController;
use App\Http\Controllers\Api\FavoriteController;
use App\Http\Controllers\Api\MessageController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\SettingController;
use App\Http\Controllers\Api\LocationController;
use App\Http\Controllers\Api\StatisticsController;
use App\Http\Controllers\Api\FileController;
use App\Http\Controllers\Api\SearchController;
use App\Http\Controllers\Api\WalletController;
use App\Http\Controllers\Api\DepositWithdrawalController;
use App\Http\Controllers\Api\ProfileController;
use Illuminate\Support\Facades\Route;

// Connection test route
Route::get('/', function () {
    return response()->json(['message' => 'AUTOHIVE API Ready', 'status' => 'ok']);
});

// Test image URLs
Route::get('/test-images', [\App\Http\Controllers\Api\TestController::class, 'testImages']);

//! Public routes
Route::get('/docs', [\App\Http\Controllers\Api\DocsController::class, 'index']);
Route::get('/status', [\App\Http\Controllers\Api\DocsController::class, 'status']);

//! Auth routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);


//! Public data endpoints
Route::get('/locations/governorates', [LocationController::class, 'governorates']);
Route::get('/locations/cities/{governorate?}', [LocationController::class, 'cities']);
Route::get('/locations/features', [LocationController::class, 'features']);
Route::get('/search/apartments', [SearchController::class, 'apartments']);
Route::get('/search/suggestions', [SearchController::class, 'suggestions']);
Route::get('/search/nearby', [SearchController::class, 'nearby']);
Route::get('/apartments/public', [ApartmentController::class, 'index']);
Route::get('/apartments/{id}/public', [ApartmentController::class, 'show']);
Route::get('/apartments/{id}/booked-dates', [ApartmentAvailabilityController::class, 'getBookedDates']);


// TODO:  Broadcasting authentication
Route::post('/broadcasting/auth', [\App\Http\Controllers\Api\BroadcastController::class, 'authenticate'])
    ->middleware('auth:sanctum');


//0 Routes that require authentication but not approval (view bookings, make requests, etc)
Route::middleware(['auth:sanctum'])->group(function () {
    //8A Booking Viewing (allowed for all authenticated users)
    Route::get('/bookings', [BookingController::class, 'index']);
    // IMPORTANT: Specific routes must come before parameterized routes
    Route::get('/bookings/history', [BookingController::class, 'history']);
    Route::get('/bookings/upcoming', [BookingController::class, 'upcoming']);
    // Categorized bookings endpoints (must be before /bookings/{id})
    Route::get('/bookings/upcoming-on-apartments', [BookingController::class, 'getUpcomingApartmentBookings']);
    Route::get('/bookings/my-pending', [BookingController::class, 'getMyPendingBookings']);
    Route::get('/bookings/my-ongoing', [BookingController::class, 'getMyOngoingBookings']);
    Route::get('/bookings/my-cancelled-rejected', [BookingController::class, 'getMyCancelledRejectedBookings']);
    Route::get('/bookings/check-availability/{apartmentId}', [BookingController::class, 'checkAvailability']);
    // Parameterized routes come last
    Route::get('/bookings/{id}', [BookingController::class, 'show']);
    Route::get('/my-apartment-bookings', [BookingController::class, 'myApartmentBookings']);
    Route::get('/my-apartment-bookings/{id}', [BookingController::class, 'apartmentBookingShow']);

    // Debug endpoint
    Route::get('/debug/bookings-debug', [BookingController::class, 'debugBookings']);
});

//0 Protected routes (require approval)
Route::middleware(['auth:sanctum', 'approved'])->group(function () {
    //1 Auth & Profile
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/profile', [AuthController::class, 'profile']);
    Route::put('/profile', [AuthController::class, 'updateProfile']);
    Route::post('/upload-id', [AuthController::class, 'uploadId']);
    Route::post('/change-password', [AuthController::class, 'changePassword']);
    Route::delete('/delete-account', [AuthController::class, 'deleteAccount']);

    //1.1 Enhanced Profile Management
    Route::get('/profile/show', [ProfileController::class, 'show']);
    Route::put('/profile/update', [ProfileController::class, 'update']);
    Route::post('/profile/upload-image', [ProfileController::class, 'uploadProfileImage']);
    Route::post('/profile/upload-id', [ProfileController::class, 'uploadIdImage']);
    Route::post('/profile/change-password', [ProfileController::class, 'changePassword']);
    Route::delete('/profile/delete-image', [ProfileController::class, 'deleteProfileImage']);
    Route::delete('/profile/delete-id', [ProfileController::class, 'deleteIdImage']);

    //1.5 User Stats
    Route::get('/user/stats', [StatisticsController::class, 'userStats']);


    //2 File Management
    Route::post('/files/profile-image', [FileController::class, 'uploadProfileImage']);
    Route::post('/files/apartment-images', [FileController::class, 'uploadApartmentImages']);
    Route::delete('/files/image', [FileController::class, 'deleteImage']);
    Route::get('/files/image-url/{path}', [FileController::class, 'getImageUrl'])->where('path', '.*');


    //3 Image Management (Mobile)
    Route::post('/images/upload', [\App\Http\Controllers\Api\ImageController::class, 'uploadApartmentImages']);
    Route::get('/images/{path}', [\App\Http\Controllers\Api\ImageController::class, 'getImageUrl'])->where('path', '.*');
    Route::delete('/images/delete', [\App\Http\Controllers\Api\ImageController::class, 'deleteImage']);


    //4 Dashboard
    Route::get('/dashboard', [\App\Http\Controllers\Api\DashboardController::class, 'userDashboard']);


    // Statistics
    Route::get('/stats/user', [StatisticsController::class, 'userStats']);
    Route::get('/stats/apartment/{id}', [StatisticsController::class, 'apartmentStats']);


    //5 Apartments
    Route::get('/apartments', [ApartmentController::class, 'index']);
    Route::get('/apartments/{id}', [ApartmentController::class, 'show']);
    Route::get('/apartments/{id}/reviews', [ReviewController::class, 'apartmentReviews']);
    Route::get('/apartments/features/available', [ApartmentController::class, 'getFeatures']);


    //6 Apartment Management
    Route::post('/apartments', [ApartmentController::class, 'store']);
    Route::put('/apartments/{id}', [ApartmentController::class, 'update']);
    Route::post('/apartments/{id}', [ApartmentController::class, 'update']); // For multipart with _method=PUT
    Route::delete('/apartments/{id}', [ApartmentController::class, 'destroy']);
    Route::get('/my-apartments', [ApartmentController::class, 'myApartments']);
    Route::post('/apartments/{id}/toggle-availability', [ApartmentController::class, 'toggleAvailability']);
    Route::post('/bookings/{id}/approve', [BookingController::class, 'approve']);
    Route::post('/bookings/{id}/reject', [BookingController::class, 'reject']);
    Route::get('/my-apartment-booking-requests', [BookingRequestController::class, 'myApartmentRequests']);
    Route::post('/booking-requests/{id}/approve', [BookingRequestController::class, 'approveRequest']);
    Route::post('/booking-requests/{id}/reject', [BookingRequestController::class, 'rejectRequest']);


    //7 Rental Applications
    Route::post('/rental-applications', [RentalApplicationController::class, 'store']);
    Route::get('/rental-applications/my-applications', [RentalApplicationController::class, 'myApplications']);
    Route::get('/rental-applications/incoming', [RentalApplicationController::class, 'incoming']);
    Route::get('/rental-applications/{id}', [RentalApplicationController::class, 'show']);
    Route::post('/rental-applications/{id}/approve', [RentalApplicationController::class, 'approve']);
    Route::post('/rental-applications/{id}/reject', [RentalApplicationController::class, 'reject']);
    Route::post('/rental-applications/{id}/modify', [RentalApplicationController::class, 'modify']);
    Route::get('/rental-applications/{id}/modifications', [RentalApplicationController::class, 'getModifications']);
    Route::post('/rental-applications/{id}/modifications/{modificationId}/approve', [RentalApplicationController::class, 'approveModification']);
    Route::post('/rental-applications/{id}/modifications/{modificationId}/reject', [RentalApplicationController::class, 'rejectModification']);


    //8 Booking Management (Create/Update/Delete - requires approval)
    Route::post('/booking-requests', [BookingController::class, 'requestBooking']);
    Route::get('/my-booking-requests', [BookingRequestController::class, 'myRequests']);
    Route::post('/bookings', [BookingController::class, 'store']);
    Route::put('/bookings/{id}', [BookingController::class, 'update']);
    Route::delete('/bookings/{id}', [BookingController::class, 'destroy']);


    //10 Reviews (Available to all users)
    Route::post('/reviews', [ReviewController::class, 'store']);
    Route::get('/my-reviews', [ReviewController::class, 'myReviews']);
    Route::get('/bookings/{id}/can-review', [ReviewController::class, 'canReview']);


    //11 Favorites (Available to all users)
    Route::get('/favorites', [FavoriteController::class, 'index']);
    Route::post('/favorites', [FavoriteController::class, 'store']);
    Route::delete('/favorites/{id}', [FavoriteController::class, 'destroy']);


    //12 Messages
    Route::get('/messages/{user_id}', [MessageController::class, 'conversation']);
    Route::post('/messages', [MessageController::class, 'store']);
    Route::post('/messages/{user_id}/read', [MessageController::class, 'markAsRead']);


    //13 Notifications
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::get('/notifications/unread-count', [NotificationController::class, 'getUnreadCount']);
    Route::post('/notifications/read', [NotificationController::class, 'markAsRead']);
    Route::post('/notifications/{id}/read', [NotificationController::class, 'markSingleAsRead']);
    Route::get('/notifications/check', [\App\Http\Controllers\Admin\NotificationController::class, 'apiCheck']);
    Route::post('/notifications/read-all', [\App\Http\Controllers\Admin\NotificationController::class, 'apiMarkAllAsRead']);


    //14 Test notification (for development)
    Route::post('/test-notification', [\App\Http\Controllers\Api\BroadcastController::class, 'testNotification']);


    //15 Debug endpoints
    Route::get('/debug/notifications', [\App\Http\Controllers\Api\DebugController::class, 'checkNotifications']);
    Route::post('/debug/force-notification', [\App\Http\Controllers\Api\DebugController::class, 'forceCreateNotification']);
    Route::get('/debug/rental-applications', [\App\Http\Controllers\Api\DebugController::class, 'checkRentalApplications']);
    Route::get('/debug/bookings', [BookingController::class, 'debugBookings']);


    //16 Admin API routes (protected by admin middleware)
    Route::middleware('admin')->group(function () {
        Route::get('/admin/dashboard', [\App\Http\Controllers\Api\AdminController::class, 'dashboard']);
        Route::get('/admin/users', [\App\Http\Controllers\Api\AdminController::class, 'users']);
        Route::post('/admin/users/{id}/approve', [\App\Http\Controllers\Api\AdminController::class, 'approveUser']);
        Route::delete('/admin/users/{id}', [\App\Http\Controllers\Api\AdminController::class, 'rejectUser']);
        Route::get('/admin/apartments', [\App\Http\Controllers\Api\AdminController::class, 'apartments']);
        Route::delete('/admin/apartments/{id}', [\App\Http\Controllers\Api\AdminController::class, 'deleteApartment']);
        Route::get('/admin/bookings', [\App\Http\Controllers\Api\AdminController::class, 'bookings']);
        Route::post('/admin/bookings/{id}/approve', [\App\Http\Controllers\Api\AdminController::class, 'approveBooking']);
        Route::post('/admin/bookings/{id}/reject', [\App\Http\Controllers\Api\AdminController::class, 'rejectBooking']);
        Route::get('/admin/activities', [\App\Http\Controllers\Api\AdminController::class, 'activities']);
        Route::get('/admin/admins', [\App\Http\Controllers\Api\AdminController::class, 'admins']);
        Route::post('/admin/admins', [\App\Http\Controllers\Api\AdminController::class, 'createAdmin']);
        Route::delete('/admin/admins/{id}', [\App\Http\Controllers\Api\AdminController::class, 'deleteAdmin']);


        //17 Admin Notifications
        Route::get('/admin/notifications', [\App\Http\Controllers\Api\AdminNotificationController::class, 'getNotifications']);
        Route::get('/admin/notifications/unread', [\App\Http\Controllers\Api\AdminNotificationController::class, 'getUnreadNotifications']);
        Route::post('/admin/notifications/{id}/read', [\App\Http\Controllers\Api\AdminNotificationController::class, 'markAsRead']);
        Route::post('/admin/notifications/read-all', [\App\Http\Controllers\Api\AdminNotificationController::class, 'markAllAsRead']);
        Route::post('/admin/test-notification', [\App\Http\Controllers\Api\AdminNotificationController::class, 'testCreateNotification']);


        //18 User Approval with Notifications
        Route::get('/admin/notifications-with-actions', [\App\Http\Controllers\Api\UserApprovalController::class, 'getNotificationsWithActions']);
        Route::get('/admin/pending-users', [\App\Http\Controllers\Api\UserApprovalController::class, 'getPendingUsers']);
        Route::get('/admin/user-details/{id}', [\App\Http\Controllers\Api\UserApprovalController::class, 'getUserDetails']);
        Route::post('/admin/approve-user/{id}', [\App\Http\Controllers\Api\UserApprovalController::class, 'approveUser']);
        Route::post('/admin/reject-user/{id}', [\App\Http\Controllers\Api\UserApprovalController::class, 'rejectUser']);


        //19 Apartment Approval
        Route::get('/admin/pending-apartments', [\App\Http\Controllers\Api\ApartmentApprovalController::class, 'getPendingApartments']);
        Route::get('/admin/apartment-details/{id}', [\App\Http\Controllers\Api\ApartmentApprovalController::class, 'getApartmentDetails']);
        Route::post('/admin/approve-apartment/{id}', [\App\Http\Controllers\Api\ApartmentApprovalController::class, 'approveApartment']);
        Route::post('/admin/reject-apartment/{id}', [\App\Http\Controllers\Api\ApartmentApprovalController::class, 'rejectApartment']);

        //20 Wallet Deposit/Withdrawal Management
        Route::get('/admin/deposit-requests', [DepositWithdrawalController::class, 'getAllRequests']);
        Route::post('/admin/deposit-requests/{id}/approve', [DepositWithdrawalController::class, 'approveRequest']);
        Route::post('/admin/deposit-requests/{id}/reject', [DepositWithdrawalController::class, 'rejectRequest']);
    });


    //20 Wallet Management
    Route::get('/wallet', [WalletController::class, 'getWallet']);
    Route::get('/wallet/transactions', [WalletController::class, 'getTransactions']);
    Route::post('/wallet/deposit-request', [DepositWithdrawalController::class, 'submitDepositRequest']);
    Route::post('/wallet/withdrawal-request', [DepositWithdrawalController::class, 'submitWithdrawalRequest']);
    Route::get('/wallet/my-requests', [DepositWithdrawalController::class, 'getMyRequests']);


    //20 Settings
    Route::get('/settings', [SettingController::class, 'index']);

    //21 Rating System
    Route::get('/apartments/{apartmentId}/reviews', [RatingController::class, 'getApartmentReviews']);
    Route::get('/apartments/{apartmentId}/rating-stats', [RatingController::class, 'getApartmentRatingStats']);
    Route::get('/bookings/{bookingId}/can-review', [RatingController::class, 'canReviewBooking']);
    Route::post('/bookings/{bookingId}/review', [RatingController::class, 'submitReview']);
    Route::get('/my-reviews', [RatingController::class, 'getUserReviews']);
    Route::get('/my-apartment-reviews', [RatingController::class, 'getMyApartmentReviews']);
    Route::put('/reviews/{reviewId}', [RatingController::class, 'updateReview']);
    Route::delete('/reviews/{reviewId}', [RatingController::class, 'deleteReview']);
    Route::put('/settings', [SettingController::class, 'update']);
});
