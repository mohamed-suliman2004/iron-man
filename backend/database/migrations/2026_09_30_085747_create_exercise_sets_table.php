<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('exercise_sets', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('workout_session_id');
            $table->foreign('workout_session_id')->references('id')->on('workout_sessions')->cascadeOnDelete();
            $table->uuid('exercise_id');
            $table->foreign('exercise_id')->references('id')->on('exercises')->cascadeOnDelete();
            $table->tinyInteger('set_number');
            $table->decimal('weight_kg', 6, 2);
            $table->smallInteger('reps');
            $table->decimal('rpe', 3, 1)->nullable();
            $table->boolean('is_pr')->default(false);
            $table->string('sync_status')->default('synced');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('exercise_sets');
    }
};
