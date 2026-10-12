<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('routine_days', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('routine_id');
            $table->foreign('routine_id')->references('id')->on('workout_routines')->cascadeOnDelete();
            $table->tinyInteger('day_number');
            $table->string('day_name');
            $table->tinyInteger('target_weekday')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('routine_days');
    }
};
