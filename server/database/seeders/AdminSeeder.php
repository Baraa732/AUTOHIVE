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
            ['phone' => '0994134966'],
            [
                'phone' => '0994134966',
                'password' => Hash::make('JACK BA RA A'),
                'first_name' => 'Jack',
                'last_name' => 'Baraa',
                'birth_date' => '1990-01-01',
                'role' => 'admin',
                'is_approved' => true,
                'status' => 'approved',
                'city' => 'Damascus',
                'governorate' => 'Damascus'
            ]
        );
    }
}
