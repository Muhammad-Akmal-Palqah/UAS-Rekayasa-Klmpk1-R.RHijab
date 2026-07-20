<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard Admin - R.R HIJAB</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="bg-gray-50 font-sans antialiased flex flex-col h-screen">
    @php
        $currentAdmin = auth()->guard('admin')->user();
        $isSuperAdmin = $currentAdmin?->role === 'super_admin';
    @endphp

    <header class="w-full bg-[#ccccff]/40 bg-gradient-to-r from-[#ccccff]/30 to-[#ccffcc]/30 py-4 px-6 border-b border-gray-200 flex items-center justify-between shadow-sm z-10">
        <h1 class="text-xl font-bold tracking-wide text-gray-800">R.R HIJAB</h1>
        <div class="flex flex-col gap-3 sm:flex-row sm:items-center sm:gap-4">
            <div class="text-sm font-semibold text-gray-700 bg-white/80 px-3 py-1 rounded-full border border-gray-200 shadow-sm flex items-center gap-2">
                <span class="w-2 h-2 rounded-full bg-green-500 animate-pulse"></span>
                Panel Admin
            </div>
            <div class="flex flex-col gap-2 sm:items-end sm:flex-row sm:gap-3">
                <div class="rounded-full px-3 py-2 text-xs font-semibold {{ isset($businessHours) && $businessHours->enabled ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800' }} border {{ isset($businessHours) && $businessHours->enabled ? 'border-green-200' : 'border-red-200' }}">
                    {{ isset($businessHours) && $businessHours->enabled ? 'Operasional Aktif' : 'Operasional Nonaktif' }}
                </div>
                <form action="{{ route('admin.business-hours.toggle') }}" method="POST">
                    @csrf
                    <button type="submit" class="rounded-full bg-[#4b1a1a] px-4 py-2 text-xs font-semibold text-white transition hover:bg-[#2e100f]">
                        {{ isset($businessHours) && $businessHours->enabled ? 'Nonaktifkan Jam' : 'Aktifkan Jam' }}
                    </button>
                </form>
            </div>
        </div>
    </header>

    <div class="flex flex-1 overflow-hidden">

        <aside class="w-64 bg-white border-r border-gray-200 flex flex-col justify-between shadow-sm">
            <div class="p-4 space-y-6">
                <div>
                    <a href="{{ route('admin.dashboard') }}" class="px-3 text-xs font-semibold text-gray-600 hover:text-gray-900 uppercase tracking-wider block mb-2 hover:bg-[#ffcccc]/20 rounded px-3 py-2 transition-colors">← Menu Utama</a>
                    <nav class="space-y-1">
                        <div class="space-y-1">
                            <button type="button" onclick="toggleDropdown('masterSubmenu')" class="w-full flex items-center justify-between px-3 py-2.5 text-sm font-medium text-gray-600 hover:bg-[#ffcccc]/20 rounded-lg">
                                <span class="flex items-center gap-2.5">
                                    <i class="fa-solid fa-gear text-gray-500"></i>
                                    Master
                                </span>
                                <i id="masterChevron" class="fa-solid fa-chevron-down text-xs text-gray-400 transition-transform duration-200"></i>
                            </button>
                            <div id="masterSubmenu" class="pl-8 space-y-1 mt-1 hidden">
                                @if($isSuperAdmin)
                                    <a href="{{ route('admin.index') }}" class="flex items-center gap-2.5 px-3 py-2.5 text-sm font-medium text-gray-600 hover:bg-[#ffcccc]/20 rounded-lg">Admin</a>
                                    <a href="{{ route('user.index') }}" class="flex items-center gap-2.5 px-3 py-2.5 text-sm font-medium text-gray-600 hover:bg-[#ffcccc]/20 rounded-lg">User</a>
                                @else
                                    <span class="flex items-center gap-2.5 px-3 py-2.5 text-sm font-medium text-gray-400 cursor-not-allowed rounded-lg" title="Hanya super admin yang bisa mengakses menu ini">Admin</span>
                                    <span class="flex items-center gap-2.5 px-3 py-2.5 text-sm font-medium text-gray-400 cursor-not-allowed rounded-lg" title="Hanya super admin yang bisa mengakses menu ini">User</span>
                                @endif
                            </div>
                        </div>

                        <a href="{{ route('product.index') }}" class="flex items-center gap-2.5 px-3 py-2.5 text-sm font-medium text-gray-600 hover:bg-[#ffcccc]/20 rounded-lg">
                            <i class="fa-solid fa-box text-gray-400"></i>
                            Katalog Barang
                        </a>

                        <a href="{{ route('payment.index') }}" class="flex items-center gap-2.5 px-3 py-2.5 text-sm font-medium text-gray-600 hover:bg-[#ffcccc]/20 rounded-lg">
                            <i class="fa-solid fa-calendar-days text-gray-400"></i>
                            Verifikasi Pembayaran
                        </a>

                        <a href="{{ route('comment.index') }}" class="flex items-center gap-2.5 px-3 py-2.5 text-sm font-medium text-gray-600 hover:bg-[#ffcccc]/20 rounded-lg">
                            <i class="fa-solid fa-comments text-gray-400"></i>
                            Komentar
                        </a>
                    </nav>
                </div>
            </div>

            <div class="p-4 border-t border-gray-100">
                <form action="{{ url('/logout') }}" method="POST">
                    @csrf
                    <button type="submit" class="w-full flex items-center gap-2.5 px-3 py-2.5 text-sm font-medium text-red-600 hover:bg-red-50 rounded-lg transition-colors">
                        <i class="fa-solid fa-arrow-right-from-bracket"></i>
                        Log out
                    </button>
                </form>
            </div>
        </aside>

        <main class="flex-1 bg-gray-50 p-8 overflow-y-auto">
            
            <div class="mb-8 border-b border-gray-200 pb-4">
                <h2 class="text-3xl font-bold text-gray-800 tracking-tight">DASHBOARD</h2>
                <p class="text-sm text-gray-500 mt-1">Selamat datang kembali, {{ auth('admin')->user()->username }} 
                ({{ auth('admin')->user()->isSuperAdmin() ? 'Super Admin' : 'Admin' }})!! Berikut ringkasan data toko saat ini.</p>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">

                <div class="bg-white rounded-xl border border-gray-100 p-6 shadow-sm flex flex-col justify-between hover:shadow-md transition-shadow">
                    <div>
                        <div class="flex items-center gap-3 mb-3">
                            <div class="w-8 h-8 rounded-lg bg-[#ccccff]/50 flex items-center justify-center">
                                <i class="fa-solid fa-gear text-gray-700 text-sm"></i>
                            </div>
                            <h3 class="text-sm font-semibold text-gray-500 uppercase tracking-wider">admin</h3>
                        </div>
                        <p class="text-sm text-gray-400">Jumlah admin: <span class="font-bold text-gray-700">{{ $adminCount ?? 0 }}</span></p>
                    </div>
                    <div class="mt-5 pt-4 border-t border-gray-50">
                        @if($isSuperAdmin)
                            <a href="{{ route('admin.index') }}" class="inline-block bg-[#ffcccc] hover:bg-[#ffb3b3] text-gray-800 p-2 rounded-lg text-xs transition-colors shadow-sm font-medium">
                                <i class="fa-solid fa-bars mr-1"></i> Kelola Admin
                            </a>
                        @else
                            <button type="button" disabled class="inline-block bg-gray-200 text-gray-500 p-2 rounded-lg text-xs font-medium shadow-sm cursor-not-allowed opacity-70">
                                <i class="fa-solid fa-bars mr-1"></i> Kelola Admin
                            </button>
                        @endif
                    </div>
                </div>

                <div class="bg-white rounded-xl border border-gray-100 p-6 shadow-sm flex flex-col justify-between hover:shadow-md transition-shadow">
                    <div>
                        <div class="flex items-center gap-3 mb-3">
                            <div class="w-8 h-8 rounded-lg bg-[#ccffcc]/50 flex items-center justify-center">
                                <i class="fa-solid fa-user text-gray-700 text-sm"></i>
                            </div>
                            <h3 class="text-sm font-semibold text-gray-500 uppercase tracking-wider">USER</h3>
                        </div>
                        <p class="text-sm text-gray-400">Jumlah user: <span class="font-bold text-gray-700">{{ $userCount ?? 0 }}</span></p>
                    </div>
                    <!-- Ganti bagian tombol di dalam Kartu 2: USER dengan baris ini, Mal: -->
                    <div class="mt-5 pt-4 border-t border-gray-50">
                        @if($isSuperAdmin)
                            <a href="{{ route('user.index') }}" class="inline-block bg-[#ffcccc] hover:bg-[#ffb3b3] text-gray-800 p-2 rounded-lg text-xs transition-colors shadow-sm font-medium">
                                <i class="fa-solid fa-bars mr-1"></i> Kelola User
                            </a>
                        @else
                            <button type="button" disabled class="inline-block bg-gray-200 text-gray-500 p-2 rounded-lg text-xs font-medium shadow-sm cursor-not-allowed opacity-70">
                                <i class="fa-solid fa-bars mr-1"></i> Kelola User
                            </button>
                        @endif
                    </div>
                </div>

                <div class="bg-white rounded-xl border border-gray-100 p-6 shadow-sm flex flex-col justify-between hover:shadow-md transition-shadow">
                    <div>
                        <div class="flex items-center gap-3 mb-3">
                            <div class="w-8 h-8 rounded-lg bg-[#ccccff]/50 flex items-center justify-center">
                                <i class="fa-solid fa-box text-gray-700 text-sm"></i>
                            </div>
                            <h3 class="text-sm font-semibold text-gray-500 uppercase tracking-wider">KATALOG BARANG</h3>
                        </div>
                        <p class="text-xs text-gray-400 mt-1">Manajemen produk hijab dan stok</p>
                    </div>
                    <!-- Cari bagian tombol di dalam Kartu 3: KATALOG BARANG lalu ganti jadi baris ini, Mal: -->
                        <div class="mt-5 pt-4 border-t border-gray-50">
                            <a href="{{ route('product.index') }}" class="inline-block bg-[#ffcccc] hover:bg-[#ffb3b3] text-gray-800 p-2 rounded-lg text-xs transition-colors shadow-sm font-medium">
                                <i class="fa-solid fa-bars mr-1"></i> Lihat Katalog
                            </a>
                        </div>
                </div>

                <div class="bg-white rounded-xl border border-gray-100 p-6 shadow-sm flex flex-col justify-between hover:shadow-md transition-shadow">
                    <div>
                        <div class="flex items-center gap-3 mb-3">
                            <div class="w-8 h-8 rounded-lg bg-[#ccffcc]/50 flex items-center justify-center">
                                <i class="fa-solid fa-calendar-days text-gray-700 text-sm"></i>
                            </div>
                            <h3 class="text-sm font-semibold text-gray-500 uppercase tracking-wider">Verifikasi Pembayaran</h3>
                        </div>
                        <p class="text-xs text-gray-400 mt-1">Konfirmasi bukti transfer masuk</p>
                    </div>
                    <div class="mt-5 pt-4 border-t border-gray-50">
                        <a href="{{ route('payment.index') }}" class="inline-block bg-[#ffcccc] hover:bg-[#ffb3b3] text-gray-800 p-2 rounded-lg text-xs transition-colors shadow-sm font-medium">
                          <i class="fa-solid fa-bars mr-1"></i> Cek Pembayaran
                        </a>
                    </div>
                </div>

                <div class="bg-white rounded-xl border border-gray-100 p-6 shadow-sm flex flex-col justify-between hover:shadow-md transition-shadow">
                    <div>
                        <div class="flex items-center gap-3 mb-3">
                            <div class="w-8 h-8 rounded-lg bg-[#ffcccc]/50 flex items-center justify-center">
                                <i class="fa-solid fa-comments text-gray-700 text-sm"></i>
                            </div>
                            <h3 class="text-sm font-semibold text-gray-500 uppercase tracking-wider">Komentar</h3>
                        </div>
                        <p class="text-xs text-gray-400 mt-1">Kelola komentar pelanggan dan hapus bila perlu.</p>
                    </div>
                    <div class="mt-5 pt-4 border-t border-gray-50">
                        <a href="{{ route('comment.index') }}" class="inline-block bg-[#ffcccc] hover:bg-[#ffb3b3] text-gray-800 p-2 rounded-lg text-xs transition-colors shadow-sm font-medium">
                          <i class="fa-solid fa-bars mr-1"></i> Kelola Komentar
                        </a>
                    </div>
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