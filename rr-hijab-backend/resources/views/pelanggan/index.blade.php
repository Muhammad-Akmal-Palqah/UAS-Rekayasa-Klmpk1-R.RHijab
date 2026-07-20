<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>R.R HIJAB - Pelanggan</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        #collectionSlider {
            scrollbar-width: none;
            -ms-overflow-style: none;
        }

        #collectionSlider::-webkit-scrollbar {
            display: none;
        }
    </style>
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const slider = document.getElementById('collectionSlider');
            const prevBtn = document.getElementById('sliderPrev');
            const nextBtn = document.getElementById('sliderNext');

            const dots = Array.from(document.querySelectorAll('#sliderDots span'));
            const items = slider ? slider.querySelectorAll('article') : [];
            let activeIndex = 0;
            let autoplayInterval = null;

            const updateDots = () => {
                dots.forEach((dot, index) => {
                    dot.classList.toggle('bg-[#4b1a1a]', index === activeIndex);
                    dot.classList.toggle('bg-[#4b1a1a]/40', index !== activeIndex);
                });
            };

            const scrollToIndex = (index) => {
                if (!items[index]) return;
                activeIndex = index;
                slider.scrollTo({ left: items[index].offsetLeft - 10, behavior: 'smooth' });
                updateDots();
            };

            function startAutoplay() {
                if (autoplayInterval || items.length === 0) return;
                autoplayInterval = setInterval(() => {
                    const nextIndex = (activeIndex + 1) % items.length;
                    scrollToIndex(nextIndex);
                }, 20000);
            }

            function stopAutoplay() {
                if (!autoplayInterval) return;
                clearInterval(autoplayInterval);
                autoplayInterval = null;
            }

            function restartAutoplay() {
                stopAutoplay();
                startAutoplay();
            }

            if (slider && prevBtn && nextBtn) {
                prevBtn.addEventListener('click', () => {
                    const nextIndex = Math.max(0, activeIndex - 1);
                    scrollToIndex(nextIndex);
                    restartAutoplay();
                });
                nextBtn.addEventListener('click', () => {
                    const nextIndex = Math.min(items.length - 1, activeIndex + 1);
                    scrollToIndex(nextIndex);
                    restartAutoplay();
                });

                slider.addEventListener('scroll', () => {
                    const center = slider.scrollLeft + slider.offsetWidth / 2;
                    items.forEach((item, index) => {
                        const itemCenter = item.offsetLeft + item.offsetWidth / 2;
                        if (Math.abs(center - itemCenter) < item.offsetWidth / 2) {
                            activeIndex = index;
                        }
                    });
                    updateDots();
                });

                updateDots();
                startAutoplay();
            }
        });
    </script>
