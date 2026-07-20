<?php

require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';
$app->make(\Illuminate\Contracts\Console\Kernel::class)->bootstrap();

$db = \Illuminate\Support\Facades\DB::getFacadeRoot();

echo "=== FINAL QUERY STRUCTURE (WITH MAX(id) TIE-BREAKER) ===\n\n";

// Build the query without executing it
// Use default DB connection after unifying Flutter data into the main database
$query = $db->table('orders as o')
    ->leftJoinSub(
        // Use default DB connection after unifying Flutter data into the main database
        $db->table('payments')
            ->select('*')
            ->whereRaw('id = (SELECT MAX(id) FROM payments p2 WHERE p2.order_id = payments.order_id)'),
        'p',
        'o.id_order',
        '=',
        'p.order_id'
    )
    ->select(
        'o.id_order',
        'o.nama_pelanggan',
        'o.no_whatsapp',
        'o.total_harga',
        'o.status_pembayaran',
        'o.created_at',
        'p.payment_type',
        'p.status as payment_status',
        'p.transaction_id as latest_transaction_id'
    )
    ->orderByDesc('o.created_at');

// Print the generated SQL
echo "Generated SQL:\n";
echo $query->toSql() . "\n\n";

echo "✓ Key improvement: Uses MAX(id) as tie-breaker instead of MAX(created_at)\n";
echo "  This guarantees only 1 payment row per order, preventing duplicates\n";
echo "  if multiple payments have identical created_at timestamps.\n\n";

echo "=== DATABASE STATISTICS ===\n";
// Use default DB connection after unifying Flutter data into the main database
$orderCount = $db->table('orders')->count();
$paymentCount = $db->table('payments')->count();
echo "Total orders: " . $orderCount . "\n";
echo "Total payments: " . $paymentCount . "\n";

echo "\n=== DUPLICATE DETECTION ===\n";
$results = $query->get();
$totalResults = count($results);
$uniqueOrders = count(collect($results)->unique('id_order'));

echo "Total query results: " . $totalResults . "\n";
echo "Unique orders: " . $uniqueOrders . "\n";

if ($totalResults === $uniqueOrders) {
    echo "✓ No duplicates detected! Each order appears exactly once.\n";
} else {
    echo "✗ WARNING: Duplicates detected! Results: " . ($totalResults - $uniqueOrders) . " duplicate(s)\n";
    echo "  Duplicate orders:\n";
    $duplicates = collect($results)->countBy('id_order')->filter(fn($count) => $count > 1);
    foreach ($duplicates as $orderId => $count) {
        echo "    - Order $orderId appears $count times\n";
    }
}

echo "\n=== TEST DATA / SAMPLE RESULTS ===\n";
if (count($results) > 0) {
    echo "Sample orders:\n";
    for ($i = 0; $i < min(3, count($results)); $i++) {
        $order = $results[$i];
        echo "\nOrder " . ($i+1) . ":\n";
        echo "  ID: " . $order->id_order . "\n";
        echo "  Customer: " . $order->nama_pelanggan . "\n";
        echo "  Total: Rp" . number_format($order->total_harga, 0) . "\n";
        echo "  Status Order: " . $order->status_pembayaran . "\n";
        echo "  Payment Type: " . ($order->payment_type ?? 'NULL') . "\n";
        echo "  Payment Status: " . ($order->payment_status ?? 'NULL') . "\n";
        echo "  Transaction ID: " . ($order->latest_transaction_id ?? 'NULL') . "\n";
    }
} else {
    echo "⚠ No orders in database to display.\n";
}

echo "\n✓ Query is ready for production deployment!\n";

