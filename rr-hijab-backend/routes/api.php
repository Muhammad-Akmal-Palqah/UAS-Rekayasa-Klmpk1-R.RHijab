<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\PaymentController;
use App\Http\Controllers\AdminOrderController;
use App\Http\Controllers\ChatController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;


Route::middleware(['auth:sanctum', 'role:user'])->group(function () {
    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    Route::patch('/user', [AuthController::class, 'updateProfile']);
    Route::get('/products/{id}/comments/status', [ProductController::class, 'getCommentStatusAPI']);
    Route::post('/products/{id}/comments', [ProductController::class, 'storeCommentAPI']);
    Route::post('/products/{id}/orders', [ProductController::class, 'storeOrderAPI']);
    Route::post('/orders/bulk', [ProductController::class, 'storeBulkOrdersAPI']);
    Route::get('/orders', [ProductController::class, 'fetchOrdersAPI']);
    Route::delete('/orders/{id}', [ProductController::class, 'destroyOrderAPI']);
    Route::post('/payments/initiate', [PaymentController::class, 'initiate']);
    Route::get('/payments/{orderId}/status', [PaymentController::class, 'status']);
});

// 📦 Public API untuk Flutter: ambil daftar produk dari database unified
Route::get('/products', [ProductController::class, 'indexAPI']);
Route::get('/products/{id}/comments', [ProductController::class, 'getCommentsAPI']);

Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);
Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);
Route::post('/payments/callback', [PaymentController::class, 'callback']);


Route::post('/chat', [ChatController::class, 'chat']);

// Admin Order routes (requires auth:sanctum + admin role)
Route::middleware(['auth:sanctum', 'role:admin,super_admin'])->group(function () {
    Route::get('/admin/orders', [AdminOrderController::class, 'indexOrders']);
    Route::get('/admin/orders/{id}', [AdminOrderController::class, 'showOrder']);
});
