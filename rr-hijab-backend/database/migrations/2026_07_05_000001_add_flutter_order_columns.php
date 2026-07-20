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
// Use default DB/Schema connection after unifying Flutter data into main database
            if (!Schema::hasColumn('orders', 'id_tele')) {
                $table->string('id_tele')->nullable()->after('no_whatsapp');
            }

// Use default DB/Schema connection after unifying Flutter data into main database
            if (!Schema::hasColumn('orders', 'id_admin')) {
                $table->unsignedBigInteger('id_admin')->nullable()->after('status_pembayaran');
            }
        });
    }

    public function down(): void
    {
// Use default DB/Schema connection after unifying Flutter data into main database
        Schema::table('orders', function (Blueprint $table) {
// Use default DB/Schema connection after unifying Flutter data into main database
            if (Schema::hasColumn('orders', 'id_admin')) {
                $table->dropColumn('id_admin');
            }

// Use default DB/Schema connection after unifying Flutter data into main database
            if (Schema::hasColumn('orders', 'id_tele')) {
                $table->dropColumn('id_tele');
            }
        });
    }
};

