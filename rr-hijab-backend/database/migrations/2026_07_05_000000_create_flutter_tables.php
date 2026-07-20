<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
// Use default DB/Schema connection after unifying Flutter data into main database
        if (!Schema::hasTable('products')) {
// Use default DB/Schema connection after unifying Flutter data into main database
            Schema::create('products', function (Blueprint $table) {
                $table->id('id_produk');
                $table->string('nama_produk');
                $table->text('deskripsi')->nullable();
                $table->decimal('harga', 12, 2)->default(0);
                $table->integer('stok')->default(0);
                $table->string('status')->default('Aktif');
                $table->string('link_foto')->nullable();
                $table->boolean('is_featured')->default(false);
                $table->string('promo')->nullable();
                $table->timestamps();
            });
        }

// Use default DB/Schema connection after unifying Flutter data into main database
        if (!Schema::hasTable('orders')) {
// Use default DB/Schema connection after unifying Flutter data into main database
            Schema::create('orders', function (Blueprint $table) {
                $table->id('id_order');
                $table->unsignedBigInteger('user_id')->nullable()->index();
                $table->string('nama_pelanggan', 100);
                $table->string('no_whatsapp', 20);
                $table->text('alamat_pengiriman');
                $table->unsignedBigInteger('id_produk');
                $table->integer('jumlah_beli');
                $table->decimal('total_harga', 10, 2);
                $table->string('ukuran')->nullable();
                $table->string('metode_pengiriman')->nullable();
                $table->text('catatan')->nullable();
                $table->string('status_pembayaran')->default('Menunggu Pembayaran');
                $table->string('email')->nullable();
                $table->string('bukti_transfer')->nullable();
                $table->timestamps();
            });
        }

// Use default DB/Schema connection after unifying Flutter data into main database
        if (!Schema::hasTable('comments')) {
// Use default DB/Schema connection after unifying Flutter data into main database
            Schema::create('comments', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('user_id');
                $table->unsignedBigInteger('id_produk');
                $table->text('komentar');
                $table->timestamps();
            });
        }

// Use default DB/Schema connection after unifying Flutter data into main database
        if (!Schema::hasTable('users')) {
// Use default DB/Schema connection after unifying Flutter data into main database
            Schema::create('users', function (Blueprint $table) {
                $table->id();
                $table->string('name');
                $table->string('email')->unique();
                $table->string('password');
                $table->rememberToken();
                $table->timestamps();
            });
        }
    }

    public function down(): void
    {
// Use default DB/Schema connection after unifying Flutter data into main database
        Schema::dropIfExists('comments');
// Use default DB/Schema connection after unifying Flutter data into main database
        Schema::dropIfExists('orders');
// Use default DB/Schema connection after unifying Flutter data into main database
        Schema::dropIfExists('products');
// Use default DB/Schema connection after unifying Flutter data into main database
        Schema::dropIfExists('users');
    }
};

