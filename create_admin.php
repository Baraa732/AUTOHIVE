<?php

require_once 'vendor/autoload.php';

$app = require_once 'bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\User;
use Illuminate\Support\Facades\Hash;

$admin = User::create([
    'first_name' => 'Baraa',
    'last_name' => 'Alrifaee',
    'phone' => '0994134960',
    'password' => Hash::make('JACKBARAA'),
    'role' => 'admin',
    'is_approved' => true,
    'status' => 'active',
    'birth_date' => '1990-01-01'
]);

echo "Admin created successfully!\n";
echo "Name: Baraa Alrifaee\n";
echo "Phone: 0994134960\n";
echo "Password: JACKBARAA\n";
echo "Role: admin\n";