<?php

use App\Http\Controllers\LoginController;
use App\Http\Controllers\ReviewController;
use App\Http\Middleware\AdminAuth;
use Illuminate\Support\Facades\Route;

// Public read-only API for the Sahti app (OFF-compatible JSON).
Route::get('/api/v1/products/{barcode}', [\App\Http\Controllers\ProductApiController::class, 'show'])
    ->middleware('throttle:120,1');

Route::get('/login',[LoginController::class, 'show'])->name('login');
Route::post('/login', [LoginController::class, 'login'])->name('login.post');
Route::post('/logout', [LoginController::class, 'logout'])->name('logout');

Route::middleware(AdminAuth::class)->group(function () {
    Route::get('/', [ReviewController::class, 'index'])->name('review.index');
    Route::get('/products/{id}', [ReviewController::class, 'show'])->whereNumber('id')->name('review.show');
    Route::post('/products/{id}/validate', [ReviewController::class, 'validateProduct'])->whereNumber('id')->name('review.validate');
    Route::post('/products/{id}/reject', [ReviewController::class, 'reject'])->whereNumber('id')->name('review.reject');
});
