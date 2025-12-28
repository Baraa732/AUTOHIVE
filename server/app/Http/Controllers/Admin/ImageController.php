<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Auth;
use App\Models\User;

class ImageController extends Controller
{
    public function deleteProfileImage(Request $request)
    {
        /** @var User $admin */
        $admin = Auth::user();
        
        if ($admin->profile_image) {
            // Delete image from storage
            Storage::disk('public')->delete($admin->profile_image);
            
            // Remove from database
            $admin->update(['profile_image' => null]);
            
            return response()->json(['success' => true, 'message' => 'Profile image deleted successfully']);
        }
        
        return response()->json(['success' => false, 'message' => 'No profile image to delete']);
    }
}