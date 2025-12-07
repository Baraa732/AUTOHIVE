<?php

require_once 'vendor/autoload.php';

$app = require_once 'bootstrap/app.php';

$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\User;
use App\Models\Notification;

echo "Testing Admin Notifications for User Registration\n";
echo "================================================\n\n";

// Check if there are any admin users
$admins = User::where('role', 'admin')->get();
echo "Found " . $admins->count() . " admin users:\n";
foreach ($admins as $admin) {
    echo "- {$admin->first_name} {$admin->last_name} (ID: {$admin->id})\n";
}
echo "\n";

// Create a test user (similar to what happens during registration)
$uniquePhone = '1234567890' . time(); // Make phone unique with timestamp
$testUser = User::create([
    'phone' => $uniquePhone,
    'password' => bcrypt('password123'),
    'role' => 'tenant',
    'first_name' => 'Test',
    'last_name' => 'User',
    'birth_date' => '1990-01-01',
    'is_approved' => false,
    'status' => 'pending',
]);

echo "Created test user: {$testUser->first_name} {$testUser->last_name} (ID: {$testUser->id})\n\n";

// Test the notification method directly
$authController = new App\Http\Controllers\Api\AuthController();
$reflection = new ReflectionClass($authController);
$method = $reflection->getMethod('notifyAdminsOfNewRegistration');
$method->setAccessible(true);

echo "Calling notifyAdminsOfNewRegistration method...\n";
$method->invoke($authController, $testUser);

echo "\nChecking for notifications created...\n";

// Check all new_user_registration notifications to see what's there
$allNotifications = Notification::where('type', 'new_user_registration')->get();
echo "Total new_user_registration notifications in DB: " . $allNotifications->count() . "\n";

// Check notifications specifically for this test user
$notifications = Notification::where('type', 'new_user_registration')
    ->where('data->user_id', $testUser->id)
    ->get();

echo "Found " . $notifications->count() . " notifications for this test user:\n";
foreach ($notifications as $notification) {
    $admin = User::find($notification->user_id);
    echo "- Notification for admin: {$admin->first_name} {$admin->last_name}\n";
    echo "  Title: {$notification->title}\n";
    echo "  Message: {$notification->message}\n";
    echo "  Data: " . json_encode($notification->data) . "\n\n";
}

// Also check recent notifications to see if they were created
$recentNotifications = Notification::where('created_at', '>=', now()->subMinutes(5))->get();
echo "Recent notifications (last 5 minutes): " . $recentNotifications->count() . "\n";
foreach ($recentNotifications as $notification) {
    if ($notification->type === 'new_user_registration') {
        $admin = User::find($notification->user_id);
        echo "- Recent notification: {$notification->title} for {$admin->first_name} {$admin->last_name}\n";
    }
}

// Clean up test data
$testUser->delete();
Notification::where('data->user_id', $testUser->id)->delete();

echo "Test completed and cleaned up.\n";
