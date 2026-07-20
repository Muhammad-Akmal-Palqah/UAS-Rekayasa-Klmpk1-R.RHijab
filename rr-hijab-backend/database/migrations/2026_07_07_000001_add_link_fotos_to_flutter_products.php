<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
// Use default DB/Schema connection after unifying Flutter data into main database
        if (Schema::hasTable('products')) {
// Use default DB/Schema connection after unifying Flutter data into main database
            Schema::table('products', function (Blueprint $table) {
// Use default DB/Schema connection after unifying Flutter data into main database
                if (! Schema::hasColumn('products', 'link_fotos')) {
                    $table->text('link_fotos')->nullable()->after('link_foto');
                }
            });
        }
    }

    public function down(): void
    {
// Use default DB/Schema connection after unifying Flutter data into main database
        if (Schema::hasTable('products')) {
// Use default DB/Schema connection after unifying Flutter data into main database
            Schema::table('products', function (Blueprint $table) {
// Use default DB/Schema connection after unifying Flutter data into main database
                if (Schema::hasColumn('products', 'link_fotos')) {
                    $table->dropColumn('link_fotos');
                }
            });
        }
    }
};

