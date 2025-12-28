<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class AdminUserSeeder extends Seeder
{
    public function run()
    {
        // Check if admin already exists
        $existingAdmin = User::where('phone', '0994134966')->first();
        
        if (!$existingAdmin) {
            User::create([
                'phone' => '0994134966',
                'password' => Hash::make('JACK BA RA A'),
                'first_name' => 'Admin',
                'last_name' => 'User',
                'role' => 'admin',
                'birth_date' => '1990-01-01',
                'is_approved' => true,
                'status' => 'active',
            ]);
            
            $this->command->info('Admin user created successfully!');
        } else {
            // Update existing user to admin
            $existingAdmin->update([
                'password' => Hash::make('JACK BA RA A'),
                'role' => 'admin',
                'is_approved' => true,
                'status' => 'active',
            ]);
            
            $this->command->info('Existing user updated to admin!');
        }
    }
}