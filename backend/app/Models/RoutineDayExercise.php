<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class RoutineDayExercise extends Model
{
    use HasUuids;

    protected $fillable = [
        'id',
        'routine_day_id',
        'exercise_id',
        'order_index',
        'target_sets',
    ];

    protected $casts = [
        'order_index' => 'integer',
        'target_sets' => 'integer',
    ];

    public function routineDay()
    {
        return $this->belongsTo(RoutineDay::class, 'routine_day_id');
    }

    public function exercise()
    {
        return $this->belongsTo(Exercise::class, 'exercise_id');
    }
}
