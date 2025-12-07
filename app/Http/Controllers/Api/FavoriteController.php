<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Favorite;
use Illuminate\Http\Request;

class FavoriteController extends Controller
{
    public function index(Request $request)
    {
        $favorites = Favorite::with('apartment.landlord')
            ->where('tenant_id', $request->user()->id)
            ->paginate(10);

        return response()->json($favorites);
    }

    public function store(Request $request)
    {
        $request->validate([
            'apartment_id' => 'required|exists:apartments,id',
        ]);

        $favorite = Favorite::firstOrCreate([
            'tenant_id' => $request->user()->id,
            'apartment_id' => $request->apartment_id,
        ]);

        return response()->json($favorite, 201);
    }

    public function destroy($id)
    {
        $favorite = Favorite::where('tenant_id', request()->user()->id)
            ->findOrFail($id);

        $favorite->delete();

        return response()->json(['message' => 'Removed from favorites']);
    }
}
