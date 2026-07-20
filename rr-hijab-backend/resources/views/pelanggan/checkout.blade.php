<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Checkout Pesanan - R.R HIJAB</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-[#ffefef] text-[#1f1f1f] min-h-screen">
    <header class="bg-white border-b border-[#d8d8d8] shadow-sm">
        <div class="mx-auto max-w-7xl px-6 py-4 flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
            <a href="{{ route('home') }}" class="text-xl font-bold tracking-wider text-[#4b1a1a]">R.R HIJAB</a>
            <nav class="flex flex-wrap items-center gap-4 text-sm font-medium text-[#4b1a1a]">
                <a href="{{ route('home') }}" class="hover:text-[#a70000]">Home</a>
                <a href="{{ route('pelanggan.katalog') }}" class="hover:text-[#a70000]">Katalog</a>
                <a href="{{ route('login') }}" class="rounded-full border border-[#4b1a1a] px-4 py-2 hover:bg-[#ccccff]">Login</a>
            </nav>
        </div>
    </header>

    <main class="mx-auto max-w-6xl px-6 py-10">
        <div class="space-y-8">
            @if(session('success'))
                <div class="rounded-[28px] border border-green-200 bg-[#ecffed] p-6 text-green-900 shadow-sm">
                    <h2 class="text-lg font-bold">Pesanan Diterima</h2>
                    <p class="mt-2 text-sm leading-7">{{ session('success') }}</p>
                </div>
            @endif

            @if(session('error'))
                <div class="rounded-[28px] border border-orange-200 bg-[#fff4e5] p-6 text-[#92400e] shadow-sm">
                    <h2 class="text-lg font-bold">Pemberitahuan</h2>
                    <p class="mt-2 text-sm leading-7">{{ session('error') }}</p>
                </div>
            @endif

            @if(session('midtrans_redirect_url'))
                <div class="rounded-[28px] border border-blue-200 bg-[#eef5ff] p-6 text-[#1e3a8a] shadow-sm">
                    <h2 class="text-lg font-bold">Pembayaran Midtrans Siap</h2>
                    <p class="mt-2 text-sm leading-7">Pesanan Anda sudah dibuat. Silakan lanjutkan pembayaran melalui Midtrans dengan metode {{ session('midtrans_payment_method', 'MIDTRANS') }}.</p>
                    <a href="{{ session('midtrans_redirect_url') }}" target="_blank" rel="noopener" class="mt-4 inline-flex items-center justify-center rounded-full bg-[#1e3a8a] px-5 py-3 text-sm font-semibold text-white transition hover:bg-[#142a5d]">
                        Lanjutkan ke Midtrans
                    </a>
                </div>
            @endif

            @if(! $isAcceptingOrders)
                <div class="rounded-[28px] border border-orange-200 bg-[#fff4e5] p-6 text-[#92400e] shadow-sm">
                    <h2 class="text-lg font-bold">⏰ Jam Operasional Ditutup</h2>
                    <p class="mt-2 text-sm leading-7">Jam operasional R.R Hijab: <strong>Senin – Sabtu, 09:00 – 17:00</strong></p>
                    <p class="mt-3 text-sm leading-7">Admin telah menutup sistem penerimaan pesanan. Silakan kembali lagi ketika jam operasional dibuka.</p>
                </div>
            @endif

            <div class="grid gap-8 lg:grid-cols-[1.4fr_0.9fr]">
                <section class="rounded-[32px] bg-white p-8 shadow-sm border border-[#ffffffcc]">
                    <div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
                        <div>
                            <h1 class="text-3xl font-bold text-[#4b1a1a]">Checkout Pesanan</h1>
                            <p class="mt-2 text-sm text-[#4b1a1a]/80">Lengkapi data pengiriman dan segera kirim bukti transfer untuk proses verifikasi.</p>
                        </div>
                        <span class="rounded-full bg-[#ccffcc] px-4 py-2 text-sm font-semibold text-[#1f4f1f]">Status: Menunggu Pembayaran</span>
                    </div>

                    <div class="mt-8 grid gap-6 lg:grid-cols-[1fr_0.95fr]">
                        <div class="rounded-[30px] bg-[#fffbf8] p-6 border border-[#f4d3d0] shadow-sm">
                            <h2 class="text-lg font-semibold text-[#4b1a1a]">Informasi Produk</h2>
                            <div class="mt-5 space-y-8">
                                <div class="flex flex-col gap-4 lg:flex-row lg:items-center">
                                    <img src="{{ $product->link_foto ? (\Illuminate\Support\Str::startsWith($product->link_foto, ['http://','https://']) ? $product->link_foto : (\Illuminate\Support\Str::startsWith($product->link_foto, 'storage/') ? asset($product->link_foto) : asset('storage/' . ltrim($product->link_foto, '/')))) : 'https://placehold.co/400x400?text=Foto+Hijab' }}" alt="{{ $product->nama_produk }}" class="h-28 w-28 rounded-[24px] object-cover flex-shrink-0" onerror="this.src='https://placehold.co/400x400?text=Foto+Hijab'">
                                    <div class="space-y-2">
                                        <p class="text-sm uppercase tracking-[0.22em] text-[#7b2222]">{{ $product->kategori }}</p>
                                        <h3 class="text-2xl font-bold text-[#4b1a1a] leading-tight">{{ $product->nama_produk }}</h3>
                                        <p class="text-sm leading-7 text-[#4b1a1a]/80">{{ Illuminate\Support\Str::limit($product->deskripsi, 120) }}</p>
                                    </div>
                                </div>
                                <div class="space-y-4">
                                    <div class="rounded-3xl bg-white p-5 text-center shadow-sm border border-[#ffffffcc]">
                                        <p class="text-[0.55rem] uppercase tracking-[0.28em] text-[#2b2b7a]">Harga satuan</p>
                                        @if($product->hasPromoPercent())
                                            <p class="mt-3 text-base font-semibold text-[#4b1a1a]">Rp {{ number_format($product->harga_after_promo, 0, ',', '.') }}</p>
                                            <p class="mt-1 text-xs text-[#7b2222] line-through">Rp {{ number_format($product->harga, 0, ',', '.') }}</p>
                                            <p class="mt-2 text-xs text-[#1f4f1f]">Diskon {{ number_format($product->promo_percent, 0, ',', '.') }}% dari admin</p>
                                        @else
                                            <p class="mt-3 text-base font-semibold text-[#4b1a1a]">Rp {{ number_format($product->harga, 0, ',', '.') }}</p>
                                        @endif
                                    </div>
                                    <div class="rounded-3xl bg-white p-5 text-center shadow-sm border border-[#ffffffcc]">
                                        <p class="text-[0.55rem] uppercase tracking-[0.28em] text-[#2b2b7a]">Stok tersedia</p>
                                        <p class="mt-3 text-base font-semibold text-[#4b1a1a]">{{ $product->stok }}</p>
                                    </div>
                                    <div class="rounded-3xl bg-white p-5 text-center shadow-sm border border-[#ffffffcc]">
                                        <p class="text-[0.55rem] uppercase tracking-[0.28em] text-[#2b2b7a]">Status produk</p>
                                        <p class="mt-3 text-base font-semibold text-[#4b1a1a]">{{ $product->status }}</p>
                                    </div>
                                    <div class="rounded-3xl bg-white p-5 text-center shadow-sm border border-[#ffffffcc]">
                                        <p class="text-[0.55rem] uppercase tracking-[0.28em] text-[#2b2b7a]">Rata-rata Rating</p>
                                        <p class="mt-3 text-base font-semibold text-[#4b1a1a]">{{ number_format($product->comments_avg_rating ?? 0, 1) }}</p>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="rounded-[30px] bg-[#f7f7ff] p-6 border border-[#d9d9ff] shadow-sm">
                            <h2 class="text-lg font-semibold text-[#4b1a1a]">Alur Pesanan</h2>
                            <ol class="mt-5 space-y-4 text-sm text-[#4b1a1a]/85">
                                <li class="flex gap-3">
                                    <span class="mt-1 inline-flex h-7 w-7 items-center justify-center rounded-full bg-[#4b1a1a] text-xs font-bold text-white">1</span>
                                    Isi data pengiriman, bukti pembayaran, dan pilih cara notifikasi (Telegram atau Email).
                                </li>
                                <li class="flex gap-3">
                                    <span class="mt-1 inline-flex h-7 w-7 items-center justify-center rounded-full bg-[#4b1a1a] text-xs font-bold text-white">2</span>
                                    Kami menerima pesanan Anda dan memberikan nomor invoice.
                                </li>
                                <li class="flex gap-3">
                                    <span class="mt-1 inline-flex h-7 w-7 items-center justify-center rounded-full bg-[#4b1a1a] text-xs font-bold text-white">3</span>
                                    Admin memeriksa bukti pembayaran dan memverifikasi pesanan Anda.
                                </li>
                                <li class="flex gap-3">
                                    <span class="mt-1 inline-flex h-7 w-7 items-center justify-center rounded-full bg-[#4b1a1a] text-xs font-bold text-white">4</span>
                                    Pesanan diproses dan Anda menerima notifikasi melalui Email pilihan Anda.
                                </li>
                            </ol>
                        </div>
                    </div>

                    <div class="mt-8 rounded-[32px] bg-white p-6 shadow-sm border border-[#ffffffcc]">
                        <h2 class="text-lg font-semibold text-[#4b1a1a]">Data Pengiriman</h2>
                        <form action="{{ route('pelanggan.katalog.checkout.store', $product->id_produk) }}" method="POST" enctype="multipart/form-data" class="mt-6 space-y-6">
                            @csrf

                            <div class="grid gap-6 sm:grid-cols-2">
                                <label class="block">
                                    <span class="text-sm font-medium text-[#4b1a1a]">Nama Lengkap</span>
                                    <input type="text" name="nama_pelanggan" value="{{ old('nama_pelanggan') }}" class="mt-2 w-full rounded-3xl border border-[#d8d8d8] bg-[#f8f8f8] px-4 py-3 text-sm text-[#1f1f1f] outline-none focus:border-[#4b1a1a]" placeholder="Nama penerima" required>
                                </label>
                                <label class="block">
                                    <span class="text-sm font-medium text-[#4b1a1a]">Nomor WhatsApp</span>
                                    <input type="text" name="no_whatsapp" value="{{ old('no_whatsapp') }}" class="mt-2 w-full rounded-3xl border border-[#d8d8d8] bg-[#f8f8f8] px-4 py-3 text-sm text-[#1f1f1f] outline-none focus:border-[#4b1a1a]" placeholder="62812xxxxxxx" required>
                                </label>
                            </div>

                            <div class="grid gap-6 sm:grid-cols-2">
                                <label class="block">
                                    <span class="text-sm font-medium text-[#4b1a1a]">Email <span class="text-[#666]">(Optional)</span></span>
                                    <input type="email" name="email" value="{{ old('email') }}" class="mt-2 w-full rounded-3xl border border-[#d8d8d8] bg-[#f8f8f8] px-4 py-3 text-sm text-[#1f1f1f] outline-none focus:border-[#4b1a1a]" placeholder="Isi untuk notifikasi via Email">
                                </label>
                            </div>

                            <label class="block">
                                <span class="text-sm font-medium text-[#4b1a1a]">Alamat Pengiriman</span>
                                <textarea name="alamat_pengiriman" rows="4" class="mt-2 w-full rounded-3xl border border-[#d8d8d8] bg-[#f8f8f8] px-4 py-3 text-sm text-[#1f1f1f] outline-none focus:border-[#4b1a1a]" placeholder="Alamat lengkap untuk pengiriman" required>{{ old('alamat_pengiriman') }}</textarea>
                            </label>

                            <div class="grid gap-6 sm:grid-cols-2">
                                <label class="block">
                                    <span class="text-sm font-medium text-[#4b1a1a]">Pilih Warna</span>
                                    <select name="warna" class="mt-2 w-full rounded-3xl border border-[#d8d8d8] bg-[#f8f8f8] px-4 py-3 text-sm text-[#1f1f1f] outline-none focus:border-[#4b1a1a]" required>
                                        <option value="">Pilih Warna</option>
                                        @foreach($product->available_colors as $warna)
                                            @php $colorStock = $product->available_color_stocks[$warna] ?? 0; @endphp
                                            <option value="{{ $warna }}" @if($colorStock <= 0) disabled @endif>
                                                {{ $warna }} @if($colorStock <= 0) (Habis) @else (Stok: {{ $colorStock }}) @endif
                                            </option>
                                        @endforeach
                                    </select>
                                </label>

                                <label class="block">
                                    <span class="text-sm font-medium text-[#4b1a1a]">Pilih Size</span>
                                    <select name="size" class="mt-2 w-full rounded-3xl border border-[#d8d8d8] bg-[#f8f8f8] px-4 py-3 text-sm text-[#1f1f1f] outline-none focus:border-[#4b1a1a]" required>
                                        <option value="">Pilih Size</option>
                                        @foreach($product->available_sizes as $size)
                                            @php $sizeStock = $product->available_size_stocks[$size] ?? 0; @endphp
                                            <option value="{{ $size }}" @if($sizeStock <= 0) disabled @endif>
                                                {{ $size }} @if($sizeStock <= 0) (Habis) @else (Stok: {{ $sizeStock }}) @endif
                                            </option>
                                        @endforeach
                                    </select>
                                </label>
                            </div>

                            <div class="grid gap-6 sm:grid-cols-2">
                                <label class="block">
                                    <span class="text-sm font-medium text-[#4b1a1a]">Jumlah Beli</span>
                                    <input type="number" id="jumlah_beli" name="jumlah_beli" value="{{ old('jumlah_beli', 1) }}" min="1" max="{{ $product->stok }}" class="mt-2 w-full rounded-3xl border border-[#d8d8d8] bg-[#f8f8f8] px-4 py-3 text-sm text-[#1f1f1f] outline-none focus:border-[#4b1a1a]" required>
                                </label>
                                <label class="block">
                                    <span class="text-sm font-medium text-[#4b1a1a]">Bukti Pembayaran</span>
                                    <input type="file" name="bukti_pembayaran" accept="image/*" class="mt-2 w-full rounded-3xl border border-[#d8d8d8] bg-[#f8f8f8] px-4 py-3 text-sm text-[#1f1f1f] outline-none focus:border-[#4b1a1a]" required>
                                </label>
                            </div>

                           <fieldset class="rounded-3xl border border-[#d8d8d8] bg-[#fafafa] p-5">
                                <legend class="px-2 text-sm font-semibold text-[#4b1a1a]">Pilihan Pembayaran</legend>
                                <div class="grid gap-4 md:grid-cols-2 mt-4 text-sm text-[#4b1a1a]">
                                    
                                    <label class="flex items-center gap-3 rounded-3xl border border-[#d8d8d8] bg-white px-4 py-3 cursor-pointer hover:border-[#4b1a1a] transition-all">
                                        <input type="radio" name="payment_method" value="gopay" class="h-4 w-4 text-[#4b1a1a]">
                                        <span>Gopay</span>
                                    </label>
                                    
                                    <label class="flex items-center gap-3 rounded-3xl border border-[#d8d8d8] bg-white px-4 py-3 cursor-pointer hover:border-[#4b1a1a] transition-all">
                                        <input type="radio" name="payment_method" value="qris" class="h-4 w-4 text-[#4b1a1a]">
                                        <span>QRIS (Scan QR)</span>
                                    </label> 
                                </div>
                                <p class="mt-3 text-xs leading-6 text-[#7b2222]">Pilihan Gopay atau QRIS akan diproses lewat Midtrans, lalu Anda akan diarahkan ke halaman pembayaran setelah pesanan dibuat.</p>
                            </fieldset>
                            <fieldset class="rounded-3xl border border-[#d8d8d8] bg-[#fafafa] p-5 mt-6">
                                <legend class="px-2 text-sm font-semibold text-[#4b1a1a]">Metode Pengiriman</legend>
                                <div class="grid gap-4 md:grid-cols-3 mt-4 text-sm text-[#4b1a1a]">
                                    
                                    <label class="rounded-3xl border border-[#d8d8d8] bg-white px-4 py-3 cursor-pointer hover:border-[#4b1a1a] transition-all">
                                        <div class="flex items-center gap-3">
                                            <input type="radio" name="pengiriman" value="jne" data-ongkir="15000" class="shipping-option h-4 w-4 text-[#4b1a1a]">
                                            <span class="font-bold">JNE</span>
                                        </div>
                                        <p class="text-[0.7rem] text-gray-500 mt-1">Rp 15.000 (Reguler)</p>
                                    </label>

                                    <label class="rounded-3xl border border-[#d8d8d8] bg-white px-4 py-3 cursor-pointer hover:border-[#4b1a1a] transition-all">
                                        <div class="flex items-center gap-3">
                                            <input type="radio" name="pengiriman" value="jnt" data-ongkir="17000" class="shipping-option h-4 w-4 text-[#4b1a1a]">
                                            <span class="font-bold">J&T Express</span>
                                        </div>
                                        <p class="text-[0.7rem] text-gray-500 mt-1">Rp 17.000 (Estimasi 2-3 hari)</p>
                                    </label>

                                    <label class="rounded-3xl border border-[#d8d8d8] bg-white px-4 py-3 cursor-pointer hover:border-[#4b1a1a] transition-all">
                                        <div class="flex items-center gap-3">
                                            <input type="radio" name="pengiriman" value="gosend" data-ongkir="25000" class="shipping-option h-4 w-4 text-[#4b1a1a]">
                                            <span class="font-bold">GoSend</span>
                                        </div>
                                        <p class="text-[0.7rem] text-gray-500 mt-1">Rp 25.000 (Instan)</p>
                                    </label>

                                </div>
                            </fieldset>

                            @if($errors->any())
                                <div class="rounded-3xl border border-red-200 bg-[#ffe7e7] p-4 text-sm text-[#7b2222]">
                                    <ul class="list-disc pl-5">
                                        @foreach($errors->all() as $error)
                                            <li>{{ $error }}</li>
                                        @endforeach
                                    </ul>
                                </div>
                            @endif

                            <div class="rounded-[28px] bg-[#fffbf8] p-6 border border-[#f4d3d0]">
                                <div class="flex items-center justify-between gap-4 text-sm text-[#4b1a1a]/85">
                                    <span>Sub total</span>
                                    <span id="subtotal_display">Rp {{ number_format($product->hasPromoPercent() ? $product->harga_after_promo : $product->harga, 0, ',', '.') }}</span>
                                </div>
                                <div class="mt-3 flex items-center justify-between gap-4 text-sm text-[#4b1a1a]/85">
                                    <span>Estimasi ongkir</span>
                                    <span id="ongkir_display">Rp 0</span>
                                </div>
                                <div class="mt-4 border-t border-[#e9d5d1] pt-4 flex items-center justify-between gap-4 text-base font-semibold text-[#4b1a1a]">
                                    <span>Total pesanan</span>
                                    <span id="total_pesanan">Rp {{ number_format($product->hasPromoPercent() ? $product->harga_after_promo : $product->harga, 0, ',', '.') }}</span>
                                </div>
                            </div>

                            <div class="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
                                <a href="{{ route('pelanggan.katalog.detail', $product->id_produk) }}" class="inline-flex items-center justify-center rounded-full border border-[#4b1a1a] bg-white px-6 py-3 text-sm font-semibold text-[#4b1a1a] transition hover:bg-[#ccccff]">Kembali ke Detail</a>
                                <button type="submit" @if(isset($isAcceptingOrders) && ! $isAcceptingOrders) disabled @endif class="inline-flex items-center justify-center rounded-full px-8 py-3 text-sm font-semibold text-white transition {{ isset($isAcceptingOrders) && ! $isAcceptingOrders ? 'bg-gray-300 text-gray-600 cursor-not-allowed' : 'bg-[#4b1a1a] hover:bg-[#2e100f]' }}">Konfirmasi Pesanan</button>
                            </div>
                        </form>
                    </div>
                </section>

                <aside class="space-y-6">
                    <div class="rounded-[32px] bg-white p-6 shadow-sm border border-[#ffffffcc]">
                        <h2 class="text-lg font-semibold text-[#4b1a1a]">Panduan Pembayaran</h2>
                        <div class="mt-4 space-y-4 text-sm leading-7 text-[#4b1a1a]/85">
                            <p>Setelah Anda klik konfirmasi, pesanan akan masuk ke antrian verifikasi kami.</p>
                            <p>Admin akan memeriksa bukti pembayaran Anda dengan cermat untuk memastikan transaksi aman.</p>
                            <p>Jika data lengkap dan benar, pesanan segera diproses dan Anda akan mendapat pemberitahuan via <strong>Email</strong> sesuai yang Anda daftarkan.</p>
                        </div>
                    </div>
                    <div class="rounded-[32px] bg-[#fffbf8] p-6 shadow-sm border border-[#f4d3d0]">
                        <h2 class="text-lg font-semibold text-[#4b1a1a] flex items-center gap-2">
                            <span class="text-xl">⏰</span> Jam Operasional
                        </h2>
                        <div class="mt-4 space-y-3 text-sm text-[#4b1a1a]/85">
                            <p><strong>Hari:</strong> Senin – Sabtu</p>
                            <p><strong>Jam:</strong> 09:00 – 17:00</p>
                            <div class="mt-4 p-3 rounded-xl bg-[#ffe7e7] border border-[#ffcccc]">
                                <p class="text-xs text-[#7b2222]">
                                    Status: <span class="font-bold">{{ $isAcceptingOrders ? '✓ Terbuka' : '✗ Tutup' }}</span>
                                </p>
                            </div>
                        </div>
                    </div>

                    <div class="rounded-[32px] bg-[#ccffcc] p-6 shadow-sm border border-[#e6ffe6]">
                        <h2 class="text-lg font-semibold text-[#1f4f1f]">Mengapa Pilih R.R HIJAB?</h2>
                        <ul class="mt-4 space-y-3 text-sm text-[#1f4f1f]/90">
                            <li class="flex gap-3"><span class="mt-1 inline-flex h-7 w-7 items-center justify-center rounded-full bg-[#4b1a1a] text-white">✓</span> Stok terbaru langsung ter-update setelah pesanan diproses.</li>
                            <li class="flex gap-3"><span class="mt-1 inline-flex h-7 w-7 items-center justify-center rounded-full bg-[#4b1a1a] text-white">✓</span> Bukti pembayaran dicek manual agar transaksi Anda aman.</li>
                            <li class="flex gap-3"><span class="mt-1 inline-flex h-7 w-7 items-center justify-center rounded-full bg-[#4b1a1a] text-white">✓</span> Proses order jelas dengan status pembayaran yang mudah diikuti.</li>
                        </ul>
                    </div>
                </aside>
            </div>
        </div>
    </main>
    <script>
    document.addEventListener('DOMContentLoaded', function() {
        const hargaSatuan = {{ json_encode($product->hasPromoPercent() ? $product->harga_after_promo : $product->harga) }};
        const inputJumlah = document.getElementById('jumlah_beli');
        const shippingOptions = document.querySelectorAll('.shipping-option');
        
        const subtotalDisplay = document.getElementById('subtotal_display');
        const ongkirDisplay = document.getElementById('ongkir_display');
        const totalDisplay = document.getElementById('total_pesanan');

        function hitungTotal() {
            const jumlah = parseInt(inputJumlah.value) || 0;
            let ongkir = 0;

            shippingOptions.forEach(option => {
                if (option.checked) {
                    ongkir = parseInt(option.getAttribute('data-ongkir'));
                }
            });

            const subtotal = jumlah * hargaSatuan;
            const total = subtotal + ongkir;

            subtotalDisplay.innerText = 'Rp ' + subtotal.toLocaleString('id-ID');
            ongkirDisplay.innerText = 'Rp ' + ongkir.toLocaleString('id-ID');
            totalDisplay.innerText = 'Rp ' + total.toLocaleString('id-ID');
        }

        inputJumlah.addEventListener('input', hitungTotal);
        shippingOptions.forEach(opt => opt.addEventListener('change', hitungTotal));
    });
</script>
</body>
</html>
