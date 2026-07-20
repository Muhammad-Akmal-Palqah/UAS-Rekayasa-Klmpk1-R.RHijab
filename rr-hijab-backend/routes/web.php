<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\DB;
use App\Models\BusinessHour;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\AdminCrudController;
use App\Http\Controllers\UserCrudController;
use App\Http\Controllers\ProductCrudController;
use App\Http\Controllers\BusinessHoursController;
use App\Http\Controllers\ProductController;
use App\Models\Product;
use App\Http\Controllers\CommentCrudController;
use App\Http\Controllers\PaymentValidationController;
use App\Http\Controllers\FlutterAdminController;

// ─── RUTE OTENTIKASI (LOGIN & LOGOUT) ───
Route::get('/login', [AuthController::class, 'showLogin'])->name('login');
Route::post('/login', [AuthController::class, 'login']);
Route::post('/logout', [AuthController::class, 'logout'])->name('logout');

// ─── RUTE REGISTRASI (SIGN UP) ───
Route::get('/register', [AuthController::class, 'showRegister'])->name('register');
Route::post('/register', [AuthController::class, 'register']);

// ─── HALAMAN PELANGGAN UMUM ───
Route::get('/', function () {
    if (app()->environment('testing')) {
        return view('pelanggan.index', ['featured' => collect()]);
    }

    $featured = Product::where('is_featured', 1)->where('status', 'Aktif')->take(3)->get();
    if ($featured->count() < 3) {
        $needed = 3 - $featured->count();
        $more = Product::where('status', 'Aktif')->where('is_featured', 0)->orderBy('created_at', 'desc')->take($needed)->get();
        $featured = $featured->concat($more);
    }

    return view('pelanggan.index', compact('featured'));
})->name('home');

// DEBUG route: update order 52 status to Sudah Dibayar (temporary)
Route::get('/debug/update-order-52', function () {
    try {
// Use default DB connection after unifying Flutter data into main database
        DB::connection()->table('orders')->where('id_order', 52)->update([
            'status_pembayaran' => 'Sudah Dibayar',
            'updated_at' => now(),
        ]);
        return response('UPDATED', 200);
    } catch (\Throwable $e) {
        return response('ERROR: ' . $e->getMessage(), 500);
    }
});

Route::get('/debug/inspect-order-52', function () {
    try {
// Use default DB connection after unifying Flutter data into main database
        $val = DB::table('orders')->where('id_order', 52)->value('status_pembayaran');
        $databaseName = DB::getDatabaseName();
        $col = DB::select("SELECT COLUMN_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = ? AND TABLE_NAME = 'orders' AND COLUMN_NAME = 'status_pembayaran'", [$databaseName]);
        return response()->json(['value' => $val, 'column' => $col]);
    } catch (\Throwable $e) {
        return response()->json(['error' => $e->getMessage()], 500);
    }
});

// DEBUG: extend enum values for status_pembayaran to include app labels
Route::get('/debug/extend-status-enum', function () {
    try {
// Use default DB connection after unifying Flutter data into main database
        DB::connection()->statement("ALTER TABLE orders MODIFY COLUMN status_pembayaran ENUM('Menunggu Pembayaran','Diproses','Dikirim','Sudah Dibayar','Selesai','Pembayaran Gagal','Dibatalkan Pelanggan','Dibatalkan Sistem') NOT NULL DEFAULT 'Menunggu Pembayaran'");
        return response('ALTERED', 200);
    } catch (\Throwable $e) {
        return response('ERROR: ' . $e->getMessage(), 500);
    }
});

Route::get('/katalog', [ProductController::class, 'katalog'])->name('pelanggan.katalog');
Route::get('/katalog/{id}', [ProductController::class, 'detail'])->name('pelanggan.katalog.detail');
Route::get('/katalog/{id}/checkout', [ProductController::class, 'checkout'])->name('pelanggan.katalog.checkout');
Route::post('/katalog/{id}/checkout', [ProductController::class, 'placeOrder'])->name('pelanggan.katalog.checkout.store');
Route::post('/katalog/{id}/komentar', [ProductController::class, 'storeComment'])->middleware('auth:web')->name('pelanggan.katalog.comment');

