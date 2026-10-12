<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class WorkoutSession extends Model
{
    use HasUuids;

    protected $fillable = [
        'id',
        'user_id',
        'routine_day_id',
        'name',
        'started_at',
        'ended_at',
        'notes',
        'sync_status',
    ];

    protected $casts = [
        'started_at' => 'datetime',
        'ended_at' => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function routineDay()
    {
        return $this->belongsTo(RoutineDay::class, 'routine_day_id');
    }

    public function sets()
    {
        return $this->hasMany(ExerciseSet::class, 'workout_session_id')->orderBy('set_number');
    }
}
