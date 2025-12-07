<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Apartment;
use Illuminate\Http\Request;

class ApartmentApprovalController extends Controller
{
    public function getPendingApartments()
    {
        $apartments = Apartment::with(['landlord'])
            ->where('status', 'pending')
            ->orderBy('created_at', 'desc')
            ->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $apartments,
            'message' => 'Pending apartments retrieved successfully'
        ]);
    }

    public function getApartmentDetails($id)
    {
        $apartment = Apartment::with(['landlord', 'reviews', 'bookings'])
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $apartment,
            'message' => 'Apartment details retrieved successfully'
        ]);
    }

    public function approveApartment($id)
    {
        $apartment = Apartment::findOrFail($id);
        
        $apartment->update([
            'is_approved' => true,
            'status' => 'approved',
            'rejection_reason' => null
        ]);

        // Log activity
        \App\Models\Activity::log('apartment_approved', "Approved apartment: {$apartment->title}", [
            'apartment_id' => $apartment->id,
            'landlord_id' => $apartment->landlord_id
        ]);

        // Notify landlord
        $this->notifyLandlord($apartment, true);

        return response()->json([
            'success' => true,
            'message' => 'Apartment approved successfully',
            'data' => $apartment
        ]);
    }

    public function rejectApartment(Request $request, $id)
    {
        $request->validate([
            'reason' => 'required|string|max:500'
        ]);

        $apartment = Apartment::findOrFail($id);
        
        $apartment->update([
            'is_approved' => false,
            'status' => 'rejected',
            'rejection_reason' => $request->reason
        ]);

        // Log activity
        \App\Models\Activity::log('apartment_rejected', "Rejected apartment: {$apartment->title}", [
            'apartment_id' => $apartment->id,
            'landlord_id' => $apartment->landlord_id,
            'reason' => $request->reason
        ]);

        // Notify landlord
        $this->notifyLandlord($apartment, false, $request->reason);

        return response()->json([
            'success' => true,
            'message' => 'Apartment rejected successfully'
        ]);
    }

    private function notifyLandlord($apartment, $approved, $reason = null)
    {
        $status = $approved ? 'approved' : 'rejected';
        $message = $approved 
            ? "Your apartment '{$apartment->title}' has been approved and is now live!"
            : "Your apartment '{$apartment->title}' has been rejected. Reason: {$reason}";
            
        \App\Models\Notification::create([
            'user_id' => $apartment->landlord_id,
            'type' => 'apartment_status',
            'title' => 'Apartment Status Update',
            'message' => $message,
            'data' => [
                'status' => $status,
                'apartment_id' => $apartment->id,
                'reason' => $reason
            ]
        ]);
    }
}