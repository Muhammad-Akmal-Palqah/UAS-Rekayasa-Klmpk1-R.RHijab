<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Verifikasi Pembayaran & Gateway - R.R HIJAB</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="bg-gray-50 font-sans antialiased flex flex-col h-screen">

    <header class="w-full bg-[#ccccff]/40 bg-gradient-to-r from-[#ccccff]/30 to-[#ccffcc]/30 py-4 px-6 border-b border-gray-200 flex items-center justify-between shadow-sm z-10">
        <h1 class="text-xl font-bold tracking-wide text-gray-800">R.R HIJAB</h1>
        <div class="text-sm font-semibold text-gray-700 bg-white/80 px-3 py-1 rounded-full border border-gray-200 shadow-sm flex items-center gap-2">
            <span class="w-2 h-2 rounded-full bg-green-500 animate-pulse"></span> Panel Admin
        </div>
    </header>

    <div class="flex flex-1 overflow-hidden">
        <aside class="w-64 bg-white border-r border-gray-200 flex flex-col justify-between shadow-sm">
            <div class="p-4 space-y-6">
                <div>
                    <a href="{{ route('admin.dashboard') }}" class="px-3 text-xs font-semibold text-gray-600 hover:text-gray-900 uppercase tracking-wider block mb-2 hover:bg-[#ffcccc]/20 rounded px-3 py-2 transition-colors">← Menu Utama</a>
                    <nav class="space-y-1">
                        <div class="space-y-1">
                            <button type="button" onclick="toggleDropdown('masterSubmenu')" class="w-full flex items-center justify-between px-3 py-2.5 text-sm font-medium text-gray-700 bg-gray-50 rounded-lg border border-gray-100">
                                <span class="flex items-center gap-2.5"><i class="fa-solid fa-gear text-gray-500"></i> Master</span>
                                <i id="masterChevron" class="fa-solid fa-chevron-down text-xs text-gray-400 transition-transform duration-200"></i>
                            </button>
                            <div id="masterSubmenu" class="pl-8 space-y-1 mt-1 hidden">
                                <a href="{{ route('admin.index') }}" class="flex items-center gap-2.5 px-3 py-2.5 text-sm font-medium text-gray-600 hover:bg-[#ffcccc]/20 rounded-lg">Admin</a>
                                <a href="{{ route('user.index') }}" class="flex items-center gap-2.5 px-3 py-2.5 text-sm font-medium text-gray-600 hover:bg-[#ffcccc]/20 rounded-lg">User</a>
                            </div>
                        </div>
                        <a href="{{ route('product.index') }}" class="flex items-center gap-2.5 px-3 py-2.5 text-sm font-medium text-gray-600 hover:bg-[#ffcccc]/20 rounded-lg"><i class="fa-solid fa-box text-gray-400"></i> Katalog Barang</a>
                        <a href="{{ route('payment.index') }}" class="flex items-center gap-2.5 px-3 py-2.5 text-sm font-semibold text-gray-900 bg-[#ffcccc]/30 rounded-md"><i class="fa-solid fa-calendar-days text-gray-700"></i> Verifikasi Pembayaran</a>
                        <a href="{{ route('comment.index') }}" class="flex items-center gap-2.5 px-3 py-2.5 text-sm font-medium text-gray-600 hover:bg-[#ffcccc]/20 rounded-lg"><i class="fa-solid fa-comments text-gray-400"></i> Komentar</a>
                    </nav>
                </div>
            </div>
            <div class="p-4 border-t border-gray-100">
                <form action="{{ url('/logout') }}" method="POST">
                    @csrf
                    <button type="submit" class="w-full flex items-center gap-2.5 px-3 py-2.5 text-sm font-medium text-red-600 hover:bg-red-50 rounded-lg"><i class="fa-solid fa-arrow-right-from-bracket"></i> Log out</button>
                </form>
            </div>
        </aside>

        <main class="flex-1 bg-gray-50 p-8 overflow-y-auto">
            
            @if(session('success'))
                <div class="bg-green-50 text-green-700 border border-green-200 p-4 rounded-xl mb-6 text-sm flex items-center gap-2 shadow-sm">
                    <i class="fa-solid fa-circle-check"></i> {{ session('success') }}
                </div>
            @endif
            @if(session('error'))
                <div class="bg-red-50 text-red-700 border border-red-200 p-4 rounded-xl mb-6 text-sm flex items-center gap-2 shadow-sm">
                    <i class="fa-solid fa-triangle-exclamation"></i> {{ session('error') }}
                </div>
            @endif

            <div class="mb-6">
                <h2 class="text-3xl font-bold text-gray-800 tracking-tight">Verifikasi Pembayaran</h2>
            </div>

            <!-- TABEL 1: ANTREAN TRANSAKSI FLUTTER & GATEWAY -->
            <div class="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden p-6">
                <div class="flex flex-col sm:flex-row justify-between items-center gap-4 mb-4">
                    <div class="text-sm text-gray-500">
                        Show <select class="border border-gray-300 rounded px-2 py-1 mx-1 text-sm bg-gray-50 focus:outline-none"><option>10</option></select> entries
                    </div>
                    <form method="GET" action="{{ route('payment.index') }}" class="w-full sm:w-auto">
                        <input type="text" name="search" value="{{ $search }}" placeholder="Cari nomor invoice / nama..." 
                               class="w-full sm:w-64 px-3 py-1.5 border border-gray-300 rounded-lg text-sm bg-gray-50 focus:outline-none focus:border-[#ffcccc]">
                    </form>
                </div>

                <div class="overflow-x-auto">
                    <table class="w-full text-left border-collapse">
                        <thead>
                            <tr class="border-b border-gray-100 text-gray-400 text-xs font-semibold uppercase bg-gray-50/70">
                                <th class="py-3 px-4 w-16">No</th>
                                <th class="py-3 px-4">Nama & Invoice</th>
                                <!-- // ADDED: Menambahkan th pesanan jilbab dari data relasi produk Flutter -->
                                <th class="py-3 px-4">Pesanan / Varian</th>
                                <th class="py-3 px-4">Total Tagihan</th>
                                <th class="py-3 px-4">Kontak & Alamat</th>
                                <th class="py-3 px-4 text-center">Metode Pengiriman</th>
                                <!-- // MODIFIED: Menyesuaikan th status pembayaran gateway Midtrans -->
                                <th class="py-3 px-4 text-center">Status Midtrans</th>
                                <th class="py-3 px-4 text-center w-48">Aksi</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100 text-sm text-gray-700">
                            @forelse($orders as $index => $item)
                            <tr class="hover:bg-gray-50/50 transition-colors">
                                <td class="py-3.5 px-4 font-medium">{{ $orders->firstItem() + $index }}</td>
                                <td class="py-3.5 px-4 font-semibold text-gray-800">
                                    {{ $item->nama_pelanggan ?? 'Pelanggan R.R Hijab' }}
                                    <div class="text-[11px] text-blue-600 font-mono mt-0.5">Invoice ID: #{{ $item->id_order }}</div>
                                </td>
                                <!-- // ADDED: Menampilkan nama produk, kuantitas beli, serta varian ukuran/warna jilbab dari Flutter -->
                                <td class="py-3.5 px-4">
                                    <div class="font-medium text-gray-800">{{ $item->product->nama_produk ?? 'Hijab Item' }}</div>
                                    @php
                                        $colorVal = $item->warna ?? null;
                                        $isHex = $colorVal && preg_match('/^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/', $colorVal);
                                    @endphp
                                    <div class="text-xs text-gray-400">
                                        Qty: {{ $item->jumlah_beli }} | Size: {{ $item->ukuran ?? '-' }}
                                        @if($colorVal)
                                            | Color: {{ $colorVal }}
                                            @if($isHex)
                                                <span class="inline-block w-4 h-4 rounded-full ml-2 align-middle" style="background-color: {{ $colorVal }};"></span>
                                            @endif
                                        @endif
                                    </div>
                                </td>
                                <!-- // ADDED: Menampilkan data total nominal harga tagihan belanja -->
                                <td class="py-3.5 px-4 font-bold text-gray-900">
                                    Rp {{ number_format($item->total_harga, 0, ',', '.') }}
                                </td>
                                <td class="py-3.5 px-4">
                                    <div class="text-xs text-gray-600 truncate max-w-[180px] mb-1" title="{{ $item->alamat_pengiriman }}"><i class="fa-solid fa-location-dot text-red-400"></i> {{ $item->alamat_pengiriman ?? '-' }}</div>
                                    <div class="text-[11px] text-green-600 font-medium"><i class="fa-brands fa-whatsapp"></i> {{ $item->no_whatsapp ?? '-' }}</div>
                                </td>
                                <td class="py-3.5 px-4 text-center">
                                    <span class="text-xs px-2.5 py-1 rounded-full font-semibold shadow-xs {{ $item->metode_pengiriman === 'JNE' ? 'bg-blue-50 text-blue-700 border border-blue-200' : 'bg-gray-50 text-gray-700 border border-gray-200' }}">
                                        {{ $item->metode_pengiriman ?? '-' }}
                                    </span>
                                <!-- // MODIFIED: Menampilkan status respons Midtrans (Menunggu Pembayaran / Gagal) secara visual -->
                                <td class="py-3.5 px-4 text-center">
                                    <span class="text-xs px-2.5 py-1 rounded-full font-semibold shadow-xs {{ $item->status_pembayaran === 'Pembayaran Gagal' ? 'bg-red-50 text-red-700 border border-red-200' : 'bg-yellow-50 text-yellow-700 border border-yellow-200' }}">
                                        {{ $item->status_pembayaran ?? 'Menunggu Pembayaran' }}
                                    </span>
                                </td>
                                <td class="py-3.5 px-4 text-center">
                                    <div class="inline-flex gap-1.5">
                                        <!-- // MODIFIED: Route aksi proses diarahkan ke endpoint update data pesanan terpadu untuk eksekusi manual apabila diperlukan -->
                                        <form action="{{ route('payment.update', $item->id_order) }}" method="POST">
                                            @csrf @method('PUT')
                                            <input type="hidden" name="status_pembayaran" value="Sudah Dibayar">
                                            <button type="submit" class="bg-[#ccffcc] hover:bg-[#b3ffb3] text-green-900 px-3 py-1 rounded text-xs font-semibold shadow-sm flex items-center gap-1">
                                                <i class="fa-solid fa-circle-check text-[10px]"></i> Lunas
                                            </button>
                                        </form>
                                        <form action="{{ route('payment.destroy', $item->id_order) }}" method="POST" onsubmit="return confirm('Tolak dan batalkan pesanan ini?')">
                                            @csrf @method('DELETE')
                                            <button type="submit" class="bg-[#ffcccc] hover:bg-[#ffb3b3] text-red-900 px-3 py-1 rounded text-xs font-semibold shadow-sm flex items-center gap-1">
                                                <i class="fa-solid fa-trash text-[10px]"></i> Hapus
                                            </button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                            @empty
                            <tr>
                                <td colspan="7" class="text-center py-8 text-gray-400">Antrean verifikasi pembayaran kosong. Semua transaksi berstatus lunas!</td>
                            </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>

                <div class="flex justify-between items-center mt-6 pt-4 border-t border-gray-100 text-sm text-gray-500">
                    <div>Showing {{ $orders->firstItem() ?? 0 }} to {{ $orders->lastItem() ?? 0 }} of {{ $orders->total() }} entries</div>
                    <div>{{ $orders->links() }}</div>
                </div>
            </div>

            <!-- TABEL 2: LAPORAN PEMESANAN (RETENTION & MATCHING FLUTTER DATA STRUCTURE) -->
            <!-- // MODIFIED: Menyamakan struktur tabel laporan pemesanan dengan tabel antrean verifikasi -->
            <div class="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden p-6 mt-10">
                <div class="flex flex-col sm:flex-row justify-between items-center gap-4 mb-4">
                    <div class="text-xl font-semibold text-gray-800">Laporan Pemesanan (Transaksi Sukses / Dikirim)</div>
                </div>

                <div class="overflow-x-auto">
                    <table class="w-full text-left border-collapse">
                        <thead>
                            <tr class="border-b border-gray-100 text-gray-400 text-xs font-semibold uppercase bg-gray-50/70">
                                <th class="py-3 px-4 w-16">No</th>
                                <th class="py-3 px-4">Nama & Invoice</th>
                                <th class="py-3 px-4">Pesanan / Varian</th>
                                <th class="py-3 px-4">Total Tagihan</th>
                                <th class="py-3 px-4">Kontak & Alamat</th>
                                <th class="py-3 px-4 text-center">Metode Pengiriman</th>
                                <th class="py-3 px-4 text-center">Status Pembayaran</th>
                                <th class="py-3 px-4 text-center">Status Produk</th>
                                <th class="py-3 px-4 text-center w-48">Aksi</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100 text-sm text-gray-700">
                            @forelse($processedOrders as $index => $item)
                            <tr class="hover:bg-gray-50/50 transition-colors">
                                <td class="py-3.5 px-4 font-medium">{{ $processedOrders->firstItem() + $index }}</td>
                                <td class="py-3.5 px-4 font-semibold text-gray-800">
                                    {{ $item->nama_pelanggan ?? 'Pelanggan R.R Hijab' }}
                                    <div class="text-[11px] text-blue-600 font-mono mt-0.5">Invoice ID: #{{ $item->id_order }}</div>
                                </td>
                                <td class="py-3.5 px-4">
                                    <div class="font-medium text-gray-800">{{ $item->product->nama_produk ?? 'Hijab Item' }}</div>
                                    <div class="text-xs text-gray-400">Qty: {{ $item->jumlah_beli }} | Size: {{ $item->ukuran ?? '-' }} | Color: {{ $item->warna ?? '-' }}</div>
                                </td>
                                <td class="py-3.5 px-4 font-bold text-gray-900">
                                    Rp {{ number_format($item->total_harga, 0, ',', '.') }}
                                </td>
                                <td class="py-3.5 px-4">
                                    <div class="text-xs text-gray-600 truncate max-w-[180px] mb-1" title="{{ $item->alamat_pengiriman }}"><i class="fa-solid fa-location-dot text-red-400"></i> {{ $item->alamat_pengiriman ?? '-' }}</div>
                                    <div class="text-[11px] text-green-600 font-medium"><i class="fa-brands fa-whatsapp"></i> {{ $item->no_whatsapp ?? '-' }}</div>
                                </td>
                                <td class="py-3.5 px-4 text-center">
                                    <span class="text-xs px-2.5 py-1 rounded-full font-semibold shadow-xs {{ $item->metode_pengiriman === 'JNE' ? 'bg-blue-50 text-blue-700 border border-blue-200' : 'bg-gray-50 text-gray-700 border border-gray-200' }}">
                                        {{ $item->metode_pengiriman ?? '-' }}
                                    </span>
                                </td>
                                <td class="py-3.5 px-4 text-center">
                                    <span class="text-xs px-2.5 py-1 rounded-full font-semibold shadow-xs {{ $item->status_pembayaran === 'Pembayaran Gagal' ? 'bg-red-50 text-red-700 border border-red-200' : 'bg-green-50 text-green-700 border border-green-200' }}">
                                        {{ $item->status_pembayaran ?? 'Sudah Dibayar' }}
                                    </span>
                                </td>
                                <td class="py-3.5 px-4 text-center">
                                    @php
                                        $statusProduk = $item->status_produk ?? 'Menunggu';
                                        $statusProdukClass = match ($statusProduk) {
                                            'Dikirim' => 'bg-blue-50 text-blue-700 border border-blue-200',
                                            'Siap Dikirim' => 'bg-yellow-50 text-yellow-700 border border-yellow-200',
                                            'Diproses' => 'bg-purple-50 text-purple-700 border border-purple-200',
                                            'Selesai' => 'bg-green-50 text-green-700 border border-green-200',
                                            default => 'bg-gray-50 text-gray-700 border border-gray-200',
                                        };
                                    @endphp
                                    <span class="text-xs px-2.5 py-1 rounded-full font-semibold shadow-xs {{ $statusProdukClass }}">
                                        {{ $statusProduk }}
                                    </span>
                                </td>
                                
                                <td class="py-3.5 px-4 text-center">
                                    <div class="inline-flex gap-1.5">
                                        <form action="{{ route('payment.update', $item->id_order) }}" method="POST">
                                            @csrf @method('PUT')
                                            <input type="hidden" name="status_pembayaran" value="Dikirim">
                                            <button type="submit" class="bg-[#ccffcc] hover:bg-[#b3ffb3] text-green-900 px-3 py-1 rounded text-xs font-semibold shadow-sm flex items-center gap-1">
                                                <i class="fa-solid fa-truck-fast text-[10px]"></i> Dikirim
                                            </button>
                                        </form>
                                        <form action="{{ route('payment.destroy', $item->id_order) }}" method="POST" onsubmit="return confirm('Hapus laporan pemesanan ini?')">
                                            @csrf @method('DELETE')
                                            <button type="submit" class="bg-[#ffcccc] hover:bg-[#ffb3b3] text-red-900 px-3 py-1 rounded text-xs font-semibold shadow-sm flex items-center gap-1">
                                                <i class="fa-solid fa-trash text-[10px]"></i> Hapus
                                            </button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                            @empty
                            <tr>
                                <td colspan="7" class="text-center py-8 text-gray-400">Belum ada laporan pemesanan yang sedang diproses.</td>
                            </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>

                <div class="flex justify-between items-center mt-6 pt-4 border-t border-gray-100 text-sm text-gray-500">
                    <div>Showing {{ $processedOrders->firstItem() ?? 0 }} to {{ $processedOrders->lastItem() ?? 0 }} of {{ $processedOrders->total() }} entries</div>
                    <div>{{ $processedOrders->links('pagination::tailwind') }}</div>
                </div>
            </div>
        </main>
    </div>
    <script>
        function toggleDropdown(id) {
            const menu = document.getElementById(id);
            const chevron = document.getElementById('masterChevron');
            if (menu.classList.contains('hidden')) {
                menu.classList.remove('hidden');
                chevron.classList.add('rotate-180');
            } else {
                menu.classList.add('hidden');
                chevron.classList.remove('rotate-180');
            }
        }
    </script>
</body>
</html>