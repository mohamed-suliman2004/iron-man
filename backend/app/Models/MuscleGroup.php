<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MuscleGroup extends Model
{
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'name_ar',
        'name_en',
        'icon_name',
        'sort_order',
    ];

    public function exercises()
    {
        return $this->hasMany(Exercise::class);
    }
}
