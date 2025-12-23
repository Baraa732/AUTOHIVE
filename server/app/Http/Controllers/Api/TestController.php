<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Apartment;
use Illuminate\Http\Request;

class TestController extends Controller
{
    public function testImages()
    {
        $apartment = Apartment::with('landlord')->first();
        
        if (!$apartment) {
            return response()->json([
                'success' => false,
                'message' => 'No apartments found'
            ]);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'apartment_id' => $apartment->id,
                'title' => $apartment->title,
                'images_raw' => $apartment->images,
                'image_urls' => $apartment->image_urls,
                'app_url' => config('app.url'),
                'storage_url' => asset('storage'),
                'first_image_full_url' => $apartment->images ? asset('storage/' . $apartment->images[0]) : null,
            ]
        ]);
    }
}