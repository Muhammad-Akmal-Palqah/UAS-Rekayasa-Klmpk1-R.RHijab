<?php

require __DIR__ . '/../vendor/autoload.php';
$app = require __DIR__ . '/../bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

$db = $app->make('db');
$schema = $db->getSchemaBuilder();

echo "default_has_home_section: " . ($schema->hasColumn('products', 'home_section') ? 'yes' : 'no') . PHP_EOL;

$rows = $db->table('products')->limit(3)->get();
if (count($rows) === 0) {
    echo "default_products: none\n";
} else {
    foreach ($rows as $r) {
        echo json_encode((array) $r) . PHP_EOL;
    }
}

try {
    // Use default DB connection after unifying Flutter data into the main database
    $fdb = $app->make('db');
    $fschema = $fdb->getSchemaBuilder();
    echo "default_has_home_section: " . ($fschema->hasColumn('products', 'home_section') ? 'yes' : 'no') . PHP_EOL;
    $frows = $fdb->table('products')->limit(3)->get();
    if (count($frows) === 0) {
        echo "default_products: none\n";
    } else {
        foreach ($frows as $r) {
            echo json_encode((array) $r) . PHP_EOL;
        }
    }
} catch (Throwable $e) {
    echo 'default_error: ' . $e->getMessage() . PHP_EOL;
}
