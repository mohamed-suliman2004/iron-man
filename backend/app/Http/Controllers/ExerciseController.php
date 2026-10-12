<?php

namespace App\Http\Controllers;

use App\Models\Exercise;
use App\Models\MuscleGroup;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class ExerciseController extends Controller
{
    /**
     * استرجاع كافة التمارين مصنفة حسب المجموعات العضلية
     */
    public function index(Request $request)
    {
        $userId = $request->user()?->id;

        $muscleGroups = MuscleGroup::with(['exercises' => function ($query) use ($userId) {
            $query->whereNull('user_id')
                  ->orWhere('user_id', $userId)
                  ->orderBy('name_ar');
        }])->orderBy('sort_order')->get();

        return response()->json([
            'status' => 'success',
            'muscle_groups' => $muscleGroups,
        ]);
    }

    /**
     * إضافة تمرين مخصص جديد للاعب
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'id' => 'nullable|uuid',
            'muscle_group_id' => 'required|exists:muscle_groups,id',
            'name_ar' => 'required|string|max:150',
            'name_en' => 'nullable|string|max:150',
            'equipment' => 'required|string|max:50',
        ]);

        $exercise = Exercise::create([
            'id' => $validated['id'] ?? (string) Str::uuid(),
            'user_id' => $request->user()->id,
            'muscle_group_id' => $validated['muscle_group_id'],
            'name_ar' => $validated['name_ar'],
            'name_en' => $validated['name_en'] ?? $validated['name_ar'],
            'equipment' => $validated['equipment'],
            'is_custom' => true,
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'تمت إضافة التمرين المخصص بنجاح',
            'exercise' => $exercise,
        ], 201);
    }
}
