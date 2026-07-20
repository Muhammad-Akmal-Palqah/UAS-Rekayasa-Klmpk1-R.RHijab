<?php

namespace App\Http\Controllers;

use App\Models\BusinessHour;
use App\Models\Payment;
use App\Models\Product; 
use Illuminate\Support\Str;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Schema;

class ProductController extends Controller
{
    private function normalizeVariantStockMap($rawValue): array
    {
        if ($rawValue === null || $rawValue === '') {
            return [];
        }

        if (is_array($rawValue)) {
            return array_map(function ($value) {
                return is_numeric($value) ? (int) $value : 0;
            }, $rawValue);
        }

        if (is_string($rawValue)) {
            $decoded = json_decode($rawValue, true);
            if (is_array($decoded)) {
                return array_map(function ($value) {
                    return is_numeric($value) ? (int) $value : 0;
                }, $decoded);
            }

            $result = [];
            foreach (explode(',', $rawValue) as $part) {
                $pair = explode(':', $part, 2);
                if (count($pair) !== 2) {
                    continue;
                }

                $key = trim($pair[0]);
                $qty = trim($pair[1]);
                if ($key === '') {
                    continue;
                }

                $result[$key] = is_numeric($qty) ? (int) $qty : 0;
            }

            return $result;
        }

        return [];
    }

    private function updateVariantStocks(Product $product, ?string $size, ?string $color, int $quantity): void
    {
        $updates = [];

        if ($size !== null && trim($size) !== '') {
            $sizeStocks = $this->normalizeVariantStockMap($product->available_size_stocks);
            $currentSizeStock = isset($sizeStocks[$size]) ? (int) $sizeStocks[$size] : 0;
            $sizeStocks[$size] = max(0, $currentSizeStock - $quantity);
            $updates['available_size_stocks'] = $sizeStocks;
        }

        if ($color !== null && trim($color) !== '') {
            $colorStocks = $this->normalizeVariantStockMap($product->available_color_stocks);
            $currentColorStock = isset($colorStocks[$color]) ? (int) $colorStocks[$color] : 0;
            $colorStocks[$color] = max(0, $currentColorStock - $quantity);
            $updates['available_color_stocks'] = $colorStocks;
        }

        if (!empty($updates)) {
            $product->forceFill($updates);
            $product->save();
        }
    }

    private function triggerN8nWebhook(array $payload): void
    {
        $webhookUrl = config('services.webhook_url') ?: env('N8N_WEBHOOK_URL');

        if (empty($webhookUrl)) {
            Log::warning('N8N webhook URL tidak dikonfigurasi, melewatkan trigger webhook.');
            return;
        }

        try {
            Http::timeout(10)->post($webhookUrl, $payload);
            Log::info('N8N webhook berhasil dikirim.', [
                'webhook_url' => $webhookUrl,
                'payload' => $payload,
            ]);
        } catch (\Exception $exception) {
            Log::error('N8N webhook gagal dikirim: ' . $exception->getMessage(), [
                'webhook_url' => $webhookUrl,
                'payload' => $payload,
            ]);
        }
    }

    private function calculateOrderPrice(Product $product, int $quantity): float
    {
        $unitPrice = $product->hasPromoPercent() ? $product->harga_after_promo : (float) $product->harga;
        return round($unitPrice * $quantity, 2);
    }

    public function indexWeb() { return view('admin.products.index', ['products' => Product::all()]); }

    public function katalog() 
{
    // Gunakan withAvg agar setiap produk membawa rata-rata rating dari tabel comments
    $products = Product::where('status', 'Aktif')
        ->withAvg('comments', 'rating') // Ini menghasilkan atribut 'comments_avg_rating'
        ->orderBy('nama_produk')
        ->get();

    return view('pelanggan.katalog', ['products' => $products]);
}
    

