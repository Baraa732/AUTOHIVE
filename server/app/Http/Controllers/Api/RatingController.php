<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Review;
use App\Models\Booking;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class RatingController extends Controller
{
   /**
    * Get all reviews for an apartment
    */
   public function getApartmentReviews($apartmentId)
   {
      $reviews = Review::with(['user:id,name,email', 'booking:id,check_in,check_out'])
         ->where('apartment_id', $apartmentId)
         ->orderBy('created_at', 'desc')
         ->paginate(10);

      return response()->json([
         'success' => true,
         'data' => $reviews,
      ]);
   }

   /**
    * Check if user can review a specific booking
    */
   public function canReviewBooking($bookingId)
   {
      $user = Auth::user();

      if (!Review::canReviewBooking($user->id, $bookingId)) {
         return response()->json([
            'success' => false,
            'message' => 'You cannot review this booking',
            'reason' => $this->getCannotReviewReason($bookingId, $user->id),
         ], 403);
      }

      return response()->json([
         'success' => true,
         'message' => 'You can review this booking',
      ]);
   }

   /**
    * Submit a review for a booking
    */
   public function submitReview(Request $request, $bookingId)
   {
      $user = Auth::user();

      // Validate user can review this booking
      if (!Review::canReviewBooking($user->id, $bookingId)) {
         return response()->json([
            'success' => false,
            'message' => 'You cannot review this booking',
            'reason' => $this->getCannotReviewReason($bookingId, $user->id),
         ], 403);
      }

      $validator = Validator::make($request->all(), [
         'rating' => 'required|integer|min:1|max:5',
         'comment' => 'nullable|string|max:1000',
      ]);

      if ($validator->fails()) {
         return response()->json([
            'success' => false,
            'message' => 'Validation failed',
            'errors' => $validator->errors(),
         ], 422);
      }

      $booking = Booking::findOrFail($bookingId);

      try {
         $review = Review::create([
            'user_id' => $user->id,
            'apartment_id' => $booking->apartment_id,
            'booking_id' => $bookingId,
            'rating' => $request->rating,
            'comment' => $request->comment,
         ]);

         return response()->json([
            'success' => true,
            'message' => 'Review submitted successfully',
            'data' => $review->load(['user:id,first_name,last_name', 'apartment:id,title']),
         ]);
      } catch (\Exception $e) {
         return response()->json([
            'success' => false,
            'message' => 'Failed to submit review',
            'error' => $e->getMessage(),
         ], 500);
      }
   }

   /**
    * Update an existing review
    */
   public function updateReview(Request $request, $reviewId)
   {
      $user = Auth::user();
      $review = Review::findOrFail($reviewId);

      // Check if user owns this review
      if ($review->user_id !== $user->id) {
         return response()->json([
            'success' => false,
            'message' => 'Unauthorized',
         ], 403);
      }

      $validator = Validator::make($request->all(), [
         'rating' => 'required|integer|min:1|max:5',
         'comment' => 'nullable|string|max:1000',
         'cleanliness_rating' => 'nullable|integer|min:1|max:5',
         'location_rating' => 'nullable|integer|min:1|max:5',
         'value_rating' => 'nullable|integer|min:1|max:5',
         'communication_rating' => 'nullable|integer|min:1|max:5',
      ]);

      if ($validator->fails()) {
         return response()->json([
            'success' => false,
            'message' => 'Validation failed',
            'errors' => $validator->errors(),
         ], 422);
      }

      try {
         $review->update([
            'rating' => $request->rating,
            'comment' => $request->comment,
            'cleanliness_rating' => $request->cleanliness_rating,
            'location_rating' => $request->location_rating,
            'value_rating' => $request->value_rating,
            'communication_rating' => $request->communication_rating,
         ]);

         return response()->json([
            'success' => true,
            'message' => 'Review updated successfully',
            'data' => $review->load(['user:id,name', 'apartment:id,title']),
         ]);
      } catch (\Exception $e) {
         return response()->json([
            'success' => false,
            'message' => 'Failed to update review',
            'error' => $e->getMessage(),
         ], 500);
      }
   }

   /**
    * Get user's reviews
    */
   public function getUserReviews()
   {
      $user = Auth::user();

      $reviews = Review::with(['apartment:id,title,images', 'booking:id,check_in,check_out'])
         ->where('user_id', $user->id)
         ->orderBy('created_at', 'desc')
         ->paginate(10);

      return response()->json([
         'success' => true,
         'data' => $reviews,
      ]);
   }

   /**
    * Get reviews for apartments owned by the user
    */
   public function getMyApartmentReviews()
   {
      $user = Auth::user();

      $reviews = Review::with(['user:id,name', 'booking:id,check_in,check_out'])
         ->whereHas('apartment', function ($query) use ($user) {
            $query->where('user_id', $user->id);
         })
         ->orderBy('created_at', 'desc')
         ->paginate(10);

      return response()->json([
         'success' => true,
         'data' => $reviews,
      ]);
   }

   /**
    * Get rating statistics for an apartment
    */
   public function getApartmentRatingStats($apartmentId)
   {
      $reviews = Review::where('apartment_id', $apartmentId);

      $totalReviews = $reviews->count();
      $averageRating = $reviews->avg('rating') ?: 0;

      $ratingDistribution = [
         5 => $reviews->where('rating', 5)->count(),
         4 => $reviews->where('rating', 4)->count(),
         3 => $reviews->where('rating', 3)->count(),
         2 => $reviews->where('rating', 2)->count(),
         1 => $reviews->where('rating', 1)->count(),
      ];

      $categoryAverages = [
         'cleanliness' => $reviews->avg('cleanliness_rating') ?: 0,
         'location' => $reviews->avg('location_rating') ?: 0,
         'value' => $reviews->avg('value_rating') ?: 0,
         'communication' => $reviews->avg('communication_rating') ?: 0,
      ];

      return response()->json([
         'success' => true,
         'data' => [
            'total_reviews' => $totalReviews,
            'average_rating' => round($averageRating, 2),
            'rating_percentage' => round(($averageRating / 5) * 100, 1),
            'rating_distribution' => $ratingDistribution,
            'category_averages' => $categoryAverages,
         ],
      ]);
   }

   /**
    * Delete a review (only the review owner can delete)
    */
   public function deleteReview($reviewId)
   {
      $user = Auth::user();
      $review = Review::findOrFail($reviewId);

      if ($review->user_id !== $user->id) {
         return response()->json([
            'success' => false,
            'message' => 'Unauthorized',
         ], 403);
      }

      try {
         $review->delete();

         return response()->json([
            'success' => true,
            'message' => 'Review deleted successfully',
         ]);
      } catch (\Exception $e) {
         return response()->json([
            'success' => false,
            'message' => 'Failed to delete review',
            'error' => $e->getMessage(),
         ], 500);
      }
   }

   /**
    * Get the reason why a user cannot review a booking
    */
   private function getCannotReviewReason($bookingId, $userId)
   {
      $booking = Booking::find($bookingId);

      if (!$booking) {
         return 'Booking not found';
      }

      if ($booking->user_id != $userId) {
         return 'You are not the owner of this booking';
      }

      if ($booking->status !== Booking::STATUS_COMPLETED) {
         return 'Booking must be completed to be reviewed';
      }

      if (Review::where('booking_id', $bookingId)->exists()) {
         return 'You have already reviewed this booking';
      }

      return 'Unknown reason';
   }
}
