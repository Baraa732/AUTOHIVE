<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Services\AdminService;
use App\Models\AdminActivity;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AdminController extends Controller
{
    protected $adminService;

    public function __construct(AdminService $adminService)
    {
        $this->adminService = $adminService;
    }

    public function login(Request $request)
    {
        $request->validate([
            'phone' => 'required|string',
            'password' => 'required|string',
        ]);

        $credentials = $request->only('phone', 'password');
        
        if (Auth::attempt($credentials)) {
            $user = Auth::user();
            if ($user->role === 'admin') {
                \App\Models\Activity::log('login', 'Admin logged in');
                $request->session()->regenerate();
                return redirect()->route('admin.dashboard');
            } else {
                Auth::logout();
                return back()->withErrors(['phone' => 'Admin access required']);
            }
        }

        return back()->withErrors(['phone' => 'Invalid credentials'])->withInput($request->except('password'));
    }

    public function logout(Request $request)
    {
        \App\Models\Activity::log('logout', 'Admin logged out');
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();
        return redirect()->route('admin.login');
    }

    public function users(Request $request)
    {
        try {
            $filters = $request->only(['status', 'search']);
            $users = $this->adminService->getUsers($filters);
            return view('admin.users', compact('users'));
        } catch (\Exception $e) {
            return back()->withErrors(['error' => 'Failed to load users: ' . $e->getMessage()]);
        }
    }

    public function approveUser($id)
    {
        try {
            $this->adminService->approveUser($id);
            return back()->with('success', 'User approved successfully');
        } catch (\Exception $e) {
            return back()->withErrors(['error' => 'Failed to approve user: ' . $e->getMessage()]);
        }
    }

    public function rejectUser($id)
    {
        try {
            $this->adminService->rejectUser($id);
            return back()->with('success', 'User rejected successfully');
        } catch (\Exception $e) {
            return back()->withErrors(['error' => 'Failed to reject user: ' . $e->getMessage()]);
        }
    }

    public function apartments(Request $request)
    {
        try {
            $filters = $request->only(['status', 'search']);
            $apartments = $this->adminService->getApartments($filters);
            return view('admin.apartments', compact('apartments'));
        } catch (\Exception $e) {
            return back()->withErrors(['error' => 'Failed to load apartments: ' . $e->getMessage()]);
        }
    }

    public function approveApartment($id)
    {
        try {
            $this->adminService->approveApartment($id);
            return back()->with('success', 'Apartment approved successfully');
        } catch (\Exception $e) {
            return back()->withErrors(['error' => 'Failed to approve apartment: ' . $e->getMessage()]);
        }
    }

    public function rejectApartment(Request $request, $id)
    {
        try {
            $reason = $request->input('reason', 'No reason provided');
            $this->adminService->rejectApartment($id, $reason);
            return back()->with('success', 'Apartment rejected successfully');
        } catch (\Exception $e) {
            return back()->withErrors(['error' => 'Failed to reject apartment: ' . $e->getMessage()]);
        }
    }

    public function deleteApartment($id)
    {
        try {
            $this->adminService->deleteApartment($id);
            return back()->with('success', 'Apartment deleted successfully');
        } catch (\Exception $e) {
            return back()->withErrors(['error' => $e->getMessage()]);
        }
    }

    public function bookings(Request $request)
    {
        try {
            $filters = $request->only(['status', 'search']);
            $bookings = $this->adminService->getBookings($filters);
            return view('admin.bookings', compact('bookings'));
        } catch (\Exception $e) {
            return back()->withErrors(['error' => 'Failed to load bookings: ' . $e->getMessage()]);
        }
    }

    public function approveBooking($id)
    {
        try {
            $this->adminService->approveBooking($id);
            return back()->with('success', 'Booking approved successfully');
        } catch (\Exception $e) {
            return back()->withErrors(['error' => 'Failed to approve booking: ' . $e->getMessage()]);
        }
    }

    public function rejectBooking($id)
    {
        try {
            $this->adminService->rejectBooking($id);
            return back()->with('success', 'Booking rejected successfully');
        } catch (\Exception $e) {
            return back()->withErrors(['error' => 'Failed to reject booking: ' . $e->getMessage()]);
        }
    }

    public function getBookingDetails($id)
    {
        try {
            $booking = \App\Models\Booking::with(['user', 'apartment'])->findOrFail($id);
            return response()->json($booking);
        } catch (\Exception $e) {
            return response()->json(['error' => 'Booking not found'], 404);
        }
    }
}
