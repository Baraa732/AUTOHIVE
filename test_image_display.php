<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

echo "=== AUTOHIVE Image Display Test ===\n\n";

// Test 1: Check storage link
echo "1. Checking storage link...\n";
$storageLink = public_path('storage');
if (is_link($storageLink) || is_dir($storageLink)) {
    echo "   ✅ Storage link exists\n";
} else {
    echo "   ❌ Storage link missing! Run: php artisan storage:link\n";
}

// Test 2: Check pending users
echo "\n2. Checking pending users...\n";
$pendingUsers = \App\Models\User::where('status', 'pending')->get();
echo "   Found {$pendingUsers->count()} pending user(s)\n";

if ($pendingUsers->count() > 0) {
    foreach ($pendingUsers as $user) {
        echo "\n   User: {$user->first_name} {$user->last_name}\n";
        echo "   - Profile Image Path: " . ($user->profile_image ?? 'NULL') . "\n";
        echo "   - ID Image Path: " . ($user->id_image ?? 'NULL') . "\n";
        echo "   - Profile Image URL: " . ($user->profile_image_url ?? 'NULL') . "\n";
        echo "   - ID Image URL: " . ($user->id_image_url ?? 'NULL') . "\n";
        
        // Check if files exist
        if ($user->profile_image) {
            $profilePath = storage_path('app/public/' . $user->profile_image);
            echo "   - Profile file exists: " . (file_exists($profilePath) ? '✅ YES' : '❌ NO') . "\n";
        }
        
        if ($user->id_image) {
            $idPath = storage_path('app/public/' . $user->id_image);
            echo "   - ID file exists: " . (file_exists($idPath) ? '✅ YES' : '❌ NO') . "\n";
        }
    }
} else {
    echo "   ℹ️  No pending users. Register a new user to test.\n";
}

// Test 3: Check image directories
echo "\n3. Checking image directories...\n";
$profilesDir = storage_path('app/public/profiles');
$idsDir = storage_path('app/public/ids');

if (is_dir($profilesDir)) {
    $profileFiles = glob($profilesDir . '/*');
    echo "   ✅ Profiles directory exists ({" . count($profileFiles) . "} files)\n";
} else {
    echo "   ❌ Profiles directory missing\n";
}

if (is_dir($idsDir)) {
    $idFiles = glob($idsDir . '/*');
    echo "   ✅ IDs directory exists (" . count($idFiles) . " files)\n";
} else {
    echo "   ❌ IDs directory missing\n";
}

// Test 4: Test API endpoint
echo "\n4. Testing API endpoint...\n";
try {
    $controller = new \App\Http\Controllers\Admin\NotificationController();
    $response = $controller->getPendingUsers();
    $data = json_decode($response->getContent(), true);
    
    echo "   ✅ API endpoint works\n";
    echo "   - Success: " . ($data['success'] ? 'YES' : 'NO') . "\n";
    echo "   - Data count: " . count($data['data']) . "\n";
    
    if (count($data['data']) > 0) {
        $firstUser = $data['data'][0]['user'];
        echo "   - First user has profile_image_url: " . (isset($firstUser['profile_image_url']) ? 'YES' : 'NO') . "\n";
        echo "   - First user has id_image_url: " . (isset($firstUser['id_image_url']) ? 'YES' : 'NO') . "\n";
    }
} catch (\Exception $e) {
    echo "   ❌ API endpoint error: " . $e->getMessage() . "\n";
}

// Test 5: Check User model accessors
echo "\n5. Testing User model accessors...\n";
$testUser = \App\Models\User::latest()->first();
if ($testUser) {
    echo "   Testing with user: {$testUser->first_name} {$testUser->last_name}\n";
    echo "   - profile_image_url accessor: " . ($testUser->profile_image_url ?? 'NULL') . "\n";
    echo "   - id_image_url accessor: " . ($testUser->id_image_url ?? 'NULL') . "\n";
    echo "   - Accessors in appends: " . (in_array('profile_image_url', $testUser->appends) ? 'YES' : 'NO') . "\n";
} else {
    echo "   ℹ️  No users in database\n";
}

echo "\n=== Test Complete ===\n";
echo "\nNext Steps:\n";
echo "1. If no pending users, register via mobile app or Postman\n";
echo "2. Check browser console on notifications page (F12)\n";
echo "3. Verify image URLs are accessible directly in browser\n";
echo "4. Check Laravel logs: storage/logs/laravel.log\n";
