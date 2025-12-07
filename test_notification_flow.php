<?php

require_once 'vendor/autoload.php';

// Test the complete notification flow
echo "=== Testing AutoHive Notification System ===\n\n";

// 1. Test user registration (should create notification)
echo "1. Testing user registration...\n";
$response = file_get_contents('http://localhost:8000/api/register', false, stream_context_create([
    'http' => [
        'method' => 'POST',
        'header' => 'Content-Type: application/json',
        'content' => json_encode([
            'phone' => '9876543210',
            'password' => 'password123',
            'password_confirmation' => 'password123',
            'role' => 'tenant',
            'first_name' => 'John',
            'last_name' => 'Doe',
            'birth_date' => '1990-01-01'
        ])
    ]
]));

$registerResult = json_decode($response, true);
echo "Registration result: " . ($registerResult['success'] ? 'SUCCESS' : 'FAILED') . "\n";
if (isset($registerResult['data']['user']['display_id'])) {
    echo "User Display ID: " . $registerResult['data']['user']['display_id'] . "\n";
}
echo "\n";

// 2. Test admin login (get token)
echo "2. Testing admin login...\n";
$adminResponse = file_get_contents('http://localhost:8000/api/login', false, stream_context_create([
    'http' => [
        'method' => 'POST',
        'header' => 'Content-Type: application/json',
        'content' => json_encode([
            'phone' => 'admin',
            'password' => 'admin123'
        ])
    ]
]));

$adminResult = json_decode($adminResponse, true);
if ($adminResult['success']) {
    $adminToken = $adminResult['data']['token'];
    echo "Admin login: SUCCESS\n";
    
    // 3. Test getting notifications
    echo "\n3. Testing notification retrieval...\n";
    $notificationResponse = file_get_contents('http://localhost:8000/api/admin/notifications-with-actions', false, stream_context_create([
        'http' => [
            'header' => 'Authorization: Bearer ' . $adminToken
        ]
    ]));
    
    $notifications = json_decode($notificationResponse, true);
    echo "Notifications found: " . count($notifications['data']) . "\n";
    
    if (count($notifications['data']) > 0) {
        $notification = $notifications['data'][0];
        echo "First notification user: " . $notification['user']['name'] . " (ID: " . $notification['user']['display_id'] . ")\n";
    }
} else {
    echo "Admin login: FAILED\n";
}

echo "\n=== Test Complete ===\n";