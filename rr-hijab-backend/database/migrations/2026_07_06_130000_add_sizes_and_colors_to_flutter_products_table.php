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
            if (!Schema::hasColumn('products', 'available_sizes')) {
                $table->json('available_sizes')->nullable()->after('status');
            }
// Use default DB/Schema connection after unifying Flutter data into main database
            if (!Schema::hasColumn('products', 'available_colors')) {
                $table->json('available_colors')->nullable()->after('available_sizes');
            }
        });
    }

    public function down(): void
    {
// Use default DB/Schema connection after unifying Flutter data into main database
        Schema::table('products', function (Blueprint $table) {
// Use default DB/Schema connection after unifying Flutter data into main database
            if (Schema::hasColumn('products', 'available_colors')) {
                $table->dropColumn('available_colors');
            }
// Use default DB/Schema connection after unifying Flutter data into main database
            if (Schema::hasColumn('products', 'available_sizes')) {
                $table->dropColumn('available_sizes');
            }
        });
    }
};

