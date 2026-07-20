<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('products', function (Blueprint $table) {
            // BAGIAN YANG DITAMBAHKAN & DISESUAIKAN DENGAN SRS:
            $table->id('id_produk'); // ID unik produk (PK)
            $table->unsignedBigInteger('id_admin')->nullable(); // Admin yang membuat produk
            $table->string('nama_produk', 255); // Nama jilbab
            $table->text('deskripsi'); // Deskripsi detail
            $table->string('kategori', 100); // Kategori produk
            $table->decimal('harga', 10, 2); // Harga jual
            $table->string('link_foto', 500); // URL foto produk
            $table->integer('stok')->default(0); // Jumlah stok
            $table->enum('status', ['Aktif', 'Tidak Aktif'])->default('Aktif'); // Status produk
            $table->timestamps(); // otomatis membuat created_at dan updated_at
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('products');
    }
};
