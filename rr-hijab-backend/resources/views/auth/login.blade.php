<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Log In - R.R HIJAB</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-white font-sans antialiased">

    <header class="bg-[#ffffffcc] backdrop-blur-md border-b border-[#d8d8d8] shadow-sm">
        <div class="mx-auto max-w-7xl px-6 py-5 flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
            <a href="{{ route('home') }}" class="text-xl font-bold tracking-wider text-[#4b1a1a]">R.R HIJAB</a>
            <nav class="flex flex-wrap items-center gap-4 text-sm font-medium text-[#4b1a1a]">
                <a href="{{ route('home') }}" class="hover:text-[#a70000]">Home</a>
                <a href="{{ route('pelanggan.katalog') }}" class="text-[#4b1a1a] font-semibold">Katalog</a>
                <a href="{{ route('register') }}" class="rounded-full border border-[#4b1a1a] px-4 py-2 hover:bg-[#ccccff]">Sign Up</a>
            </nav>
        </div>
    </header>

    <div class="flex flex-col items-center justify-center min-h-[80vh] px-4">
        <div class="w-full max-w-md bg-white p-8 rounded-xl border border-gray-100 shadow-sm">
            
            <h2 class="text-3xl font-semibold text-gray-900 mb-1">Log In</h2>
            <p class="text-gray-500 text-sm mb-6">Log in di bawah untuk akses akun mu</p>

            @if($errors->any())
                <div class="bg-red-50 text-red-700 p-3 rounded-md mb-4 text-sm border border-red-200">
                    {{ $errors->first() }}
                </div>
            @endif

            <form action="{{ url('/login') }}" method="POST" class="space-y-5">
                @csrf
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
                    <input type="email" name="email" placeholder="masukan alamat email" required
                        class="w-full px-3 py-2.5 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-1 focus:ring-[#ffcccc] focus:border-[#ffcccc] text-sm">
                </div>

                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Password</label>
                    <input type="password" name="password" placeholder="masukan password anda" required
                        class="w-full px-3 py-2.5 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-1 focus:ring-[#ffcccc] focus:border-[#ffcccc] text-sm">
                </div>

                <!-- 💡 SUDAH BERSIH: Tag menggantung `<a href` di dalam tombol sudah dibuang -->
                <button type="submit" 
                    class="w-full bg-[#ffcccc] text-gray-800 py-2.5 px-4 rounded-md font-semibold text-sm hover:bg-[#ffb3b3] transition duration-200 shadow-sm active:scale-[0.99]">
                    Log In
                </button>
            </form>

            <!-- 💡 SUDAH DIRAPIKAN: Teks pengantar pendaftaran agar logis -->
            <p class="mt-6 text-sm text-gray-600">
                Belum punya Akun? <a href="{{ url('/register') }}" class="text-gray-800 font-semibold hover:underline bg-[#ccccff]/50 px-1.5 py-0.5 rounded">Daftar Sekarang</a>
            </p>

        </div>
    </div>

</body>
</html>