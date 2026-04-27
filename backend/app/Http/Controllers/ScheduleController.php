<?php

namespace App\Http\Controllers;

use App\Models\Schedule;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ScheduleController extends Controller {
    public function index() {
        return response()->json(Schedule::where('user_id', Auth::id())->get());
    }
}
