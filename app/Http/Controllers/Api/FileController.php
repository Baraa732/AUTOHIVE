<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class FileController extends Controller
{
    public function uploadProfileImage(Request $request)
    {
        $request->validate([
            'image' => 'required|image|mimes:jpeg,png,jpg|max:2048',
        ]);

        $user = $request->user();

        // Delete old image if exists
        if ($user->profile_image) {
            Storage::disk('public')->delete($user->profile_image);
        }

        $path = $request->file('image')->store('profiles', 'public');
        $user->update(['profile_image' => $path]);

        return response()->json([
            'message' => 'Profile image uploaded successfully',
            'image_url' => Storage::url($path),
            'path' => $path
        ]);
    }

    public function uploadApartmentImages(Request $request)
    {
        $request->validate([
            'images' => 'required|array|max:10',
            'images.*' => 'image|mimes:jpeg,png,jpg|max:2048',
        ]);

        $paths = [];
        $urls = [];

        foreach ($request->file('images') as $image) {
            $path = $image->store('apartments', 'public');
            $paths[] = $path;
            $urls[] = Storage::url($path);
        }

        return response()->json([
            'message' => 'Images uploaded successfully',
            'paths' => $paths,
            'urls' => $urls
        ]);
    }

    public function deleteImage(Request $request)
    {
        $request->validate([
            'path' => 'required|string',
        ]);

        if (Storage::disk('public')->exists($request->path)) {
            Storage::disk('public')->delete($request->path);
            return response()->json(['message' => 'Image deleted successfully']);
        }

        return response()->json(['message' => 'Image not found'], 404);
    }

    public function getImageUrl($path)
    {
        if (Storage::disk('public')->exists($path)) {
            return response()->json([
                'url' => Storage::url($path),
                'exists' => true
            ]);
        }

        return response()->json([
            'url' => null,
            'exists' => false
        ], 404);
    }
}
