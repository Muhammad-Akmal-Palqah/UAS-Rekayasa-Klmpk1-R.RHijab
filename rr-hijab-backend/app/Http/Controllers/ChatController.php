<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Http;
use App\Models\Product;

class ChatController extends Controller
{
    public function chat(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'message' => 'required|string',
        ]);

        $message = $validated['message'];
        
        // Deteksi intent dari pertanyaan pelanggan
        $intent = $this->detectIntent($message);
        
        // Cari data dari database berdasarkan intent
        if ($intent) {
            $databaseReply = $this->searchProductDatabase($message, $intent);
            
            // Jika data ditemukan, kembalikan jawaban berdasarkan database
            if ($databaseReply) {
                return response()->json([
                    'reply' => $databaseReply,
                ]);
            }
        }
        
        // Jika tidak ada data di database atau intent tidak terdeteksi, berikan jawaban standar
        return response()->json([
            'reply' => 'Maaf, informasi tersebut belum tersedia di katalog kami. Apakah ada yang lain yang bisa saya bantu?',
        ]);
    }

    /**
     * Deteksi intent dari pesan pelanggan
     * 
     * @param string $message
     * @return string|null
     */
    private function detectIntent(string $message): ?string
    {
        $messageLower = strtolower($message);
        
        // Deteksi kata kunci untuk pemesanan
        if (strpos($messageLower, 'pesan') !== false || 
            strpos($messageLower, 'pemesanan') !== false ||
            strpos($messageLower, 'order') !== false ||
            strpos($messageLower, 'beli') !== false ||
            strpos($messageLower, 'bagaimana cara') !== false ||
            strpos($messageLower, 'cara pemesanan') !== false ||
            strpos($messageLower, 'cara pesan') !== false ||
            strpos($messageLower, 'cara beli') !== false) {
            return 'order';
        }
        
        // Deteksi kata kunci untuk harga
        if (strpos($messageLower, 'harga') !== false || 
            strpos($messageLower, 'berapa harga') !== false ||
            strpos($messageLower, 'berapa') !== false ||
            strpos($messageLower, 'biaya') !== false ||
            strpos($messageLower, 'tarif') !== false) {
            return 'price';
        }
        
        // Deteksi kata kunci untuk bahan
        if (strpos($messageLower, 'bahan') !== false || 
            strpos($messageLower, 'material') !== false ||
            strpos($messageLower, 'terbuat dari') !== false ||
            strpos($messageLower, 'terbuat') !== false) {
            return 'material';
        }
        
        // Deteksi kata kunci untuk stok
        if (strpos($messageLower, 'stok') !== false || 
            strpos($messageLower, 'ada') !== false ||
            strpos($messageLower, 'tersedia') !== false ||
            strpos($messageLower, 'ketersediaan') !== false ||
            strpos($messageLower, 'stock') !== false) {
            return 'stock';
        }
        
        return null;
    }
    
    /**
     * Cari data produk dari database berdasarkan intent dan pesan
     * 
     * @param string $message
     * @param string $intent
     * @return string|null
     */
    private function searchProductDatabase(string $message, string $intent): ?string
    {
        $messageLower = strtolower($message);
        
        try {
            if ($intent === 'order') {
                return $this->handleOrderQuery();
            } elseif ($intent === 'price') {
                return $this->handlePriceQuery($message, $messageLower);
            } elseif ($intent === 'material') {
                return $this->handleMaterialQuery($message, $messageLower);
            } elseif ($intent === 'stock') {
                return $this->handleStockQuery($message, $messageLower);
            }
        } catch (\Exception $e) {
            \Log::error('Chat Database Query Error: ' . $e->getMessage());
        }
        
        return null;
    }
    
    /**
     * Handle pertanyaan tentang cara pemesanan
     * 
     * @return string
     */
    private function handleOrderQuery(): string
    {
        return "🛍️ Berikut cara melakukan pemesanan di toko kami:\n\n"
            . "1️⃣ Pilih Produk\n"
            . "   - Lihat daftar produk hijab kami yang tersedia\n"
            . "   - Tanya harga atau ketersediaan jika ada yang kurang jelas\n\n"
            . "2️⃣ Tambahkan ke Keranjang\n"
            . "   - Pilih ukuran dan warna yang Anda inginkan\n"
            . "   - Tentukan jumlah pembelian\n\n"
            . "3️⃣ Proses Checkout\n"
            . "   - Masukkan data pengiriman (alamat, nama, nomor HP)\n"
            . "   - Pilih metode pengiriman yang tersedia\n\n"
            . "4️⃣ Pembayaran\n"
            . "   - Pilih metode pembayaran (Transfer Bank, E-wallet, COD)\n"
            . "   - Ikuti instruksi pembayaran\n\n"
            . "5️⃣ Konfirmasi Order\n"
            . "   - Order akan diproses setelah pembayaran dikonfirmasi\n"
            . "   - Anda akan menerima notifikasi perubahan status pesanan\n\n"
            . "📱 Hubungi kami jika ada pertanyaan lebih lanjut!\n"
            . "WhatsApp: [+62 877 9909 7630]\n"
            . "Email: [rrhijabofficial@gmail.com]\n"
            . "Customer Service: 24/7 siap membantu";
    }
    
    /**
     * Handle pertanyaan tentang harga produk
     * 
     * @param string $message
     * @param string $messageLower
     * @return string|null
     */
    private function handlePriceQuery(string $message, string $messageLower): ?string
    {
        // Cari nama produk yang mungkin disebut dalam pesan
        $products = Product::all();
        
        foreach ($products as $product) {
            $productName = strtolower($product->nama_produk ?? '');
            if (!empty($productName) && strpos($messageLower, $productName) !== false) {
                $price = $product->harga ?? 0;
                $formattedPrice = 'Rp ' . number_format($price, 0, ',', '.');
                
                // Cek jika ada promo
                if (!empty($product->promo)) {
                    $hargaAfterPromo = $product->harga_after_promo ?? $price;
                    $formattedPromoPrice = 'Rp ' . number_format($hargaAfterPromo, 0, ',', '.');
                    return "Harga produk {$product->nama_produk} adalah {$formattedPrice} (Promo: {$product->promo}) menjadi {$formattedPromoPrice}.";
                } else {
                    return "Harga produk {$product->nama_produk} adalah {$formattedPrice}.";
                }
            }
        }
        
        // Jika tidak ada nama produk spesifik, tampilkan daftar harga semua produk
        $products = Product::where('harga', '>', 0)->get();
        
        if ($products->count() > 0) {
            $priceList = "Berikut daftar harga produk kami:\n";
            foreach ($products as $product) {
                $price = $product->harga ?? 0;
                $formattedPrice = 'Rp ' . number_format($price, 0, ',', '.');
                
                // Jika ada promo, tampilkan dengan harga setelah diskon
                if (!empty($product->promo)) {
                    $hargaAfterPromo = $product->harga_after_promo ?? $price;
                    $formattedPromoPrice = 'Rp ' . number_format($hargaAfterPromo, 0, ',', '.');
                    $priceList .= "- {$product->nama_produk}: {$formattedPrice} ({$product->promo}) → {$formattedPromoPrice}\n";
                } else {
                    $priceList .= "- {$product->nama_produk}: {$formattedPrice}\n";
                }
            }
            return trim($priceList);
        }
        
        return null;
    }
    
    /**
     * Handle pertanyaan tentang bahan/material produk
     * 
     * @param string $message
     * @param string $messageLower
     * @return string|null
     */
    private function handleMaterialQuery(string $message, string $messageLower): ?string
    {
        // Cari nama produk yang mungkin disebut dalam pesan
        $products = Product::all();
        
        foreach ($products as $product) {
            $productName = strtolower($product->nama_produk ?? '');
            if (!empty($productName) && strpos($messageLower, $productName) !== false) {
                // Cek deskripsi sebagai material reference
                $description = $product->deskripsi ?? null;
                if ($description) {
                    return "Produk {$product->nama_produk}: {$description}";
                }
            }
        }
        
        // Jika tidak ada nama produk spesifik, tampilkan info produk dengan deskripsi
        $products = Product::whereNotNull('deskripsi')
            ->where('deskripsi', '!=', '')
            ->get();
        
        if ($products->count() > 0) {
            $materialList = "Berikut informasi produk kami:\n";
            foreach ($products as $product) {
                $materialList .= "- {$product->nama_produk}: {$product->deskripsi}\n";
            }
            return trim($materialList);
        }
        
        return null;
    }
    
    /**
     * Handle pertanyaan tentang stok produk
     * 
     * @param string $message
     * @param string $messageLower
     * @return string|null
     */
    private function handleStockQuery(string $message, string $messageLower): ?string
    {
        // Cari nama produk yang mungkin disebut dalam pesan
        $products = Product::all();
        
        foreach ($products as $product) {
            $productName = strtolower($product->nama_produk ?? '');
            if (!empty($productName) && strpos($messageLower, $productName) !== false) {
                $stock = $product->stok ?? 0;
                $stockStatus = $stock > 0 ? "Produk {$product->nama_produk} tersedia dengan stok {$stock} unit." 
                                          : "Maaf, produk {$product->nama_produk} saat ini habis.";
                return $stockStatus;
            }
        }
        
        // Jika tidak ada nama produk spesifik, tampilkan ketersediaan semua produk
        $products = Product::all();
        
        if ($products->count() > 0) {
            $stockList = "Berikut status ketersediaan produk kami:\n";
            foreach ($products as $product) {
                $stock = $product->stok ?? 0;
                $status = $stock > 0 ? "Tersedia ({$stock} unit)" : "Habis";
                $stockList .= "- {$product->nama_produk}: {$status}\n";
            }
            return trim($stockList);
        }
        
        return null;
    }
}
