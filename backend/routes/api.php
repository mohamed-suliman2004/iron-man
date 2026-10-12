<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\ExerciseController;
use App\Http\Controllers\RoutineController;
use App\Http\Controllers\SyncController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes - IronLog Gym Tracking System
|--------------------------------------------------------------------------
*/

// مسارات عامة (بدون توكن)
Route::prefix('auth')->group(function () {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/reset-password', [AuthController::class, 'resetPassword']);
});

// مسارات محمية بتوكن Sanctum
Route::middleware('auth:sanctum')->group(function () {
    // الملف الشخصي وتسجيل الخروج
    Route::get('/auth/me', [AuthController::class, 'me']);
    Route::post('/auth/logout', [AuthController::class, 'logout']);

    // التمارين الرياضية
    Route::get('/exercises', [ExerciseController::class, 'index']);
    Route::post('/exercises', [ExerciseController::class, 'store']);

    // الجداول التدريبية
    Route::get('/routines', [RoutineController::class, 'index']);
    Route::post('/routines', [RoutineController::class, 'store']);
    Route::get('/routines/{id}', [RoutineController::class, 'show']);
    Route::delete('/routines/{id}', [RoutineController::class, 'destroy']);

    // محرك المزامنة الذكي (Offline-First Sync Engine)
    Route::post('/sync/push', [SyncController::class, 'push']);
    Route::get('/sync/pull', [SyncController::class, 'pull']);
});