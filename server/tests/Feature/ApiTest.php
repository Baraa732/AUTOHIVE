<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\User;
use App\Models\Apartment;
use App\Models\Booking;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;

class ApiTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->artisan('migrate');
    }

    public function test_user_registration()
    {
        $response = $this->postJson('/api/register', [
            'phone' => '1234567890',
            'first_name' => 'John',
            'last_name' => 'Doe',
            'password' => 'password123',
            'password_confirmation' => 'password123',
            'role' => 'tenant'
        ]);

        $response->assertStatus(201)
                ->assertJsonStructure([
                    'success',
                    'message',
                    'data' => [
                        'user',
                        'token'
                    ]
                ]);
    }

    public function test_user_login()
    {
        $user = User::factory()->create([
            'phone' => '1234567890',
            'password' => bcrypt('password123'),
            'is_approved' => true
        ]);

        $response = $this->postJson('/api/login', [
            'phone' => '1234567890',
            'password' => 'password123'
        ]);

        $response->assertStatus(200)
                ->assertJsonStructure([
                    'success',
                    'message',
                    'data' => [
                        'user',
                        'token'
                    ]
                ]);
    }

    public function test_apartment_filtering()
    {
        $response = $this->getJson('/api/apartments?governorate=Damascus&city=Mezzeh&min_price=100&max_price=500');

        $response->assertStatus(200)
                ->assertJsonStructure([
                    'success',
                    'data' => [
                        'data',
                        'current_page',
                        'total'
                    ],
                    'message'
                ]);
    }

    public function test_booking_creation_requires_auth()
    {
        $response = $this->postJson('/api/bookings', [
            'apartment_id' => 1,
            'check_in' => '2024-12-10',
            'check_out' => '2024-12-15'
        ]);

        $response->assertStatus(401);
    }

    public function test_dashboard_requires_auth()
    {
        $response = $this->getJson('/api/dashboard');
        $response->assertStatus(401);
    }
}