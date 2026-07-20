<?php

use App\Models\Product;

// Insert sample data produk
$sampleProducts = [
    [
        'id_admin' => 1,
        'nama_produk' => 'Hijab Premium Katun',
        'deskripsi' => '100% Katun berkualitas premium, lembut dan nyaman digunakan',
        'kategori' => 'Hijab',
        'harga' => 85000,
        'link_foto' => '/images/hijab-katun.jpg',
        'promo' => null,
        'home_section' => 'featured',
        'stok' => 50,
        'status' => 'active',
        'is_featured' => true,
    ],
    [
        'id_admin' => 1,
        'nama_produk' => 'Hijab Chiffon Elegant',
        'deskripsi' => 'Chiffon dengan tekstur halus, cocok untuk acara formal',
        'kategori' => 'Hijab',
        'harga' => 125000,
        'link_foto' => '/images/hijab-chiffon.jpg',
        'promo' => '10%',
        'home_section' => 'featured',
        'stok' => 30,
        'status' => 'active',
        'is_featured' => true,
    ],
    [
        'id_admin' => 1,
        'nama_produk' => 'Hijab Satin Glossy',
        'deskripsi' => 'Satin berkilau, material premium dengan perpaduan warna menarik',
        'kategori' => 'Hijab',
        'harga' => 95000,
        'link_foto' => '/images/hijab-satin.jpg',
        'promo' => null,
        'home_section' => 'normal',
        'stok' => 25,
        'status' => 'active',
        'is_featured' => false,
    ],
    [
        'id_admin' => 1,
        'nama_produk' => 'Hijab Cotton Pastel',
        'deskripsi' => 'Warna pastel yang lembut, bahan cotton breathable',
        'kategori' => 'Hijab',
        'harga' => 75000,
        'link_foto' => '/images/hijab-pastel.jpg',
        'promo' => null,
        'home_section' => 'normal',
        'stok' => 0,
        'status' => 'active',
        'is_featured' => false,
    ],
];

try {
    foreach ($sampleProducts as $productData) {
        Product::updateOrCreate(
            ['nama_produk' => $productData['nama_produk']],
            $productData
        );
        echo "✓ Produk '{$productData['nama_produk']}' berhasil disimpan\n";
    }
    echo "\n✅ Semua sample data produk berhasil ditambahkan!\n";
} catch (\Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
?>
