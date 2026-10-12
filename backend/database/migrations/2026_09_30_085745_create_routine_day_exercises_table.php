<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('routine_day_exercises', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('routine_day_id');
            $table->foreign('routine_day_id')->references('id')->on('routine_days')->cascadeOnDelete();
            $table->uuid('exercise_id');
            $table->foreign('exercise_id')->references('id')->on('exercises')->cascadeOnDelete();
            $table->smallInteger('order_index')->default(1);
            $table->tinyInteger('target_sets')->default(3);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('routine_day_exercises');
    }
};
