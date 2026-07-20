<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

/**
 * Seeder untuk membersihkan database dari semua data
 * Gunakan: php artisan db:seed --class=CleanDatabaseSeeder
 * 
 * Ini akan menghapus semua data tapi TIDAK akan membuat data master baru
 * Setelah menggunakan ini, jalankan DatabaseSeeder untuk membuat data bersih
 */
class CleanDatabaseSeeder extends Seeder
{
    /**
     * Bersihkan database dengan menghapus semua data dari tabel
     */
    public function run(): void
    {
        // ============================================================
        // LANGKAH 1: Matikan Foreign Key Constraint untuk truncate
        // ============================================================
        // Disable temporary untuk mencegah error saat truncate table dengan FK
        DB::statement('SET FOREIGN_KEY_CHECKS=0');

        // ============================================================
        // LANGKAH 2: Hapus semua data dari tabel (dalam urutan yang tepat)
        // ============================================================
        
        // Hapus orders terlebih dahulu karena banyak FK menunjuk kepadanya
        if (DB::table('orders')->exists()) {
            DB::table('orders')->truncate(); // Bersihkan semua order lama
        }

        // Hapus payments yang berelasi ke orders
        if (DB::table('payments')->exists()) {
            DB::table('payments')->truncate(); // Bersihkan semua payment lama
        }

        // Hapus comments yang bisa berelasi ke produk/order
        if (DB::table('comments')->exists()) {
            DB::table('comments')->truncate(); // Bersihkan semua comment lama
        }

        // Hapus products dengan FK ke admins
        if (DB::table('products')->exists()) {
            DB::table('products')->truncate(); // Bersihkan semua produk lama
        }

        // Hapus personal access tokens (Sanctum tokens)
        if (DB::table('personal_access_tokens')->exists()) {
            DB::table('personal_access_tokens')->truncate(); // Bersihkan semua token lama
        }

        // Hapus users yang mungkin memiliki FK di orders
        if (DB::table('users')->exists()) {
            DB::table('users')->truncate(); // Bersihkan semua user lama
        }

        // Hapus admins yang memiliki FK di products dan orders
        if (DB::table('admins')->exists()) {
            DB::table('admins')->truncate(); // Bersihkan semua admin lama
        }

        // Hapus business hours
        if (DB::table('business_hours')->exists()) {
            DB::table('business_hours')->truncate(); // Bersihkan business hours lama
        }

        // ============================================================
        // LANGKAH 3: Enable kembali Foreign Key Constraint
        // ============================================================
        // Enable ulang untuk menjaga integritas data
        DB::statement('SET FOREIGN_KEY_CHECKS=1');

        // Informasi untuk user
        $this->command->info('✓ Database berhasil dibersihkan dari semua data lama');
        $this->command->info('→ Sekarang jalankan: php artisan db:seed --class=DatabaseSeeder');
        $this->command->info('  untuk mengisi database dengan data master yang bersih');
    }
}
