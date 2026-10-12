<?php

namespace App\Http\Controllers;

use App\Models\RoutineDay;
use App\Models\RoutineDayExercise;
use App\Models\WorkoutRoutine;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class RoutineController extends Controller
{
    /**
     * استرجاع الجداول الافتراضية وجداول المستخدم المخصصة
     */
    public function index(Request $request)
    {
        $userId = $request->user()->id;

        $routines = WorkoutRoutine::with(['days.dayExercises.exercise'])
            ->where(function ($query) use ($userId) {
                $query->where('is_system', true)
                      ->orWhere('user_id', $userId);
            })
            ->orderBy('is_system', 'desc')
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'status' => 'success',
            'routines' => $routines,
        ]);
    }

    /**
     * إنشاء جدول تدريبي مخصص جديد
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'id' => 'nullable|uuid',
            'title' => 'required|string|max:150',
            'description' => 'nullable|string',
            'days_count' => 'required|integer|min:1|max:7',
            'days' => 'required|array|min:1',
            'days.*.id' => 'nullable|uuid',
            'days.*.day_number' => 'required|integer',
            'days.*.day_name' => 'required|string|max:100',
            'days.*.target_weekday' => 'nullable|integer',
            'days.*.exercises' => 'nullable|array',
            'days.*.exercises.*.exercise_id' => 'required|uuid|exists:exercises,id',
            'days.*.exercises.*.order_index' => 'required|integer',
            'days.*.exercises.*.target_sets' => 'nullable|integer',
        ]);

        $routine = DB::transaction(function () use ($validated, $request) {
            $routineId = $validated['id'] ?? (string) Str::uuid();

            $routine = WorkoutRoutine::create([
                'id' => $routineId,
                'user_id' => $request->user()->id,
                'title' => $validated['title'],
                'description' => $validated['description'] ?? null,
                'days_count' => $validated['days_count'],
                'is_active' => false,
                'is_system' => false,
            ]);

            foreach ($validated['days'] as $dayData) {
                $dayId = $dayData['id'] ?? (string) Str::uuid();

                $day = RoutineDay::create([
                    'id' => $dayId,
                    'routine_id' => $routine->id,
                    'day_number' => $dayData['day_number'],
                    'day_name' => $dayData['day_name'],
                    'target_weekday' => $dayData['target_weekday'] ?? null,
                ]);

                if (!empty($dayData['exercises'])) {
                    foreach ($dayData['exercises'] as $exData) {
                        RoutineDayExercise::create([
                            'id' => (string) Str::uuid(),
                            'routine_day_id' => $day->id,
                            'exercise_id' => $exData['exercise_id'],
                            'order_index' => $exData['order_index'],
                            'target_sets' => $exData['target_sets'] ?? 3,
                        ]);
                    }
                }
            }

            return $routine->load('days.dayExercises.exercise');
        });

        return response()->json([
            'status' => 'success',
            'message' => 'تم إنشاء الجدول التدريبي بنجاح',
            'routine' => $routine,
        ], 201);
    }

    /**
     * جلب تفاصيل جدول تدريبي محدد
     */
    public function show(Request $request, $id)
    {
        $routine = WorkoutRoutine::with('days.dayExercises.exercise')->findOrFail($id);

        if (!$routine->is_system && $routine->user_id !== $request->user()->id) {
            return response()->json(['status' => 'error', 'message' => 'غير مصرح'], 403);
        }

        return response()->json([
            'status' => 'success',
            'routine' => $routine,
        ]);
    }

    /**
     * حذف جدول مخصص
     */
    public function destroy(Request $request, $id)
    {
        $routine = WorkoutRoutine::where('id', $id)
            ->where('user_id', $request->user()->id)
            ->where('is_system', false)
            ->firstOrFail();

        $routine->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'تم حذف الجدول بنجاح',
        ]);
    }
}
