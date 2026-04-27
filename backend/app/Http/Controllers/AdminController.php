<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Clocking;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AdminController extends Controller
{
    /**
     * Check if user is admin.
     */
    protected function checkAdmin()
    {
        if (Auth::user()->role !== 'admin') {
            abort(403, 'Unauthorized action.');
        }
    }

    /**
     * List all employees with their last clocking status.
     */
    public function indexEmployees()
    {
        $this->checkAdmin();

        $users = User::where('role', 'employee')
            ->with(['clockings' => function($query) {
                $query->latest('clock_time')->limit(1);
            }])
            ->get();

        return response()->json($users);
    }

    /**
     * Get history for a specific employee.
     */
    public function employeeHistory($userId)
    {
        $this->checkAdmin();

        $history = Clocking::where('user_id', $userId)
            ->orderBy('clock_time', 'desc')
            ->get();

        return response()->json($history);
    }

    /**
     * Get global stats for the admin dashboard.
     */
    public function globalStats()
    {
        $this->checkAdmin();

        $totalEmployees = User::where('role', 'employee')->count();
        $presentToday = Clocking::where('type', 'in')
            ->whereDate('clock_time', now())
            ->distinct('user_id')
            ->count();

        return response()->json([
            'total_employees' => $totalEmployees,
            'present_today' => $presentToday,
            'absent_today' => $totalEmployees - $presentToday,
        ]);
    }
}