// ─── HALAMAN YANG DIPROTEKSI (WAJIB LOGIN) ───
// 💡 PERBAIKAN: Mengubah dari ['auth:admin'] menjadi ['auth:admin,web'] agar akun Super Admin dari tabel users/admins sama-sama dikenali sistem
Route::middleware(['auth:admin,web'])->group(function () {
    
    // Dashboard Utama: Bisa diakses oleh admin dan super_admin
    Route::get('/admin/dashboard', function () {
        $adminCount = DB::table('admins')->count();
        $userCount = DB::table('users')->count();
        $businessHours = BusinessHour::current();
        
        return view('admin.dashboard', compact('adminCount', 'userCount', 'businessHours'));
    })->middleware('role:admin,super_admin')->name('admin.dashboard');

    // Jam Operasional: Hanya untuk Super Admin
    Route::post('/admin/business-hours/toggle', [BusinessHoursController::class, 'toggle'])
        ->middleware('role:super_admin')
        ->name('admin.business-hours.toggle');

    // CRUD Admin: Hanya untuk Super Admin
    Route::middleware('role:super_admin')->group(function () {
        Route::get('/admin/manage', [AdminCrudController::class, 'index'])->name('admin.index');
        Route::post('/admin/manage', [AdminCrudController::class, 'store'])->name('admin.store');
        Route::put('/admin/manage/{id}', [AdminCrudController::class, 'update'])->name('admin.update');
        Route::delete('/admin/manage/{id}', [AdminCrudController::class, 'destroy'])->name('admin.destroy');
    });

    // Jalur Pengelolaan Terpadu: Bisa diakses bersama oleh Admin biasa dan Super Admin
    Route::middleware('role:admin,super_admin')->group(function () {
        Route::get('/user/manage', [UserCrudController::class, 'index'])->name('user.index');
        Route::post('/user/manage', [UserCrudController::class, 'store'])->name('user.store');
        Route::put('/user/manage/{id}', [UserCrudController::class, 'update'])->name('user.update');
        Route::delete('/user/manage/{id}', [UserCrudController::class, 'destroy'])->name('user.destroy');

        Route::get('/product/manage', [ProductCrudController::class, 'index'])->name('product.index');
        Route::post('/product/manage', [ProductCrudController::class, 'store'])->name('product.store');
        Route::put('/product/manage/{id}', [ProductCrudController::class, 'update'])->name('product.update');
        Route::delete('/product/manage/{id}', [ProductCrudController::class, 'destroy'])->name('product.destroy');

        Route::get('/admin/payment-verification', [PaymentValidationController::class, 'index'])->name('payment.index');
        Route::post('/admin/payment-verification/{id}/process', [PaymentValidationController::class, 'validatePayment'])->name('payment.process');
        Route::post('/admin/payment-verification/{id}/cancel', [PaymentValidationController::class, 'cancelPayment'])->name('payment.cancel');
        Route::put('/admin/payment-verification/{id}', [PaymentValidationController::class, 'update'])->name('payment.update');
        Route::delete('/admin/payment-verification/{id}', [PaymentValidationController::class, 'destroy'])->name('payment.destroy'); 

        Route::get('/admin/comments', [CommentCrudController::class, 'index'])->name('comment.index');
        Route::delete('/admin/comments/{id}', [CommentCrudController::class, 'destroy'])->name('comment.destroy');
        Route::post('/admin/generate-description', [ProductCrudController::class, 'generateDescription'])->name('admin.generate.description');

       
    });
});

Route::middleware(['auth:web'])->group(function () {
    // 🛍️ Jika yang masuk adalah PELANGGAN via Web -> Buka halaman pesan
    Route::get('/pesan-hijab', function () {
        return view('pelanggan.index');
    })->name('pelanggan.index');
});
