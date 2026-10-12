<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class Exercise extends Model
{
    use HasUuids;

    protected $fillable = [
        'id',
        'user_id',
        'muscle_group_id',
        'name_ar',
        'name_en',
        'equipment',
        'is_custom',
    ];

    protected $casts = [
        'is_custom' => 'boolean',
    ];

    public function muscleGroup()
    {
        return $this->belongsTo(MuscleGroup::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function routineDayExercises()
    {
        return $this->hasMany(RoutineDayExercise::class);
    }

    public function sets()
    {
        return $this->hasMany(ExerciseSet::class);
    }
}
