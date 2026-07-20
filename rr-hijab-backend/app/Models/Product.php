<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    // // 💡 Pastikan model ini menembak tabel utama 'products' yang digunakan bersama
    protected $table = 'products';

    protected $primaryKey = 'id_produk';

    // // 💡 Menggabungkan semua kolom input untuk keperluan panel Web Admin dan Aplikasi Flutter
    protected $fillable = [
        'id_admin',
        'nama_produk',
        'deskripsi',
        'kategori',
        'harga',
        'link_foto',             // Foto utama produk (Web & Flutter)
        'link_fotos',            // Galeri foto tambahan berbentuk JSON Array
        'promo',
        'home_section',          // Pengondisian letak produk di beranda aplikasi
        'stok',                  // Stok global
        'status',
        'is_featured',
        'available_sizes',       // Kebutuhan Flutter: Daftar ukuran tersedia
        'available_colors',      // Kebutuhan Flutter: Daftar warna tersedia
        'available_size_stocks', // Kebutuhan Flutter: Detail stok per ukuran
        'available_color_stocks',// Kebutuhan Flutter: Detail stok per warna
    ];

    // // 💡 Casts sangat penting agar Flutter menerima format data JSON asli (Array/Boolean), bukan String text
    protected $casts = [
        'is_featured' => 'boolean',
        'available_sizes' => 'array',
        'available_colors' => 'array',
        'available_size_stocks' => 'array',
        'available_color_stocks' => 'array',
        'link_fotos' => 'array',
    ];

    public function getPromoPercentAttribute(): ?float
    {
        if (empty($this->promo) || !is_string($this->promo)) {
            return null;
        }

        if (preg_match('/(\d+(?:[\.,]\d*)?)\s*%/', $this->promo, $matches)) {
            $percent = floatval(str_replace(',', '.', $matches[1]));
            return min(100, max(0, $percent));
        }

        return null;
    }

    public function getHargaAfterPromoAttribute(): float
    {
        $harga = (float) $this->harga;
        $percent = $this->promo_percent;

        if ($percent === null) {
            return $harga;
        }

        $discounted = $harga * (100 - $percent) / 100;
        return round(max(0, $discounted), 2);
    }

    public function hasPromoPercent(): bool
    {
        return $this->promo_percent !== null;
    }

    public function comments()
{
    return $this->hasMany(Comment::class, 'id_produk', 'id_produk');
}

}