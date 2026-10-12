<?php

namespace App\Http\Controllers;

use App\Models\ExerciseSet;
use App\Models\RoutineDay;
use App\Models\RoutineDayExercise;
use App\Models\WorkoutRoutine;
use App\Models\WorkoutSession;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class SyncController extends Controller
{
    /**
     * استقبال الحركات والجلسات والجولات غير المزامنة من الهاتف وحفظها في MySQL
     */
    public function push(Request $request)
    {
        $user = $request->user();
        $payload = $request->all();

        $syncedSessionIds = [];
        $syncedSetIds = [];
        $syncedRoutineIds = [];

        DB::transaction(function () use ($user, $payload, &$syncedSessionIds, &$syncedSetIds, &$syncedRoutineIds) {
            // 1. مزامنة الجداول المخصصة
            if (!empty($payload['custom_routines'])) {
                foreach ($payload['custom_routines'] as $routineData) {
                    WorkoutRoutine::updateOrCreate(
                        ['id' => $routineData['id']],
                        [
                            'user_id' => $user->id,
                            'title' => $routineData['title'],
                            'description' => $routineData['description'] ?? null,
                            'days_count' => $routineData['days_count'] ?? 3,
                            'is_active' => $routineData['is_active'] ?? false,
                            'is_system' => false,
                        ]
                    );

                    if (!empty($routineData['days'])) {
                        foreach ($routineData['days'] as $dayData) {
                            RoutineDay::updateOrCreate(
                                ['id' => $dayData['id']],
                                [
                                    'routine_id' => $routineData['id'],
                                    'day_number' => $dayData['day_number'],
                                    'day_name' => $dayData['day_name'],
                                    'target_weekday' => $dayData['target_weekday'] ?? null,
                                ]
                            );

                            if (!empty($dayData['exercises'])) {
                                foreach ($dayData['exercises'] as $exData) {
                                    RoutineDayExercise::updateOrCreate(
                                        ['id' => $exData['id']],
                                        [
                                            'routine_day_id' => $dayData['id'],
                                            'exercise_id' => $exData['exercise_id'],
                                            'order_index' => $exData['order_index'] ?? 1,
                                            'target_sets' => $exData['target_sets'] ?? 3,
                                        ]
                                    );
                                }
                            }
                        }
                    }

                    $syncedRoutineIds[] = $routineData['id'];
                }
            }

            // 2. مزامنة جلسات التمرين
            if (!empty($payload['sessions'])) {
                foreach ($payload['sessions'] as $sessionData) {
                    WorkoutSession::updateOrCreate(
                        ['id' => $sessionData['id']],
                        [
                            'user_id' => $user->id,
                            'routine_day_id' => $sessionData['routine_day_id'] ?? null,
                            'name' => $sessionData['name'],
                            'started_at' => $sessionData['started_at'],
                            'ended_at' => $sessionData['ended_at'] ?? null,
                            'notes' => $sessionData['notes'] ?? null,
                            'sync_status' => 'synced',
                        ]
                    );
                    $syncedSessionIds[] = $sessionData['id'];
                }
            }

            // 3. مزامنة الجولات الفردية والأوزان
            if (!empty($payload['sets'])) {
                foreach ($payload['sets'] as $setData) {
                    ExerciseSet::updateOrCreate(
                        ['id' => $setData['id']],
                        [
                            'workout_session_id' => $setData['workout_session_id'],
                            'exercise_id' => $setData['exercise_id'],
                            'set_number' => $setData['set_number'],
                            'weight_kg' => $setData['weight_kg'],
                            'reps' => $setData['reps'],
                            'rpe' => $setData['rpe'] ?? null,
                            'is_pr' => $setData['is_pr'] ?? false,
                            'sync_status' => 'synced',
                        ]
                    );
                    $syncedSetIds[] = $setData['id'];
                }
            }
        });

        return response()->json([
            'status' => 'success',
            'message' => 'تمت المزامنة بنجاح',
            'synced_session_ids' => $syncedSessionIds,
            'synced_set_ids' => $syncedSetIds,
            'synced_routine_ids' => $syncedRoutineIds,
            'server_timestamp' => now()->toIso8601String(),
        ]);
    }

    /**
     * جلب أي تحديثات جديدة حدثت على حساب المستخدم منذ تاريخ محدد
     */
    public function pull(Request $request)
    {
        $user = $request->user();
        $since = $request->query('since');

        $sessionsQuery = WorkoutSession::with('sets')->where('user_id', $user->id);
        $routinesQuery = WorkoutRoutine::with(['days.dayExercises'])->where('user_id', $user->id);

        if ($since) {
            $sessionsQuery->where('updated_at', '>=', $since);
            $routinesQuery->where('updated_at', '>=', $since);
        }

        return response()->json([
            'status' => 'success',
            'sessions' => $sessionsQuery->get(),
            'custom_routines' => $routinesQuery->get(),
            'server_timestamp' => now()->toIso8601String(),
        ]);
    }
}
