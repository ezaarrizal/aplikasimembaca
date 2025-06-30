<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;

Route::get('/', function () {
    return view('welcome');
});

// Auth Routes
Route::middleware('guest')->group(function () {
    Route::get('/login', [AuthController::class, 'showLoginForm'])->name('login');
    Route::post('/login', [AuthController::class, 'login']);
});

Route::middleware('auth')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout'])->name('logout');
    
    // Guru Routes
    Route::middleware('role:guru')->prefix('guru')->group(function () {
        Route::get('/dashboard', function () {
            return view('guru.dashboard');
        })->name('guru.dashboard');
    });

    // Siswa Routes
    Route::middleware('role:siswa')->prefix('siswa')->group(function () {
        Route::get('/dashboard', function () {
            return view('siswa.dashboard');
        })->name('siswa.dashboard');
    });

    // Orangtua Routes
    Route::middleware('role:orangtua')->prefix('orangtua')->group(function () {
        Route::get('/dashboard', function () {
            return view('orangtua.dashboard');
        })->name('orangtua.dashboard');
    });
}); 