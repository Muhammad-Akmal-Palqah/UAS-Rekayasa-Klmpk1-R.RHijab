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
        Schema::table('orders', function (Blueprint $table) {
            $table->string('ukuran', 20)->nullable()->after('total_harga');
            $table->string('metode_pengiriman', 50)->nullable()->after('ukuran');
            $table->text('catatan')->nullable()->after('metode_pengiriman');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->dropColumn(['ukuran', 'metode_pengiriman', 'catatan']);
        });
    }
};