  public function detail(Request $request, $id) // Tambahkan Request $request
{
    // 1. Ambil data produk
    $product = Product::where('id_produk', $id)->where('status', 'Aktif')->firstOrFail();
    
    // 2. Decode JSON warna & ukuran
    $colors = is_string($product->available_colors) ? json_decode($product->available_colors, true) : $product->available_colors;
    $sizes = is_string($product->available_sizes) ? json_decode($product->available_sizes, true) : $product->available_sizes;
    $sizeStocks = $this->normalizeVariantStockMap($product->available_size_stocks);
    $colorStocks = $this->normalizeVariantStockMap($product->available_color_stocks);

    // 3. Hitung statistik rating (Untuk ringkasan di atas)
    $stats = DB::table('comments')
        ->where('id_produk', $id)
        ->selectRaw('AVG(rating) as average, COUNT(*) as total')
        ->first();

    // 4. Hitung jumlah untuk filter tiap bintang
    $ratingCounts = DB::table('comments')
        ->where('id_produk', $id)
        ->select('rating', DB::raw('count(*) as count'))
        ->groupBy('rating')
        ->pluck('count', 'rating');

    // 5. Query komentar dengan filter
    $query = DB::table('comments')
        ->join('users', 'comments.user_id', '=', 'users.id')
        ->select('comments.*', 'users.name as user_name')
        ->where('comments.id_produk', $id);

    // Jika user mengklik salah satu filter bintang
    if ($request->has('rating')) {
        $query->where('comments.rating', $request->rating);
    }

    $comments = $query->orderByDesc('comments.created_at')->get();

    // 6. Kirim SEMUA variabel sekaligus dalam SATU return
    return view('pelanggan.katalog-detail', compact(
        'product', 'comments', 'colors', 'sizes', 'stats', 'ratingCounts', 'sizeStocks', 'colorStocks'
    ));
}

    public function checkout($id)
    {
        $product = Product::where('id_produk', $id)
            ->where('status', 'Aktif')
            ->withAvg('comments', 'rating') // Mengambil rata-rata rating
            ->firstOrFail();

        return view('pelanggan.checkout', [
            'product' => $product,
            'businessHours' => BusinessHour::current(),
            'isAcceptingOrders' => BusinessHour::current()->isOpenAt()
        ]);
    }

    private function initiateMidtransPayment(array $orderData, int $orderId, string $paymentMethod): array
    {
        if (!in_array($paymentMethod, ['gopay', 'qris'], true)) {
            return [
                'redirect_url' => null,
                'snap_token' => null,
                'transaction_id' => null,
            ];
        }

        try {
            \Midtrans\Config::$serverKey = config('midtrans.server_key');
            \Midtrans\Config::$isProduction = (bool) config('midtrans.is_production', false);
            \Midtrans\Config::$isSanitized = true;
            \Midtrans\Config::$is3ds = true;

            $transactionId = 'ORDER-' . $orderId . '-' . Str::upper(Str::random(6));
            $params = [
                'payment_type' => $paymentMethod,
                'transaction_details' => [
                    'order_id' => $transactionId,
                    'gross_amount' => (int) round((float) ($orderData['total_harga'] ?? 0)),
                ],
                'customer_details' => [
                    'first_name' => $orderData['nama_pelanggan'] ?? 'Customer',
                    'email' => $orderData['email'] ?? '',
                    'phone' => $orderData['no_whatsapp'] ?? '',
                ],
            ];

            if ($paymentMethod === 'gopay') {
                $params['gopay'] = ['enable_callback' => true];
            } elseif ($paymentMethod === 'qris') {
                $params['qris'] = [];
            }

            $snapResponse = \Midtrans\Snap::createTransaction($params);
            $snapToken = $snapResponse->token ?? null;
            $redirectUrl = $snapResponse->redirect_url ?? null;
            $midtransRedirectUrl = $snapToken ? 'https://app.sandbox.midtrans.com/snap/v2/vtweb/' . $snapToken : $redirectUrl;

            Payment::create([
                'order_id' => $orderId,
                'user_id' => null,
                'transaction_id' => $transactionId,
                'amount' => $orderData['total_harga'],
                'payment_type' => $paymentMethod,
                'snap_token' => $snapToken,
                'status' => 'pending',
                'midtrans_response' => json_decode(json_encode($snapResponse), true),
                'qr_code_url' => $snapResponse->qr_code_url ?? null,
                'deeplink_redirect' => $redirectUrl,
                'expired_at' => null,
            ]);

            return [
                'redirect_url' => $midtransRedirectUrl,
                'snap_token' => $snapToken,
                'transaction_id' => $transactionId,
            ];
        } catch (\Throwable $e) {
            Log::error('Midtrans web checkout initiation failed', [
                'order_id' => $orderId,
                'payment_method' => $paymentMethod,
                'message' => $e->getMessage(),
            ]);

            return [
                'redirect_url' => null,
                'snap_token' => null,
                'transaction_id' => null,
                'error' => $e->getMessage(),
            ];
        }
    }

