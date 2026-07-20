<?php

require_once 'vendor/autoload.php';

$app = require_once 'bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\Product;
use Illuminate\Support\Facades\DB;

// Truncate existing products untuk clean state
// DB::table('products')->truncate();

$sampleProducts = [
    [
        'id_admin' => 1,
        'nama_produk' => 'Hijab Premium Katun',
        'deskripsi' => '100% Katun berkualitas premium, lembut dan nyaman digunakan',
        'kategori' => 'Hijab',
        'harga' => 85000,
        'link_foto' => '/images/hijab-katun.jpg',
        'stok' => 50,
        'status' => 'Aktif',
        'is_featured' => 1,
    ],
    [
        'id_admin' => 1,
        'nama_produk' => 'Hijab Chiffon Elegant',
        'deskripsi' => 'Chiffon dengan tekstur halus, cocok untuk acara formal',
        'kategori' => 'Hijab',
        'harga' => 125000,
        'link_foto' => '/images/hijab-chiffon.jpg',
        'stok' => 30,
        'status' => 'Aktif',
        'is_featured' => 1,
    ],
    [
        'id_admin' => 1,
        'nama_produk' => 'Hijab Satin Glossy',
        'deskripsi' => 'Satin berkilau, material premium dengan perpaduan warna menarik',
        'kategori' => 'Hijab',
        'harga' => 95000,
        'link_foto' => '/images/hijab-satin.jpg',
        'stok' => 25,
        'status' => 'Aktif',
        'is_featured' => 0,
    ],
];

try {
    foreach ($sampleProducts as $productData) {
        Product::updateOrCreate(
            ['nama_produk' => $productData['nama_produk']],
            $productData
        );
        echo "✓ Produk '{$productData['nama_produk']}' berhasil ditambahkan\n";
    }
    echo "\n✅ Semua sample data produk berhasil disimpan!\n";
} catch (\Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    echo "Stack trace:\n" . $e->getTraceAsString() . "\n";
}
?>
