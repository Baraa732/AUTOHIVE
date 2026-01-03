<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Apartment;
use App\Models\Booking;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ApartmentController extends Controller
{
    public function index(Request $request)
    {
        $query = Apartment::with(['landlord']);

        if ($request->has('status') && $request->status != 'all') {
            if (in_array($request->status, ['pending', 'approved', 'rejected'])) {
                $query->where('status', $request->status);
            }
        }

        $apartments = $query->orderBy('created_at', 'desc')->paginate(12);

        $stats = [
            'total' => Apartment::count(),
            'pending' => Apartment::where('status', 'pending')->count(),
            'approved' => Apartment::where('status', 'approved')->count(),
            'rejected' => Apartment::where('status', 'rejected')->count(),
        ];

        $currentStatus = $request->status ?? 'all';

        return view('admin.apartments.index-advanced', compact('apartments', 'stats', 'currentStatus'));
    }

    public function bookingDetails($id)
    {
        try {
            $booking = Booking::with(['tenant', 'apartment'])->findOrFail($id);
            return response()->json($booking);
        } catch (\Exception $e) {
            return response()->json(['error' => 'Booking not found'], 404);
        }
    }

    // In ApartmentController.php - show method
    public function show($id)
    {
        $apartment = Apartment::with([
            'landlord',
            'reviews',
            'bookings' => function ($query) {
                $query->with('tenant')
                    ->orderBy('check_in', 'desc')
                    ->take(10); // Limit to recent bookings
            },
            'bookings.tenant' // Eager load tenant for each booking
        ])->findOrFail($id);

        // Calculate booking stats
        $bookingStats = [
            'total' => $apartment->bookings()->count(),
            'pending' => $apartment->bookings()->where('status', 'pending')->count(),
            'confirmed' => $apartment->bookings()->where('status', 'confirmed')->count(),
            'completed' => $apartment->bookings()->where('status', 'completed')->count(),
            'revenue' => $apartment->bookings()->where('status', 'completed')->sum('total_price')
        ];

        return view('admin.apartments.show', compact('apartment', 'bookingStats'));
    }

    // ADD THESE TWO METHODS:

    public function approve($id)
    {
        try {
            $apartment = Apartment::findOrFail($id);

            $apartment->update([
                'is_approved' => true,
                'status' => 'approved',
                'rejection_reason' => null,
                'approved_at' => now(),
                'approved_by' => Auth::id()
            ]);

            // Log activity
            \App\Models\Activity::log(
                'apartment_approved',
                "Approved apartment: {$apartment->title}",
                ['apartment_id' => $apartment->id, 'admin_id' => Auth::id()]
            );

            // Send notification to landlord
            \App\Models\Notification::create([
                'user_id' => $apartment->landlord_id,
                'type' => 'apartment_status',
                'title' => 'Apartment Approved',
                'message' => "Your apartment '{$apartment->title}' has been approved and is now live!",
                'data' => [
                    'status' => 'approved',
                    'apartment_id' => $apartment->id
                ]
            ]);

            return redirect()->back()->with('success', 'Apartment approved successfully!');
        } catch (\Exception $e) {
            return redirect()->back()->with('error', 'Failed to approve apartment: ' . $e->getMessage());
        }
    }

    public function reject(Request $request, $id)
    {
        try {
            $request->validate([
                'reason' => 'required|string|max:500'
            ]);

            $apartment = Apartment::findOrFail($id);

            $apartment->update([
                'is_approved' => false,
                'status' => 'rejected',
                'rejection_reason' => $request->reason,
                'rejected_at' => now(),
                'rejected_by' => Auth::id()
            ]);

            // Log activity
            \App\Models\Activity::log(
                'apartment_rejected',
                "Rejected apartment: {$apartment->title}",
                ['apartment_id' => $apartment->id, 'admin_id' => Auth::id(), 'reason' => $request->reason]
            );

            // Send notification to landlord
            \App\Models\Notification::create([
                'user_id' => $apartment->landlord_id,
                'type' => 'apartment_status',
                'title' => 'Apartment Rejected',
                'message' => "Your apartment '{$apartment->title}' has been rejected. Reason: {$request->reason}",
                'data' => [
                    'status' => 'rejected',
                    'apartment_id' => $apartment->id,
                    'reason' => $request->reason
                ]
            ]);

            return redirect()->back()->with('success', 'Apartment rejected successfully!');
        } catch (\Exception $e) {
            return redirect()->back()->with('error', 'Failed to reject apartment: ' . $e->getMessage());
        }
    }

    public function edit($id)
    {
        $apartment = Apartment::with('landlord')->findOrFail($id);
        return view('admin.apartments.edit', compact('apartment'));
    }

    public function update(Request $request, $id)
    {
        try {
            $apartment = Apartment::findOrFail($id);
            
            $validated = $request->validate([
                'title' => 'required|string|max:255',
                'description' => 'nullable|string',
                'price_per_night' => 'required|numeric|min:0',
                'bedrooms' => 'required|integer|min:0',
                'bathrooms' => 'required|integer|min:0',
                'area' => 'required|numeric|min:0',
                'max_guests' => 'required|integer|min:1',
                'address' => 'required|string',
                'city' => 'required|string',
                'governorate' => 'required|string',
                'is_available' => 'boolean'
            ]);

            $apartment->update($validated);

            \App\Models\Activity::log(
                'apartment_updated',
                "Updated apartment: {$apartment->title}",
                ['apartment_id' => $apartment->id]
            );

            return redirect()->route('admin.apartments.show', $apartment->id)
                ->with('success', 'Apartment updated successfully');
        } catch (\Exception $e) {
            return back()->withErrors(['error' => 'Failed to update apartment: ' . $e->getMessage()])
                ->withInput();
        }
    }
}