    // 💡 WEB PLACE ORDER: Form checkout manual transfer dari interface browser web pelanggan
    public function placeOrder(Request $request, $id)
    {
        if (!BusinessHour::current()->isOpenAt()) { return redirect()->back()->with('error', 'Toko tutup.'); }

        $product = Product::where('id_produk', $id)
            ->where('status', 'Aktif')
            ->firstOrFail();

        $validated = $request->validate([
            'nama_pelanggan' => 'required|string|max:100',
            'no_whatsapp' => 'required|string|max:20',
            'email' => 'nullable|email|max:100',
            'alamat_pengiriman' => 'required|string|max:500',
            'jumlah_beli' => 'required|integer|min:1|max:' . $product->stok,
            'bukti_pembayaran' => 'required|image|max:4096',
            'size' => 'required|string|max:20',
            'warna' => 'required|string|max:50',
            'payment_method' => 'nullable|string|max:50',
            'pengiriman' => 'required|string|in:jne,jnt,gosend',
        ]);

        $shippingCostMap = [
            'jne' => 15000,
            'jnt' => 17000,
            'gosend' => 25000,
        ];

        $shippingCost = $shippingCostMap[$validated['pengiriman']] ?? 0;
        $productTotal = $this->calculateOrderPrice($product, $validated['jumlah_beli']);
        $totalHarga = $productTotal + $shippingCost;

        $buktiTransfer = 'storage/' . $request->file('bukti_pembayaran')->store('bukti_pembayaran', 'public');

        $orderData = [
            'nama_pelanggan' => $validated['nama_pelanggan'],
            'no_whatsapp' => $validated['no_whatsapp'],
            'email' => $validated['email'] ?? null,
            'alamat_pengiriman' => $validated['alamat_pengiriman'],
            'id_produk' => $product->id_produk,
            'jumlah_beli' => $validated['jumlah_beli'],
            'total_harga' => $totalHarga,
            'ukuran' => $validated['size'],
            'warna' => $validated['warna'],
            'metode_pengiriman' => $validated['pengiriman'],
            'catatan' => ($validated['payment_method'] ?? null) ? 'Metode pembayaran: ' . $validated['payment_method'] : null,
            'status_pembayaran' => 'Menunggu Pembayaran',
            'bukti_transfer' => $buktiTransfer,
            'created_at' => now(),
            'updated_at' => now(),
        ];

        $orderId = DB::table('orders')->insertGetId($orderData);

        Product::where('id_produk', $product->id_produk)->decrement('stok', $validated['jumlah_beli']);
        $this->updateVariantStocks($product, $validated['size'] ?? null, $validated['warna'] ?? null, $validated['jumlah_beli']);

        $paymentMethod = $validated['payment_method'] ?? null;
        $midtransData = null;
        if (in_array($paymentMethod, ['gopay', 'qris'], true)) {
            $midtransData = $this->initiateMidtransPayment($orderData, $orderId, $paymentMethod);
            if (!empty($midtransData['error'])) {
                DB::table('orders')->where('id_order', $orderId)->update(['status_pembayaran' => 'Pembayaran Gagal']);
                return redirect()->back()->with('error', 'Pesanan dibuat, tetapi pembayaran Midtrans gagal. Silakan coba lagi.');
            }
        }

        $redirectResponse = redirect()->route('pelanggan.katalog.checkout', [$id])
            ->with('success', "Pesanan dibuat. Invoice #{$orderId}");

        if ($midtransData && !empty($midtransData['redirect_url'])) {
            $redirectResponse->with('midtrans_redirect_url', $midtransData['redirect_url']);
            $redirectResponse->with('midtrans_payment_method', Str::upper($paymentMethod));
        }

        return $redirectResponse;
    }

