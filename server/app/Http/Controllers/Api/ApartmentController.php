<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Apartment;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class ApartmentController extends Controller
{
    public function index(Request $request)
    {
        $query = Apartment::with(['user', 'reviews'])
            ->where('is_approved', true) // MUST be approved by admin
            ->where('status', 'approved'); // MUST have approved status

        // Filter by governorate
        if ($request->governorate) {
            $query->where('governorate', $request->governorate);
        }

        // Filter by city
        if ($request->city) {
            $query->where('city', $request->city);
        }

        // Price range filtering
        if ($request->min_price) {
            $query->where('price_per_night', '>=', $request->min_price);
        }
        if ($request->max_price) {
            $query->where('price_per_night', '<=', $request->max_price);
        }

        // Guest capacity filtering
        if ($request->min_guests) {
            $query->where('max_guests', '>=', $request->min_guests);
        }

        // Room specifications
        if ($request->bedrooms) {
            $query->where('bedrooms', '>=', $request->bedrooms);
        }
        if ($request->bathrooms) {
            $query->where('bathrooms', '>=', $request->bathrooms);
        }
        if ($request->min_area) {
            $query->where('area', '>=', $request->min_area);
        }

        // Search functionality
        if ($request->search) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('title', 'like', "%{$search}%")
                  ->orWhere('description', 'like', "%{$search}%")
                  ->orWhere('address', 'like', "%{$search}%")
                  ->orWhere('city', 'like', "%{$search}%")
                  ->orWhere('governorate', 'like', "%{$search}%");
            });
        }

        // Features/amenities filtering
        if ($request->features) {
            $features = is_array($request->features) ? $request->features : [$request->features];
            foreach ($features as $feature) {
                $query->whereJsonContains('features', $feature);
            }
        }

        // Sorting options
        $sortBy = $request->get('sort_by', 'created_at');
        $sortOrder = $request->get('sort_order', 'desc');
        
        switch ($sortBy) {
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
                $query->orderBy($sortBy, $sortOrder);
        }

        $apartments = $query->paginate($request->get('per_page', 10));

        // Add average rating to each apartment
        $apartments->getCollection()->transform(function ($apartment) {
            $apartment->average_rating = $apartment->reviews->avg('rating') ?? 0;
            $apartment->reviews_count = $apartment->reviews->count();
            return $apartment;
        });

        return response()->json([
            'success' => true,
            'data' => $apartments,
            'message' => 'Apartments retrieved successfully'
        ]);
    }

    public function show($id)
    {
        $apartment = Apartment::with(['user', 'reviews.user', 'bookings'])
            ->where('is_approved', true)
            ->where('status', 'approved')
            ->find($id);

        if (!$apartment) {
            return response()->json([
                'success' => false,
                'message' => 'Apartment not found or not approved yet'
            ], 404);
        }

        $apartment->average_rating = $apartment->reviews->avg('rating') ?? 0;
        $apartment->reviews_count = $apartment->reviews->count();
        $apartment->bookings_count = $apartment->bookings->count();
        
        $apartment->availability_calendar = $this->getAvailabilityCalendar($apartment);

        return response()->json([
            'success' => true,
            'data' => $apartment,
            'message' => 'Apartment details retrieved successfully'
        ]);
    }

    private function getAvailabilityCalendar($apartment)
    {
        $calendar = [];
        $startDate = now();
        
        for ($i = 0; $i < 30; $i++) {
            $date = $startDate->copy()->addDays($i);
            $isBooked = $apartment->bookings()
                ->where('status', 'approved')
                ->where('check_in', '<=', $date)
                ->where('check_out', '>', $date)
                ->exists();
                
            $calendar[] = [
                'date' => $date->format('Y-m-d'),
                'available' => !$isBooked
            ];
        }
        
        return $calendar;
    }

    public function store(Request $request)
    {
        $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'required|string|max:1000',
            'governorate' => 'required|string|max:100',
            'city' => 'required|string|max:100',
            'address' => 'required|string|max:255',
            'price_per_night' => 'required|numeric|min:1',
            'max_guests' => 'required|integer|min:1|max:20',
            'rooms' => 'required|integer|min:1|max:10',
            'bedrooms' => 'required|integer|min:1|max:10',
            'bathrooms' => 'required|integer|min:1|max:10',
            'area' => 'required|numeric|min:10|max:1000',
            'features' => 'array',
            'features.*' => 'string|in:' . implode(',', array_column(\App\Enums\ApartmentFeature::cases(), 'value')),
            'images' => 'required|array|min:1|max:10',
            'images.*' => 'image|mimes:jpeg,png,jpg,webp|max:5120'
        ]);

        $data = $request->only([
            'title',
            'description',
            'governorate',
            'city',
            'address',
            'price_per_night',
            'max_guests',
            'rooms',
            'bedrooms',
            'bathrooms',
            'area',
            'features'
        ]);

        $data['user_id'] = $request->user()->id;
        $data['is_available'] = true;
        $data['is_approved'] = true;
        $data['status'] = 'approved';

        // Handle image uploads
        if ($request->hasFile('images')) {
            $images = [];
            foreach ($request->file('images') as $image) {
                $path = $image->store('apartments', 'public');
                $images[] = $path;
            }
            $data['images'] = $images;
        }

        $apartment = Apartment::create($data);

        return response()->json([
            'success' => true,
            'message' => 'Apartment created successfully.',
            'data' => $apartment
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $apartment = Apartment::where('user_id', $request->user()->id)
            ->findOrFail($id);

        $request->validate([
            'title' => 'string|max:255',
            'description' => 'string',
            'governorate' => 'string',
            'city' => 'string',
            'address' => 'string',
            'price_per_night' => 'numeric|min:0',
            'max_guests' => 'integer|min:1',
            'rooms' => 'integer|min:1',
            'bedrooms' => 'integer|min:1',
            'bathrooms' => 'integer|min:1',
            'area' => 'numeric|min:10',
            'features' => 'array',
            'is_available' => 'boolean',
            'existing_images' => 'array',
            'images' => 'array',
            'images.*' => 'image|mimes:jpeg,png,jpg,webp|max:5120'
        ]);

        $data = $request->only([
            'title', 'description', 'governorate', 'city', 'address',
            'price_per_night', 'max_guests', 'rooms', 'bedrooms', 'bathrooms', 
            'area', 'features', 'is_available'
        ]);

        // Handle images: combine existing images with new uploads
        $finalImages = [];
        
        // Add existing images that weren't removed
        if ($request->has('existing_images')) {
            $finalImages = $request->existing_images;
        }
        
        // Add new uploaded images
        if ($request->hasFile('images')) {
            foreach ($request->file('images') as $image) {
                $path = $image->store('apartments', 'public');
                $finalImages[] = $path;
            }
        }
        
        // Update images only if there are changes
        if (!empty($finalImages) || $request->has('existing_images')) {
            $data['images'] = $finalImages;
        }

        $apartment->update($data);

        return response()->json([
            'success' => true,
            'message' => 'Apartment updated successfully',
            'data' => $apartment->fresh()
        ]);
    }

    public function destroy(Request $request, $id)
    {
        $apartment = Apartment::where('user_id', $request->user()->id)
            ->findOrFail($id);

        // Check if apartment has active bookings
        $activeBookings = $apartment->bookings()
            ->whereIn('status', ['pending', 'approved'])
            ->exists();

        if ($activeBookings) {
            return response()->json([
                'message' => 'Cannot delete apartment with active bookings'
            ], 422);
        }

        $apartment->delete();

        return response()->json([
            'message' => 'Apartment deleted successfully'
        ]);
    }

    public function myApartments(Request $request)
    {
        $apartments = Apartment::where('user_id', $request->user()->id)
            ->with(['reviews', 'bookings'])
            ->withCount(['bookings', 'reviews'])
            ->paginate(10);

        return response()->json([
            'success' => true,
            'data' => $apartments,
            'message' => 'My apartments retrieved successfully'
        ]);
    }

    public function toggleAvailability(Request $request, $id)
    {
        $apartment = Apartment::where('user_id', $request->user()->id)
            ->findOrFail($id);

        $apartment->update([
            'is_available' => !$apartment->is_available
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Apartment availability updated',
            'data' => ['is_available' => $apartment->is_available]
        ]);
    }

    public function getFeatures()
    {
        return response()->json([
            'success' => true,
            'data' => \App\Enums\ApartmentFeature::all(),
            'message' => 'Available features retrieved successfully'
        ]);
    }

    private function notifyAdminsOfNewApartment($apartment)
    {
        try {
            Log::info('New apartment created', [
                'apartment_id' => $apartment->id,
                'apartment_title' => $apartment->title,
                'user_id' => $apartment->user_id,
                'status' => $apartment->status
            ]);
        } catch (\Exception $e) {
            Log::error('Failed to log apartment creation', ['error' => $e->getMessage()]);
        }
    }
}
