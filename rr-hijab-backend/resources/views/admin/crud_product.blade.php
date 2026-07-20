<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}"> 
    <title>Katalog Barang Terpadu - R.R HIJAB</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="bg-gray-50 font-sans antialiased flex flex-col h-screen">

    <header class="w-full bg-[#ccccff]/40 bg-gradient-to-r from-[#ccccff]/30 to-[#ccffcc]/30 py-4 px-6 border-b border-gray-200 flex items-center justify-between shadow-sm z-10">
        <h1 class="text-xl font-bold tracking-wide text-gray-800">R.R HIJAB</h1>
        <div class="text-sm font-semibold text-gray-700 bg-white/80 px-3 py-1 rounded-full border border-gray-200 shadow-sm flex items-center gap-2">
            <span class="w-2 h-2 rounded-full bg-green-500 animate-pulse"></span> Panel Admin Terpadu
        </div>
    </header>

    <div class="flex flex-1 overflow-hidden">
        <aside class="w-64 bg-white border-r border-gray-200 flex flex-col justify-between shadow-sm">
            <div class="p-4 space-y-6">
                <div>
                    <a href="{{ route('admin.dashboard') }}" class="px-3 text-xs font-semibold text-gray-600 hover:text-gray-900 uppercase tracking-wider block mb-2 hover:bg-[#ffcccc]/20 rounded px-3 py-2 transition-colors">← Menu Utama</a>
                    <nav class="space-y-1">
                        <div class="space-y-1">
                            <button type="button" onclick="toggleDropdown('masterSubmenu')" class="w-full flex items-center justify-between px-3 py-2.5 text-sm font-medium text-gray-700 bg-gray-50 rounded-lg border border-gray-100 hover:bg-[#ffcccc]/20 transition-colors">
                                <span class="flex items-center gap-2.5"><i class="fa-solid fa-gear text-gray-500"></i> Master</span>
                                <i id="masterChevron" class="fa-solid fa-chevron-down text-xs text-gray-400 transition-transform duration-200"></i>
                            </button>
                            <div id="masterSubmenu" class="pl-8 space-y-1 mt-1 hidden transition-all duration-200">
                                <a href="{{ route('admin.index') }}" class="flex items-center gap-2.5 px-3 py-2.5 text-sm font-medium text-gray-600 hover:bg-[#ffcccc]/20 rounded-lg">Admin</a>
                                <a href="{{ route('user.index') }}" class="flex items-center gap-2.5 px-3 py-2.5 text-sm font-medium text-gray-600 hover:bg-[#ffcccc]/20 rounded-lg">User</a>
                            </div>
                        </div>
                        <a href="{{ route('product.index') }}" class="flex items-center gap-2.5 px-3 py-2.5 text-sm font-semibold text-gray-900 bg-[#ffcccc]/30 rounded-md"><i class="fa-solid fa-box text-gray-700"></i> Katalog Barang</a>
                        <a href="{{ route('payment.index') }}" class="flex items-center gap-2.5 px-3 py-2.5 text-sm font-medium text-gray-600 hover:bg-[#ffcccc]/20 rounded-lg"><i class="fa-solid fa-calendar-days text-gray-400"></i> Verifikasi Pembayaran</a>
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

            <div class="flex justify-between items-center mb-6">
                <h2 class="text-3xl font-bold text-gray-800 tracking-tight">Katalog Barang Terpadu</h2>
                <button onclick="toggleModal('addProductModal')" class="bg-[#ccffcc] hover:bg-[#b3ffb3] text-gray-800 px-4 py-2 rounded-lg text-sm font-semibold flex items-center gap-2 transition-colors shadow-sm">
                    <i class="fa-solid fa-plus text-xs"></i> Tambah Barang
                </button>
            </div>

            <div class="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden p-6">
                <div class="flex flex-col sm:flex-row justify-between items-center gap-4 mb-4">
                    <div class="text-sm text-gray-500">
                        Show <select class="border border-gray-300 rounded px-2 py-1 mx-1 text-sm bg-gray-50 focus:outline-none"><option>10</option></select> entries
                    </div>
                    <form method="GET" action="{{ route('product.index') }}" class="w-full sm:w-auto">
                        <input type="text" name="search" value="{{ $search }}" placeholder="Search..." 
                               class="w-full sm:w-64 px-3 py-1.5 border border-gray-300 rounded-lg text-sm bg-gray-50 focus:outline-none focus:border-[#ffcccc]">
                    </form>
                </div>

                <div class="overflow-x-auto">
                    <table class="w-full text-left border-collapse">
                        <thead>
                            <tr class="border-b border-gray-100 text-gray-400 text-xs font-semibold uppercase bg-gray-50/70">
                                <th class="py-3 px-4 w-16">No</th>
                                <th class="py-3 px-4">Nama Barang</th>
                                <th class="py-3 px-4">Gambar Cover</th>
                                <th class="py-3 px-4">Kategori / Harga</th>
                                <th class="py-3 px-4">Penempatan Beranda</th>
                                <th class="py-3 px-4">Sizes / Colors (Flutter)</th>
                                <th class="py-3 px-4 w-20 text-center">Stok</th>
                                <th class="py-3 px-4 text-center w-56">Aksi</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100 text-sm text-gray-700">
                            @forelse($products as $index => $item)
                            <tr class="hover:bg-gray-50/50 transition-colors">
                                <td class="py-3.5 px-4 font-medium">{{ $products->firstItem() + $index }}</td>
                                <td class="py-3.5 px-4 font-semibold text-gray-800">{{ $item->nama_produk }}</td>
                                <td class="py-3.5 px-4">
                                    <img src="{{ Illuminate\Support\Str::startsWith($item->link_foto, ['http://', 'https://']) ? $item->link_foto : asset($item->link_foto) }}" alt="Foto Hijab" class="w-12 h-12 rounded-lg object-cover border border-gray-100 shadow-sm" onerror="this.src='https://placehold.co/150?text=No+Image'">
                                </td>
                                <td class="py-3.5 px-4">
                                    <span class="text-xs bg-gray-100 text-gray-600 px-2 py-0.5 rounded-full font-medium">{{ $item->kategori }}</span>
                                    <div class="text-gray-900 font-semibold mt-1">Rp {{ number_format($item->harga, 0, ',', '.') }}</div>
                                    <div class="mt-1 flex flex-wrap gap-1">
                                        <span class="inline-block px-2 py-0.5 rounded-full text-[10px] font-medium {{ $item->status === 'Aktif' ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700' }}">
                                            {{ $item->status }}
                                        </span>
                                        @if($item->is_featured)
                                            <span class="bg-purple-100 text-purple-700 text-[10px] px-2 py-0.5 rounded-full font-medium">Featured</span>
                                        @endif
                                        @if($item->promo)
                                            <span class="bg-rose-100 text-rose-700 text-[10px] px-2 py-0.5 rounded-full font-semibold">Promo: {{ $item->promo }}</span>
                                        @endif
                                    </div>
                                </td>
                                <td class="py-3.5 px-4">
                                    @if($item->home_section === 'koleksi')
                                        <span class="text-xs text-blue-700 bg-blue-50 border border-blue-100 px-2 py-1 rounded-md font-medium">Koleksi Terbaru</span>
                                    @elseif($item->home_section === 'terbaru')
                                        <span class="text-xs text-orange-700 bg-orange-50 border border-orange-100 px-2 py-1 rounded-md font-medium">Produk Terbaru</span>
                                    @elseif($item->home_section === 'promo')
                                        <span class="text-xs text-red-700 bg-red-50 border border-red-100 px-2 py-1 rounded-md font-medium">Promo Spesial</span>
                                    @else
                                        <span class="text-xs text-gray-400 italic">Katalog Biasa</span>
                                    @endif
                                </td>
                                <td class="py-3.5 px-4">
                                    <div class="space-y-1 text-xs text-gray-600">
                                        <div><strong>Sizes:</strong> {{ !empty($item->available_sizes) ? (is_array($item->available_sizes) ? implode(', ', $item->available_sizes) : $item->available_sizes) : '-' }}</div>
                                        <div><strong>Colors:</strong> {{ !empty($item->available_colors) ? (is_array($item->available_colors) ? implode(', ', $item->available_colors) : $item->available_colors) : '-' }}</div>
                                    </div>
                                </td>
                                <td class="py-3.5 px-4 text-center">
                                    <span class="font-bold {{ $item->stok == 0 ? 'text-red-500' : 'text-gray-700' }}">{{ $item->stok }}</span>
                                </td>
                                <td class="py-3.5 px-4 text-center">
                                    <div class="inline-flex gap-1">
                                        <button type="button" onclick='openDetailModal({!! json_encode($item) !!})' class="bg-[#ccffcc] text-[#1f4f1f] px-2.5 py-1 rounded text-xs font-medium">Detail</button>
                                        <button type="button" onclick='openEditProductModal({!! json_encode($item) !!})' class="bg-[#ccccff] text-gray-800 px-2.5 py-1 rounded text-xs font-medium">Edit</button>
                                        <form action="{{ route('product.destroy', $item->id_produk) }}" method="POST" onsubmit="return confirm('Hapus barang ini?')">
                                            @csrf @method('DELETE')
                                            <button type="submit" class="bg-[#ffcccc] text-gray-800 px-2.5 py-1 rounded text-xs font-medium">Hapus</button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                            @empty
                            <tr>
                                <td colspan="8" class="text-center py-8 text-gray-400">Belum ada barang di katalog.</td>
                            </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>

                <div class="flex justify-between items-center mt-6 pt-4 border-t border-gray-100 text-sm text-gray-500">
                    <div>Showing {{ $products->firstItem() ?? 0 }} to {{ $products->lastItem() ?? 0 }} of {{ $products->total() }} entries</div>
                    <div>{{ $products->links() }}</div>
                </div>
            </div>
        </main>
    </div>

    <div id="addProductModal" class="fixed inset-0 bg-black/40 backdrop-blur-sm hidden items-center justify-center z-50">
        <div class="bg-white rounded-xl shadow-xl max-w-md w-full p-6 mx-4 overflow-y-auto max-h-[90vh]">
            <div class="flex justify-between items-center mb-4 pb-2 border-b">
                <h3 class="text-lg font-bold text-gray-800">Tambah Barang Baru</h3>
                <button onclick="toggleModal('addProductModal')" class="text-gray-400 hover:text-gray-600"><i class="fa-solid fa-xmark"></i></button>
            </div>
            <form action="{{ route('product.store') }}" method="POST" enctype="multipart/form-data" class="space-y-4">
                @csrf
                <div>
                    <label class="block text-xs font-semibold text-gray-600 uppercase mb-1">Nama Jilbab</label>
                    <input type="text" name="nama_produk" id="add_nama_produk" required class="w-full px-3 py-2 border rounded-lg text-sm focus:outline-none focus:border-[#ffcccc]">
                </div>
                <div class="grid grid-cols-2 gap-3">
                    <div>
                        <label class="block text-xs font-semibold text-gray-600 uppercase mb-1">Kategori</label>
                        <input type="text" name="kategori" required class="w-full px-3 py-2 border rounded-lg text-sm focus:outline-none focus:border-[#ffcccc]">
                    </div>
                    <div>
                        <label class="block text-xs font-semibold text-gray-600 uppercase mb-1">Stok Awal</label>
                        <input type="number" name="stok" required class="w-full px-3 py-2 border rounded-lg text-sm focus:outline-none focus:border-[#ffcccc]">
                    </div>
                </div>
                <div>
                    <label class="block text-xs font-semibold text-gray-600 uppercase mb-1">Harga Jual</label>
                    <input type="number" name="harga" required step="0.01" class="w-full px-3 py-2 border rounded-lg text-sm focus:outline-none focus:border-[#ffcccc]">
                </div>
                <div>
                    <label class="block text-xs font-semibold text-gray-600 uppercase mb-1">Status Keaktifan</label>
                    <select name="status" class="w-full px-3 py-2 border rounded-lg text-sm focus:outline-none focus:border-[#ffcccc]">
                        <option value="Aktif">Aktif</option>
                        <option value="Tidak Aktif">Tidak Aktif</option>
                    </select>
                </div>
                <div>
                    <label class="block text-xs font-semibold text-gray-600 uppercase mb-1">Upload File Foto Produk (Pilih Banyak)</label>
                    <input type="file" name="gambar_produk[]" accept="image/*" multiple required class="w-full rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm focus:outline-none focus:border-[#ffcccc] file:mr-3 file:rounded-full file:border-0 file:bg-[#ffcccc] file:px-3 file:py-1.5 file:text-xs file:font-semibold">
                </div>

                <div>
                    <label class="block text-xs font-semibold text-gray-600 uppercase mb-1">Promo Produk (Opsional)</label>
                    <input type="text" name="promo" maxlength="255" class="w-full px-3 py-2 border rounded-lg text-sm focus:outline-none focus:border-[#ffcccc]" placeholder="Contoh: Diskon 20% / Flash Sale">
                </div>

                <div class="grid gap-3 p-3 bg-gray-50 rounded-xl border border-gray-100">
                    <span class="text-xs font-bold text-gray-700 uppercase block"><i class="fa-solid fa-mobile-screen"></i> Atribut Variasi Data</span>
                    <div class="grid grid-cols-2 gap-2">
                        <div>
                            <label class="block text-[10px] font-semibold text-gray-600 uppercase mb-0.5">Available Sizes (Koma)</label>
                            <input type="text" name="available_sizes" placeholder="S, M, L" class="w-full px-2 py-1 border rounded text-xs focus:outline-none">
                        </div>
                        <div>
                            <label class="block text-[10px] font-semibold text-gray-600 uppercase mb-0.5">Stok per Size (Format k:v)</label>
                            <input type="text" name="available_size_stocks" placeholder="S:5, M:3" class="w-full px-2 py-1 border rounded text-xs focus:outline-none">
                        </div>
                    </div>
                    <div class="grid grid-cols-2 gap-2">
                        <div>
                            <label class="block text-[10px] font-semibold text-gray-600 uppercase mb-0.5">Available Colors (Koma)</label>
                            <input type="text" name="available_colors" placeholder="Hitam, Navy" class="w-full px-2 py-1 border rounded text-xs focus:outline-none">
                        </div>
                        <div>
                            <label class="block text-[10px] font-semibold text-gray-600 uppercase mb-0.5">Stok per Warna (Format k:v)</label>
                            <input type="text" name="available_color_stocks" placeholder="Hitam:10, Navy:5" class="w-full px-2 py-1 border rounded text-xs focus:outline-none">
                        </div>
                    </div>
                </div>

                <div>
                    <label class="block text-xs font-semibold text-gray-600 uppercase mb-1">Tampilkan di Beranda (Section)</label>
                    <select name="home_section" class="w-full px-3 py-2 border rounded-lg text-sm focus:outline-none focus:border-[#ffcccc]">
                        <option value="">-- Tidak di Beranda (Katalog Biasa) --</option>
                        <option value="koleksi">Koleksi Terbaru</option>
                        <option value="terbaru">Produk Terbaru</option>
                        <option value="promo">Promo Spesial</option>
                    </select>
                </div>

                <div>
                    <label class="block text-xs font-semibold text-gray-600 uppercase mb-1">Deskripsi Produk</label>
                    <textarea id="add_deskripsi" name="deskripsi" rows="3" required class="w-full px-3 py-2 border rounded-lg text-sm focus:outline-none focus:border-[#ffcccc]"></textarea>
                    <button type="button" id="btn_add_generate" onclick="generateDeskripsi('add')" class="mt-2 w-full bg-[#ccccff] text-gray-800 py-1.5 rounded-lg text-xs font-semibold">✨ Generate Deskripsi dengan AI</button>
                </div>
                <div class="flex items-center gap-2">
                    <input type="checkbox" id="add_is_featured" name="is_featured" value="1" class="w-4 h-4">
                    <label for="add_is_featured" class="text-sm text-gray-600">Tandai sebagai Unggulan (Featured)</label>
                </div>
                <div class="flex gap-3">
                    <button type="button" onclick="toggleModal('addProductModal')" class="flex-1 bg-gray-300 text-gray-800 py-2 rounded-lg text-sm font-semibold">Batal</button>
                    <button type="submit" class="flex-1 bg-[#ccffcc] text-gray-800 py-2 rounded-lg text-sm font-semibold">Simpan</button>
                </div>
            </form>
        </div>
    </div>

    <div id="detailProductModal" class="fixed inset-0 bg-black/40 backdrop-blur-sm hidden items-center justify-center z-50 px-4">
        <div class="bg-white rounded-2xl shadow-xl max-w-lg w-full p-6 mx-auto overflow-y-auto max-h-[90vh] border border-gray-100">
            <div class="flex justify-between items-start mb-4 pb-2 border-b">
                <div>
                    <h3 class="text-lg font-bold text-gray-800">Detail Lengkap Komoditas</h3>
                    <p id="detailNama" class="text-sm font-semibold text-gray-500 mt-1"></p>
                </div>
                <button onclick="toggleModal('detailProductModal')" class="text-gray-400 hover:text-gray-600"><i class="fa-solid fa-xmark"></i></button>
            </div>
            
            <div class="space-y-4">
                <div class="grid grid-cols-2 gap-3 text-xs">
                    <div class="bg-gray-50 p-3 rounded-lg border">
                        <span class="text-gray-400 uppercase block font-bold mb-0.5">Kategori</span>
                        <span id="detailKategori" class="font-semibold text-gray-800 text-sm"></span>
                    </div>
                    <div class="bg-gray-50 p-3 rounded-lg border">
                        <span class="text-gray-400 uppercase block font-bold mb-0.5">Harga</span>
                        <span id="detailHarga" class="font-semibold text-gray-800 text-sm"></span>
                    </div>
                    <div class="bg-gray-50 p-3 rounded-lg border">
                        <span class="text-gray-400 uppercase block font-bold mb-0.5">Stok Global</span>
                        <span id="detailStok" class="font-semibold text-gray-800 text-sm"></span>
                    </div>
                    <div class="bg-gray-50 p-3 rounded-lg border">
                        <span class="text-gray-400 uppercase block font-bold mb-0.5">Lokasi Beranda</span>
                        <span id="detailHomeSection" class="font-semibold text-gray-800 text-sm"></span>
                    </div>
                </div>

                <div class="bg-rose-50/50 p-3 rounded-lg border border-rose-100 text-xs">
                    <span class="text-rose-400 uppercase block font-bold mb-0.5">Status Promo Aktif</span>
                    <span id="detailPromo" class="font-semibold text-rose-700 text-sm">-</span>
                </div>

                <div class="bg-gray-50 p-3 rounded-lg border text-xs">
                    <span class="text-gray-400 uppercase block font-bold mb-1"><i class="fa-solid fa-mobile-screen"></i> Atribut Variasi & Rincian Stok</span>
                    <div class="grid grid-cols-2 gap-2 mt-1">
                        <div><strong>Sizes:</strong> <span id="detailSizes"></span></div>
                        <div><strong>Stok/Size:</strong> <span id="detailSizesStocks"></span></div>
                    </div>
                    <div class="grid grid-cols-2 gap-2 mt-2 pt-2 border-t border-gray-200">
                        <div><strong>Colors:</strong> <span id="detailColors"></span></div>
                        <div><strong>Stok/Warna:</strong> <span id="detailColorsStocks"></span></div>
                    </div>
                </div>

                <div>
                    <span class="text-xs font-bold text-gray-400 uppercase block mb-1">Cover Utama & Galeri Gambar</span>
                    <div id="detailPhotoContainer" class="flex flex-wrap gap-2 p-2 bg-gray-50 rounded-lg border"></div>
                </div>

                <div>
                    <span class="text-xs font-bold text-gray-400 uppercase block mb-1">Deskripsi Narasi</span>
                    <p id="detailDesc" class="text-xs text-gray-600 bg-gray-50 p-3 rounded-lg border leading-relaxed"></p>
                </div>
            </div>
        </div>
    </div>

    <div id="editProductModal" class="fixed inset-0 bg-black/40 backdrop-blur-sm hidden items-center justify-center z-50">
        <div class="bg-white rounded-xl shadow-xl max-w-md w-full p-6 mx-4 overflow-y-auto max-h-[90vh]">
            <div class="flex justify-between items-center mb-4 pb-2 border-b">
                <h3 class="text-lg font-bold text-gray-800">Edit Data Barang</h3>
                <button onclick="toggleModal('editProductModal')" class="text-gray-400 hover:text-gray-600"><i class="fa-solid fa-xmark"></i></button>
            </div>
            <form id="editProductForm" method="POST" enctype="multipart/form-data" class="space-y-4">
                @csrf 
                @method('PUT')

                <input type="hidden" id="edit_current_link_foto" name="current_link_foto">

                <div>
                    <label class="block text-xs font-semibold text-gray-600 uppercase mb-1">Nama Jilbab</label>
                    <input type="text" id="edit_nama_produk" name="nama_produk" required class="w-full px-3 py-2 border rounded-lg text-sm focus:outline-none focus:border-[#ffcccc]">
                </div>
                <div class="grid grid-cols-2 gap-3">
                    <div>
                        <label class="block text-xs font-semibold text-gray-600 uppercase mb-1">Kategori</label>
                        <input type="text" id="edit_kategori" name="kategori" required class="w-full px-3 py-2 border rounded-lg text-sm focus:outline-none focus:border-[#ffcccc]">
                    </div>
                    <div>
                        <label class="block text-xs font-semibold text-gray-600 uppercase mb-1">Stok</label>
                        <input type="number" id="edit_stok" name="stok" required class="w-full px-3 py-2 border rounded-lg text-sm focus:outline-none focus:border-[#ffcccc]">
                    </div>
                </div>
                <div>
                    <label class="block text-xs font-semibold text-gray-600 uppercase mb-1">Harga Jual</label>
                    <input type="number" id="edit_harga" name="harga" required step="0.01" class="w-full px-3 py-2 border rounded-lg text-sm focus:outline-none focus:border-[#ffcccc]">
                </div>
                <div>
                    <label class="block text-xs font-semibold text-gray-600 uppercase mb-1">Status Keaktifan</label>
                    <select id="edit_status" name="status" class="w-full px-3 py-2 border rounded-lg text-sm focus:outline-none focus:border-[#ffcccc]">
                        <option value="Aktif">Aktif</option>
                        <option value="Tidak Aktif">Tidak Aktif</option>
                    </select>
                </div>
                
                <div>
                    <label class="block text-xs font-semibold text-gray-600 uppercase mb-1">Ganti Semua Galeri Foto Baru (Pilih Banyak / Opsional)</label>
                    <input type="file" name="gambar_produk[]" accept="image/*" multiple class="w-full rounded-lg border border-gray-300 bg-white px-3 py-2 text-sm focus:outline-none">
                </div>

                <div>
                    <label class="block text-xs font-semibold text-gray-600 uppercase mb-1">Promo Produk (Opsional)</label>
                    <input type="text" id="edit_promo" name="promo" maxlength="255" class="w-full px-3 py-2 border rounded-lg text-sm focus:outline-none focus:border-[#ffcccc]" placeholder="Contoh: Diskon 20% / Flash Sale">
                </div>

                <div class="grid gap-3 p-3 bg-gray-50 rounded-xl border border-gray-100">
                    <span class="text-xs font-bold text-gray-700 uppercase block"><i class="fa-solid fa-mobile-screen"></i> Atribut Variasi Data</span>
                    <div class="grid grid-cols-2 gap-2">
                        <div>
                            <label class="block text-[10px] font-semibold text-gray-600 uppercase mb-0.5">Available Sizes</label>
                            <input type="text" id="edit_available_sizes" name="available_sizes" class="w-full px-2 py-1 border rounded text-xs focus:outline-none">
                        </div>
                        <div>
                            <label class="block text-[10px] font-semibold text-gray-600 uppercase mb-0.5">Stok per Size</label>
                            <input type="text" id="edit_available_size_stocks" name="available_size_stocks" class="w-full px-2 py-1 border rounded text-xs focus:outline-none">
                        </div>
                    </div>
                    <div class="grid grid-cols-2 gap-2">
                        <div>
                            <label class="block text-[10px] font-semibold text-gray-600 uppercase mb-0.5">Available Colors</label>
                            <input type="text" id="edit_available_colors" name="available_colors" class="w-full px-2 py-1 border rounded text-xs focus:outline-none">
                        </div>
                        <div>
                            <label class="block text-[10px] font-semibold text-gray-600 uppercase mb-0.5">Stok per Warna</label>
                            <input type="text" id="edit_available_color_stocks" name="available_color_stocks" class="w-full px-2 py-1 border rounded text-xs focus:outline-none">
                        </div>
                    </div>
                </div>

                <div>
                    <label class="block text-xs font-semibold text-gray-600 uppercase mb-1">Tampilkan di Beranda (Section)</label>
                    <select id="edit_home_section" name="home_section" class="w-full px-3 py-2 border rounded-lg text-sm focus:outline-none focus:border-[#ffcccc]">
                        <option value="">-- Tidak di Beranda (Katalog Biasa) --</option>
                        <option value="koleksi">Koleksi Terbaru</option>
                        <option value="terbaru">Produk Terbaru</option>
                        <option value="promo">Promo Spesial</option>
                    </select>
                </div>

                <div>
                    <label class="block text-xs font-semibold text-gray-600 uppercase mb-1">Deskripsi Produk</label>
                    <textarea id="edit_deskripsi" name="deskripsi" rows="3" required class="w-full px-3 py-2 border rounded-lg text-sm focus:outline-none focus:border-[#ffcccc]"></textarea>
                </div>
                <div class="flex items-center gap-2">
                    <input type="checkbox" id="edit_is_featured" name="is_featured" value="1" class="w-4 h-4">
                    <label for="edit_is_featured" class="text-sm text-gray-600">Tandai sebagai Unggulan (Featured)</label>
                </div>
                <div class="flex gap-3">
                    <a href="{{ route('product.index') }}" class="flex-1 bg-gray-300 text-gray-800 py-2 rounded-lg text-sm font-semibold text-center flex items-center justify-center transition-colors hover:bg-gray-400">Batal</a>
                    <button type="submit" class="flex-1 bg-[#ccccff] text-gray-800 py-2 rounded-lg text-sm font-semibold hover:bg-[#b3b3ff] transition-colors">Simpan Perubahan</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function toggleModal(modalId) {
            const modal = document.getElementById(modalId);
            modal.classList.toggle('hidden');
            if(!modal.classList.contains('hidden')) modal.classList.add('flex');
        }

        function toggleDropdown(id) {
            document.getElementById(id).classList.toggle('hidden');
            document.getElementById('masterChevron').classList.toggle('rotate-180');
        }

        function formatStockObjectToString(obj) {
            if (!obj || typeof obj !== 'object') return obj || '';
            return Object.entries(obj).map(([k, v]) => `${k}:${v}`).join(', ');
        }

        function openDetailModal(product) {
            document.getElementById('detailNama').textContent = product.nama_produk;
            document.getElementById('detailKategori').textContent = product.kategori;
            document.getElementById('detailHarga').textContent = 'Rp ' + Number(product.harga).toLocaleString('id-ID');
            document.getElementById('detailStok').textContent = product.stok + ' pcs';
            document.getElementById('detailDesc').textContent = product.deskripsi;
            
            document.getElementById('detailPromo').textContent = product.promo || 'Tidak ada promo aktif';
            
            const sectionLabels = { 'koleksi': 'Koleksi Terbaru', 'terbaru': 'Produk Terbaru', 'promo': 'Promo Spesial' };
            document.getElementById('detailHomeSection').textContent = sectionLabels[product.home_section] || 'Katalog Biasa';
            
            document.getElementById('detailSizes').textContent = Array.isArray(product.available_sizes) ? product.available_sizes.join(', ') : (product.available_sizes || '-');
            document.getElementById('detailSizesStocks').textContent = formatStockObjectToString(product.available_size_stocks) || '-';
            document.getElementById('detailColors').textContent = Array.isArray(product.available_colors) ? product.available_colors.join(', ') : (product.available_colors || '-');
            document.getElementById('detailColorsStocks').textContent = formatStockObjectToString(product.available_color_stocks) || '-';
            
            const photoContainer = document.getElementById('detailPhotoContainer');
            photoContainer.innerHTML = ''; 
            
            const imgCover = document.createElement('img');
            imgCover.src = product.link_foto.startsWith('http') ? product.link_foto : '/' + product.link_foto;
            imgCover.className = "w-16 h-16 rounded border-2 border-blue-400 object-cover shadow-sm";
            photoContainer.appendChild(imgCover);

            if(Array.isArray(product.link_fotos)) {
                product.link_fotos.forEach(foto => {
                    if(foto !== product.link_foto) {
                        const imgExtra = document.createElement('img');
                        imgExtra.src = foto.startsWith('http') ? foto : '/' + foto;
                        imgExtra.className = "w-16 h-16 rounded border object-cover shadow-xs";
                        photoContainer.appendChild(imgExtra);
                    }
                });
            }
            
            toggleModal('detailProductModal');
        }

        // // FIXED: URL action form edit diserahkan aman menuju rute update panel utama terpadu aktif
        function openEditProductModal(product) {
            document.getElementById('editProductForm').action = `/product/manage/${product.id_produk}`;
            
            document.getElementById('edit_nama_produk').value = product.nama_produk;
            document.getElementById('edit_kategori').value = product.kategori;
            document.getElementById('edit_harga').value = product.harga;
            document.getElementById('edit_stok').value = product.stok;
            document.getElementById('edit_status').value = product.status || 'Aktif';
            document.getElementById('edit_deskripsi').value = product.deskripsi;
            document.getElementById('edit_promo').value = product.promo || '';
            
            // // FIXED SINKRONISASI: Menaruh path foto lama database ke input hidden cadangan penolak error null
            document.getElementById('edit_current_link_foto').value = product.link_foto;

            document.getElementById('edit_available_sizes').value = Array.isArray(product.available_sizes) ? product.available_sizes.join(', ') : (product.available_sizes || '');
            document.getElementById('edit_available_colors').value = Array.isArray(product.available_colors) ? product.available_colors.join(', ') : (product.available_colors || '');
            
            document.getElementById('edit_available_size_stocks').value = formatStockObjectToString(product.available_size_stocks);
            document.getElementById('edit_available_color_stocks').value = formatStockObjectToString(product.available_color_stocks);
            
            document.getElementById('edit_home_section').value = product.home_section || '';
            document.getElementById('edit_is_featured').checked = (parseInt(product.is_featured) === 1 || product.is_featured === true);
            
            toggleModal('editProductModal');
        }

        function generateDeskripsi(mode) {
            const namaInput = document.getElementById(mode === 'add' ? 'add_nama_produk' : 'edit_nama_produk');
            const tekstArea = document.getElementById(mode === 'add' ? 'add_deskripsi' : 'edit_deskripsi');
            const btn = document.getElementById(`btn_${mode}_generate`);

            if (!namaInput.value) { alert('Isi nama produk dulu!'); return; }

            btn.innerText = '⏳ Generating...';
            btn.disabled = true;

            fetch('/admin/generate-description', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                },
                body: JSON.stringify({ nama_produk: namaInput.value })
            })
            .then(res => res.json())
            .then(data => {
                tekstArea.value = data.deskripsi;
                btn.innerText = '✨ Generate Deskripsi dengan AI';
                btn.disabled = false;
            })
            .catch(() => {
                alert('Gagal generate deskripsi!');
                btn.disabled = false;
            });
        }
    </script>
</body>
</html>