    // 💡 FLUTTER API CATALOG: Menyediakan output JSON ter-parsing rapi untuk konsumsi aplikasi HP Android/iOS
    public function indexAPI(Request $request)
    {
        $commentStats = DB::table('comments')->select('id_produk', DB::raw('ROUND(AVG(rating), 1) as avg_rating'), DB::raw('COUNT(*) as review_count'))->groupBy('id_produk');

        // 💡 PERBAIKAN: Berhasil menembak model tunggal terpadu 'Product'
        $query = Product::query()
            ->select('products.*', 'comment_stats.avg_rating as avg_rating', 'comment_stats.review_count as review_count')
            ->leftJoinSub($commentStats, 'comment_stats', fn($join) => $join->on('products.id_produk', '=', 'comment_stats.id_produk'))
            ->where('status', 'Aktif');

        // Logika filtering data JSON Array menggunakan query native JSON MySQL
        if ($request->filled('color')) {
            foreach (array_filter(explode(',', $request->color)) as $color) {
                $query->whereRaw("LOWER(JSON_EXTRACT(available_colors, '$')) LIKE ?", ["%\"" . strtolower($color) . "\"%"]);
            }
        }

        if ($request->filled('size')) {
            foreach (array_filter(explode(',', $request->size)) as $size) {
                $query->whereRaw("LOWER(JSON_EXTRACT(available_sizes, '$')) LIKE ?", ["%\"" . strtolower($size) . "\"%"]);
            }
        }

        // ✅ Filter harga berdasarkan rentang yang dikirim dari Flutter
        if ($request->filled('min_price')) {
            $query->where('harga', '>=', (float) $request->min_price);
        }

        if ($request->filled('max_price')) {
            $query->where('harga', '<=', (float) $request->max_price);
        }

        $data = $query->get()->map(function ($p) {
            $arr = $p->toArray();
            $arr['link_foto'] = Str::startsWith($arr['link_foto'] ?? '', 'http') ? $arr['link_foto'] : asset($arr['link_foto']);
            return $arr;
        });

        return response()->json(['status' => 'success', 'data' => $data]);
    }

