<?php

namespace App\Http\Controllers;

use App\Models\Order; // 💡 Impor Model Order
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;

class PaymentValidationController extends Controller
{
    public function index(Request $request)
    {
        $search = $request->input('search');

        // Menggunakan Model Order agar lebih elegan
        $orders = Order::where('status_pembayaran', 'Menunggu Pembayaran')
            ->when($search, function ($query, $search) {
                return $query->where('id_order', 'like', "%{$search}%")
                             ->orWhere('nama_pelanggan', 'like', "%{$search}%");
            })->paginate(10);

        $processedOrders = Order::whereIn('status_pembayaran', ['Diproses', 'Sudah Dibayar', 'Selesai'])
            ->when($search, function ($query, $search) {
                return $query->where('id_order', 'like', "%{$search}%")
                             ->orWhere('nama_pelanggan', 'like', "%{$search}%");
            })->paginate(10, ['*'], 'processed_page');

        return view('admin.verify_payment', compact('orders', 'processedOrders', 'search'));
    }

    public function validatePayment($id)
    {
        DB::beginTransaction();
        try {
            // 💡 Menggunakan Model Order untuk mencari data
            $order = Order::findOrFail($id);

            if ($order->status_pembayaran !== 'Menunggu Pembayaran') {
                return redirect()->back()->with('error', 'Pesanan tidak valid untuk divalidasi.');
            }

            // 💡 Update menggunakan Eloquent (otomatis menyimpan ke database)
            $order->update([
                'status_pembayaran' => 'Diproses',
                'id_admin'          => auth()->id(),
                'validated_at'      => now(),
            ]);

            DB::commit();

            // Trigger automation
            try { $this->triggerOrderProcessedWebhook($order); } 
            catch (\Exception $e) { logger()->error('N8N webhook failed: ' . $e->getMessage()); }

            return redirect()->back()->with('success', 'Pembayaran Invoice #' . $id . ' sukses divalidasi!');
        } catch (\Exception $e) {
            DB::rollBack();
            return redirect()->back()->with('error', 'Terjadi kesalahan: ' . $e->getMessage());
        }
    }

    private function triggerOrderProcessedWebhook($order)
    {
        $webhookUrl = env('N8N_WEBHOOK_URL');
        
        // 💡 Mengirim data langsung dari objek $order
        $payload = [
            'order_id'          => $order->id_order,
            'nama_pelanggan'    => $order->nama_pelanggan,
            'email'             => $order->email,
            'total_harga'       => (float) $order->total_harga,
            'ukuran'            => $order->size, // Pastikan size terkirim
            'warna'             => $order->warna, // Pastikan warna terkirim
            'status_pembayaran' => 'Diproses'
        ];

        Http::timeout(10)->post($webhookUrl, $payload);
    }

    public function cancelPayment($id)
    {
        DB::beginTransaction();
        try {
            $order = Order::findOrFail($id);

            // 💡 Menggunakan Model untuk memproses stok
            // Asumsi: Anda memiliki Model Product
            \App\Models\Product::where('id_produk', $order->id_produk)
                ->increment('stok', $order->jumlah_beli);

            $order->update(['status_pembayaran' => 'Dibatalkan Pelanggan']);
            
            DB::commit();
            return redirect()->back()->with('success', 'Pesanan #' . $id . ' dibatalkan.');
        } catch (\Exception $e) {
            DB::rollBack();
            return redirect()->back()->with('error', 'Gagal memproses pembatalan.');
        }
    }

    public function update(Request $request, $id)
    {
        DB::beginTransaction();
        try {
            $order = Order::findOrFail($id);
            $status = $this->normalizeStatusForStorage($request->input('status_pembayaran', 'Sudah Dibayar'));

            $updateData = [];

            if ($this->shouldUpdatePaymentStatus($request->input('status_pembayaran', 'Sudah Dibayar'))) {
                $updateData['status_pembayaran'] = $status;
            }

            $updateData['status_produk'] = $this->normalizeProductStatus($request->input('status_pembayaran', 'Sudah Dibayar'));

            if ($status === 'Sudah Dibayar') {
                $updateData['id_admin'] = auth()->id();
                $updateData['validated_at'] = now();
            }

            $order->update($updateData);
            DB::commit();

            return redirect()->back()->with('success', 'Status pesanan #' . $id . ' berhasil diperbarui.');
        } catch (\Exception $e) {
            DB::rollBack();
            return redirect()->back()->with('error', 'Gagal memperbarui status pesanan: ' . $e->getMessage());
        }
    }

    private function normalizeStatusForStorage($status)
    {
        $normalized = trim((string) $status);

        if ($normalized === '') {
            return 'Sudah Dibayar';
        }

        $mapping = [
            'dikirim' => 'Dikirim',
            'diproses' => 'Diproses',
            'selesai' => 'Selesai',
            'sudah dibayar' => 'Sudah Dibayar',
            'pembayaran gagal' => 'Pembayaran Gagal',
        ];

        return $mapping[strtolower($normalized)] ?? $normalized;
    }

    private function normalizeProductStatus($status)
    {
        $normalized = trim((string) $status);

        if ($normalized === '') {
            return 'Menunggu';
        }

        $mapping = [
            'dikirim' => 'Dikirim',
            'diproses' => 'Diproses',
            'selesai' => 'Selesai',
            'sudah dibayar' => 'Siap Dikirim',
            'pembayaran gagal' => 'Gagal',
        ];

        return $mapping[strtolower($normalized)] ?? 'Menunggu';
    }

    private function shouldUpdatePaymentStatus($status)
    {
        $normalized = strtolower(trim((string) $status));

        return !in_array($normalized, ['dikirim'], true);
    }

    public function destroy($id)
    {
        DB::beginTransaction();
        try {
            $order = Order::findOrFail($id);

            \App\Models\Product::where('id_produk', $order->id_produk)
                ->increment('stok', $order->jumlah_beli);

            $order->update(['status_pembayaran' => 'Dibatalkan Sistem']);

            DB::commit();
            return redirect()->back()->with('success', 'Pesanan #' . $id . ' dibatalkan dari sistem.');
        } catch (\Exception $e) {
            DB::rollBack();
            return redirect()->back()->with('error', 'Gagal membatalkan pesanan: ' . $e->getMessage());
        }
    }
}