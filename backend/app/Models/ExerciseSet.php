<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class ExerciseSet extends Model
{
    use HasUuids;

    protected $fillable = [
        'id',
        'workout_session_id',
        'exercise_id',
        'set_number',
        'weight_kg',
        'reps',
        'rpe',
        'is_pr',
        'sync_status',
    ];

    protected $casts = [
        'set_number' => 'integer',
        'weight_kg' => 'float',
        'reps' => 'integer',
        'rpe' => 'float',
        'is_pr' => 'boolean',
    ];

    public function workoutSession()
    {
        return $this->belongsTo(WorkoutSession::class, 'workout_session_id');
    }

    public function exercise()
    {
        return $this->belongsTo(Exercise::class, 'exercise_id');
    }
}