    // 💡 FLUTTER API CHECKOUT: Endpoint penerima checkout transaksi belanja dari aplikasi HP Flutter
    public function storeOrderAPI(Request $request, $id)
    {
        $product = Product::where('id_produk', $id)->firstOrFail();
        $validated = $request->validate([
            'nama_pelanggan' => 'required|string',
            'no_whatsapp' => 'required|string',
            'alamat_pengiriman' => 'required|string',
            'ukuran' => 'nullable|string',
            'warna' => 'nullable|string', // 💡 SINKRONISASI: Mendukung variasi warna
            'jumlah_beli' => 'required|integer|max:' . $product->stok,
            'total_harga' => 'nullable|integer',
            'email' => 'nullable|email|max:100',
            'metode_pengiriman' => 'nullable|string|max:50',
            'catatan' => 'nullable|string|max:500',
            'metode_pembayaran' => 'nullable|string|max:50',
        ]);

        $orderData = [
            'nama_pelanggan' => $validated['nama_pelanggan'],
            'no_whatsapp' => $validated['no_whatsapp'],
            'alamat_pengiriman' => $validated['alamat_pengiriman'],
            'id_produk' => $product->id_produk,
            'jumlah_beli' => $validated['jumlah_beli'],
            'total_harga' => $validated['total_harga'] ?? ($product->harga * $validated['jumlah_beli']),
            'status_pembayaran' => 'Menunggu Pembayaran',
            'user_id' => $request->user()->id,
            'created_at' => now(),
            'updated_at' => now(),
        ];

        if (Schema::hasColumn('orders', 'email')) {
            $orderData['email'] = $validated['email'] ?? null;
        }

        if (Schema::hasColumn('orders', 'ukuran')) {
            $orderData['ukuran'] = $validated['ukuran'] ?? null;
        }

        if (Schema::hasColumn('orders', 'warna')) {
            $orderData['warna'] = $validated['warna'] ?? null;
        }

        if (Schema::hasColumn('orders', 'metode_pengiriman')) {
            $orderData['metode_pengiriman'] = $validated['metode_pengiriman'] ?? null;
        }

        if (Schema::hasColumn('orders', 'catatan')) {
            $orderData['catatan'] = $validated['catatan'] ?? null;
        }

        if (Schema::hasColumn('orders', 'metode_pembayaran')) {
            $orderData['metode_pembayaran'] = $validated['metode_pembayaran'] ?? null;
        }

        $orderId = DB::table('orders')->insertGetId($orderData);
        Product::where('id_produk', $product->id_produk)->decrement('stok', $validated['jumlah_beli']);
        $this->updateVariantStocks($product, $validated['ukuran'] ?? null, $validated['warna'] ?? null, $validated['jumlah_beli']);

        return response()->json(['success' => true, 'data' => ['order_id' => $orderId]], 201);
    }

