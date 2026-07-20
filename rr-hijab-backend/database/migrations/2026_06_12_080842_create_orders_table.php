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
        Schema::create('orders', function (Blueprint $table) {
            $table->id('id_order'); // Primary Key
            $table->string('nama_pelanggan', 100);
            $table->string('no_whatsapp', 20); // Nomor HP untuk n8n kirim WA otomatis
            $table->text('alamat_pengiriman');
            
            // Relasi ke produk yang dibeli
            $table->unsignedBigInteger('id_produk');
            $table->integer('jumlah_beli');
            $table->decimal('total_harga', 10, 2);
            
            // Data Bukti Transfer & Status Validasi Admin
            $table->string('bukti_transfer')->nullable(); // Menyimpan nama file foto struk
            // Enum values updated to match SRS: Menunggu Pembayaran, Diproses, Selesai, Dibatalkan Pelanggan, Dibatalkan Sistem
            $table->enum('status_pembayaran', ['Menunggu Pembayaran', 'Diproses', 'Selesai', 'Dibatalkan Pelanggan', 'Dibatalkan Sistem'])->default('Menunggu Pembayaran');
            
            // Relasi ke admin yang memvalidasi pembayaran
            $table->unsignedBigInteger('id_admin')->nullable();
            
            $table->timestamps();

            // Set Foreign Key agar data terikat kuat di MySQL
            $table->foreign('id_produk')->references('id_produk')->on('products')->onDelete('cascade');
            $table->foreign('id_admin')->references('id_admin')->on('admins')->onDelete('set null');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('orders');
    }
};
