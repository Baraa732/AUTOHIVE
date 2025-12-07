<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ImageController extends Controller
{
    public function deleteProfileImage(Request $request)
    {
        $admin = auth()->user();
        
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