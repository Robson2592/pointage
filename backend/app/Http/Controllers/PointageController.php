<?php

namespace App\Http\Controllers;

use App\Models\Clocking;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Carbon\Carbon;

class PointageController extends Controller
{
    public function clock(Request $request)
    {
        $request->validate([
            'type' => 'required|in:in,out',
            'method' => 'required|in:nfc,qr,geo,manual',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric'
        ]);

        $user = Auth::user();

        $clocking = Clocking::create([
            'user_id' => $user->id,
            'type' => $request->type,
            'method' => $request->method,
            'latitude' => $request->latitude,
            'longitude' => $request->longitude,
            'clock_time' => Carbon::now()
        ]);

        return response()->json([
            'message' => 'Pointage enregistré avec succès',
            'data' => $clocking
        ], 201);
    }

    public function history()
    {
        $user = Auth::user();
        $history = Clocking::where('user_id', $user->id)
            ->orderBy('clock_time', 'desc')
            ->get();

        return response()->json($history);
    }

    public function stats()
    {
        $user = Auth::user();
        $stats = Clocking::where('user_id', $user->id)
            ->selectRaw('type, count(*) as count')
            ->groupBy('type')
            ->get();

        return response()->json($stats);
    }

    public function meStatus()
    {
        $user = Auth::user();
        $today = Carbon::today();

        // Check current status
        $lastClocking = Clocking::where('user_id', $user->id)
            ->orderBy('clock_time', 'desc')
            ->first();

        $currentStatus = ($lastClocking && $lastClocking->type === 'in') ? 'clocked_in' : 'clocked_out';

        // Calculate hours today
        $clockings = Clocking::where('user_id', $user->id)
            ->whereDate('clock_time', $today)
            ->orderBy('clock_time', 'asc')
            ->get();

        $totalMinutes = 0;
        $tempIn = null;

        foreach ($clockings as $c) {
            if ($c->type === 'in') {
                $tempIn = Carbon::parse($c->clock_time);
            } else if ($c->type === 'out' && $tempIn) {
                $totalMinutes += $tempIn->diffInMinutes(Carbon::parse($c->clock_time));
                $tempIn = null;
            }
        }

        // If still clocked in, add time until now
        if ($tempIn) {
            $totalMinutes += $tempIn->diffInMinutes(Carbon::now());
        }

        return response()->json([
            'status' => $currentStatus,
            'hours_today' => round($totalMinutes / 60, 2),
            'tasks_completed' => $user->tasks()->where('status', 'completed')->count(),
            'total_tasks' => $user->tasks()->count(),
        ]);
    }
}
