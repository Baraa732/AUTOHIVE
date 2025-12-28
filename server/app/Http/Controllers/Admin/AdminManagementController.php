<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\CreateAdminRequest;
use App\Services\AdminService;
use App\Models\User;
use App\Models\AdminActivity;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Auth;

class AdminManagementController extends Controller
{
    protected $adminService;

    public function __construct(AdminService $adminService)
    {
        $this->adminService = $adminService;
    }

    public function index()
    {
        try {
            $admins = User::where('role', 'admin')->latest()->paginate(10);
            return view('admin.admins', compact('admins'));
        } catch (\Exception $e) {
            return back()->withErrors(['error' => 'Failed to load admins: ' . $e->getMessage()]);
        }
    }

    public function create()
    {
        return view('admin.create-admin');
    }

    public function store(CreateAdminRequest $request)
    {
        try {
            DB::beginTransaction();
            
            // Construct birth_date from separate fields
            $birthDate = sprintf('%04d-%02d-%02d', $request->birth_year, $request->birth_month, $request->birth_day);

            $admin = User::create([
                'phone' => $request->phone,
                'password' => Hash::make($request->password),
                'role' => 'admin',
                'first_name' => $request->first_name,
                'last_name' => $request->last_name,
                'birth_date' => $birthDate,
                'is_approved' => true,
                'status' => 'approved'
            ]);

            AdminActivity::log('admin_created', "Created new admin: {$admin->first_name} {$admin->last_name}", [
                'admin_id' => $admin->id,
                'admin_phone' => $admin->phone,
            ]);

            DB::commit();
            return redirect()->route('admin.admins')->with('success', "Admin '{$admin->first_name} {$admin->last_name}' created successfully!");
        } catch (\Exception $e) {
            DB::rollBack();
            return back()->withInput()->withErrors(['error' => 'Failed to create admin: ' . $e->getMessage()]);
        }
    }

    public function destroy($id)
    {
        try {
            DB::beginTransaction();
            
            $admin = User::where('role', 'admin')->findOrFail($id);
            
            if ($admin->id === Auth::id()) {
                return back()->withErrors(['error' => 'You cannot delete your own account.']);
            }

            $adminCount = User::where('role', 'admin')->count();
            if ($adminCount <= 1) {
                return back()->withErrors(['error' => 'Cannot delete the last admin account.']);
            }

            $adminName = "{$admin->first_name} {$admin->last_name}";
            
            AdminActivity::log('admin_deleted', "Deleted admin: {$adminName}", [
                'deleted_admin_id' => $admin->id,
                'deleted_admin_phone' => $admin->phone,
            ]);

            $admin->delete();
            
            DB::commit();
            return back()->with('success', "Admin '{$adminName}' has been removed successfully.");
        } catch (\Exception $e) {
            DB::rollBack();
            return back()->withErrors(['error' => 'Failed to delete admin: ' . $e->getMessage()]);
        }
    }

    public function activities(Request $request)
    {
        try {
            $filters = $request->only(['action', 'admin_id', 'date']);
            $activities = $this->adminService->getActivities($filters);
            return view('admin.activities', compact('activities'));
        } catch (\Exception $e) {
            return back()->withErrors(['error' => 'Failed to load activities: ' . $e->getMessage()]);
        }
    }
}
