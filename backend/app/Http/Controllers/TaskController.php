<?php

namespace App\Http\Controllers;

use App\Models\Task;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class TaskController extends Controller {
    public function index() {
        return response()->json(Task::where('user_id', Auth::id())->get());
    }

    public function store(Request $request) {
        $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'required|string',
        ]);

        $task = Task::create([
            'user_id' => Auth::id(),
            'title' => $request->title,
            'description' => $request->description,
            'status' => 'pending',
        ]);

        return response()->json([
            'message' => 'Tâche créée avec succès',
            'data' => $task
        ], 201);
    }

    public function updateStatus(Request $request, $id) {
        $request->validate([
            'status' => 'required|in:pending,in_progress,completed'
        ]);

        $task = Task::where('user_id', Auth::id())->findOrFail($id);
        $task->update(['status' => $request->status]);

        return response()->json([
            'message' => 'Statut de la tâche mis à jour',
            'data' => $task
        ]);
    }
}
