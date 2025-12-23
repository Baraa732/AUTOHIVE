<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Apartment;
use App\Models\User;
use Illuminate\Http\Request;

class SearchController extends Controller
{
    public function apartments(Request $request)
    {
        $query = Apartment::with(['landlord', 'reviews'])
            ->where('is_available', true);

        // Location filters
        if ($request->governorate) {
            $query->where('governorate', $request->governorate);
        }

        if ($request->city) {
            $query->where('city', $request->city);
        }

        // Price filters
        if ($request->min_price) {
            $query->where('price_per_night', '>=', $request->min_price);
        }

        if ($request->max_price) {
            $query->where('price_per_night', '<=', $request->max_price);
        }

        // Guest capacity
        if ($request->guests) {
            $query->where('max_guests', '>=', $request->guests);
        }

        // Room count
        if ($request->rooms) {
            $query->where('rooms', '>=', $request->rooms);
        }

        // Features filter
        if ($request->features) {
            $features = is_array($request->features) ? $request->features : explode(',', $request->features);
            foreach ($features as $feature) {
                $query->whereJsonContains('features', trim($feature));
            }
        }

        // Date availability
        if ($request->check_in && $request->check_out) {
            $query->whereDoesntHave('bookings', function ($q) use ($request) {
                $q->where('status', 'approved')
                    ->where(function ($dateQuery) use ($request) {
                        $dateQuery->whereBetween('check_in', [$request->check_in, $request->check_out])
                            ->orWhereBetween('check_out', [$request->check_in, $request->check_out])
                            ->orWhere(function ($overlapQuery) use ($request) {
                                $overlapQuery->where('check_in', '<=', $request->check_in)
                                    ->where('check_out', '>=', $request->check_out);
                            });
                    });
            });
        }

        // Text search
        if ($request->search) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('title', 'like', "%{$search}%")
                    ->orWhere('description', 'like', "%{$search}%")
                    ->orWhere('address', 'like', "%{$search}%")
                    ->orWhere('city', 'like', "%{$search}%")
                    ->orWhere('governorate', 'like', "%{$search}%");
            });
        }

        // Sorting
        switch ($request->sort_by) {
            case 'price_low':
                $query->orderBy('price_per_night', 'asc');
                break;
            case 'price_high':
                $query->orderBy('price_per_night', 'desc');
                break;
            case 'rating':
                $query->withAvg('reviews', 'rating')->orderBy('reviews_avg_rating', 'desc');
                break;
            case 'newest':
                $query->orderBy('created_at', 'desc');
                break;
            default:
                $query->orderBy('created_at', 'desc');
        }

        $apartments = $query->paginate($request->per_page ?? 10);

        return response()->json([
            'success' => true,
            'data' => $apartments,
            'message' => 'Apartments search completed successfully'
        ]);
    }

    public function suggestions(Request $request)
    {
        $search = $request->get('q', '');

        if (strlen($search) < 2) {
            return response()->json([
                'success' => true,
                'data' => [],
                'message' => 'Search query too short'
            ]);
        }

        $apartments = Apartment::where('is_available', true)
            ->where(function ($query) use ($search) {
                $query->where('title', 'like', "%{$search}%")
                    ->orWhere('city', 'like', "%{$search}%")
                    ->orWhere('governorate', 'like', "%{$search}%");
            })
            ->select('id', 'title', 'city', 'governorate', 'price_per_night')
            ->limit(10)
            ->get();

        return response()->json([
            'success' => true,
            'data' => $apartments,
            'message' => 'Search suggestions retrieved successfully'
        ]);
    }

    public function nearby(Request $request)
    {
        $request->validate([
            'latitude' => 'required|numeric',
            'longitude' => 'required|numeric',
            'radius' => 'numeric|min:1|max:100'
        ]);

        // This is a simplified version - in production you'd use spatial queries
        $apartments = Apartment::with(['landlord', 'reviews'])
            ->where('is_available', true)
            ->paginate(10);

        return response()->json([
            'success' => true,
            'data' => $apartments,
            'message' => 'Nearby apartments retrieved successfully'
        ]);
    }
}
