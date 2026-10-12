<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('muscle_groups', function (Blueprint $table) {
            $table->string('id')->primary(); // 'chest', 'back', 'shoulders', 'legs', 'arms', 'core'
            $table->string('name_ar');
            $table->string('name_en');
            $table->string('icon_name')->default('fitness_center');
            $table->integer('sort_order')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('muscle_groups');
    }
};
