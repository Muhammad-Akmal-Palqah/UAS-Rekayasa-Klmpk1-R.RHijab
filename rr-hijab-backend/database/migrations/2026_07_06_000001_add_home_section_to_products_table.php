<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Tambah kolom home_section ke tabel default products jika belum ada
        if (Schema::hasTable('products') && ! Schema::hasColumn('products', 'home_section')) {
            Schema::table('products', function (Blueprint $table) {
                $table->string('home_section')->nullable()->after('is_featured');
            });
        }

        // Tambah kolom home_section ke tabel flutter.products jika koneksi dan tabel ada
        try {
// Use default DB/Schema connection after unifying Flutter data into main database
            if (Schema::hasTable('products') && ! Schema::hasColumn('products', 'home_section')) {
// Use default DB/Schema connection after unifying Flutter data into main database
                Schema::table('products', function (Blueprint $table) {
                    $table->string('home_section')->nullable()->after('is_featured');
                });
            }
        } catch (\Throwable $e) {
            // jika koneksi flutter belum dikonfigurasi, abaikan
        }
    }

    public function down(): void
    {
        if (Schema::hasTable('products') && Schema::hasColumn('products', 'home_section')) {
            Schema::table('products', function (Blueprint $table) {
                $table->dropColumn('home_section');
            });
        }

        try {
// Use default DB/Schema connection after unifying Flutter data into main database
            if (Schema::hasTable('products') && Schema::hasColumn('products', 'home_section')) {
// Use default DB/Schema connection after unifying Flutter data into main database
                Schema::table('products', function (Blueprint $table) {
                    $table->dropColumn('home_section');
                });
            }
        } catch (\Throwable $e) {
        }
    }
};

