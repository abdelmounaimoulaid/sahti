<?php

use App\Http\Controllers\ReviewController;
use Illuminate\Support\Facades\Route;

// Local admin only for now. Add authentication before hosting this online.
Route::get('/', [ReviewController::class, 'index'])->name('review.index');
Route::get('/products/{id}', [ReviewController::class, 'show'])->whereNumber('id')->name('review.show');
Route::post('/products/{id}/validate', [ReviewController::class, 'validateProduct'])->whereNumber('id')->name('review.validate');
Route::post('/products/{id}/reject', [ReviewController::class, 'reject'])->whereNumber('id')->name('review.reject');
