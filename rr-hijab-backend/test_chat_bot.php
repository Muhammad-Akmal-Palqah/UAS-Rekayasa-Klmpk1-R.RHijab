<?php

$baseUrl = 'http://127.0.0.1:8000/api/chat';

// Test Case 1: Pertanyaan tentang cara pemesanan
echo "=== Test 1: Cara Pemesanan ===\n";
testChatBot($baseUrl, 'Bagaimana cara pemesanan?');

// Test Case 2: Pertanyaan tentang harga
echo "\n=== Test 2: Pertanyaan tentang Harga ===\n";
testChatBot($baseUrl, 'Berapa harga produk?');

// Test Case 3: Pertanyaan tentang bahan
echo "\n=== Test 3: Pertanyaan tentang Bahan ===\n";
testChatBot($baseUrl, 'Apa bahan dari hijab kalian?');

// Test Case 4: Pertanyaan tentang stok
echo "\n=== Test 4: Pertanyaan tentang Stok ===\n";
testChatBot($baseUrl, 'Apakah ada stok tersedia?');

// Test Case 5: Pertanyaan umum (tidak ada keyword)
echo "\n=== Test 5: Pertanyaan Umum (No Keyword) ===\n";
testChatBot($baseUrl, 'Halo, apa kabar?');

// Test Case 6: Cara beli
echo "\n=== Test 6: Cara Beli ===\n";
testChatBot($baseUrl, 'Bagaimana cara beli?');

function testChatBot($url, $message) {
    echo "Pesan: $message\n";
    
    $payload = json_encode(['message' => $message]);
    
    $context = stream_context_create([
        'http' => [
            'method' => 'POST',
            'header' => "Content-Type: application/json\r\n",
            'content' => $payload,
            'ignore_errors' => true
        ]
    ]);
    
    try {
        $response = file_get_contents($url, false, $context);
        
        if ($response === false) {
            echo "ERROR: Tidak dapat terhubung ke server\n";
            return;
        }
        
        $data = json_decode($response, true);
        
        if (isset($data['reply'])) {
            echo "Jawaban Bot:\n" . $data['reply'] . "\n";
        } else {
            echo "Response: " . $response . "\n";
        }
    } catch (Exception $e) {
        echo "ERROR: " . $e->getMessage() . "\n";
    }
}
?>
