<?php

namespace App\Services;

use App\Models\RentalApplication;
use App\Models\RentalApplicationModification;
use App\Models\Booking;
use App\Models\Notification;
use Illuminate\Support\Facades\DB;
use Exception;

class RentalApplicationService
{
    public function submitModification($applicationId, array $newData, ?string $reason = null)
    {
        DB::beginTransaction();
        try {
            $application = RentalApplication::findOrFail($applicationId);

            if (!$application->canBeModified()) {
                throw new Exception('This application cannot be modified. Status: ' . $application->status);
            }

            $previousValues = [
                'check_in' => $application->check_in->format('Y-m-d'),
                'check_out' => $application->check_out->format('Y-m-d'),
                'message' => $application->message,
            ];

            $newValues = [
                'check_in' => $newData['check_in'],
                'check_out' => $newData['check_out'],
                'message' => $newData['message'] ?? $application->message,
            ];

            $modification = RentalApplicationModification::create([
                'rental_application_id' => $applicationId,
                'status' => RentalApplicationModification::STATUS_PENDING,
                'previous_values' => $previousValues,
                'new_values' => $newValues,
                'modification_reason' => $reason,
                'submitted_at' => now(),
            ]);

            $application->update([
                'status' => RentalApplication::STATUS_MODIFIED_PENDING,
                'previous_status' => $application->status,
                'previous_data' => $previousValues,
                'current_data' => $newValues,
                'modification_reason' => $reason,
                'modification_submitted_at' => now(),
            ]);

            $landlordId = $application->apartment->user_id;

            Notification::create([
                'user_id' => $landlordId,
                'type' => 'rental_application_modified',
                'title' => 'Application Modified',
                'message' => "{$application->user->first_name} {$application->user->last_name} has modified their rental application for {$application->apartment->title}",
                'data' => ['application_id' => $applicationId, 'modification_id' => $modification->id],
            ]);

            DB::commit();

            return $modification;
        } catch (Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    public function getModificationDiff($applicationId, $modificationId)
    {
        $application = RentalApplication::findOrFail($applicationId);
        $modification = RentalApplicationModification::where('id', $modificationId)
            ->where('rental_application_id', $applicationId)
            ->firstOrFail();

        return [
            'modification' => $modification,
            'diff' => $modification->getDiff(),
        ];
    }

    public function approveModification($applicationId, $modificationId)
    {
        DB::beginTransaction();
        try {
            $application = RentalApplication::findOrFail($applicationId);
            $modification = RentalApplicationModification::where('id', $modificationId)
                ->where('rental_application_id', $applicationId)
                ->firstOrFail();

            if ($modification->status !== RentalApplicationModification::STATUS_PENDING) {
                throw new Exception('This modification has already been reviewed.');
            }

            $newCheckIn = $modification->new_values['check_in'];
            $newCheckOut = $modification->new_values['check_out'];
            $newMessage = $modification->new_values['message'];

            $application->update([
                'check_in' => $newCheckIn,
                'check_out' => $newCheckOut,
                'message' => $newMessage,
                'status' => RentalApplication::STATUS_APPROVED,
                'responded_at' => now(),
            ]);

            $modification->update([
                'status' => RentalApplicationModification::STATUS_APPROVED,
                'responded_at' => now(),
            ]);

            $booking = Booking::updateOrCreate(
                [
                    'user_id' => $application->user_id,
                    'apartment_id' => $application->apartment_id,
                ],
                [
                    'check_in' => $newCheckIn,
                    'check_out' => $newCheckOut,
                    'total_price' => $this->calculateTotalPrice($application, $newCheckIn, $newCheckOut),
                    'status' => 'confirmed',
                ]
            );

            $application->apartment->update(['is_available' => false]);

            $application->user->update([
                'rental_status' => 'active',
                'rental_end_date' => $newCheckOut,
            ]);

            Notification::create([
                'user_id' => $application->user_id,
                'type' => 'rental_application_modification_approved',
                'title' => 'Modification Approved',
                'message' => "Your modification for {$application->apartment->title} has been approved!",
                'data' => ['application_id' => $applicationId, 'booking_id' => $booking->id],
            ]);

            DB::commit();

            return [
                'application' => $application->fresh(),
                'booking' => $booking,
                'modification' => $modification->fresh(),
            ];
        } catch (Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    public function rejectModification($applicationId, $modificationId, ?string $reason = null)
    {
        DB::beginTransaction();
        try {
            $application = RentalApplication::findOrFail($applicationId);
            $modification = RentalApplicationModification::where('id', $modificationId)
                ->where('rental_application_id', $applicationId)
                ->firstOrFail();

            if ($modification->status !== RentalApplicationModification::STATUS_PENDING) {
                throw new Exception('This modification has already been reviewed.');
            }

            $previousStatus = $application->previous_status ?? RentalApplication::STATUS_PENDING;

            $application->update([
                'status' => $previousStatus,
                'previous_status' => null,
                'previous_data' => null,
                'current_data' => null,
                'modification_reason' => null,
                'modification_submitted_at' => null,
                'responded_at' => now(),
            ]);

            $modification->update([
                'status' => RentalApplicationModification::STATUS_REJECTED,
                'rejection_reason' => $reason,
                'responded_at' => now(),
            ]);

            Notification::create([
                'user_id' => $application->user_id,
                'type' => 'rental_application_modification_rejected',
                'title' => 'Modification Rejected',
                'message' => "Your modification for {$application->apartment->title} was rejected." . 
                            (isset($reason) ? " Reason: {$reason}" : ""),
                'data' => ['application_id' => $applicationId],
            ]);

            DB::commit();

            return $application->fresh();
        } catch (Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    private function calculateTotalPrice($application, $checkIn, $checkOut)
    {
        $startDate = is_string($checkIn) ? \Carbon\Carbon::parse($checkIn) : $checkIn;
        $endDate = is_string($checkOut) ? \Carbon\Carbon::parse($checkOut) : $checkOut;
        
        $nights = $endDate->diffInDays($startDate);
        $pricePerNight = $application->apartment->price_per_night;
        
        return $nights * $pricePerNight;
    }
}
