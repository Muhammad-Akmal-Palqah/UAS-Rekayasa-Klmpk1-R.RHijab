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
        Schema::create('payments', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('order_id');
            $table->unsignedBigInteger('user_id')->nullable();
            $table->string('transaction_id')->nullable()->unique();
            $table->decimal('amount', 12, 2);
            $table->string('payment_type')->nullable(); // 'gopay' atau 'qris'
            $table->string('status')->default('pending'); // pending, settlement, expire, cancel, deny
            $table->json('midtrans_response')->nullable();
            $table->string('qr_code_url')->nullable();
            $table->string('deeplink_redirect')->nullable();
            $table->timestamp('expired_at')->nullable();
            $table->timestamp('paid_at')->nullable();
            $table->timestamps();

            // Foreign keys
            $table->foreign('order_id')
                ->references('id_order')
                ->on('orders')
                ->onDelete('cascade');

            $table->foreign('user_id')
                ->references('id')
                ->on('users')
                ->onDelete('set null');

            // Indexes
            $table->index('transaction_id');
            $table->index('order_id');
            $table->index('user_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
// Use default DB/Schema connection after unifying Flutter data into main database
        Schema::dropIfExists('payments');
    }
};

