<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Services\AdminService;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    protected $adminService;

    public function __construct(AdminService $adminService)
    {
        $this->adminService = $adminService;
    }

    public function index()
    {
        try {
            $stats = $this->adminService->getDashboardStats();
            $recentActivities = $this->adminService->getRecentActivities(8);
            $adminStats = $this->adminService->getAdminStats();

            return view('admin.dashboard', compact('stats', 'recentActivities', 'adminStats'));
        } catch (\Exception $e) {
            return back()->withErrors(['error' => 'Failed to load dashboard: ' . $e->getMessage()]);
        }
    }
}
