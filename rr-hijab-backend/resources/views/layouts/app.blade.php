<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'R.R HIJAB')</title>
    <script src="https://cdn.tailwindcss.com"></script>
    @stack('head')
</head>
<body class="bg-[#f3f3f3] text-[#1f1f1f] min-h-screen">
    <header class="bg-white border-b border-[#d8d8d8] shadow-sm">
        <div class="mx-auto max-w-7xl px-6 py-4 flex flex-wrap items-center justify-between gap-4">
            <a href="{{ route('home') }}" class="text-xl font-bold tracking-wider text-[#4b1a1a]">R.R HIJAB</a>
            <nav class="flex flex-wrap items-center gap-4 text-sm font-medium text-[#4b1a1a]">
                <a href="{{ route('home') }}" class="hover:text-[#a70000]">Home</a>
                <a href="{{ route('pelanggan.katalog') }}" class="hover:text-[#a70000]">Katalog</a>
                <a href="{{ route('login') }}" class="rounded-full border border-[#4b1a1a] px-4 py-2 hover:bg-[#ccccff]">Login</a>
            </nav>
        </div>
    </header>

    <main class="mx-auto max-w-6xl px-6 py-10">
        @yield('content')
    </main>

    <footer class="mt-10 rounded-[40px] bg-white p-10 text-[#4b1a1a] shadow-sm border border-[#ffffffcc]">
        <div class="flex flex-col gap-6 lg:flex-row lg:items-center lg:justify-between">
            <div>
                <h3 class="text-lg font-bold">R.R HIJAB</h3>
                <p class="mt-3 max-w-md text-sm leading-7 text-[#4b1a1a]/80">Nikmati pengalaman belanja hijab yang praktis dan seamless. Sistem kami terintegrasi penuh untuk memastikan setiap pesanan Anda diproses dengan cepat dan aman.</p>
            </div>
            <div class="space-y-2 text-sm text-[#4b1a1a]/80">
                <p><span class="font-semibold">Email:</span> info@rrhijab.com</p>
                <p><span class="font-semibold">Phone:</span> 0812-3456-7890</p>
            </div>
        </div>
    </footer>

    @stack('scripts')
</body>
</html>
