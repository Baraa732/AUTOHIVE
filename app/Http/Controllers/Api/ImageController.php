<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ImageController extends Controller
{
    public function uploadApartmentImages(Request $request)
    {
        $request->validate([
            'images' => 'required|array|min:1|max:10',
            'images.*' => 'image|mimes:jpeg,png,jpg,webp|max:5120' // 5MB max
        ]);

        $uploadedImages = [];
        
        foreach ($request->file('images') as $image) {
            $path = $image->store('apartments', 'public');
            $uploadedImages[] = [
                'path' => $path,
                'url' => Storage::url($path),
                'size' => $image->getSize(),
                'original_name' => $image->getClientOriginalName()
            ];
        }

        return response()->json([
            'success' => true,
            'message' => 'Images uploaded successfully',
            'data' => [
                'images' => $uploadedImages,
                'paths' => array_column($uploadedImages, 'path')
            ]
        ]);
    }

    public function getImageUrl($path)
    {
        if (!Storage::disk('public')->exists($path)) {
            return response()->json([
                'success' => false,
                'message' => 'Image not found'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'url' => Storage::url($path),
                'full_url' => asset('storage/' . $path)
            ]
        ]);
    }

    public function deleteImage(Request $request)
    {
        $request->validate([
            'path' => 'required|string'
        ]);

        if (Storage::disk('public')->exists($request->path)) {
            Storage::disk('public')->delete($request->path);
            
            return response()->json([
                'success' => true,
                'message' => 'Image deleted successfully'
            ]);
        }

        return response()->json([
            'success' => false,
            'message' => 'Image not found'
        ], 404);
    }
}