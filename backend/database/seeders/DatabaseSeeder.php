<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Schedule;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder {
    public function run() {
        // Create Admin
        User::updateOrCreate(
            ['email' => 'admin@pointage.com'],
            [
                'name' => 'Directeur Admin',
                'password' => Hash::make('admin123'),
                'role' => 'admin',
            ]
        );

        $employee = User::updateOrCreate(
            ['email' => 'employee@pointage.com'],
            [
                'name' => 'Jean Employé',
                'password' => Hash::make('emp123'),
                'role' => 'employee',
            ]
        );

        // Create Schedules for Employee
        Schedule::updateOrCreate(
            ['user_id' => $employee->id, 'day_of_week' => 'Lundi'],
            [
                'start_time' => '08:00',
                'end_time' => '17:00',
                'status' => 'scheduled'
            ]
        );

        Schedule::updateOrCreate(
            ['user_id' => $employee->id, 'day_of_week' => 'Mardi'],
            [
                'start_time' => '09:00',
                'end_time' => '18:00',
                'status' => 'scheduled'
            ]
        );
    }
}
