<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class WorkoutRoutine extends Model
{
    use HasUuids;

    protected $fillable = [
        'id',
        'user_id',
        'title',
        'description',
        'days_count',
        'is_active',
        'is_system',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'is_system' => 'boolean',
        'days_count' => 'integer',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function days()
    {
        return $this->hasMany(RoutineDay::class, 'routine_id')->orderBy('day_number');
    }
}
