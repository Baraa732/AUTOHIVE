<?php

// app/Http/Middleware/CheckApartmentApproved.php
namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use App\Models\Apartment;

class CheckApartmentApproved
{
    public function handle(Request $request, Closure $next)
    {
        // Check if we're trying to access an apartment
        if ($request->route('apartment') || $request->input('apartment_id')) {
            $apartmentId = $request->route('apartment') ?: $request->input('apartment_id');

            $apartment = Apartment::find($apartmentId);

            if ($apartment && (!$apartment->is_approved || $apartment->status !== 'approved')) {
                return response()->json([
                    'success' => false,
                    'message' => 'This apartment is not available yet.'
                ], 403);
            }
        }

        return $next($request);
    }
}
