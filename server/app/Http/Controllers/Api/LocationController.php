<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Apartment;

class LocationController extends Controller
{
    public function governorates()
    {
        $governorates = Apartment::distinct()->pluck('governorate')->filter()->values();
        return response()->json([
            'success' => true,
            'data' => $governorates,
            'message' => 'Governorates retrieved successfully'
        ]);
    }

    public function cities($governorate = null)
    {
        $query = Apartment::distinct();
        
        if ($governorate) {
            $query->where('governorate', $governorate);
        }
        
        $cities = $query->pluck('city')->filter()->values();
        return response()->json([
            'success' => true,
            'data' => $cities,
            'message' => 'Cities retrieved successfully'
        ]);
    }

    public function features()
    {
        $features = Apartment::whereNotNull('features')
            ->get()
            ->pluck('features')
            ->flatten()
            ->unique()
            ->values();
            
        return response()->json([
            'success' => true,
            'data' => $features,
            'message' => 'Features retrieved successfully'
        ]);
    }
}
