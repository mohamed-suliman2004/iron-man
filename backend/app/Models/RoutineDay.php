<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class RoutineDay extends Model
{
    use HasUuids;

    protected $fillable = [
        'id',
        'routine_id',
        'day_number',
        'day_name',
        'target_weekday',
    ];

    protected $casts = [
        'day_number' => 'integer',
        'target_weekday' => 'integer',
    ];

    public function routine()
    {
        return $this->belongsTo(WorkoutRoutine::class, 'routine_id');
    }

    public function dayExercises()
    {
        return $this->hasMany(RoutineDayExercise::class, 'routine_day_id')->orderBy('order_index');
    }

    public function sessions()
    {
        return $this->hasMany(WorkoutSession::class, 'routine_day_id');
    }
}