</head>
<body class="bg-[#ffcccc] text-[#1f1f1f] min-h-screen">
    <header class="bg-[#ffffffcc] backdrop-blur-md border-b border-[#d8d8d8] shadow-sm">
        <div class="mx-auto max-w-7xl px-6 py-5 flex items-center justify-between gap-4">
            <a href="{{ url('/') }}" class="text-xl font-bold tracking-wider text-[#4b1a1a]">R.R HIJAB</a>
            <nav class="flex items-center gap-4 text-sm font-medium text-[#4b1a1a]">
                <a href="{{ url('/') }}" class="hover:text-[#a70000]">Home</a>
                <a href="{{ route('pelanggan.katalog') }}" class="hover:text-[#a70000]">Katalog</a>
                <a href="{{ route('login') }}" class="rounded-full border border-[#4b1a1a] px-4 py-2 hover:bg-[#ccccff]">Login</a>
            </nav>
        </div>
    </header>

    <main class="mx-auto max-w-7xl px-6 py-10">
        <section class="grid gap-10 lg:grid-cols-[1.2fr_0.8fr] items-center">
            <div class="space-y-6">
                <span class="inline-flex rounded-full bg-[#ccffcc] px-4 py-1 text-sm font-semibold uppercase tracking-[0.18em] text-[#2f4f2f]">Fashion Muslimah Modern</span>
                <h1 class="text-4xl font-bold leading-tight text-[#4b1a1a]">R.R HIJAB - Jilbab Cantik dan Nyaman untuk Semua Momen</h1>
                <p class="max-w-xl text-base leading-8 text-[#3e3e3e]">Jelajahi koleksi hijab premium dengan warna lembut dan desain elegan. Pesan langsung dari aplikasi pelanggan atau web dan nikmati proses pemesanan yang mudah.</p>
                <div class="flex flex-wrap items-center gap-4">
                    <a href="{{ route('pelanggan.katalog') }}" class="inline-flex items-center justify-center rounded-full bg-[#4b1a1a] px-6 py-3 text-white shadow-sm transition hover:bg-[#2e100f]">Lihat Katalog</a>
                    <a href="{{ route('login') }}" class="inline-flex items-center justify-center rounded-full border border-[#4b1a1a] bg-white px-6 py-3 text-[#4b1a1a] transition hover:bg-[#ccccff]">Login untuk Pesan</a>
                </div>
            </div>
            <div class="overflow-hidden rounded-[42px] border border-[#ffffffaa] bg-[#ccccff] p-8 shadow-[0_15px_60px_rgba(0,0,0,0.08)]">
                <div class="aspect-[4/3] rounded-[32px] bg-gradient-to-br from-[#ffcccc] via-[#ccccff] to-[#ccffcc] p-8 shadow-inner">
                    <div class="h-full w-full rounded-[24px] bg-white/70 backdrop-blur-sm p-8 flex flex-col justify-between">
                        <div>
                            <h2 class="text-2xl font-bold text-[#4b1a1a]">Koleksi Terbaru</h2>
                            <p class="mt-4 max-w-sm text-sm leading-7 text-[#4b1a1a]/90">Pilihan jilbab dengan bahan nyaman dan motif modern untuk gaya sehari-hari maupun acara spesial.</p>
                        </div>
                        <div class="relative mt-6">
                            <div id="collectionSlider" class="flex gap-4 overflow-x-auto snap-x snap-mandatory pb-2 scroll-smooth pl-14 pr-14">
                                <article class="min-w-[200px] max-w-[260px] sm:min-w-[240px] sm:max-w-[280px] snap-center shrink-0 rounded-3xl bg-[#ffcccc] p-4 shadow-sm">
                                    <p class="text-xs uppercase tracking-[0.3em] text-[#7b2222]">New</p>
                                    <p class="mt-2 text-base font-semibold text-[#4b1a1a] sm:text-lg">Hijab Pastel Premium</p>
                                </article>
                                <article class="min-w-[200px] max-w-[260px] sm:min-w-[240px] sm:max-w-[280px] snap-center shrink-0 rounded-3xl bg-[#ccffcc] p-4 shadow-sm">
                                    <p class="text-xs uppercase tracking-[0.3em] text-[#256b27]">Best Seller</p>
                                    <p class="mt-2 text-base font-semibold text-[#265023] sm:text-lg">Hijab Sifon Elegan</p>
                                </article>
                            </div>
                            <div id="sliderDots" class="mt-4 flex justify-center gap-2">
                                <span class="h-2 w-2 rounded-full bg-[#4b1a1a]"></span>
                                <span class="h-2 w-2 rounded-full bg-[#4b1a1a]/40"></span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        

        <section class="mt-16 grid gap-6 lg:grid-cols-3">
            <article class="rounded-3xl border border-[#ffffffcc] bg-white p-8 shadow-sm transition hover:-translate-y-1">
                <h3 class="text-xl font-bold text-[#4b1a1a]">Visi</h3>
                <p class="mt-4 text-sm leading-7 text-[#4b1a1a]/90">Menjadi platform pilihan untuk busana muslimah yang elegan, nyaman, dan mudah diakses oleh semua pelanggan.</p>
            </article>
            <article class="rounded-3xl border border-[#ffffffcc] bg-[#ccffcc] p-8 shadow-sm transition hover:-translate-y-1">
                <h3 class="text-xl font-bold text-[#194b1a]">Misi</h3>
                <p class="mt-4 text-sm leading-7 text-[#194b1a]/90">Menyediakan jilbab berkualitas dengan layanan cepat dan sistem pesan online yang terintegrasi antara pelanggan dan admin.</p>
            </article>
            <article class="rounded-3xl border border-[#ffffffcc] bg-white p-8 shadow-sm transition hover:-translate-y-1">
                <h3 class="text-xl font-bold text-[#4b1a1a]">Keunggulan</h3>
                <p class="mt-4 text-sm leading-7 text-[#4b1a1a]/90">Stok terjamin, desain terbaru, serta proses pemesanan yang langsung terhubung ke halaman order pelanggan.</p>
            </article>
        </section>

        <section id="katalog" class="mt-20">
            <div class="flex flex-col gap-3 md:flex-row md:items-end md:justify-between">
                <div>
                    <span class="inline-block rounded-full bg-[#ccccff] px-3 py-1 text-xs font-semibold uppercase tracking-[0.2em] text-[#2b2b7a]">Katalog</span>
                    <h2 class="mt-4 text-3xl font-bold text-[#4b1a1a]">Pilihan Jilbab Unggulan</h2>
                </div>
                <p class="max-w-xl text-sm leading-7 text-[#4b1a1a]/80">Temukan koleksi terbaik dengan warna lembut dan potongan modern, cocok untuk berbagai gaya busana muslimah.</p>
            </div>

            <div class="mt-10 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
                @if(isset($featured) && $featured->isNotEmpty())
                    @foreach($featured as $prod)
                            <div class="rounded-[36px] bg-white p-6 shadow-sm border border-[#ffffffcc] w-full">
                                <div class="overflow-hidden rounded-[28px] bg-[#f8f8f8] mb-5 h-56">
                                    <img src="{{ Illuminate\Support\Str::startsWith($prod->link_foto, ['http://', 'https://']) ? $prod->link_foto : asset($prod->link_foto) }}"
                                         alt="{{ $prod->nama_produk }}"
                                         class="h-full w-full object-cover"
                                         onerror="this.src='https://placehold.co/600x400?text=Foto+Hijab'">
                                </div>
                                <h3 class="text-xl font-semibold text-[#4b1a1a]">{{ $prod->nama_produk }}</h3>
                                <p class="mt-3 text-sm leading-7 text-[#4b1a1a]/80">{{ Illuminate\Support\Str::limit($prod->deskripsi, 120) }}</p>
                            </div>
                    @endforeach
                @else
                    <div class="col-span-1 sm:col-span-2 lg:col-span-3">
                        <div class="rounded-[36px] bg-white p-10 shadow-sm border border-[#ffffffcc] w-full">
                            <div class="p-6 text-center">
                                <p class="text-lg font-semibold text-[#4b1a1a]">Produk katalog belum tersedia.</p>
                                <p class="mt-3 text-sm text-[#4b1a1a]/80">Silakan cek kembali setelah admin menambahkan barang baru ke katalog.</p>
                            </div>
                        </div>
                    </div>
                @endif
            </div>
        </section>

        <footer class="mt-24 rounded-[40px] bg-[#ffffffdd] p-10 text-[#4b1a1a] shadow-sm border border-[#ffffffcc]">
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
    </main>
</body>
</html>
