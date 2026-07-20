<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
// Use default DB/Schema connection after unifying Flutter data into main database
        Schema::table('users', function (Blueprint $table) {
// Use default DB/Schema connection after unifying Flutter data into main database
            if (! Schema::hasColumn('users', 'photo')) {
                $table->text('photo')->nullable()->after('password');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
// Use default DB/Schema connection after unifying Flutter data into main database
        Schema::table('users', function (Blueprint $table) {
// Use default DB/Schema connection after unifying Flutter data into main database
            if (Schema::hasColumn('users', 'photo')) {
                $table->dropColumn('photo');
            }
        });
    }
};

