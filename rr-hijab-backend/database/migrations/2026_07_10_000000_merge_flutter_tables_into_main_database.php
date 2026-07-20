<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Pastikan tabel products utama memiliki kolom tambahan dari Flutter
        if (Schema::hasTable('products')) {
            Schema::table('products', function (Blueprint $table) {
                if (!Schema::hasColumn('products', 'is_featured')) {
                    $table->boolean('is_featured')->default(false)->after('link_foto'); // tanda produk unggulan dari Flutter
                }

                if (!Schema::hasColumn('products', 'promo')) {
                    $table->string('promo')->nullable()->after('is_featured'); // jalur promo / diskon dari Flutter
                }
            });
        }

        // Tambahkan kolom pesanan Flutter yang belum ada di tabel orders utama
        if (Schema::hasTable('orders')) {
            Schema::table('orders', function (Blueprint $table) {
                if (!Schema::hasColumn('orders', 'user_id')) {
                    $table->unsignedBigInteger('user_id')->nullable()->after('id_order'); // relasi user Flutter
                }

                if (!Schema::hasColumn('orders', 'email')) {
                    $table->string('email')->nullable()->after('nama_pelanggan'); // email pembeli optional dari Flutter
                }

                if (!Schema::hasColumn('orders', 'ukuran')) {
                    $table->string('ukuran')->nullable()->after('jumlah_beli'); // ukuran produk yang dibeli
                }

                if (!Schema::hasColumn('orders', 'metode_pengiriman')) {
                    $table->string('metode_pengiriman')->nullable()->after('ukuran'); // metode pengiriman order Flutter
                }

                if (!Schema::hasColumn('orders', 'catatan')) {
                    $table->text('catatan')->nullable()->after('metode_pengiriman'); // catatan tambahan buyer
                }
            });

            if ($this->hasForeignKey('orders', 'orders_user_id_foreign') === false && Schema::hasColumn('orders', 'user_id')) {
                DB::statement('ALTER TABLE `orders` ADD CONSTRAINT `orders_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL');
            }
        }

        // Buat tabel payments di database utama berdasarkan struktur Flutter
        if (!Schema::hasTable('payments')) {
            Schema::create('payments', function (Blueprint $table) {
                $table->id(); // PK otomatis
                $table->unsignedBigInteger('order_id'); // relasi ke pesanan
                $table->unsignedBigInteger('user_id')->nullable(); // relasi ke user
                $table->string('transaction_id')->unique(); // id transaksi Midtrans
                $table->decimal('amount', 12, 2); // jumlah yang dibayarkan
                $table->string('payment_type')->nullable(); // tipe pembayaran seperti gopay atau qris
                $table->string('status')->default('pending'); // status Midtrans / transaksi
                $table->json('midtrans_response')->nullable(); // payload response Midtrans
                $table->string('qr_code_url')->nullable(); // url QRIS bila ada
                $table->string('deeplink_redirect')->nullable(); // deeplink pembayaran
                $table->timestamp('expired_at')->nullable(); // waktu kadaluarsa payment link
                $table->timestamp('paid_at')->nullable(); // waktu pembayaran diterima
                $table->timestamps(); // created_at dan updated_at

                $table->foreign('order_id')
                    ->references('id_order')
                    ->on('orders')
                    ->onDelete('cascade'); // hapus payment saat order dihapus

                $table->foreign('user_id')
                    ->references('id')
                    ->on('users')
                    ->onDelete('set null'); // user dihapus tidak menghapus payment

                $table->index('transaction_id'); // optimasi pencarian transaksi
                $table->index('order_id');
                $table->index('user_id');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        if (Schema::hasTable('payments')) {
            Schema::dropIfExists('payments'); // hapus tabel payment utama bila rollback
        }

        if (Schema::hasTable('orders')) {
            Schema::table('orders', function (Blueprint $table) {
                if (Schema::hasColumn('orders', 'user_id')) {
                    $table->dropForeign(['user_id']); // hapus constraint relasi user
                    $table->dropColumn('user_id');
                }

                if (Schema::hasColumn('orders', 'email')) {
                    $table->dropColumn('email');
                }

                if (Schema::hasColumn('orders', 'ukuran')) {
                    $table->dropColumn('ukuran');
                }

                if (Schema::hasColumn('orders', 'metode_pengiriman')) {
                    $table->dropColumn('metode_pengiriman');
                }

                if (Schema::hasColumn('orders', 'catatan')) {
                    $table->dropColumn('catatan');
                }
            });
        }

        if (Schema::hasTable('products')) {
            Schema::table('products', function (Blueprint $table) {
                if (Schema::hasColumn('products', 'is_featured')) {
                    $table->dropColumn('is_featured');
                }

                if (Schema::hasColumn('products', 'promo')) {
                    $table->dropColumn('promo');
                }
            });
        }
    }

    private function hasForeignKey(string $table, string $constraintName): bool
    {
        $connection = DB::connection();
        $database = $connection->getDatabaseName();

        $result = DB::selectOne(
            'SELECT CONSTRAINT_NAME FROM information_schema.TABLE_CONSTRAINTS WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ? AND CONSTRAINT_NAME = ? AND CONSTRAINT_TYPE = ? LIMIT 1',
            [$database, $table, $constraintName, 'FOREIGN KEY']
        );

        return $result !== null;
    }
};
