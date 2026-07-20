<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kelola Komentar Terpadu - R.R HIJAB</title>
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
                        <a href="{{ route('product.index') }}" class="flex items-center gap-2.5 px-3 py-2.5 text-sm font-medium text-gray-600 hover:bg-[#ffcccc]/20 rounded-lg"><i class="fa-solid fa-box text-gray-400"></i> Katalog Barang</a>
                        <a href="{{ route('payment.index') }}" class="flex items-center gap-2.5 px-3 py-2.5 text-sm font-medium text-gray-600 hover:bg-[#ffcccc]/20 rounded-lg"><i class="fa-solid fa-calendar-days text-gray-400"></i> Verifikasi Pembayaran</a>
                        <a href="{{ route('comment.index') }}" class="flex items-center gap-2.5 px-3 py-2.5 text-sm font-semibold text-gray-900 bg-[#ffcccc]/30 rounded-md"><i class="fa-solid fa-comments text-gray-700"></i> Ulasan & Komentar</a>
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

            <div class="mb-6">
                <h2 class="text-3xl font-bold text-gray-800 tracking-tight">Manajemen Ulasan & Komentar</h2>
                <p class="text-sm text-gray-500 mt-1">Moderasi seluruh review bintang dan isi opini ulasan produk hijab dari aplikasi Web maupun Flutter Mobile.</p>
            </div>

            <div class="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden p-6">
                <div class="flex flex-col sm:flex-row justify-between items-center gap-4 mb-4">
                    <div class="text-sm text-gray-500">
                        Show <select class="border border-gray-300 rounded px-2 py-1 mx-1 text-sm bg-gray-50 focus:outline-none"><option>10</option></select> entries
                    </div>
                    <form method="GET" action="{{ route('comment.index') }}" class="w-full sm:w-auto">
                        <input type="text" name="search" value="{{ $search }}" placeholder="Cari user, produk, isi ulasan..." 
                               class="w-full sm:w-64 px-3 py-1.5 border border-gray-300 rounded-lg text-sm bg-gray-50 focus:outline-none focus:border-[#ffcccc]">
                    </form>
                </div>

                <div class="overflow-x-auto">
                    <table class="w-full text-left border-collapse">
                        <thead>
                            <tr class="border-b border-gray-100 text-gray-400 text-xs font-semibold uppercase bg-gray-50/70">
                                <th class="py-3 px-4 w-16">No</th>
                                <th class="py-3 px-4">Nama Pelanggan</th>
                                <th class="py-3 px-4">Produk Hijab</th>
                                <th class="py-3 px-4 w-28 text-center">Rating</th>
                                <th class="py-3 px-4">Isi Komentar / Ulasan</th>
                                <th class="py-3 px-4">Foto Barang</th>
                                <th class="py-3 px-4 w-40">Tanggal Post</th>
                                <th class="py-3 px-4 text-center w-28">Aksi</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100 text-sm text-gray-700">
                            @forelse($comments as $index => $item)
                            <tr class="hover:bg-gray-50/50 transition-colors">
                                <td class="py-3.5 px-4 font-medium">{{ $comments->firstItem() + $index }}</td>
                                <td class="py-3.5 px-4 font-semibold text-gray-800">{{ $item->user_name ?? 'Pelanggan R.R Hijab' }}</td>
                                <td class="py-3.5 px-4 font-medium text-blue-600">{{ $item->product_name ?? 'Produk Terhapus' }}</td>
                                <td class="py-3.5 px-4 text-center">
                                    <div class="flex items-center justify-center text-amber-400 gap-0.5">
                                        @if(isset($item->rating) && $item->rating > 0)
                                            @for($i = 1; $i <= 5; $i++)
                                                <i class="{{ $i <= $item->rating ? 'fa-solid' : 'fa-regular' }} fa-star text-xs"></i>
                                            @endfor
                                        @else
                                            <span class="text-xs text-gray-400 font-normal">No Rate</span>
                                        @endif
                                    </div>
                                </td>
                                <td class="py-3.5 px-4 text-gray-600 leading-relaxed max-w-sm truncate" title="{{ $item->komentar }}">
                                    {{ $item->komentar }}
                                </td>
                                <td class="py-3.5 px-4">
                                    @if(!empty($item->comment_image_url))
                                        <img src="{{ asset('storage/' . $item->comment_image_url) }}" 
                                             alt="Foto Ulasan" 
                                             class="w-12 h-12 rounded border border-gray-200 object-cover cursor-pointer"
                                             onclick="window.open(this.src)">
                                    @else
                                        <span class="text-xs text-gray-400">No Photo</span>
                                    @endif
                                </td>
                                <td class="py-3.5 px-4 text-gray-400 text-xs">
                                    {{ \Carbon\Carbon::parse($item->created_at)->translatedFormat('d F Y, H:i') }}
                                </td>
                                <td class="py-3.5 px-4 text-center">
                                    <form action="{{ route('comment.destroy', $item->id) }}" method="POST" onsubmit="return confirm('Hapus ulasan/komentar ini?')">
                                        @csrf @method('DELETE')
                                        <button type="submit" class="bg-[#ffcccc] hover:bg-[#ffb3b3] text-red-900 px-3 py-1.5 rounded text-xs font-semibold shadow-sm transition-colors flex items-center gap-1 mx-auto">
                                            <i class="fa-solid fa-trash text-[10px]"></i> Hapus
                                        </button>
                                    </form>
                                </td>
                            </tr>
                            @empty
                            <tr>
                                <td colspan="7" class="text-center py-8 text-gray-400">Belum ada review atau komentar masuk dari pelanggan platform Web maupun Flutter.</td>
                            </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>

                <div class="flex justify-between items-center mt-6 pt-4 border-t border-gray-100 text-sm text-gray-500">
                    <div>Showing {{ $comments->firstItem() ?? 0 }} to {{ $comments->lastItem() ?? 0 }} of {{ $comments->total() }} entries</div>
                    <div>{{ $comments->links() }}</div>
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