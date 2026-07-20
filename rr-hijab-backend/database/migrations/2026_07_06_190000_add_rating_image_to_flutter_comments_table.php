<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
// Use default DB/Schema connection after unifying Flutter data into main database
        if (Schema::hasTable('comments')) {
// Use default DB/Schema connection after unifying Flutter data into main database
            Schema::table('comments', function (Blueprint $table) {
// Use default DB/Schema connection after unifying Flutter data into main database
                if (! Schema::hasColumn('comments', 'rating')) {
                    $table->unsignedTinyInteger('rating')->default(5)->after('komentar');
                }
// Use default DB/Schema connection after unifying Flutter data into main database
                if (! Schema::hasColumn('comments', 'image_url')) {
                    $table->string('image_url')->nullable()->after('rating');
                }
            });
        }
    }

    public function down(): void
    {
// Use default DB/Schema connection after unifying Flutter data into main database
        if (Schema::hasTable('comments')) {
// Use default DB/Schema connection after unifying Flutter data into main database
            Schema::table('comments', function (Blueprint $table) {
// Use default DB/Schema connection after unifying Flutter data into main database
                if (Schema::hasColumn('comments', 'image_url')) {
                    $table->dropColumn('image_url');
                }
// Use default DB/Schema connection after unifying Flutter data into main database
                if (Schema::hasColumn('comments', 'rating')) {
                    $table->dropColumn('rating');
                }
            });
        }
    }
};

