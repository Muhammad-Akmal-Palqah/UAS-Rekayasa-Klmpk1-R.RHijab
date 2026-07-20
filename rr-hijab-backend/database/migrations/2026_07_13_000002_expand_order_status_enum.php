<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        DB::statement("ALTER TABLE `orders` MODIFY COLUMN `status_pembayaran` ENUM('Menunggu Pembayaran','Diproses','Sudah Dibayar','Selesai','Pembayaran Gagal','Dibatalkan Pelanggan','Dibatalkan Sistem') NOT NULL DEFAULT 'Menunggu Pembayaran'");
    }

    public function down(): void
    {
        DB::statement("ALTER TABLE `orders` MODIFY COLUMN `status_pembayaran` ENUM('Menunggu Pembayaran','Diproses','Selesai','Dibatalkan Pelanggan','Dibatalkan Sistem') NOT NULL DEFAULT 'Menunggu Pembayaran'");
    }
};
