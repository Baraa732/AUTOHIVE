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
        $request->validate([
            'phone' => 'required|string|unique:users',
            'password' => 'required|string|min:6|confirmed',
            'role' => 'required|in:tenant,landlord',
            'first_name' => 'required|string|max:255',
            'last_name' => 'required|string|max:255',
            'birth_date' => 'required|date',
            'profile_image' => 'required|image|max:2048',
            'id_image' => 'required|image|max:2048',
        ]);

        // Upload images
        $profileImagePath = $request->file('profile_image')->store('profiles', 'public');
        $idImagePath = $request->file('id_image')->store('ids', 'public');

        // Check if user was previously rejected and can re-register
        $existingUser = User::withTrashed()->where('phone', $request->phone)->first();
        if ($existingUser && $existingUser->status === 'rejected') {
            // Allow re-registration by restoring and updating
            $existingUser->restore();
            $existingUser->update([
                'password' => Hash::make($request->password),
                'role' => $request->role,
                'first_name' => $request->first_name,
                'last_name' => $request->last_name,
                'birth_date' => $request->birth_date,
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
                'role' => $request->role,
                'first_name' => $request->first_name,
                'last_name' => $request->last_name,
                'birth_date' => $request->birth_date,
                'profile_image' => $profileImagePath,
                'id_image' => $idImagePath,
                'is_approved' => false,
                'status' => 'pending',
            ]);
        }

        // Send notification to admins only once
        $this->notifyAdminsOfNewRegistration($user);

        return response()->json([
            'success' => true,
            'message' => 'Registration successful. Awaiting admin approval.',
            'data' => ['user' => $user->makeHidden(['password'])]
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
            throw ValidationException::withMessages([
                'phone' => ['Invalid credentials.'],
            ]);
        }

        if (!$user->is_approved) {
            return response()->json([
                'success' => false,
                'message' => 'Account pending approval.',
                'errors' => ['approval' => ['Account not approved']]
            ], 403);
        }

        $token = $user->createToken('api-token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login successful',
            'data' => [
                'user' => $user,
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

        if ($request->hasFile('profile_image')) {
            $path = $request->file('profile_image')->store('profiles', 'public');
            $user->profile_image = $path;
        }

        $user->update($request->only(['first_name', 'last_name', 'birth_date']));

        return response()->json([
            'success' => true,
            'message' => 'Profile updated successfully',
            'data' => $user->fresh()
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
