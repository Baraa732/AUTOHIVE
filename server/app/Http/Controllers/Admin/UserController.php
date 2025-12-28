<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;

class UserController extends Controller
{
    public function index(Request $request)
    {
        $query = User::where('status', 'approved')
            ->orderBy('created_at', 'desc');

        // Search functionality
        if ($request->search) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('first_name', 'like', "%{$search}%")
                  ->orWhere('last_name', 'like', "%{$search}%")
                  ->orWhere('phone', 'like', "%{$search}%");
            });
        }

        $users = $query->paginate(15);
        $stats = [
            'total_users' => User::where('status', 'approved')->count(),
            'total_with_apartments' => User::whereHas('apartments')->count(),
            'total_with_bookings' => User::whereHas('bookings')->count(),
            'pending_approvals' => User::where('status', 'pending')->count()
        ];

        return view('admin.users.index', compact('users', 'stats'));
    }

    public function show($id)
    {
        $user = User::findOrFail($id);
        return view('admin.users.show', compact('user'));
    }

    public function destroy(Request $request, $id)
    {
        try {
            $user = User::findOrFail($id);
            $userName = "{$user->first_name} {$user->last_name}";
            
            // Log activity before deletion (optional, don't fail if it errors)
            try {
                \App\Models\Activity::log('user_deleted', "Deleted user {$userName}", ['user_id' => $user->id]);
            } catch (\Exception $e) {
                // Continue even if logging fails
            }
            
            $user->forceDelete();
            
            if ($request->expectsJson()) {
                return response()->json([
                    'success' => true,
                    'message' => 'User deleted successfully'
                ]);
            }
            
            return redirect()->route('admin.users')->with('success', 'User deleted successfully');
        } catch (\Exception $e) {
            if ($request->expectsJson()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Failed to delete user: ' . $e->getMessage()
                ], 500);
            }
            
            return redirect()->route('admin.users')->with('error', 'Failed to delete user');
        }
    }
}
