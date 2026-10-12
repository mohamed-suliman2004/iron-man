<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('exercises', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignId('user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('muscle_group_id');
            $table->foreign('muscle_group_id')->references('id')->on('muscle_groups')->cascadeOnDelete();
            $table->string('name_ar');
            $table->string('name_en');
            $table->string('equipment')->default('barbell'); // barbell, dumbbell, cable, machine, bodyweight
            $table->boolean('is_custom')->default(false);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('exercises');
    }
};
