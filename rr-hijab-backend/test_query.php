<?php

require 'vendor/autoload.php';
$app = require_once 'bootstrap/app.php';

// Boot the application
$app->make(\Illuminate\Contracts\Console\Kernel::class)->bootstrap();

$db = \Illuminate\Support\Facades\DB::getFacadeRoot();

echo "Testing FIXED LEFT JOIN query with leftJoinSub()...\n\n";

try {
    // Use default DB connection after unifying Flutter data into the main database
    $orders = $db->table('orders as o')
        ->leftJoinSub(
            $db->table('payments')
                ->select('*')
                ->whereRaw('created_at = (SELECT MAX(created_at) FROM payments p2 WHERE p2.order_id = payments.order_id)'),
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
        ->orderByDesc('o.created_at')
        ->get();
    
    echo "✓ Query succeeded! Found " . count($orders) . " orders.\n\n";
    
    if (count($orders) > 0) {
        echo "First 3 orders:\n";
        echo str_repeat("=", 100) . "\n";
        for ($i = 0; $i < min(3, count($orders)); $i++) {
            $order = $orders[$i];
            $orderNum = $i + 1;
            echo "Order #" . $orderNum . ":\n";
            echo "  ID: " . $order->id_order . "\n";
            echo "  Customer: " . $order->nama_pelanggan . "\n";
            echo "  Total: Rp" . number_format($order->total_harga, 0) . "\n";
            echo "  Status Order: " . $order->status_pembayaran . "\n";
            echo "  Payment Type: " . ($order->payment_type ?? 'N/A') . "\n";
            echo "  Payment Status: " . ($order->payment_status ?? 'N/A') . "\n";
            echo "  Transaction ID: " . ($order->latest_transaction_id ?? 'N/A') . "\n";
            echo str_repeat("-", 100) . "\n";
        }
    } else {
        echo "⚠ No orders found in database.\n";
    }
} catch (Exception $e) {
    echo "✗ Error occurred!\n";
    echo "Message: " . $e->getMessage() . "\n\n";
    echo "Stack trace:\n";
    echo $e->getTraceAsString();
}
