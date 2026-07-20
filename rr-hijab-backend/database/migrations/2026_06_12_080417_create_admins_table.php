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
        Schema::create('admins', function (Blueprint $table) {
            $table->id('id_admin'); // Primary Key otomatis sesuai SRS
            $table->string('username', 50)->unique(); // Username untuk login
            $table->string('email', 100)->unique(); // Email cadangan/kontak
            $table->string('password'); // Password aman terenkripsi (Bcrypt)
            $table->timestamps(); // Mencatat waktu akun dibuat/diubah
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('admins');
    }
};
