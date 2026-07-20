<?php

require __DIR__ . '/../vendor/autoload.php';
$app = require __DIR__ . '/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$db = $app->make('db');

$updates = [
    4 => 'koleksi',
    5 => 'terbaru',
    6 => 'promo',
];

echo "Updating default connection:\n";
foreach ($updates as $id => $section) {
    $affected = $db->table('products')->where('id_produk', $id)->update(['home_section' => $section]);
    echo "id={$id} set to {$section} -> " . ($affected ? 'ok' : 'not found') . "\n";
}

try {
    // Use default DB connection after unifying Flutter data into the main database
    $fdb = $app->make('db');
    echo "\nUpdating default connection:\n";
    foreach ($updates as $id => $section) {
        $affected = $fdb->table('products')->where('id_produk', $id)->update(['home_section' => $section]);
        echo "id={$id} set to {$section} -> " . ($affected ? 'ok' : 'not found') . "\n";
    }
} catch (Throwable $e) {
    echo "default connection error: " . $e->getMessage() . "\n";
}

echo "\nSample rows after update (default):\n";
$rows = $db->table('products')->whereIn('id_produk', array_keys($updates))->get();
foreach ($rows as $r) {
    echo json_encode((array)$r) . PHP_EOL;
}

try {
    // Use default DB connection after unifying Flutter data into the main database
    echo "\nSample rows after update (default):\n";
    $frows = $app->make('db')->table('products')->whereIn('id_produk', array_keys($updates))->get();
    foreach ($frows as $r) {
        echo json_encode((array)$r) . PHP_EOL;
    }
} catch (Throwable $e) {
    echo "default read error: " . $e->getMessage() . "\n";
}
