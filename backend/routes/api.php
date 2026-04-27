<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\PointageController;
use App\Http\Controllers\TaskController;
use App\Http\Controllers\ScheduleController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\AdminController;

Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    Route::post('/clocking', [PointageController::class, 'clock']);
    Route::get('/history', [PointageController::class, 'history']);
    Route::get('/stats', [PointageController::class, 'stats']);
    Route::get('/me-status', [PointageController::class, 'meStatus']);
    
    // Tasks routes
    Route::get('/tasks', [TaskController::class, 'index']);
    Route::post('/tasks', [TaskController::class, 'store']);
    Route::patch('/tasks/{id}/status', [TaskController::class, 'updateStatus']);
    
    // Schedules routes
    Route::get('/schedules', [ScheduleController::class, 'index']);

    // Admin routes
    Route::prefix('admin')->group(function () {
        Route::get('/employees', [AdminController::class, 'indexEmployees']);
        Route::get('/employees/{id}/history', [AdminController::class, 'employeeHistory']);
        Route::get('/stats', [AdminController::class, 'globalStats']);
    });
});