    public function storeBulkOrdersAPI(Request $request)
    {
        $validated = $request->validate([
            'nama_pelanggan' => 'required|string',
            'no_whatsapp' => 'required|string',
            'alamat_pengiriman' => 'required|string',
            'email' => 'nullable|email|max:100',
            'metode_pengiriman' => 'nullable|string|max:50',
            'catatan' => 'nullable|string|max:500',
            'metode_pembayaran' => 'nullable|string|max:50',
            'items' => 'required|array|min:1',
            'items.*.product_id' => 'required|integer|exists:products,id_produk',
            'items.*.jumlah_beli' => 'required|integer|min:1',
            'items.*.total_harga' => 'nullable|numeric|min:0',
            'items.*.ukuran' => 'nullable|string|max:50',
            'items.*.warna' => 'nullable|string|max:50',
        ]);

        Log::info('storeBulkOrdersAPI request', [
            'user_id' => optional($request->user())->id,
            'item_count' => count($validated['items']),
            'payload' => $request->all(),
        ]);

        $orderIds = [];
        $totalAmount = 0.0;

        DB::transaction(function () use ($validated, $request, &$orderIds, &$totalAmount) {
            foreach ($validated['items'] as $index => $item) {
                Log::debug('Processing bulk order item', ['index' => $index, 'item' => $item]);

                $product = Product::where('id_produk', $item['product_id'])->firstOrFail();
                $quantity = (int) $item['jumlah_beli'];

                if ($quantity > $product->stok) {
                    abort(422, "Stok tidak cukup untuk produk {$product->id_produk}");
                }

                $totalHarga = isset($item['total_harga'])
                    ? (float) $item['total_harga']
                    : ($product->harga * $quantity);

                $orderData = [
                    'nama_pelanggan' => $validated['nama_pelanggan'],
                    'no_whatsapp' => $validated['no_whatsapp'],
                    'alamat_pengiriman' => $validated['alamat_pengiriman'],
                    'id_produk' => $product->id_produk,
                    'jumlah_beli' => $quantity,
                    'total_harga' => $totalHarga,
                    'status_pembayaran' => 'Menunggu Pembayaran',
                    'user_id' => $request->user()->id,
                    'created_at' => now(),
                    'updated_at' => now(),
                ];

                if (Schema::hasColumn('orders', 'email')) {
                    $orderData['email'] = $validated['email'] ?? null;
                }
                if (Schema::hasColumn('orders', 'ukuran')) {
                    $orderData['ukuran'] = $item['ukuran'] ?? null;
                }
                if (Schema::hasColumn('orders', 'warna')) {
                    $orderData['warna'] = $item['warna'] ?? null;
                }
                if (Schema::hasColumn('orders', 'metode_pengiriman')) {
                    $orderData['metode_pengiriman'] = $validated['metode_pengiriman'] ?? null;
                }
                if (Schema::hasColumn('orders', 'catatan')) {
                    $orderData['catatan'] = $validated['catatan'] ?? null;
                }
                if (Schema::hasColumn('orders', 'metode_pembayaran')) {
                    $orderData['metode_pembayaran'] = $validated['metode_pembayaran'] ?? null;
                }

                $orderId = DB::table('orders')->insertGetId($orderData);
                Product::where('id_produk', $product->id_produk)->decrement('stok', $quantity);
                $this->updateVariantStocks($product, $item['ukuran'] ?? null, $item['warna'] ?? null, $quantity);
                $orderIds[] = $orderId;
                $totalAmount += $totalHarga;

                Log::debug('Bulk order item inserted', [
                    'order_id' => $orderId,
                    'product_id' => $product->id_produk,
                    'quantity' => $quantity,
                    'total_harga' => $totalHarga,
                ]);
            }
        });

        Log::info('Bulk order completed', ['user_id' => $request->user()->id, 'order_ids' => $orderIds]);

        $webhookPayload = [
            'event' => 'order_placed',
            'order_ids' => $orderIds,
            'nama_pelanggan' => $validated['nama_pelanggan'],
            'email' => $validated['email'] ?? null,
            'no_whatsapp' => $validated['no_whatsapp'],
            'alamat_pengiriman' => $validated['alamat_pengiriman'],
            'metode_pengiriman' => $validated['metode_pengiriman'] ?? null,
            'metode_pembayaran' => $validated['metode_pembayaran'] ?? null,
            'catatan' => $validated['catatan'] ?? null,
            'total_harga' => $totalAmount,
            'status_pembayaran' => 'Menunggu Pembayaran',
            'items' => $validated['items'],
        ];

        $this->triggerN8nWebhook($webhookPayload);

        return response()->json([
            'success' => true,
            'data' => [
                'order_ids' => $orderIds,
                'created_count' => count($orderIds),
            ],
        ], 201);
    }

    public function fetchOrdersAPI(Request $request)
    {
        // Mengembalikan data riwayat belanja user yang terautentikasi lengkap beserta informasi 'warna' & 'ukuran' hijab
        $orders = DB::table('orders')->join('products', 'orders.id_produk', '=', 'products.id_produk')->where('orders.user_id', $request->user()->id)->select('orders.*', 'products.nama_produk', 'products.link_foto')->orderByDesc('orders.created_at')->get();
        return response()->json(['success' => true, 'data' => $orders]);
    }

     public function destroyOrderAPI(Request $request, $id)
{
    // 1. Cari pesanan berdasarkan ID dan memastikan milik user yang benar
    $order = DB::table('orders')
        ->where('id_order', $id)
        ->where('user_id', $request->user()->id)
        ->first();

    // 2. Jika tidak ditemukan, kembalikan error 404
    if (!$order) {
        return response()->json(['message' => 'Pesanan tidak ditemukan.'], 404);
    }

    // 3. Langsung eksekusi hapus tanpa mengecek status pembayaran
    // Menggunakan DB::transaction agar aman jika ada relasi ke tabel lain
    DB::transaction(function () use ($id) {
        // Hapus item terkait jika ada (penting untuk menjaga kebersihan database)
        
        // Hapus order utamanya
        DB::table('orders')->where('id_order', $id)->delete();
    });

    return response()->json(['message' => 'Pesanan berhasil dihapus.'], 200);
}

