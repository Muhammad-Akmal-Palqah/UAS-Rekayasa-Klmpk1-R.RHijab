<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

/**
 * Seeder untuk kategori produk & master data
 * Gunakan: php artisan db:seed --class=ProductCategorySeeder
 * 
 * Seeder ini berisi daftar kategori produk hijab yang tersedia di sistem
 * Berguna untuk validasi kategori dan reference di berbagai tempat
 */
class ProductCategorySeeder extends Seeder
{
    /**
     * Run the database seeds untuk kategori produk
     */
    public function run(): void
    {
        // ============================================================
        // KATEGORI PRODUK HIJAB DI RR HIJAB
        // ============================================================
        // Catatan: Kategori disimpan sebagai string di field 'kategori' di tabel products
        // Ini adalah referensi/dokumentasi kategori apa saja yang bisa ada
        
        // Untuk melihat semua kategori yang digunakan:
        // SELECT DISTINCT kategori FROM products WHERE status = 'Aktif';
        
        $categories = [
            // Kategori utama 1: Segi Empat
            // Hijab dengan bentuk persegi yang bisa dilipat berbagai cara
            // Ukuran standar: 115x115 cm, 120x120 cm
            // Cocok untuk: hijab sehari-hari, acara formal
            'Segi Empat',
            
            // Kategori utama 2: Pashmina
            // Hijab dengan tekstur ceruty yang lembut dan mudah dibentuk
            // Ukuran standar: 180x70 cm
            // Cocok untuk: hijab modern, casual, santai
            'Pashmina',
            
            // Kategori utama 3: Voal
            // Hijab dengan bahan voal yang ringan dan tipis
            // Ukuran standar: 120x120 cm
            // Cocok untuk: musim panas, hijab tipis
            'Voal',
            
            // Kategori utama 4: Instan
            // Hijab siap pakai yang sudah berbentuk dan dilengkapi aksesoris
            // Jenis: Bergo, Bergo instan dengan bros, dll
            // Cocok untuk: hijab praktis, cepat dipakai
            'Instan',
            
            // Kategori utama 5: Jilbab Bergo
            // Jilbab bergo panjang yang sudah terstruktur
            // Ukuran: Standar, Large, Extra Large
            // Cocok untuk: acara formal, shalat, kegiatan penting
            'Jilbab Bergo',
            
            // Kategori tambahan: Aksesoris
            // Aksesori tambahan untuk melengkapi hijab
            // Contoh: Bros hijab, pin, peniti, inner cap, dll
            'Aksesoris',
        ];

        // ============================================================
        // INFORMASI UNTUK DEVELOPER
        // ============================================================
        // Catatan penting tentang struktur kategori:
        // 
        // 1. Kategori disimpan di field 'kategori' (VARCHAR 100) di tabel products
        // 2. TIDAK ada tabel terpisah untuk kategori (disimpan langsung di produk)
        // 3. Untuk validasi kategori, gunakan array ini atau query distinct
        // 4. Jika ingin menambah kategori baru:
        //    - Tambahkan ke array $categories di atas
        //    - Update dokumentasi
        //    - Rerun seeder ini agar list up-to-date
        
        // ============================================================
        // OUTPUT INFORMASI KE CONSOLE
        // ============================================================
        $this->command->line('');
        $this->command->info('╔══════════════════════════════════════════════╗');
        $this->command->info('║ KATEGORI PRODUK HIJAB RR HIJAB TERSEDIA ║');
        $this->command->info('╚══════════════════════════════════════════════╝');
        
        // Loop dan tampilkan semua kategori
        foreach ($categories as $index => $category) {
            // Format nomor dengan padding untuk alignment yang rapi
            $number = str_pad($index + 1, 2, '0', STR_PAD_LEFT); // Nomor 01, 02, dst
            // Tampilkan dengan icon bullet point
            $this->command->line("   → {$number}. {$category}"); // Tampilkan kategori dengan format rapi
        }
        
        $this->command->line('');
        $this->command->info('✓ Total ' . count($categories) . ' kategori produk tersedia'); // Hitung total kategori
        $this->command->info('ℹ Gunakan kategori ini saat membuat produk baru'); // Reminder untuk gunakan kategori
        $this->command->line('');

        // ============================================================
        // STATISTIK: CEK KATEGORI YANG SEDANG DIGUNAKAN
        // ============================================================
        // Query untuk lihat kategori mana saja yang sudah ada di database
        $usedCategories = DB::table('products') // Ambil dari tabel products
            ->where('status', 'Aktif') // Hanya produk yang aktif
            ->distinct() // Jangan duplikat
            ->pluck('kategori') // Ambil field kategori saja
            ->sort() // Sorting A-Z
            ->values(); // Reset index array

        // Tampilkan hasil query jika ada produk
        if ($usedCategories->count() > 0) {
            $this->command->warn('Kategori yang sedang digunakan di produk aktif:'); // Header
            foreach ($usedCategories as $cat) {
                // Hitung berapa produk yang pakai kategori ini
                $count = DB::table('products') // Ambil dari tabel products
                    ->where('kategori', $cat) // Filter kategori yang sesuai
                    ->where('status', 'Aktif') // Hanya produk aktif
                    ->count(); // Hitung jumlah
                // Tampilkan kategori dan jumlah produk
                $this->command->line("   • {$cat} ({$count} produk)");
            }
        } else {
            // Jika tidak ada produk
            $this->command->comment('   (Belum ada produk dengan kategori apapun)');
        }
        
        $this->command->line('');
    }
}
