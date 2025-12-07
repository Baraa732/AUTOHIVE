<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Review;
use App\Models\Booking;
use Illuminate\Http\Request;

class ReviewController extends Controller
{
    public function store(Request $request)
    {
        $request->validate([
            'booking_id' => 'required|exists:bookings,id',
            'rating' => 'required|integer|min:1|max:5',
            'comment' => 'required|string|max:1000',
            'cleanliness_rating' => 'integer|min:1|max:5',
            'location_rating' => 'integer|min:1|max:5',
            'value_rating' => 'integer|min:1|max:5',
            'communication_rating' => 'integer|min:1|max:5',
        ]);

        // Get the booking and verify landlordship
        $booking = Booking::where('id', $request->booking_id)
            ->where('tenant_id', $request->user()->id)
            ->where('status', 'completed')
            ->with('apartment')
            ->first();

        if (!$booking) {
            return response()->json([
                'success' => false,
                'message' => 'You can only review completed bookings.',
                'errors' => ['booking_id' => ['Invalid or incomplete booking']]
            ], 403);
        }

        // Check if user already reviewed this booking
        $existingReview = Review::where('tenant_id', $request->user()->id)
            ->where('apartment_id', $booking->apartment_id)
            ->where('booking_id', $request->booking_id)
            ->exists();

        if ($existingReview) {
            return response()->json([
                'success' => false,
                'message' => 'You have already reviewed this booking.',
                'errors' => ['booking_id' => ['Already reviewed']]
            ], 422);
        }

        // Check if review is within allowed timeframe (e.g., 30 days after checkout)
        if ($booking->check_out->diffInDays(now()) > 30) {
            return response()->json([
                'success' => false,
                'message' => 'Review period has expired (30 days after checkout).',
                'errors' => ['timing' => ['Review period expired']]
            ], 422);
        }

        $reviewData = [
            'tenant_id' => $request->user()->id,
            'apartment_id' => $booking->apartment_id,
            'booking_id' => $request->booking_id,
            'rating' => $request->rating,
            'comment' => $request->comment,
        ];

        // Add detailed ratings if provided
        if ($request->cleanliness_rating) $reviewData['cleanliness_rating'] = $request->cleanliness_rating;
        if ($request->location_rating) $reviewData['location_rating'] = $request->location_rating;
        if ($request->value_rating) $reviewData['value_rating'] = $request->value_rating;
        if ($request->communication_rating) $reviewData['communication_rating'] = $request->communication_rating;

        $review = Review::create($reviewData);

        // Notify apartment landlord
        \App\Models\Notification::create([
            'user_id' => $booking->apartment->landlord_id,
            'type' => 'new_review',
            'title' => 'New Review Received',
            'message' => "You received a {$request->rating}-star review for {$booking->apartment->title}",
            'data' => ['review_id' => $review->id, 'apartment_id' => $booking->apartment_id]
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Review submitted successfully',
            'data' => $review->load(['tenant', 'apartment'])
        ], 201);
    }

    public function apartmentReviews(Request $request, $apartmentId)
    {
        $query = Review::with(['tenant', 'booking'])
            ->where('apartment_id', $apartmentId);

        // Filter by rating
        if ($request->min_rating) {
            $query->where('rating', '>=', $request->min_rating);
        }

        // Sort options
        $sortBy = $request->get('sort_by', 'newest');
        switch ($sortBy) {
            case 'oldest':
                $query->orderBy('created_at', 'asc');
                break;
            case 'highest_rating':
                $query->orderBy('rating', 'desc');
                break;
            case 'lowest_rating':
                $query->orderBy('rating', 'asc');
                break;
            default:
                $query->orderBy('created_at', 'desc');
        }

        $reviews = $query->paginate($request->get('per_page', 10));

        // Calculate rating statistics
        $stats = Review::where('apartment_id', $apartmentId)
            ->selectRaw('AVG(rating) as average_rating, COUNT(*) as total_reviews')
            ->selectRaw('SUM(CASE WHEN rating = 5 THEN 1 ELSE 0 END) as five_star')
            ->selectRaw('SUM(CASE WHEN rating = 4 THEN 1 ELSE 0 END) as four_star')
            ->selectRaw('SUM(CASE WHEN rating = 3 THEN 1 ELSE 0 END) as three_star')
            ->selectRaw('SUM(CASE WHEN rating = 2 THEN 1 ELSE 0 END) as two_star')
            ->selectRaw('SUM(CASE WHEN rating = 1 THEN 1 ELSE 0 END) as one_star')
            ->first();

        return response()->json([
            'success' => true,
            'data' => [
                'reviews' => $reviews,
                'statistics' => $stats
            ],
            'message' => 'Reviews retrieved successfully'
        ]);
    }

    public function myReviews(Request $request)
    {
        $reviews = Review::with(['apartment.landlord', 'booking'])
            ->where('tenant_id', $request->user()->id)
            ->orderBy('created_at', 'desc')
            ->paginate($request->get('per_page', 10));

        return response()->json([
            'success' => true,
            'data' => $reviews,
            'message' => 'Your reviews retrieved successfully'
        ]);
    }

    public function canReview(Request $request, $bookingId)
    {
        $booking = Booking::where('id', $bookingId)
            ->where('tenant_id', $request->user()->id)
            ->where('status', 'completed')
            ->first();

        if (!$booking) {
            return response()->json([
                'success' => false,
                'can_review' => false,
                'reason' => 'Booking not found or not completed'
            ]);
        }

        $existingReview = Review::where('booking_id', $bookingId)
            ->where('tenant_id', $request->user()->id)
            ->exists();

        if ($existingReview) {
            return response()->json([
                'success' => true,
                'can_review' => false,
                'reason' => 'Already reviewed'
            ]);
        }

        $daysSinceCheckout = $booking->check_out->diffInDays(now());
        if ($daysSinceCheckout > 30) {
            return response()->json([
                'success' => true,
                'can_review' => false,
                'reason' => 'Review period expired'
            ]);
        }

        return response()->json([
            'success' => true,
            'can_review' => true,
            'days_remaining' => 30 - $daysSinceCheckout
        ]);
    }
}
