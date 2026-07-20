<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
// Use default DB/Schema connection after unifying Flutter data into main database
        Schema::table('orders', function (Blueprint $table) {
            // Some DB drivers require foreign key names to be unique; Laravel will generate automatically
// Use default DB/Schema connection after unifying Flutter data into main database
            if (! Schema::hasColumn('orders', 'user_id')) {
                return;
            }

            // Add foreign key if it doesn't exist. There's no portable way to check FK existence
            // so we attempt to add it and rely on migrations to run only once.
            $table->foreign('user_id')
                ->references('id')
                ->on('users')
                ->onDelete('set null');
        });
    }

    public function down(): void
    {
// Use default DB/Schema connection after unifying Flutter data into main database
        Schema::table('orders', function (Blueprint $table) {
            // Drop the foreign key if exists. Use convention-based name.
            try {
                $table->dropForeign(['user_id']);
            } catch (\Exception $e) {
                // ignore if it doesn't exist
            }
        });
    }
};

