<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign Up - R.R HIJAB</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-white font-sans antialiased">

    <!-- Header Atas (Sentuhan kombinasi ccccff & ccffcc pastel) -->
    <header class="bg-[#ffffffcc] backdrop-blur-md border-b border-[#d8d8d8] shadow-sm">
        <div class="mx-auto max-w-7xl px-6 py-5 flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
            <a href="{{ route('home') }}" class="text-xl font-bold tracking-wider text-[#4b1a1a]">R.R HIJAB</a>
            <nav class="flex flex-wrap items-center gap-4 text-sm font-medium text-[#4b1a1a]">
                <a href="{{ route('home') }}" class="hover:text-[#a70000]">Home</a>
                <a href="{{ route('pelanggan.katalog') }}" class="text-[#4b1a1a] font-semibold">Katalog</a>
                <a href="{{ route('login') }}" class="rounded-full border border-[#4b1a1a] px-4 py-2 hover:bg-[#ccccff]">Login</a>
            </nav>
        </div>
    </header>

    <!-- Form Container -->
    <div class="flex flex-col items-center justify-center min-h-[80vh] px-4">
        <div class="w-full max-w-md bg-white p-8 rounded-xl border border-gray-100 shadow-sm">
            
            <!-- Judul Sesuai Gambar sign up page - dekstop (1)_2.png -->
            <h2 class="text-3xl font-semibold text-gray-900 mb-1">Sign Up</h2>
            <p class="text-gray-500 text-sm mb-6">Daftar akun di bawah untuk membuat akun mu</p>

            <!-- Menampilkan Error jika validasi gagal -->
            @if($errors->any())
                <div class="bg-red-50 text-red-700 p-3 rounded-md mb-4 text-sm border border-red-200">
                    {{ $errors->first() }}
                </div>
            @endif

            <form action="{{ url('/register') }}" method="POST" class="space-y-5">
                @csrf
                <!-- Input Email -->
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
                    <input type="email" name="email" placeholder="masukan alamat email" required
                        class="w-full px-3 py-2.5 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-1 focus:ring-[#ffcccc] focus:border-[#ffcccc] text-sm">
                </div>

                <!-- Input Password -->
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">password</label>
                    <input type="password" name="password" placeholder="buat password baru" required
                        class="w-full px-3 py-2.5 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-1 focus:ring-[#ffcccc] focus:border-[#ffcccc] text-sm">
                </div>

                <!-- Tombol Daftar (Warna Utama #ffcccc) -->
                <button type="submit" 
                    class="w-full bg-[#ffcccc] text-gray-800 py-2.5 px-4 rounded-md font-semibold text-sm hover:bg-[#ffb3b3] transition duration-200 shadow-sm active:scale-[0.99]">
                    Daftar
                </button>
            </form>

            <!-- Teks Bawah Sesuai Gambar (Sudah punya Akun? Sudah) -->
            <p class="mt-6 text-sm text-gray-600">
                Sudah punya Akun? <a href="{{ url('/login') }}" class="text-gray-800 font-semibold hover:underline bg-[#ccccff]/50 px-1.5 py-0.5 rounded">Sudah</a>
            </p>

        </div>
    </div>

</body>
</html>