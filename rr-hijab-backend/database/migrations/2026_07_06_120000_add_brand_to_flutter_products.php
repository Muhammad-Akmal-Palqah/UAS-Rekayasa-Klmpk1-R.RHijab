<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
// Use default DB/Schema connection after unifying Flutter data into main database
        if (! Schema::hasColumn('products', 'brand')) {
// Use default DB/Schema connection after unifying Flutter data into main database
            Schema::table('products', function (Blueprint $table) {
                $table->string('brand')->nullable()->after('nama_produk');
            });
        }
    }

    public function down(): void
    {
// Use default DB/Schema connection after unifying Flutter data into main database
        if (Schema::hasColumn('products', 'brand')) {
// Use default DB/Schema connection after unifying Flutter data into main database
            Schema::table('products', function (Blueprint $table) {
                $table->dropColumn('brand');
            });
        }
    }
};

