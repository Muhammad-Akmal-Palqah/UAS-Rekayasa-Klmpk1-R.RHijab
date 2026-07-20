<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Detail Produk - R.R HIJAB</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-[#f3f3f3] text-[#1f1f1f] min-h-screen">
    <header class="bg-white border-b border-[#d8d8d8] shadow-sm">
        <div class="mx-auto max-w-7xl px-6 py-4 flex items-center justify-between gap-4">
            <a href="{{ route('home') }}" class="text-xl font-bold tracking-wider text-[#4b1a1a]">R.R HIJAB</a>
            <nav class="flex items-center gap-4 text-sm font-medium text-[#4b1a1a]">
                <a href="{{ route('home') }}" class="hover:text-[#a70000]">Home</a>
                <a href="{{ route('pelanggan.katalog') }}" class="hover:text-[#a70000]">Katalog</a>
                <a href="{{ route('login') }}" class="rounded-full border border-[#4b1a1a] px-4 py-2 hover:bg-[#ccccff]">Login</a>
            </nav>
        </div>
    </header>

    <main class="mx-auto max-w-6xl px-6 py-10">
        <div class="space-y-8">
            <div class="rounded-[32px] bg-white p-6 shadow-sm border border-[#ffffffcc]">
                <div class="grid gap-8 lg:grid-cols-[1.3fr_0.7fr] items-start">
                    <div class="space-y-6">
                        <div class="overflow-hidden rounded-[28px] bg-[#1f1f1f] shadow-inner">
                            <img src="{{ Illuminate\Support\Str::startsWith($product->link_foto, ['http://', 'https://']) ? $product->link_foto : asset($product->link_foto) }}" alt="{{ $product->nama_produk }}" class="h-full w-full object-cover" onerror="this.src='https://placehold.co/1200x700?text=Foto+Hijab'">
                        </div>
                        <div class="rounded-[28px] bg-[#f8f8f8] p-6">
                            <h1 class="text-3xl font-bold text-[#4b1a1a]">{{ $product->nama_produk }}</h1>
                            <p class="mt-3 text-sm text-[#4b1a1a]/80 leading-7">{{ $product->deskripsi }}</p>
                            <div class="mt-4 flex flex-wrap items-center gap-3 text-sm text-[#4b1a1a]/75">
                                <span class="rounded-full bg-[#ffcccc]/80 px-3 py-1 font-semibold">{{ $product->kategori }}</span>
                                <span class="rounded-full bg-[#ccccff]/80 px-3 py-1 font-semibold">{{ $product->status }}</span>
                                <span class="rounded-full bg-[#ccffcc]/80 px-3 py-1 font-semibold">Stok: {{ $product->stok }}</span>
                                
                            </div>
                        </div>
                    </div>
                    <aside class="space-y-6 rounded-[32px] bg-[#ccccff] p-6 shadow-sm border border-[#ffffffcc]">
                        <div class="rounded-[28px] bg-white p-6 shadow-sm">
                            <p class="text-sm uppercase tracking-[0.2em] text-[#2b2b7a]">Detail Produk</p>
                            @if($product->hasPromoPercent())
                                <p class="mt-4 text-4xl font-bold text-[#4b1a1a]">Rp {{ number_format($product->harga_after_promo, 0, ',', '.') }}</p>
                                <p class="mt-2 text-sm text-[#7b2222] line-through">Rp {{ number_format($product->harga, 0, ',', '.') }}</p>
                                <p class="mt-2 text-sm text-[#1f4f1f]">Harga sudah diskon {{ number_format($product->promo_percent, 0, ',', '.') }}%.</p>
                            @else
                                <p class="mt-4 text-4xl font-bold text-[#4b1a1a]">Rp {{ number_format($product->harga, 0, ',', '.') }}</p>
                            @endif
                        </div>
                        <div class="rounded-[28px] bg-white p-6 shadow-sm mt-6">
                            <p class="text-sm uppercase tracking-[0.2em] text-[#2b2b7a]">Varian Produk</p>
                            
                            @if(!empty($colors))
                            <div class="mt-4">
                                <p class="text-xs font-semibold text-[#4b1a1a]/70">Warna:</p>
                                <div class="flex flex-wrap gap-2 mt-2">
                                    @foreach($colors as $color)
                                        <span class="inline-flex items-center gap-2 rounded-full bg-gray-100 px-3 py-1 text-xs text-[#4b1a1a] border">
                                            <span>{{ $color }}</span>
                                            <span class="rounded-full bg-[#ccffcc]/80 px-2 py-0.5 text-[0.65rem] font-semibold text-[#1f4f1f]">Stok: {{ $colorStocks[$color] ?? 0 }}</span>
                                        </span>
                                    @endforeach
                                </div>
                            </div>
                            @endif

                            @if(!empty($sizes))
                            <div class="mt-4">
                                <p class="text-xs font-semibold text-[#4b1a1a]/70">Ukuran:</p>
                                <div class="flex flex-wrap gap-2 mt-2">
                                    @foreach($sizes as $size)
                                        <span class="inline-flex items-center gap-2 rounded-full bg-gray-100 px-3 py-1 text-xs text-[#4b1a1a] border">
                                            <span>{{ $size }}</span>
                                            <span class="rounded-full bg-[#ccffcc]/80 px-2 py-0.5 text-[0.65rem] font-semibold text-[#1f4f1f]">Stok: {{ $sizeStocks[$size] ?? 0 }}</span>
                                        </span>
                                    @endforeach
                                </div>
                            </div>
                            @endif
                        </div>
                        <div class="rounded-[28px] bg-white p-6 shadow-sm">
                            <p class="text-sm uppercase tracking-[0.2em] text-[#2b2b7a]">Promo</p>
                            <p class="mt-3 text-base font-semibold text-[#4b1a1a]">{{ $product->promo ?: 'Diskon 70% Hari ini' }}</p>
                            <p class="mt-2 text-sm leading-6 text-[#4b1a1a]/80">{{ $product->promo ? 'Nikmati promo khusus untuk produk ini.' : 'Dapatkan potongan harga khusus untuk koleksi favorit dengan stok terbatas.' }}</p>
                        </div>
                        <a href="{{ route('pelanggan.katalog.checkout', $product->id_produk) }}" class="block w-full rounded-full bg-[#4b1a1a] px-6 py-4 text-center text-white text-sm font-semibold transition hover:bg-[#2e100f]">Pesan</a>
                    </aside>
                </div>
            </div>

           <section class="rounded-[32px] bg-white p-6 shadow-sm border border-[#ffffffcc]">
                <div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
                    <h2 class="text-xl font-bold text-[#4b1a1a]">Komentar / Feedback</h2>
                    <p class="text-sm text-[#4b1a1a]/80">Sampaikan kesanmu tentang produk ini.</p>
                </div>

                @auth
                    <form action="{{ route('pelanggan.katalog.comment', $product->id_produk) }}" method="POST" enctype="multipart/form-data" class="mt-6">
                        @csrf
                        
                        @if(session('success'))
                            <div class="rounded-3xl border border-green-200 bg-[#ecffed] p-4 text-sm text-[#1f4f1f] shadow-sm mb-4">
                                {{ session('success') }}
                            </div>
                        @endif

                        @if($errors->any())
                            <div class="rounded-3xl border border-red-200 bg-[#ffe7e7] p-4 text-sm text-[#7b2222] shadow-sm mb-4">
                                <ul>
                                    @foreach ($errors->all() as $error)
                                        <li>{{ $error }}</li>
                                    @endforeach
                                </ul>
                            </div>
                        @endif

                        <div class="mb-4">
                            <label class="block text-sm font-semibold text-[#4b1a1a] mb-2">Berikan Rating (1-5)</label>
                            <div class="flex flex-row-reverse justify-end gap-1">
                                @for($i = 5; $i >= 1; $i--)
                                    <input type="radio" name="rating" value="{{ $i }}" id="star{{ $i }}" class="hidden peer" required>
                                    
                                    <label for="star{{ $i }}" class="cursor-pointer text-3xl text-gray-300 
                                        peer-checked:text-yellow-400 
                                        peer-hover:text-yellow-400 
                                        hover:text-yellow-400 
                                        transition-colors">
                                        ★
                                    </label>
                                @endfor
                            </div>
                        </div>

                        <div class="mb-4">
                            <label class="block text-sm font-semibold text-[#4b1a1a] mb-2">Unggah Foto (Opsional)</label>
                            <input type="file" name="image" accept="image/*" class="w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-[#4b1a1a] file:text-white hover:file:bg-[#2e100f]">
                        </div>

                        <textarea name="komentar" rows="5" class="w-full rounded-3xl border border-[#d8d8d8] bg-[#f8f8f8] p-4 text-sm text-[#1f1f1f] outline-none focus:border-[#4b1a1a]" placeholder="Tulis komentar atau pertanyaanmu di sini..." required>{{ old('komentar') }}</textarea>
                        
                        <div class="mt-4 text-right">
                            <button type="submit" class="inline-flex items-center justify-center rounded-full bg-[#4b1a1a] px-6 py-3 text-white text-sm font-semibold transition hover:bg-[#2e100f]">Kirimkan</button>
                        </div>
                    </form>
                @else
                    <div class="mt-6 rounded-3xl border border-[#d8d8d8] bg-[#fff7f6] p-6 text-sm text-[#4b1a1a]/90">
                        <p class="mb-3">Silakan <a href="{{ route('login') }}" class="font-semibold text-[#4b1a1a] underline">login terlebih dahulu</a> untuk mengirim komentar atau pertanyaan.</p>
                    </div>
                @endauth
            </section>

           <section class="rounded-[32px] bg-white p-6 shadow-sm border border-[#ffffffcc]">
        <div class="mb-6">
            <h2 class="text-xl font-bold text-[#4b1a1a] mb-4">Ulasan Produk</h2>
            
            <div class="flex flex-col md:flex-row gap-6 items-center bg-[#fcfcfc] p-6 rounded-3xl border border-[#eeeeee]">
                <div class="text-center">
                    <p class="text-5xl font-bold text-[#4b1a1a]">{{ number_format($stats->average ?? 0, 1) }}</p>
                    <div class="flex text-yellow-500 text-lg justify-center my-1">★★★★★</div>
                    <p class="text-xs text-gray-500">{{ $stats->total ?? 0 }} total ulasan</p>
                </div>
                <div class="flex-1 w-full space-y-1">
                    @for ($i = 5; $i >= 1; $i--)
                        <div class="flex items-center gap-3 text-xs">
                            <span class="w-4 font-semibold">{{ $i }}★</span>
                            <div class="flex-1 h-2 bg-gray-200 rounded-full overflow-hidden">
                                <div class="h-full bg-yellow-400" style="width: {{ ($stats->total ?? 0) > 0 ? (($ratingCounts[$i] ?? 0) / $stats->total * 100) : 0 }}%"></div>
                            </div>
                            <span class="w-8 text-right text-gray-600">{{ $ratingCounts[$i] ?? 0 }}</span>
                        </div>
                    @endfor
                </div>
            </div>

            <div class="flex flex-wrap gap-2 mt-6">
                <a href="{{ url()->current() }}" class="px-4 py-2 rounded-full border {{ !request()->has('rating') ? 'bg-[#4b1a1a] text-white' : 'bg-white hover:bg-gray-100' }} text-sm font-medium transition">Semua</a>
                @for ($i = 5; $i >= 1; $i--)
                    <a href="{{ url()->current() }}?rating={{ $i }}" class="px-4 py-2 rounded-full border {{ request('rating') == $i ? 'bg-[#4b1a1a] text-white' : 'bg-white hover:bg-gray-100' }} text-sm font-medium transition">
                        {{ $i }} Bintang ({{ $ratingCounts[$i] ?? 0 }})
                    </a>
                @endfor
            </div>
        </div>

        @if($comments->isEmpty())
            <div class="mt-6 rounded-3xl border border-[#d8d8d8] bg-[#f8f8f8] p-6 text-sm text-[#4b1a1a]/90">
                Belum ada komentar untuk rating ini.
            </div>
        @else
            <div class="mt-6 space-y-4">
                @foreach($comments as $comment)
                    <div class="rounded-3xl border border-[#e8e8e8] bg-[#fafafa] p-6 shadow-sm">
                        <div class="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
                            <div>
                                <p class="font-semibold text-[#4b1a1a]">{{ $comment->user_name }}</p>
                                <div class="flex text-yellow-500 text-sm my-1">
                                    @for ($i = 1; $i <= 5; $i++)
                                        <span>{{ $i <= $comment->rating ? '★' : '☆' }}</span>
                                    @endfor
                                </div>
                                <p class="text-xs text-[#4b1a1a]/70">
                                    {{ \Illuminate\Support\Carbon::parse($comment->created_at)->isoFormat('D MMMM YYYY, HH:mm') }}
                                </p>
                            </div>
                        </div>
                        <p class="mt-4 text-sm leading-7 text-[#4b1a1a]/85">{{ $comment->komentar }}</p>
                        @if(!empty($comment->image_url))
                            <div class="mt-4">
                                <img src="{{ asset('storage/' . $comment->image_url) }}" class="w-32 h-32 object-cover rounded-2xl border border-gray-200 shadow-sm hover:scale-105 transition-transform duration-200">
                            </div>
                        @endif
                    </div>
                @endforeach
            </div>
        @endif
    </section>
        </div>
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
</body>
</html>
