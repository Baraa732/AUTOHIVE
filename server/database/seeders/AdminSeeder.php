<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class AdminSeeder extends Seeder
{
    public function run()
    {
        User::updateOrCreate(
            ['phone' => '1234567890'],
            [
                'phone' => '1234567890',
                'password' => Hash::make('admin123'),
                'first_name' => 'Admin',
                'last_name' => 'User',
                'birth_date' => '1990-01-01',
                'role' => 'admin',
                'is_approved' => true,
                'status' => 'approved'
            ]
        );
    }
}
