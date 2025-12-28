<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        // Check if user exists and is rejected (soft deleted)
        $existingUser = User::withTrashed()->where('phone', $request->phone)->first();
        
        // Handle existing users with different statuses
        if ($existingUser) {
            if ($existingUser->status === 'approved') {
                return response()->json([
                    'success' => false,
                    'message' => 'This phone number is already registered. Please login instead.',
                    'errors' => ['phone' => ['Phone number already exists']]
                ], 422);
            }
            
            if ($existingUser->status === 'pending') {
                return response()->json([
                    'success' => false,
                    'message' => 'This phone number is already registered and pending approval. Please wait for admin approval.',
                    'errors' => ['phone' => ['Account pending approval']]
                ], 422);
            }
        }
        
        $request->validate([
            'phone' => 'required|string',
            'password' => 'required|string|min:6|confirmed',
            'first_name' => 'required|string|max:255',
            'last_name' => 'required|string|max:255',
            'birth_date' => 'required|date',
            'city' => 'required|string|max:255',
            'governorate' => 'required|string|max:255',
            'profile_image' => 'required|file|mimes:jpeg,jpg,png,gif|max:2048',
            'id_image' => 'required|file|mimes:jpeg,jpg,png,gif|max:2048',
        ]);

        // Handle file uploads with error checking
        if (!$request->hasFile('profile_image') || !$request->file('profile_image')->isValid()) {
            return response()->json([
                'success' => false,
                'message' => 'Profile image upload failed',
                'errors' => ['profile_image' => ['Invalid or missing profile image file']]
            ], 422);
        }

        if (!$request->hasFile('id_image') || !$request->file('id_image')->isValid()) {
            return response()->json([
                'success' => false,
                'message' => 'ID image upload failed',
                'errors' => ['id_image' => ['Invalid or missing ID image file']]
            ], 422);
        }

        $profileImagePath = $request->file('profile_image')->store('profiles', 'public');
        $idImagePath = $request->file('id_image')->store('ids', 'public');

        // Handle re-registration for rejected users
        if ($existingUser && $existingUser->status === 'rejected') {
            // Allow re-registration by restoring and updating
            $existingUser->restore();
            $existingUser->update([
                'password' => Hash::make($request->password),
                'role' => 'user',
                'first_name' => $request->first_name,
                'last_name' => $request->last_name,
                'birth_date' => $request->birth_date,
                'city' => $request->city,
                'governorate' => $request->governorate,
                'profile_image' => $profileImagePath,
                'id_image' => $idImagePath,
                'is_approved' => false,
                'status' => 'pending',
            ]);
            $user = $existingUser;
        } else {
            $user = User::create([
                'phone' => $request->phone,
                'password' => Hash::make($request->password),
                'first_name' => $request->first_name,
                'last_name' => $request->last_name,
                'birth_date' => $request->birth_date,
                'city' => $request->city,
                'governorate' => $request->governorate,
                'profile_image' => $profileImagePath,
                'id_image' => $idImagePath,
                'is_approved' => false,
                'status' => 'pending',
            ]);
        }

        // Send notification to admins only once
        \Log::info('Sending admin notification for new user registration', [
            'user_id' => $user->id,
            'user_name' => $user->first_name . ' ' . $user->last_name,
            'user_type' => 'user',
            'user_status' => $user->status
        ]);
        
        $this->notifyAdminsOfNewRegistration($user);

        return response()->json([
            'success' => true,
            'message' => 'Registration successful. Awaiting admin approval.',
            'data' => [
                'user' => $user->makeHidden(['password']),
                'profile_image_url' => $user->profile_image_url,
                'id_image_url' => $user->id_image_url
            ]
        ], 201);
    }

    public function login(Request $request)
    {
        $request->validate([
            'phone' => 'required|string',
            'password' => 'required|string',
        ]);

        $user = User::where('phone', $request->phone)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid phone number or password.',
                'errors' => ['credentials' => ['Invalid credentials']]
            ], 401);
        }

        if ($user->status === 'pending') {
            return response()->json([
                'success' => false,
                'message' => 'Your account is pending admin approval. Please wait for approval.',
                'errors' => ['status' => ['Account pending approval']]
            ], 403);
        }
        
        if ($user->status === 'rejected') {
            return response()->json([
                'success' => false,
                'message' => 'Your account was rejected. You can register again with updated information.',
                'errors' => ['status' => ['Account rejected']]
            ], 403);
        }
        
        if (!$user->is_approved) {
            return response()->json([
                'success' => false,
                'message' => 'Your account is not approved yet. Please wait for admin approval.',
                'errors' => ['approval' => ['Account not approved']]
            ], 403);
        }

        $token = $user->createToken('api-token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login successful',
            'data' => [
                'user' => $user->makeHidden(['password']),
                'token' => $token
            ]
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logged out successfully'
        ]);
    }

    public function profile(Request $request)
    {
        return response()->json([
            'success' => true,
            'data' => $request->user(),
            'message' => 'Profile retrieved successfully'
        ]);
    }

    public function updateProfile(Request $request)
    {
        $user = $request->user();
        
        $request->validate([
            'first_name' => 'string|max:255',
            'last_name' => 'string|max:255',
            'birth_date' => 'date',
            'profile_image' => 'image|max:2048',
        ]);

        $updateData = $request->only(['first_name', 'last_name', 'birth_date']);
        
        if ($request->hasFile('profile_image')) {
            $path = $request->file('profile_image')->store('profiles', 'public');
            $updateData['profile_image'] = $path;
        }

        $user->update($updateData);

        return response()->json([
            'success' => true,
            'message' => 'Profile updated successfully',
            'data' => [
                'user' => $user->fresh()
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

    public function deleteAccount(Request $request)
    {
        $request->validate([
            'password' => 'required|string',
        ]);

        $user = $request->user();

        if (!Hash::check($request->password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Password is incorrect',
                'errors' => ['password' => ['Incorrect password']]
            ], 422);
        }

        $user->tokens()->delete();
        $user->delete();

        return response()->json([
            'success' => true,
            'message' => 'Account deleted successfully'
        ]);
    }

    public function uploadId(Request $request)
    {
        $request->validate([
            'id_image' => 'required|image|max:2048',
        ]);

        $user = $request->user();
        $path = $request->file('id_image')->store('ids', 'public');
        $user->update(['id_image' => $path]);

        return response()->json([
            'success' => true,
            'message' => 'ID uploaded successfully'
        ]);
    }

    private function notifyAdminsOfNewRegistration($user)
    {
        \App\Services\NotificationService::sendUserApprovalNotification($user);
    }

    private function notifyUserOfApprovalStatus($user, $approved)
    {
        $status = $approved ? 'approved' : 'rejected';
        $message = $approved 
            ? 'Your account has been approved. You can now login and use the app.' 
            : 'Your account registration has been rejected. Please contact support for more information.';
            
        $notification = \App\Models\Notification::create([
            'user_id' => $user->id,
            'type' => 'account_status',
            'title' => 'Account Status Update',
            'message' => $message,
            'data' => ['status' => $status]
        ]);
        
        // Broadcast to user if they're online
        broadcast(new \App\Events\UserNotification($user->id, $notification));
    }
}
