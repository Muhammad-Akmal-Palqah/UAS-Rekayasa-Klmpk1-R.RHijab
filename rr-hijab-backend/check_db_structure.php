<?php

require_once 'vendor/autoload.php';

$app = require_once 'bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use Illuminate\Support\Facades\DB;

// Query directly to see table structure
$columns = DB::select("DESCRIBE products");

echo "Struktur tabel products:\n";
echo "======================\n";
foreach ($columns as $col) {
    if ($col->Field === 'status') {
        echo "Field: {$col->Field}\n";
        echo "Type: {$col->Type}\n";
        echo "Null: {$col->Null}\n";
        echo "Key: {$col->Key}\n";
        echo "Default: {$col->Default}\n";
        echo "Extra: {$col->Extra}\n";
    }
}

// Check existing products
echo "\n\nExisting Products:\n";
echo "==================\n";
$products = DB::table('products')->select('id_produk', 'nama_produk', 'harga', 'stok', 'status')->get();
foreach ($products as $p) {
    echo "- {$p->nama_produk} (Status: {$p->status}, Harga: {$p->harga}, Stok: {$p->stok})\n";
}
echo "\nTotal: " . count($products) . " produk\n";
?>
