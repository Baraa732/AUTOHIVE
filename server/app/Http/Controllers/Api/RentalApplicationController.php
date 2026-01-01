<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\RentalApplication;
use App\Models\RentalApplicationModification;
use App\Models\Booking;
use App\Services\RentalApplicationService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class RentalApplicationController extends Controller
{
    public function store(Request $request)
    {
        $validated = $request->validate([
            'apartment_id' => 'required|exists:apartments,id',
            'check_in' => 'required|date|after_or_equal:today',
            'check_out' => 'required|date|after:check_in',
            'message' => 'nullable|string|max:1000',
        ]);

        $userId = $request->user()->id;
        $apartmentId = $validated['apartment_id'];

        \Log::info('Rental Application Submission Started', [
            'user_id' => $userId,
            'apartment_id' => $apartmentId,
        ]);

        $submissionCount = RentalApplication::where('user_id', $userId)
            ->where('apartment_id', $apartmentId)
            ->count();

        if ($submissionCount >= 3) {
            return response()->json([
                'success' => false,
                'message' => 'You have reached the maximum number of application submissions for this apartment (3 attempts).'
            ], 422);
        }

        $application = RentalApplication::create([
            'user_id' => $userId,
            'apartment_id' => $apartmentId,
            'check_in' => $validated['check_in'],
            'check_out' => $validated['check_out'],
            'message' => $validated['message'] ?? null,
            'submission_attempt' => $submissionCount,
            'status' => 'pending',
            'submitted_at' => now(),
        ]);

        \Log::info('Rental Application Created', [
            'application_id' => $application->id,
            'status' => $application->status,
        ]);

        $apartment = \App\Models\Apartment::find($apartmentId);
        
        if (!$apartment) {
            \Log::error('Apartment not found', ['apartment_id' => $apartmentId]);
            return response()->json([
                'success' => false,
                'message' => 'Apartment not found'
            ], 422);
        }

        if (!$apartment->user_id) {
            \Log::error('Apartment has no owner', ['apartment_id' => $apartmentId]);
            return response()->json([
                'success' => false,
                'message' => 'Apartment has no owner assigned'
            ], 422);
        }

        $landlordId = $apartment->user_id;

        \Log::info('Creating Notification', [
            'landlord_id' => $landlordId,
            'apartment_title' => $apartment->title,
        ]);

        try {
            \App\Models\Notification::create([
                'user_id' => $landlordId,
                'type' => 'rental_application_submitted',
                'title' => 'New Rental Application',
                'message' => "{$request->user()->first_name} {$request->user()->last_name} has submitted a rental application for {$apartment->title}",
                'data' => ['application_id' => $application->id, 'apartment_id' => $apartmentId]
            ]);
            
            \Log::info('Notification Created Successfully', ['landlord_id' => $landlordId]);
        } catch (\Exception $e) {
            \Log::error('Failed to create notification', [
                'error' => $e->getMessage(),
                'landlord_id' => $landlordId,
            ]);
        }

        return response()->json([
            'success' => true,
            'data' => $application->load('user', 'apartment'),
            'message' => 'Application submitted successfully'
        ], 201);
    }

    public function myApplications(Request $request)
    {
        $applications = RentalApplication::with(['apartment', 'apartment.user'])
            ->where('user_id', $request->user()->id)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $applications,
            'message' => 'Your rental applications retrieved successfully'
        ]);
    }

    public function show(Request $request, $id)
    {
        $application = RentalApplication::with(['user', 'apartment', 'apartment.user'])
            ->findOrFail($id);

        $userId = $request->user()->id;
        $isTenant = $application->user_id === $userId;
        $isLandlord = $application->apartment->user_id === $userId;

        if (!$isTenant && !$isLandlord) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 403);
        }

        return response()->json([
            'success' => true,
            'data' => $application,
            'message' => 'Application retrieved successfully'
        ]);
    }

    public function incoming(Request $request)
    {
        $userId = $request->user()->id;

        \Log::info('Fetching Incoming Applications', [
            'landlord_id' => $userId,
        ]);

        $applications = RentalApplication::with(['user', 'apartment'])
            ->whereHas('apartment', function ($query) use ($userId) {
                $query->where('user_id', $userId);
            })
            ->whereIn('status', ['pending', 'modified-pending', 'approved', 'modified-approved'])
            ->orderBy('created_at', 'desc')
            ->get();

        \Log::info('Incoming Applications Retrieved', [
            'landlord_id' => $userId,
            'count' => count($applications),
        ]);

        return response()->json([
            'success' => true,
            'data' => $applications,
            'message' => 'Incoming rental applications retrieved successfully'
        ]);
    }

    public function approve(Request $request, $id)
    {
        $application = RentalApplication::with(['apartment', 'user'])
            ->whereHas('apartment', function ($query) use ($request) {
                $query->where('user_id', $request->user()->id);
            })
            ->whereIn('status', [
                RentalApplication::STATUS_PENDING,
                RentalApplication::STATUS_MODIFIED_PENDING,
            ])
            ->findOrFail($id);

        DB::beginTransaction();
        try {
            $checkIn = $application->check_in;
            $checkOut = $application->check_out;

            $application->update([
                'status' => 'approved',
                'responded_at' => now(),
            ]);

            $booking = Booking::create([
                'user_id' => $application->user_id,
                'apartment_id' => $application->apartment_id,
                'check_in' => $checkIn,
                'check_out' => $checkOut,
                'total_price' => $this->calculateTotalPrice($application),
                'status' => 'confirmed',
            ]);

            $application->apartment->update(['is_available' => false]);

            $application->user->update([
                'rental_status' => 'active',
                'rental_end_date' => $checkOut,
            ]);

            DB::commit();

            \App\Models\Notification::create([
                'user_id' => $application->user_id,
                'type' => 'rental_application_approved',
                'title' => 'Application Approved',
                'message' => "Your rental application for {$application->apartment->title} has been approved!",
                'data' => ['application_id' => $application->id, 'booking_id' => $booking->id]
            ]);

            return response()->json([
                'success' => true,
                'data' => [
                    'application' => $application,
                    'booking' => $booking
                ],
                'message' => 'Application approved successfully'
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Failed to approve application: ' . $e->getMessage()
            ], 500);
        }
    }

    public function reject(Request $request, $id)
    {
        $validated = $request->validate([
            'rejected_reason' => 'nullable|string|max:500',
        ]);

        $application = RentalApplication::with(['apartment', 'user'])
            ->whereHas('apartment', function ($query) use ($request) {
                $query->where('user_id', $request->user()->id);
            })
            ->where('status', 'pending')
            ->findOrFail($id);

        $application->update([
            'status' => 'rejected',
            'rejected_reason' => $validated['rejected_reason'] ?? null,
            'responded_at' => now(),
        ]);

        \App\Models\Notification::create([
            'user_id' => $application->user_id,
            'type' => 'rental_application_rejected',
            'title' => 'Application Rejected',
            'message' => "Your rental application for {$application->apartment->title} was rejected" . 
                        (isset($validated['rejected_reason']) ? ". Reason: {$validated['rejected_reason']}" : ""),
            'data' => ['application_id' => $application->id]
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Application rejected successfully'
        ]);
    }

    public function modify(Request $request, $id)
    {
        $validated = $request->validate([
            'check_in' => 'required|date|after_or_equal:today',
            'check_out' => 'required|date|after:check_in',
            'message' => 'nullable|string|max:1000',
        ]);

        try {
            $application = RentalApplication::with(['apartment', 'user'])
                ->findOrFail($id);

            if ($application->user_id !== $request->user()->id) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized'
                ], 403);
            }

            $service = new RentalApplicationService();
            $modification = $service->submitModification(
                $id,
                $validated,
                $validated['message'] ?? null
            );

            return response()->json([
                'success' => true,
                'data' => [
                    'application' => $application->fresh()->load('user', 'apartment', 'modifications'),
                    'modification' => $modification
                ],
                'message' => 'Modification submitted successfully'
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 422);
        }
    }

    public function getModifications(Request $request, $id)
    {
        try {
            $application = RentalApplication::findOrFail($id);

            $userId = $request->user()->id;
            $isTenant = $application->user_id === $userId;
            $isOwner = $application->apartment->user_id === $userId;

            if (!$isTenant && !$isOwner) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized'
                ], 403);
            }

            $modifications = RentalApplicationModification::where('rental_application_id', $id)
                ->orderBy('submitted_at', 'desc')
                ->get()
                ->map(function ($mod) {
                    return [
                        'id' => $mod->id,
                        'status' => $mod->status,
                        'previous_values' => $mod->previous_values,
                        'new_values' => $mod->new_values,
                        'diff' => $mod->getDiff(),
                        'modification_reason' => $mod->modification_reason,
                        'rejection_reason' => $mod->rejection_reason,
                        'submitted_at' => $mod->submitted_at,
                        'responded_at' => $mod->responded_at,
                    ];
                });

            return response()->json([
                'success' => true,
                'data' => $modifications,
                'message' => 'Modification history retrieved successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 500);
        }
    }

    public function approveModification(Request $request, $id, $modificationId)
    {
        try {
            $application = RentalApplication::with(['apartment', 'user'])
                ->findOrFail($id);

            if ($application->apartment->user_id !== $request->user()->id) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized'
                ], 403);
            }

            $service = new RentalApplicationService();
            $result = $service->approveModification($id, $modificationId);

            return response()->json([
                'success' => true,
                'data' => $result,
                'message' => 'Modification approved successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 422);
        }
    }

    public function rejectModification(Request $request, $id, $modificationId)
    {
        $validated = $request->validate([
            'rejection_reason' => 'nullable|string|max:500',
        ]);

        try {
            $application = RentalApplication::with(['apartment', 'user'])
                ->findOrFail($id);

            if ($application->apartment->user_id !== $request->user()->id) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized'
                ], 403);
            }

            $service = new RentalApplicationService();
            $result = $service->rejectModification(
                $id,
                $modificationId,
                $validated['rejection_reason'] ?? null
            );

            return response()->json([
                'success' => true,
                'data' => $result,
                'message' => 'Modification rejected successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 422);
        }
    }

    private function calculateTotalPrice($application)
    {
        $nights = $application->check_out->diffInDays($application->check_in);
        $pricePerNight = $application->apartment->price_per_night;
        return $nights * $pricePerNight;
    }
}
