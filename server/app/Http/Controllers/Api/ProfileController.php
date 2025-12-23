<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ProfileController extends Controller
{
    public function show(Request $request)
    {
        return response()->json($request->user());
    }

    public function update(Request $request)
    {
        $user = $request->user();

        $validated = $request->validate([
            'first_name' => 'string|max:50',
            'last_name' => 'string|max:50',
            'birth_date' => 'date|before:today',
        ]);

        $user->update($validated);

        return response()->json([
            'message' => 'Profile updated successfully',
            'user' => $user
        ]);
    }

    public function uploadProfileImage(Request $request)
    {
        $request->validate([
            'image' => 'required|image|mimes:jpeg,png,jpg|max:2048',
        ]);

        $user = $request->user();

        // Delete old image if exists
        if ($user->profile_image) {
            Storage::delete($user->profile_image);
        }

        $path = $request->file('image')->store('profile_images', 'public');
        $user->update(['profile_image' => $path]);

        return response()->json([
            'message' => 'Profile image uploaded successfully',
            'image_url' => asset('storage/' . $path)
        ]);
    }

    public function uploadIdImage(Request $request)
    {
        $request->validate([
            'image' => 'required|image|mimes:jpeg,png,jpg|max:2048',
        ]);

        $user = $request->user();

        // Delete old image if exists
        if ($user->id_image) {
            Storage::delete($user->id_image);
        }

        $path = $request->file('image')->store('id_images', 'public');
        $user->update(['id_image' => $path]);

        return response()->json([
            'message' => 'ID image uploaded successfully',
            'image_url' => asset('storage/' . $path)
        ]);
    }
}