    private function hasUserCommented(Request $request, $id): bool
    {
        $userId = $request->user()?->id;
        if (!$userId) {
            return false;
        }

        return DB::table('comments')
            ->where('user_id', $userId)
            ->where('id_produk', $id)
            ->exists();
    }

    // 1. Logika Utama (Digunakan oleh Flutter dan Web)
    private function processCommentData(Request $request, $id) {
        $validated = $request->validate([
            'komentar' => 'required|string',
            'rating'   => 'required|integer|min:1|max:5',
            'image'    => 'nullable|image|max:4096',
        ]);

        $userId = $request->user()?->id;
        if (!$userId) {
            abort(401, 'Unauthenticated');
        }

        $imagePath = $request->hasFile('image') ? $request->file('image')->store('comments', 'public') : null;

        $commentId = DB::table('comments')->insertGetId([
            'user_id'    => $userId,
            'id_produk'  => $id,
            'komentar'   => $validated['komentar'],
            'rating'     => $validated['rating'],
            'image_url'  => $imagePath,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

       return DB::table('comments')
        ->join('users', 'comments.user_id', '=', 'users.id')
        ->select('comments.*', 'users.name as user_name')
        ->where('comments.id', $commentId)
        ->first();
    }

    public function getCommentStatusAPI(Request $request, $id)
    {
        return response()->json([
            'has_commented' => $this->hasUserCommented($request, $id),
        ]);
    }

    // 2. Fungsi untuk Flutter (API)
    public function storeCommentAPI(Request $request, $id) {
        if ($this->hasUserCommented($request, $id)) {
            return response()->json([
                'message' => 'Anda sudah pernah memberikan ulasan untuk produk ini.',
            ], 409);
        }

        $comment = $this->processCommentData($request, $id);
        return response()->json(['success' => true, 'data' => $comment], 201);
    }

    // Tambahkan ini di ProductController.php
public function getCommentsAPI($id) {
    $comments = DB::table('comments')
        ->join('users', 'comments.user_id', '=', 'users.id')
        ->select('comments.*', 'users.name as user_name', 'users.photo as user_photo')
        ->where('id_produk', $id)
        ->orderByDesc('comments.created_at')
        ->get()
        ->map(function ($comment) {
            if (!empty($comment->image_url)) {
                if (strpos($comment->image_url, 'http://') === 0 || strpos($comment->image_url, 'https://') === 0) {
                    $comment->image_url = $comment->image_url;
                } else {
                    $comment->image_url = url('storage/' . ltrim($comment->image_url, '/'));
                }
            }

            if (!empty($comment->user_photo)) {
                if (strpos($comment->user_photo, 'http://') === 0 || strpos($comment->user_photo, 'https://') === 0) {
                    $comment->user_photo = $comment->user_photo;
                } else {
                    $comment->user_photo = url('storage/' . ltrim($comment->user_photo, '/'));
                }
            } else {
                $comment->user_photo = url('images/default-avatar.png');
            }

            return $comment;
        });

    return response()->json(['data' => $comments]);
}

    // 3. Fungsi untuk Web
    public function storeComment(Request $request, $id) {
        if ($this->hasUserCommented($request, $id)) {
            return redirect()->back()->with('error', 'Anda sudah pernah memberikan ulasan untuk produk ini.');
        }

        $this->processCommentData($request, $id);
        return redirect()->back()->with('success', 'Ulasan berhasil dikirim!');
    }
    
    // Fungsi ini menghasilkan path gambar yang seragam untuk Web dan API
    private function formatImageUrl($path) {
        if (empty($path)) return null;
        // Kita simpan path relatif 'comments/foto.jpg' 
        // sehingga Web bisa menggunakan asset('storage/' . $path)
        // dan Flutter bisa menggunakan baseUrl + path
        return str_replace('storage/', '', $path);
    }

}