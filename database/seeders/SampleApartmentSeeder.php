<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Apartment;
use App\Models\User;

class SampleApartmentSeeder extends Seeder
{
    public function run()
    {
        // Get some users to be owners
        $owners = User::where('role', 'user')->take(3)->get();
        
        if ($owners->isEmpty()) {
            // Create sample owners if none exist
            $owners = collect([
                User::create([
                    'phone' => '0911111111',
                    'password' => bcrypt('password'),
                    'first_name' => 'Ahmed',
                    'last_name' => 'Owner',
                    'birth_date' => '1990-01-01',
                    'role' => 'user',
                    'is_approved' => true,
                ]),
                User::create([
                    'phone' => '0922222222',
                    'password' => bcrypt('password'),
                    'first_name' => 'Fatima',
                    'last_name' => 'Property',
                    'birth_date' => '1985-05-15',
                    'role' => 'user',
                    'is_approved' => true,
                ]),
            ]);
        }

        $apartments = [
            [
                'owner_id' => $owners->first()->id,
                'title' => 'Luxury Apartment in Damascus',
                'description' => 'Beautiful 2-bedroom apartment with modern amenities in the heart of Damascus.',
                'governorate' => 'Damascus',
                'city' => 'Damascus',
                'address' => 'Mazzeh District, Damascus',
                'price_per_night' => 75.00,
                'max_guests' => 4,
                'rooms' => 3,
                'bedrooms' => 2,
                'bathrooms' => 2,
                'area' => 120.50,
                'features' => ['wifi', 'parking', 'air_conditioning', 'kitchen'],
                'images' => [],
                'is_available' => true,
            ],
            [
                'owner_id' => $owners->count() > 1 ? $owners->get(1)->id : $owners->first()->id,
                'title' => 'Cozy Studio in Aleppo',
                'description' => 'Perfect studio apartment for solo travelers or couples.',
                'governorate' => 'Aleppo',
                'city' => 'Aleppo',
                'address' => 'Old City, Aleppo',
                'price_per_night' => 45.00,
                'max_guests' => 2,
                'rooms' => 1,
                'bedrooms' => 1,
                'bathrooms' => 1,
                'area' => 45.00,
                'features' => ['wifi', 'kitchen'],
                'images' => [],
                'is_available' => true,
            ],
            [
                'owner_id' => $owners->first()->id,
                'title' => 'Family House in Lattakia',
                'description' => 'Spacious family house near the beach with garden.',
                'governorate' => 'Lattakia',
                'city' => 'Lattakia',
                'address' => 'Corniche, Lattakia',
                'price_per_night' => 120.00,
                'max_guests' => 8,
                'rooms' => 5,
                'bedrooms' => 3,
                'bathrooms' => 3,
                'area' => 200.00,
                'features' => ['wifi', 'parking', 'garden', 'beach_access', 'air_conditioning'],
                'images' => [],
                'is_available' => false,
            ],
        ];

        foreach ($apartments as $apartment) {
            Apartment::create($apartment);
        }
    }
}