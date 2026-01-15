<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Apartment;
use App\Models\Booking;
use App\Models\Review;
use App\Models\Favorite;
use App\Models\Setting;
use Illuminate\Support\Facades\Hash;

class SampleDataSeeder extends Seeder
{
    public function run()
    {
        // Create sample users
        $tenant = User::create([
            'phone' => '01555555555',
            'password' => Hash::make('password'),
            'role' => 'tenant',
            'first_name' => 'Ahmed',
            'last_name' => 'Hassan',
            'birth_date' => '1995-03-15',
            'is_approved' => true,
        ]);

        $owner = User::create([
            'phone' => '01666666666',
            'password' => Hash::make('password'),
            'role' => 'owner',
            'first_name' => 'Fatima',
            'last_name' => 'Ali',
            'birth_date' => '1988-07-22',
            'is_approved' => true,
        ]);

        // Create sample apartments
        $apartments = [
            [
                'owner_id' => $owner->id,
                'title' => 'Luxury Apartment in Mezzeh',
                'description' => 'Beautiful 2-bedroom apartment with mountain view in the heart of Mezzeh.',
                'governorate' => 'Damascus',
                'city' => 'Mezzeh',
                'address' => '15 Mezzeh Autostrad, Damascus',
                'price_per_night' => 150.00,
                'max_guests' => 4,
                'rooms' => 2,
                'features' => ['wifi', 'air_conditioning', 'balcony', 'parking'],
                'images' => ['apartments/sample1.jpg', 'apartments/sample2.jpg'],
                'is_available' => true,
            ],
            [
                'owner_id' => $owner->id,
                'title' => 'Cozy Studio in New Aleppo',
                'description' => 'Modern studio apartment perfect for business travelers.',
                'governorate' => 'Aleppo',
                'city' => 'New Aleppo',
                'address' => 'Halab al-Jadida Street, Aleppo',
                'price_per_night' => 80.00,
                'max_guests' => 2,
                'rooms' => 1,
                'features' => ['wifi', 'air_conditioning', 'gym'],
                'images' => ['apartments/sample3.jpg'],
                'is_available' => true,
            ],
        ];

        foreach ($apartments as $apartmentData) {
            Apartment::create($apartmentData);
        }

        // Create sample settings
        $settings = [
            ['key' => 'app_name', 'value' => 'AUTOHIVE'],
            ['key' => 'app_version', 'value' => '1.0.0'],
            ['key' => 'maintenance_mode', 'value' => 'false'],
            ['key' => 'default_language', 'value' => 'en'],
            ['key' => 'supported_languages', 'value' => json_encode(['en', 'ar'])],
        ];

        foreach ($settings as $setting) {
            Setting::create($setting);
        }
    }
}