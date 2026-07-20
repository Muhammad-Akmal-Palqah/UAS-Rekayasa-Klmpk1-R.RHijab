<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AdminOrderController extends Controller
{
    // 💡 GET ALL ORDERS: API untuk mengambil semua data pesanan pelanggan beserta filternya
    public function indexOrders(Request $request)
    {
        $validated = $request->validate([
            'status_pembayaran' => 'nullable|string|in:Menunggu Pembayaran,Sudah Dibayar,Pembayaran Gagal',
            'search' => 'nullable|string|max:255',
            'page' => 'nullable|integer|min:1',
            'limit' => 'nullable|integer|min:1|max:100',
            'sort' => 'nullable|string|in:id_order,created_at,nama_pelanggan,total_harga,status_pembayaran',
            'order' => 'nullable|string|in:asc,desc',
        ]);

        $page = $validated['page'] ?? 1;
        $limit = $validated['limit'] ?? 10;
        $sort = $validated['sort'] ?? 'created_at';
        $sortOrder = $validated['order'] ?? 'desc';
        $search = $validated['search'] ?? null;
        $statusFilter = $validated['status_pembayaran'] ?? null;

        // Mengambil koneksi database utama yang telah menyatu
        $query = DB::table('orders as o')
            ->select([
                'o.id_order', 'o.nama_pelanggan', 'o.no_whatsapp', 'o.email', 'o.total_harga',
                'o.status_pembayaran', 'o.created_at', 'o.id_produk', 'o.nama_produk',
                'o.jumlah_beli', 'o.alamat_pengiriman', 'o.ukuran', 'o.warna', 'o.metode_pengiriman', 'o.bukti_transfer'
            ]); // 💡 Memastikan kolom 'warna' ikut terpilih

        // Filter pencarian berdasarkan identitas pelanggan
        if ($search) {
            $query->where(function ($q) use ($search) {
                $q->where('o.nama_pelanggan', 'like', "%{$search}%")
                  ->orWhere('o.no_whatsapp', 'like', "%{$search}%")
                  ->orWhere('o.email', 'like', "%{$search}%");
            });
        }

        if ($statusFilter) {
            $query->where('o.status_pembayaran', $statusFilter);
        }

        $total = $query->count();
        $orders = $query->orderBy("o.{$sort}", $sortOrder)->offset(($page - 1) * $limit)->limit($limit)->get();

        // Menyisipkan data riwayat pembayaran Midtrans terakhir ke dalam response objek order
        $ordersData = $orders->map(function ($order) {
            $latestPayment = DB::table('payments')
                ->where('order_id', $order->id_order)
                ->orderBy('created_at', 'desc')
                ->first();

            return [
                'id_order' => $order->id_order,
                'nama_pelanggan' => $order->nama_pelanggan,
                'no_whatsapp' => $order->no_whatsapp,
                'email' => $order->email,
                'id_produk' => $order->id_produk,
                'nama_produk' => $order->nama_produk,
                'jumlah_beli' => $order->jumlah_beli,
                'total_harga' => $order->total_harga,
                'ukuran' => $order->ukuran,
                'warna' => $order->warna, // 💡 Data warna tersaji transparan untuk kebutuhan visual
                'metode_pengiriman' => $order->metode_pengiriman,
                'alamat_pengiriman' => $order->alamat_pengiriman,
                'status_pembayaran' => $order->status_pembayaran,
                'bukti_transfer' => $order->bukti_transfer,
                'created_at' => $order->created_at,
                'latest_payment' => $latestPayment ? [
                    'transaction_id' => $latestPayment->transaction_id,
                    'amount' => $latestPayment->amount,
                    'payment_type' => $latestPayment->payment_type,
                    'status' => $latestPayment->status,
                    'paid_at' => $latestPayment->paid_at,
                ] : null,
            ];
        });

        return response()->json([
            'success' => true,
            'message' => 'Orders retrieved successfully',
            'data' => ['orders' => $ordersData, 'pagination' => ['current_page' => $page, 'per_page' => $limit, 'total' => $total, 'total_pages' => ceil($total / $limit)]],
        ]);
    }

    // 💡 SHOW DETAIL ORDER: Mengambil detail lengkap satu pesanan dan semua riwayat transaksinya
    public function showOrder($orderId)
    {
        $order = DB::table('orders')->where('id_order', $orderId)->first();

        if (!$order) {
            return response()->json(['success' => false, 'message' => 'Order not found'], 404);
        }

        $payments = DB::table('payments')->where('order_id', $orderId)->orderBy('created_at', 'desc')->get();

        $paymentsData = $payments->map(function ($payment) {
            return [
                'id' => $payment->id,
                'transaction_id' => $payment->transaction_id,
                'amount' => $payment->amount,
                'payment_type' => $payment->payment_type,
                'status' => $payment->status,
                'qr_code_url' => $payment->qr_code_url,
                'deeplink_redirect' => $payment->deeplink_redirect,
                'expired_at' => $payment->expired_at,
                'paid_at' => $payment->paid_at,
                'midtrans_response' => $payment->midtrans_response ? json_decode($payment->midtrans_response, true) : null,
                'created_at' => $payment->created_at,
                'updated_at' => $payment->updated_at,
            ];
        });

        return response()->json([
            'success' => true,
            'message' => 'Order detail retrieved successfully',
            'data' => [
                'order' => [
                    'id_order' => $order->id_order, 'nama_pelanggan' => $order->nama_pelanggan, 'no_whatsapp' => $order->no_whatsapp,
                    'email' => $order->email, 'id_produk' => $order->id_produk, 'nama_produk' => $order->nama_produk,
                    'jumlah_beli' => $order->jumlah_beli, 'total_harga' => $order->total_harga, 'ukuran' => $order->ukuran,
                    'warna' => $order->warna, 'metode_pengiriman' => $order->metode_pengiriman, 'alamat_pengiriman' => $order->alamat_pengiriman,
                    'status_pembayaran' => $order->status_pembayaran, 'bukti_transfer' => $order->bukti_transfer, 'catatan' => $order->catatan,
                    'created_at' => $order->created_at, 'updated_at' => $order->updated_at,
                ],
                'payments' => $paymentsData
            ],
        ]);
    }
}