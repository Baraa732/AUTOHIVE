<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Hash;

class ProfileController extends Controller
{
    public function show(Request $request)
    {
        $user = $request->user()->fresh();
        return response()->json([
            'success' => true,
            'data' => [
                'user' => $user,
                'profile_image_url' => $user->profile_image_url,
                'id_image_url' => $user->id_image_url
            ]
        ]);
    }

    public function update(Request $request)
    {
        $user = $request->user();

        $validated = $request->validate([
            'first_name' => 'string|max:255',
            'last_name' => 'string|max:255',
            'birth_date' => 'date|before:today',
            'city' => 'string|max:255',
            'governorate' => 'string|max:255',
        ]);

        $user->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Profile updated successfully',
            'data' => [
                'user' => $user->fresh()
            ]
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
            Storage::disk('public')->delete($user->profile_image);
        }

        $path = $request->file('image')->store('profile_images', 'public');
        $user->update(['profile_image' => $path]);

        return response()->json([
            'success' => true,
            'message' => 'Profile image uploaded successfully',
            'data' => [
                'image_url' => $user->profile_image_url
            ]
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
            Storage::disk('public')->delete($user->id_image);
        }

        $path = $request->file('image')->store('id_images', 'public');
        $user->update(['id_image' => $path]);

        return response()->json([
            'success' => true,
            'message' => 'ID image uploaded successfully',
            'data' => [
                'image_url' => $user->id_image_url
            ]
        ]);
    }

    public function changePassword(Request $request)
    {
        $request->validate([
            'current_password' => 'required|string',
            'new_password' => 'required|string|min:6|confirmed',
        ]);

        $user = $request->user();

        if (!Hash::check($request->current_password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Current password is incorrect',
                'errors' => ['current_password' => ['Incorrect password']]
            ], 422);
        }

        $user->update([
            'password' => Hash::make($request->new_password)
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Password changed successfully'
        ]);
    }

    public function deleteProfileImage(Request $request)
    {
        $user = $request->user();

        if ($user->profile_image) {
            Storage::disk('public')->delete($user->profile_image);
            $user->update(['profile_image' => null]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Profile image deleted successfully'
        ]);
    }

    public function deleteIdImage(Request $request)
    {
        $user = $request->user();

        if ($user->id_image) {
            Storage::disk('public')->delete($user->id_image);
            $user->update(['id_image' => null]);
        }

        return response()->json([
            'success' => true,
            'message' => 'ID image deleted successfully'
        ]);
    }
}
