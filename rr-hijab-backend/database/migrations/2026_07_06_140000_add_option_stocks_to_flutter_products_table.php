<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
// Use default DB/Schema connection after unifying Flutter data into main database
        Schema::table('products', function (Blueprint $table) {
// Use default DB/Schema connection after unifying Flutter data into main database
            if (!Schema::hasColumn('products', 'available_size_stocks')) {
                $table->json('available_size_stocks')->nullable()->after('available_colors');
            }
// Use default DB/Schema connection after unifying Flutter data into main database
            if (!Schema::hasColumn('products', 'available_color_stocks')) {
                $table->json('available_color_stocks')->nullable()->after('available_size_stocks');
            }
        });
    }

    public function down(): void
    {
// Use default DB/Schema connection after unifying Flutter data into main database
        Schema::table('products', function (Blueprint $table) {
// Use default DB/Schema connection after unifying Flutter data into main database
            if (Schema::hasColumn('products', 'available_color_stocks')) {
                $table->dropColumn('available_color_stocks');
            }
// Use default DB/Schema connection after unifying Flutter data into main database
            if (Schema::hasColumn('products', 'available_size_stocks')) {
                $table->dropColumn('available_size_stocks');
            }
        });
    }
};

