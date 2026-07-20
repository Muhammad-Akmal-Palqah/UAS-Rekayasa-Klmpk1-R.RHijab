<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kelola User Pelanggan - R.R HIJAB</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
</head>
<body class="bg-gray-50 font-sans antialiased flex flex-col h-screen">

    <!-- HEADER ATAS -->
    <header class="w-full bg-[#ccccff]/40 bg-gradient-to-r from-[#ccccff]/30 to-[#ccffcc]/30 py-4 px-6 border-b border-gray-200 flex items-center justify-between shadow-sm z-10">
        <h1 class="text-xl font-bold tracking-wide text-gray-800">R.R HIJAB</h1>
        <div class="text-sm font-semibold text-gray-700 bg-white/80 px-3 py-1 rounded-full border border-gray-200 shadow-sm flex items-center gap-2">
            <span class="w-2 h-2 rounded-full bg-green-500 animate-pulse"></span> Panel Admin Terpadu
        </div>
    </header>

    <div class="flex flex-1 overflow-hidden">
        <!-- SIDEBAR KIRI -->
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
                                <a href="{{ route('user.index') }}" class="flex items-center gap-2.5 px-3 py-2.5 text-sm font-semibold text-gray-900 bg-[#ffcccc]/30 rounded-lg">User</a>
                            </div>
                        </div>
                        <a href="{{ route('product.index') }}" class="flex items-center gap-2.5 px-3 py-2.5 text-sm font-medium text-gray-600 hover:bg-[#ffcccc]/20 rounded-lg"><i class="fa-solid fa-box text-gray-400"></i> Katalog Barang</a>
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

        <!-- AREA KONTEN UTAMA -->
        <main class="flex-1 bg-gray-50 p-8 overflow-y-auto">
            
            @if(session('success'))
                <div class="bg-green-50 text-green-700 border border-green-200 p-4 rounded-xl mb-6 text-sm flex items-center gap-2 shadow-sm">
                    <i class="fa-solid fa-circle-check"></i> {{ session('success') }}
                </div>
            @endif

            <div class="flex justify-between items-center mb-6">
                <div>
                    <h2 class="text-3xl font-bold text-gray-800 tracking-tight">Katalog Data User Pelanggan</h2>
                    <p class="text-sm text-gray-500 mt-1">Data pelanggan terintegrasi yang terdaftar pada platform Web & Flutter[cite: 22].</p>
                </div>
                <button onclick="toggleModal('addUserModal')" class="bg-[#ccffcc] hover:bg-[#b3ffb3] text-gray-800 px-4 py-2 rounded-lg text-sm font-semibold flex items-center gap-2 transition-colors shadow-sm">
                    <i class="fa-solid fa-plus text-xs"></i> Tambah User
                </button>
            </div>

            <!-- Bagian Filter Search & Entries -->
            <div class="bg-white rounded-xl border border-gray-100 shadow-sm overflow-hidden p-6">
                <div class="flex flex-col sm:flex-row justify-between items-center gap-4 mb-4">
                    <div class="text-sm text-gray-500">
                        Show <select class="border border-gray-300 rounded px-2 py-1 mx-1 text-sm bg-gray-50 focus:outline-none"><option>10</option></select> entries
                    </div>
                    <!-- // MODIFIED: Route form cari dialihkan ke endpoint index user terpadu mobile -->
                    <form method="GET" action="{{ route('user.index') }}" class="w-full sm:w-auto">
                        <input type="text" name="search" value="{{ $search ?? '' }}" placeholder="Cari nama atau email..." 
                               class="w-full sm:w-64 px-3 py-1.5 border border-gray-300 rounded-lg text-sm bg-gray-50 focus:outline-none focus:border-[#ffcccc]">
                    </form>
                </div>

                <!-- Tabel Utama Pelanggan -->
                <div class="overflow-x-auto">
                    <table class="w-full text-left border-collapse">
                        <thead>
                            <tr class="border-b border-gray-100 text-gray-400 text-xs font-semibold uppercase bg-gray-50/70">
                                <th class="py-3 px-4 w-16">No</th>
                                <th class="py-3 px-4">Nama Pelanggan</th>
                                <th class="py-3 px-4">Email</th>
                                <!-- // ADDED: Kolom penanda waktu registrasi pengguna sesuai skema tabel mobile -->
                                <th class="py-3 px-4">Tanggal Daftar</th>
                                <th class="py-3 px-4 text-center w-48">Aksi</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100 text-sm text-gray-700">
                            @forelse($users as $index => $item)
                            <tr class="hover:bg-gray-50/50 transition-colors">
                                <td class="py-3.5 px-4 font-medium">{{ $users->firstItem() + $index }}</td>
                                <td class="py-3.5 px-4 font-semibold text-gray-800">{{ $item->name }}</td>
                                <td class="py-3.5 px-4 text-gray-600">{{ $item->email }}</td>
                                <!-- // ADDED: Penayangan tanggal pendaftaran pengguna terurai rapi via Carbon -->
                                <td class="py-3.5 px-4 text-gray-500">{{ \Illuminate\Support\Carbon::parse($item->created_at)->translatedFormat('d M Y') }}</td>
                                <td class="py-3.5 px-4 text-center">
                                    <div class="inline-flex gap-1.5">
                                        <button onclick="openEditUserModal('{{ $item->id }}', '{{ $item->name }}', '{{ $item->email }}')" 
                                                class="bg-[#ccccff] hover:bg-[#b3b3ff] text-gray-800 px-3 py-1 rounded text-xs font-medium shadow-sm transition-colors">
                                            <i class="fa-solid fa-pen-to-square mr-1"></i> Edit
                                        </button>
                                        <!-- // MODIFIED: Form destruksi data diarahkan menuju endpoint destroy terpadu -->
                                        <form action="{{ route('user.destroy', $item->id) }}" method="POST" onsubmit="return confirm('Yakin ingin menghapus pelanggan ini?')">
                                            @csrf @method('DELETE')
                                            <button type="submit" class="bg-[#ffcccc] hover:bg-[#ffb3b3] text-gray-800 px-3 py-1 rounded text-xs font-medium shadow-sm transition-colors">
                                                <i class="fa-solid fa-trash mr-1"></i> Hapus
                                            </button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                            @empty
                            <tr>
                                <td colspan="5" class="text-center py-8 text-gray-400">Data pelanggan tidak ditemukan atau masih kosong.</td>
                            </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>

                <!-- Pagination -->
                <div class="flex justify-between items-center mt-6 pt-4 border-t border-gray-100 text-sm text-gray-500">
                    <div>
                        Showing {{ $users->firstItem() ?? 0 }} to {{ $users->lastItem() ?? 0 }} of {{ $users->total() }} entries
                    </div>
                    <div>
                        {{ $users->links() }}
                    </div>
                </div>
            </div>
        </main>
    </div>

    <!-- MODAL POPUP: TAMBAH USER -->
    <div id="addUserModal" class="fixed inset-0 bg-black/40 backdrop-blur-sm hidden items-center justify-center z-50">
        <div class="bg-white rounded-xl shadow-xl max-w-md w-full p-6 mx-4">
            <div class="flex justify-between items-center mb-4 pb-2 border-b">
                <h3 class="text-lg font-bold text-gray-800">Tambah Pelanggan Baru</h3>
                <button onclick="toggleModal('addUserModal')" class="text-gray-400 hover:text-gray-600"><i class="fa-solid fa-xmark"></i></button>
            </div>
            <!-- // MODIFIED: Alur simpan dialihkan menuju route store terpadu -->
            <form action="{{ route('user.store') }}" method="POST" class="space-y-4">
                @csrf
                <div>
                    <label class="block text-xs font-semibold text-gray-600 uppercase mb-1">Nama Lengkap</label>
                    <input type="text" name="name" required class="w-full px-3 py-2 border rounded-lg text-sm focus:outline-none focus:border-[#ffcccc]">
                </div>
                <div>
                    <label class="block text-xs font-semibold text-gray-600 uppercase mb-1">Email</label>
                    <input type="email" name="email" required class="w-full px-3 py-2 border rounded-lg text-sm focus:outline-none focus:border-[#ffcccc]">
                </div>
                <div>
                    <label class="block text-xs font-semibold text-gray-600 uppercase mb-1">Password</label>
                    <input type="password" name="password" required class="w-full px-3 py-2 border rounded-lg text-sm focus:outline-none focus:border-[#ffcccc]">
                </div>
                <button type="submit" class="w-full bg-[#ccffcc] hover:bg-[#b3ffb3] text-gray-800 py-2.5 rounded-lg font-semibold text-sm shadow-sm">Simpan Pelanggan</button>
            </form>
        </div>
    </div>

    <!-- MODAL POPUP: EDIT USER -->
    <div id="editUserModal" class="fixed inset-0 bg-black/40 backdrop-blur-sm hidden items-center justify-center z-50">
        <div class="bg-white rounded-xl shadow-xl max-w-md w-full p-6 mx-4">
            <div class="flex justify-between items-center mb-4 pb-2 border-b">
                <h3 class="text-lg font-bold text-gray-800">Edit Data Pelanggan</h3>
                <button onclick="toggleModal('editUserModal')" class="text-gray-400 hover:text-gray-600"><i class="fa-solid fa-xmark"></i></button>
            </div>
            <form id="editUserForm" method="POST" class="space-y-4">
                @csrf @method('PUT')
                <div>
                    <label class="block text-xs font-semibold text-gray-600 uppercase mb-1">Nama Lengkap</label>
                    <input type="text" id="edit_name" name="name" required class="w-full px-3 py-2 border rounded-lg text-sm focus:outline-none focus:border-[#ffcccc]">
                </div>
                <div>
                    <label class="block text-xs font-semibold text-gray-600 uppercase mb-1">Email</label>
                    <input type="email" id="edit_user_email" name="email" required class="w-full px-3 py-2 border rounded-lg text-sm focus:outline-none focus:border-[#ffcccc]">
                </div>
                <div>
                    <label class="block text-xs font-semibold text-gray-600 uppercase mb-1">Password Baru (Opsional)</label>
                    <input type="password" name="password" placeholder="Kosongkan jika tidak diubah" class="w-full px-3 py-2 border rounded-lg text-sm focus:outline-none focus:border-[#ffcccc]">
                </div>
                <button type="submit" class="w-full bg-[#ccccff] hover:bg-[#b3b3ff] text-gray-800 py-2.5 rounded-lg font-semibold text-sm shadow-sm">Perbarui Data</button>
            </form>
        </div>
    </div>

    <script>
        function toggleModal(modalId) {
            const modal = document.getElementById(modalId);
            if (modal.classList.contains('hidden')) {
                modal.classList.remove('hidden');
                modal.classList.add('flex');
            } else {
                modal.classList.remove('flex');
                modal.classList.add('hidden');
            }
        }

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

        // // MODIFIED: Inject rute pembaruan data pengguna mengarah langsung ke scope controller mobile terpadu
        function openEditUserModal(id, name, email) {
            document.getElementById('editUserForm').action = '/user/manage/' + id;
            document.getElementById('edit_name').value = name;
            document.getElementById('edit_user_email').value = email;
            toggleModal('editUserModal');
        }
    </script>
</body>
</html>