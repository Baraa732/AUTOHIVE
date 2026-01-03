<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Admin\AdminController;
use App\Http\Controllers\Admin\DashboardController;


Route::get('/', function () {
    return view('welcome');
});

// Admin routes
Route::prefix('admin')->group(function () {
    Route::get('/login', function () {
        return view('admin.login');
    })->name('admin.login');
    
    Route::post('/login', [AdminController::class, 'login'])->name('admin.login.post');
    
    Route::middleware(['admin.auth'])->group(function () {
        Route::get('/dashboard', [DashboardController::class, 'index'])->name('admin.dashboard');
        Route::get('/users', [\App\Http\Controllers\Admin\UserController::class, 'index'])->name('admin.users');
        Route::get('/users/stats', [\App\Http\Controllers\Admin\UserController::class, 'stats'])->name('admin.users.stats');
        Route::get('/users/{id}', [\App\Http\Controllers\Admin\UserController::class, 'show'])->name('admin.users.show');
        Route::delete('/users/{id}', [\App\Http\Controllers\Admin\UserController::class, 'destroy'])->name('admin.users.destroy');
        Route::post('/users/{id}/approve', [AdminController::class, 'approveUser'])->name('admin.users.approve');
        Route::delete('/users/{id}/reject', [AdminController::class, 'rejectUser'])->name('admin.users.reject');
        Route::get('/apartments', [\App\Http\Controllers\Admin\ApartmentController::class, 'index'])->name('admin.apartments');
        Route::get('/apartments/pending', function() { return view('admin.apartments.pending'); })->name('admin.apartments.pending');
        Route::get('/apartments/{id}', [\App\Http\Controllers\Admin\ApartmentController::class, 'show'])->name('admin.apartments.show');
        Route::get('/apartments/{id}/edit', [\App\Http\Controllers\Admin\ApartmentController::class, 'edit'])->name('admin.apartments.edit');
        Route::put('/apartments/{id}', [\App\Http\Controllers\Admin\ApartmentController::class, 'update'])->name('admin.apartments.update');
        Route::post('/apartments/{id}/approve', [\App\Http\Controllers\Admin\ApartmentController::class, 'approve'])->name('admin.apartments.approve');
        Route::post('/apartments/{id}/reject', [\App\Http\Controllers\Admin\ApartmentController::class, 'reject'])->name('admin.apartments.reject');
        Route::delete('/apartments/{id}', [AdminController::class, 'deleteApartment'])->name('admin.apartments.delete');
        Route::get('/bookings', [AdminController::class, 'bookings'])->name('admin.bookings');
        Route::get('/bookings/{id}/details', [AdminController::class, 'getBookingDetails'])->name('admin.bookings.details');
        Route::post('/bookings/{id}/approve', [AdminController::class, 'approveBooking'])->name('admin.bookings.approve');
        Route::post('/bookings/{id}/reject', [AdminController::class, 'rejectBooking'])->name('admin.bookings.reject');
        
        // Admin Management
        Route::get('/admins', [\App\Http\Controllers\Admin\AdminManagementController::class, 'index'])->name('admin.admins');
        Route::get('/admins/create', [\App\Http\Controllers\Admin\AdminManagementController::class, 'create'])->name('admin.admins.create');
        Route::post('/admins', [\App\Http\Controllers\Admin\AdminManagementController::class, 'store'])->name('admin.admins.store');
        Route::delete('/admins/{id}', [\App\Http\Controllers\Admin\AdminManagementController::class, 'destroy'])->name('admin.admins.delete');
        Route::get('/profile', [\App\Http\Controllers\Admin\ProfileController::class, 'index'])->name('admin.profile');
        Route::put('/profile', [\App\Http\Controllers\Admin\ProfileController::class, 'update'])->name('admin.profile.update');
        Route::delete('/profile/image', [\App\Http\Controllers\Admin\ImageController::class, 'deleteProfileImage'])->name('admin.profile.image.delete');
        
        // Wallet Management
        Route::get('/wallet-requests', [\App\Http\Controllers\Admin\WalletController::class, 'requests'])->name('admin.wallet.requests');
        Route::post('/wallet-requests/{id}/approve', [\App\Http\Controllers\Admin\WalletController::class, 'approve'])->name('admin.wallet.approve');
        Route::post('/wallet-requests/{id}/reject', [\App\Http\Controllers\Admin\WalletController::class, 'reject'])->name('admin.wallet.reject');
        Route::get('/wallet-users', [\App\Http\Controllers\Admin\WalletController::class, 'users'])->name('admin.wallet.users');
        
        // Notification routes
        Route::get('/notifications/check', [\App\Http\Controllers\Admin\NotificationController::class, 'check'])->name('admin.notifications.check');
        Route::get('/notifications/pending', [\App\Http\Controllers\Admin\NotificationController::class, 'getPendingUsers'])->name('admin.notifications.pending');
        Route::post('/notifications/{id}/read', [\App\Http\Controllers\Admin\NotificationController::class, 'markAsRead'])->name('admin.notifications.read');
        Route::post('/notifications/read-all', [\App\Http\Controllers\Admin\NotificationController::class, 'markAllAsRead'])->name('admin.notifications.read-all');
        Route::post('/notifications/approve-user/{id}', [\App\Http\Controllers\Admin\NotificationController::class, 'approveUser'])->name('admin.notifications.approve');
        Route::post('/notifications/reject-user/{id}', [\App\Http\Controllers\Admin\NotificationController::class, 'rejectUser'])->name('admin.notifications.reject');
        Route::get('/notifications', [\App\Http\Controllers\Admin\NotificationController::class, 'getAll'])->name('admin.notifications');
        
        Route::post('/logout', [AdminController::class, 'logout'])->name('admin.logout');
    });
});
