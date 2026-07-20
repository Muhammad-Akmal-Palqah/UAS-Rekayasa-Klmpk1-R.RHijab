<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Update enum values to match SRS
        DB::statement("ALTER TABLE `orders` MODIFY COLUMN `status_pembayaran` ENUM('Menunggu Pembayaran','Diproses','Selesai','Dibatalkan Pelanggan','Dibatalkan Sistem') NOT NULL DEFAULT 'Menunggu Pembayaran'");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Revert to previous enum values
        DB::statement("ALTER TABLE `orders` MODIFY COLUMN `status_pembayaran` ENUM('Belum Bayar','Menunggu Validasi','Selesai') NOT NULL DEFAULT 'Belum Bayar'");
    }
};
