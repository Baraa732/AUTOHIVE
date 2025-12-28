<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Auth;
use App\Models\User;

class ProfileController extends Controller
{
    public function index()
    {
        $admin = Auth::user();
        return view('admin.profile', compact('admin'));
    }

    public function update(Request $request)
    {
        /** @var User $admin */
        $admin = Auth::user();
        
        $updateData = [];
        
        // Validate and update only provided fields
        if ($request->filled('first_name')) {
            $request->validate(['first_name' => 'string|min:2|max:50']);
            $updateData['first_name'] = trim($request->first_name);
        }
        
        if ($request->filled('last_name')) {
            $request->validate(['last_name' => 'string|min:2|max:50']);
            $updateData['last_name'] = trim($request->last_name);
        }
        
        if ($request->filled('phone')) {
            // Skip validation if phone is same as current
            if ($request->phone !== $admin->phone) {
                $request->validate(['phone' => 'string|regex:/^[0-9]{10}$/|unique:users,phone']);
            } else {
                $request->validate(['phone' => 'string|regex:/^[0-9]{10}$/']);
            }
            $updateData['phone'] = $request->phone;
        }
        
        if ($request->filled(['birth_day', 'birth_month', 'birth_year'])) {
            $request->validate([
                'birth_day' => 'integer|min:1|max:31',
                'birth_month' => 'integer|min:1|max:12', 
                'birth_year' => 'integer|min:' . (date('Y') - 80) . '|max:' . (date('Y') - 18)
            ]);
            
            $birthDate = $request->birth_year . '-' . str_pad($request->birth_month, 2, '0', STR_PAD_LEFT) . '-' . str_pad($request->birth_day, 2, '0', STR_PAD_LEFT);
            
            // Validate the constructed date
            if (checkdate($request->birth_month, $request->birth_day, $request->birth_year) && strtotime($birthDate) < time()) {
                $updateData['birth_date'] = $birthDate;
            } else {
                return back()->withErrors(['birth_date' => 'Invalid birth date']);
            }
        }
        
        // Handle profile image upload
        if ($request->hasFile('profile_image')) {
            $request->validate([
                'profile_image' => 'image|mimes:jpeg,png,jpg,gif|max:2048'
            ]);
            
            // Delete old image if exists
            if ($admin->profile_image) {
                Storage::disk('public')->delete($admin->profile_image);
            }
            
            // Store new image
            $imagePath = $request->file('profile_image')->store('profile-images', 'public');
            $updateData['profile_image'] = $imagePath;
        }
        
        // Update basic info if any fields provided
        if (!empty($updateData)) {
            $admin->update($updateData);
        }

        // Update password if provided
        if ($request->filled('current_password') && $request->filled('new_password')) {
            $request->validate([
                'current_password' => 'string',
                'new_password' => 'string|min:6|confirmed',
            ]);
            
            if (!Hash::check($request->current_password, $admin->password)) {
                return back()->withErrors(['current_password' => 'Current password is incorrect']);
            }
            
            $admin->update(['password' => Hash::make($request->new_password)]);
        }

        return back()->with('success', 'Profile updated successfully');
    }
}