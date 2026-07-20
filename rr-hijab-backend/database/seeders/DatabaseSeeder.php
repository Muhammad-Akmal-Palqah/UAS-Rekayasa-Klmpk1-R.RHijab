<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database dengan data master yang bersih
     */
    public function run(): void
    {
        // ============================================================
        // STEP 1: Matikan Foreign Key Constraint untuk menghapus data lama
        // ============================================================
        DB::statement('SET FOREIGN_KEY_CHECKS=0');

        // Hapus semua data sampah dari tabel orders terlebih dahulu (memiliki FK)
        DB::table('orders')->truncate();
        // Hapus semua data sampah dari tabel payments (memiliki FK ke orders)
        DB::table('payments')->truncate();
        // Hapus semua data sampah dari tabel comments
        DB::table('comments')->truncate();
        // Hapus semua data sampah dari tabel products
        DB::table('products')->truncate();
        // Hapus semua data sampah dari tabel users (Flutter)
        DB::table('users')->truncate();
        // Hapus semua data sampah dari tabel admins
        DB::table('admins')->truncate();
        // Hapus semua data sampah dari tabel business_hours
        DB::table('business_hours')->truncate();
        // Hapus semua personal access tokens yang lama
        DB::table('personal_access_tokens')->truncate();

        // Nyalakan kembali Foreign Key Constraint setelah pembersihan
        DB::statement('SET FOREIGN_KEY_CHECKS=1');

        // ============================================================
        // STEP 2: Buat data master - Jam Operasional Bisnis
        // ============================================================
        DB::table('business_hours')->insert([
            [
                // Data hari operasional toko RR Hijab (Senin-Jumat)
                'open_time' => '09:00', // Jam buka pagi
                'close_time' => '17:00', // Jam tutup sore
                'open_days' => json_encode(['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']), // Hari buka dalam format JSON array
                'enabled' => true, // Status operasional aktif
                'created_at' => now(), // Timestamp pembuatan
                'updated_at' => now(), // Timestamp terakhir update
            ],
        ]);

        // ============================================================
        // STEP 3: Buat data master - Admin Accounts
        // ============================================================
        DB::table('admins')->insert([
            [
                // Admin utama untuk manage produk dan order
                'username' => 'admin_rrhijab', // Username untuk login dashboard
                'email' => 'admin@rrhijab.com', // Email admin untuk notifikasi
                'password' => Hash::make('admin@rrhijab123'), // Password di-hash untuk keamanan
                'role' => 'super_admin', // Super Admin: bisa kelola seluruh sistem, termasuk akun admin
                'created_at' => now(), // Timestamp pembuatan akun
                'updated_at' => now(), // Timestamp terakhir update
            ],
            [
                // Admin tambahan untuk backup atau tugas tertentu
                'username' => 'moderator_rrhijab', // Username moderator dengan privilege lebih rendah
                'email' => 'moderator@rrhijab.com', // Email moderator
                'password' => Hash::make('moderator@rrhijab123'), // Password moderator di-hash
                'role' => 'admin', // Admin: hanya kelola toko/web, tidak bisa buat super admin
                'created_at' => now(), // Timestamp pembuatan akun
                'updated_at' => now(), // Timestamp terakhir update
            ],
        ]);

        // ============================================================
        // STEP 4: Buat data master - User Sample (Pembeli)
        // ============================================================
        DB::table('users')->insert([
            [
                // User contoh untuk testing aplikasi Flutter
                'name' => 'Aisyah Miftah', // Nama pembeli sample
                'email' => 'aisyah@example.com', // Email pembeli
                'password' => Hash::make('password123'), // Password di-hash
                'role' => 'user', // Pelanggan aplikasi Flutter/Web
                'photo' => null, // Foto profil belum diunggah
                'email_verified_at' => now(), // Email sudah terverifikasi
                'created_at' => now(), // Timestamp pembuatan akun
                'updated_at' => now(), // Timestamp terakhir update
            ],
            [
                // User contoh kedua untuk testing
                'name' => 'Nabilah Zahra', // Nama pembeli sample lainnya
                'email' => 'nabilah@example.com', // Email pembeli lainnya
                'password' => Hash::make('password123'), // Password di-hash
                'role' => 'user',
                'photo' => null, // Foto profil belum diunggah
                'email_verified_at' => now(), // Email sudah terverifikasi
                'created_at' => now(), // Timestamp pembuatan akun
                'updated_at' => now(), // Timestamp terakhir update
            ],
            [
                // User contoh ketiga untuk testing berbagai scenario
                'name' => 'Siti Nur Aziza', // Nama pembeli sample ketiga
                'email' => 'siti@example.com', // Email pembeli ketiga
                'password' => Hash::make('password123'), // Password di-hash
                'role' => 'user',
                'photo' => null, // Foto profil belum diunggah
                'email_verified_at' => now(), // Email sudah terverifikasi
                'created_at' => now(), // Timestamp pembuatan akun
                'updated_at' => now(), // Timestamp terakhir update
            ],
        ]);

        // Ambil ID admin pertama untuk relasi dengan produk
        $adminId = DB::table('admins')->first()->id_admin; // Dapatkan ID admin utama untuk assign ke produk

        // ============================================================
        // STEP 5: Buat data master - Kategori & Produk
        // ============================================================
        // Catatan: Kategori disimpan sebagai string field di produk (tidak ada tabel kategori terpisah)

        DB::table('products')->insert([
            [
                // Produk 1: Hijab Segi Empat Premium
                'id_admin' => $adminId, // Admin yang membuat produk ini
                'nama_produk' => 'Hijab Bella Square Premium', // Nama produk yang menarik
                'deskripsi' => 'Hijab segi empat premium dengan bahan Pollycotton 100% asli. Tekstur lembut, nyaman di wajah, dan tahan lama. Ukuran 115x115 cm dengan finishing jahitan rapi. Cocok untuk segala usia dan gaya busana.', // Deskripsi detail produk
                'kategori' => 'Segi Empat', // Kategori: Segi Empat
                'harga' => 45000.00, // Harga normal tanpa promo
                'link_foto' => 'https://images.unsplash.com/photo-1609357505561-eb983637cba8?q=80&w=500', // URL foto dari Unsplash
                'stok' => 50, // Stok tersedia di gudang
                'status' => 'Aktif', // Produk aktif dan bisa dijual
                'is_featured' => true, // Produk ini ditampilkan di home screen
                'promo' => null, // Tidak ada promo khusus
                'created_at' => now(), // Timestamp pembuatan produk
                'updated_at' => now(), // Timestamp terakhir update
            ],
            [
                // Produk 2: Pashmina Ceruty Baby Doll
                'id_admin' => $adminId, // Admin yang membuat produk ini
                'nama_produk' => 'Pashmina Ceruty Baby Doll', // Nama produk
                'deskripsi' => 'Pashmina model baby doll dengan tekstur ceruty yang halus dan mudah dibentuk. Bahan polyester berkualitas tinggi yang jatuh sempurna saat dipakai. Panjang 180 cm dengan lebar 70 cm. Tersedia dalam berbagai pilihan warna.', // Deskripsi detail produk
                'kategori' => 'Pashmina', // Kategori: Pashmina
                'harga' => 35000.00, // Harga normal
                'link_foto' => 'https://images.unsplash.com/photo-1618244972963-dbee1a7edc95?q=80&w=500', // URL foto dari Unsplash
                'stok' => 75, // Stok tersedia
                'status' => 'Aktif', // Produk aktif
                'is_featured' => true, // Produk ini ditampilkan di home screen
                'promo' => null, // Tidak ada promo
                'created_at' => now(), // Timestamp pembuatan produk
                'updated_at' => now(), // Timestamp terakhir update
            ],
            [
                // Produk 3: Hijab Instan Bergo
                'id_admin' => $adminId, // Admin yang membuat produk ini
                'nama_produk' => 'Hijab Instan Bergo Instant', // Nama produk
                'deskripsi' => 'Hijab instan model bergo yang praktis dan cepat dipakai. Sudah dilengkapi peniti dan dalaman yang nyaman. Bahan jersey yang elastis dan breathable. Cocok untuk aktivitas sehari-hari maupun acara formal.', // Deskripsi detail produk
                'kategori' => 'Instan', // Kategori: Instan
                'harga' => 55000.00, // Harga normal
                'link_foto' => 'https://images.unsplash.com/photo-1599599810694-b5ac4dd64b73?q=80&w=500', // URL foto dari Unsplash
                'stok' => 40, // Stok tersedia
                'status' => 'Aktif', // Produk aktif
                'is_featured' => false, // Produk ini tidak ditampilkan di home screen
                'promo' => null, // Tidak ada promo
                'created_at' => now(), // Timestamp pembuatan produk
                'updated_at' => now(), // Timestamp terakhir update
            ],
            [
                // Produk 4: Hijab Voal Motif
                'id_admin' => $adminId, // Admin yang membuat produk ini
                'nama_produk' => 'Hijab Voal Motif Geometri', // Nama produk
                'deskripsi' => 'Hijab voal dengan motif geometri modern yang stylish. Bahan voal yang tipis dan adem, sangat cocok untuk musim panas. Ukuran 120x120 cm dengan desain eksklusif dari desainer lokal.', // Deskripsi detail produk
                'kategori' => 'Voal', // Kategori: Voal
                'harga' => 38000.00, // Harga normal
                'link_foto' => 'https://images.unsplash.com/photo-1595808920846-79cfd14c57eb?q=80&w=500', // URL foto dari Unsplash
                'stok' => 60, // Stok tersedia
                'status' => 'Aktif', // Produk aktif
                'is_featured' => true, // Produk ini ditampilkan di home screen
                'promo' => 'Diskon 10% untuk pembelian 3 pcs', // Ada promo khusus
                'created_at' => now(), // Timestamp pembuatan produk
                'updated_at' => now(), // Timestamp terakhir update
            ],
            [
                // Produk 5: Hijab Silk Glossy Premium
                'id_admin' => $adminId, // Admin yang membuat produk ini
                'nama_produk' => 'Hijab Silk Glossy Premium', // Nama produk
                'deskripsi' => 'Hijab segi empat dengan bahan sutra glossy yang berkilau elegan. Tekstur halus dan lembut di kulit, nyaman untuk pemakaian jangka panjang. Ukuran 115x115 cm dengan tampilan premium yang cocok untuk acara formal.', // Deskripsi detail produk
                'kategori' => 'Segi Empat', // Kategori: Segi Empat
                'harga' => 85000.00, // Harga premium
                'link_foto' => 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?q=80&w=500', // URL foto dari Unsplash
                'stok' => 25, // Stok terbatas
                'status' => 'Aktif', // Produk aktif
                'is_featured' => true, // Produk ini ditampilkan di home screen
                'promo' => null, // Tidak ada promo
                'created_at' => now(), // Timestamp pembuatan produk
                'updated_at' => now(), // Timestamp terakhir update
            ],
        ]);

        // ============================================================
        // SEEDER SELESAI - DATABASE SIAP DENGAN DATA BERSIH
        // ============================================================
        // Catatan: Order, Payment, dan Comment akan dibuat saat user melakukan transaksi
        // Jangan buat sample data transaksi untuk menjaga database tetap bersih dan proper
    }
}


