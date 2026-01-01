<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Favorite;
use Illuminate\Http\Request;

class FavoriteController extends Controller
{
    public function index(Request $request)
    {
        $favorites = Favorite::with('apartment')
            ->where('user_id', $request->user()->id)
            ->paginate(10);

        return response()->json([
            'success' => true,
            'data' => $favorites
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'apartment_id' => 'required|exists:apartments,id',
        ]);

        $favorite = Favorite::firstOrCreate([
            'user_id' => $request->user()->id,
            'apartment_id' => $request->apartment_id,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Added to favorites',
            'data' => $favorite
        ], 201);
    }

    public function destroy($id)
    {
        $favorite = Favorite::where('user_id', request()->user()->id)
            ->findOrFail($id);

        $favorite->delete();

        return response()->json([
            'success' => true,
            'message' => 'Removed from favorites'
        ]);
    }
}
