<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;

class UserController extends Controller
{
    public function index(Request $request)
    {
        $query = User::with('wallet')
            ->where('role', '!=', 'admin')
            ->orderBy('created_at', 'desc');

        // Search functionality
        if ($request->search) {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('first_name', 'like', "%{$search}%")
                  ->orWhere('last_name', 'like', "%{$search}%")
                  ->orWhere('phone', 'like', "%{$search}%")
                  ->orWhere('id', 'like', "%{$search}%");
            });
        }

        // Filter by status
        if ($request->filter) {
            switch($request->filter) {
                case 'approved':
                    $query->where('is_approved', true);
                    break;
                case 'pending':
                    $query->where('is_approved', false);
                    break;
                case 'recent':
                    $query->where('created_at', '>=', now()->subDays(7));
                    break;
            }
        }

        $users = $query->paginate(24);
        
        $stats = [
            'total_users' => User::where('role', '!=', 'admin')->count(),
            'approved_users' => User::where('role', '!=', 'admin')->where('is_approved', true)->count(),
            'pending_users' => User::where('role', '!=', 'admin')->where('is_approved', false)->count(),
            'recent_users' => User::where('role', '!=', 'admin')->where('created_at', '>=', now()->subDays(7))->count(),
            'total_with_apartments' => User::whereHas('apartments')->count(),
            'total_with_bookings' => User::whereHas('bookings')->count()
        ];

        return view('admin.users-advanced', compact('users', 'stats'));
    }

    public function stats(Request $request)
    {
        $stats = [
            'total' => User::where('role', '!=', 'admin')->count(),
            'approved' => User::where('role', '!=', 'admin')->where('is_approved', true)->count(),
            'pending' => User::where('role', '!=', 'admin')->where('is_approved', false)->count(),
            'recent' => User::where('role', '!=', 'admin')->where('created_at', '>=', now()->subDays(7))->count(),
            'growth' => $this->calculateGrowth()
        ];

        return response()->json($stats);
    }

    private function calculateGrowth()
    {
        $currentWeek = User::where('role', '!=', 'admin')->where('created_at', '>=', now()->subDays(7))->count();
        $previousWeek = User::where('role', '!=', 'admin')->whereBetween('created_at', [now()->subDays(14), now()->subDays(7)])->count();
        
        if ($previousWeek == 0) return 0;
        
        return round((($currentWeek - $previousWeek) / $previousWeek) * 100, 1);
    }

    public function show($id)
    {
        $user = User::with(['wallet', 'apartments', 'bookings', 'reviews', 'favorites'])->findOrFail($id);
        return view('admin.users.show-advanced', compact('user'));
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
