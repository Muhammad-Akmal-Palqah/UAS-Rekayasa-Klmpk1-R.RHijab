<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use App\Models\Product; 

class ProductCrudController extends Controller
{
    // 1. VIEW PRODUCTS: Menampilkan katalog inventoris barang di dashboard admin
    public function index(Request $request)
    {
        $search = $request->input('search');
        
        $products = Product::when($search, function ($query, $search) {
            return $query->where(function($q) use ($search) {
                $q->where('nama_produk', 'like', "%{$search}%")->orWhere('kategori', 'like', "%{$search}%");
            });
        })->paginate(10);

        return view('admin.crud_product', compact('products', 'search'));
    }

    // 2. STORE PRODUCT: Menambahkan produk hijab baru dari interface form web admin
    public function store(Request $request)
    {
        $request->validate([
            'nama_produk' => 'required|string|max:255', 
            'kategori' => 'required|string|max:100',
            'harga' => 'required|numeric|min:0', 
            'stok' => 'required|integer|min:0|max:10000',
            'gambar_produk' => 'required|array', // Menyesuaikan array multi-upload dari Blade
            'gambar_produk.*' => 'image|max:2048', 
            'deskripsi' => 'required|string'
        ]);

        // Proses Multi-upload foto galeri
        $uploadedPaths = [];
        if ($request->hasFile('gambar_produk')) {
            foreach ($request->file('gambar_produk') as $file) {
                $path = $file->store('product_images', 'public');
                $uploadedPaths[] = 'storage/' . $path;
            }
        }

        Product::create([
            'nama_produk' => $request->nama_produk, 
            'kategori' => $request->kategori, 
            'harga' => $request->harga, 
            'stok' => $request->stok,
            'deskripsi' => $request->deskripsi,
            'link_foto' => $uploadedPaths[0] ?? null, // Foto pertama sebagai cover utama
            'link_fotos' => $uploadedPaths, // Menyimpan array seluruh galeri foto
            'promo' => $request->promo,
            'home_section' => $request->home_section,
            'is_featured' => $request->has('is_featured') ? 1 : 0,
            'status' => $request->stok > 0 ? 'Aktif' : 'Tidak Aktif',
            'available_sizes' => $this->parseCommaSeparated($request->input('available_sizes')), 
            'available_colors' => $this->parseCommaSeparated($request->input('available_colors')),
            'available_size_stocks' => $this->parseKeyValuePairs($request->input('available_size_stocks')), 
            'available_color_stocks' => $this->parseKeyValuePairs($request->input('available_color_stocks')),
        ]);

        return redirect()->back()->with('success', 'Produk hijab baru berhasil ditambahkan!');
    }

    // 3. UPDATE PRODUCT: Menyimpan perubahan data produk ke database (ANTI-NULL)
    public function update(Request $request, $id)
    {
        $product = Product::findOrFail($id);
        $request->validate([
            'nama_produk' => 'required|string', 
            'kategori' => 'required|string', 
            'harga' => 'required|numeric', 
            'stok' => 'required|integer|max:10000', 
            'deskripsi' => 'required|string'
        ]);

        // JALUR PENYELAMAT: Mengambil link_foto lama dari input hidden jika admin tidak ganti foto
        $linkFoto = $request->input('current_link_foto', $product->link_foto);
        $linkFotos = $product->link_fotos; 

        // Jika admin mengunggah kumpulan foto baru
        if ($request->hasFile('gambar_produk')) {
            // Hapus foto-foto lama dari storage local
            if (!empty($product->link_fotos) && is_array($product->link_fotos)) {
                foreach ($product->link_fotos as $oldFoto) {
                    if (str_starts_with($oldFoto, 'storage/')) {
                        Storage::disk('public')->delete(substr($oldFoto, 8));
                    }
                }
            } elseif (str_starts_with($product->link_foto, 'storage/')) {
                Storage::disk('public')->delete(substr($product->link_foto, 8));
            }

            // Simpan kumpulan foto baru
            $uploadedPaths = [];
            foreach ($request->file('gambar_produk') as $file) {
                $path = $file->store('product_images', 'public');
                $uploadedPaths[] = 'storage/' . $path;
            }

            $linkFoto = $uploadedPaths[0]; // Set cover baru
            $linkFotos = $uploadedPaths;   // Set galeri baru
        }

        // Jalankan update terpadu ke database
        $product->update([
            'nama_produk' => $request->nama_produk, 
            'kategori' => $request->kategori, 
            'harga' => $request->harga, 
            'stok' => $request->stok, 
            'link_foto' => $linkFoto, // DIJAMIN AMAN: Tidak akan null lagi!
            'link_fotos' => $linkFotos,
            'deskripsi' => $request->deskripsi, 
            'promo' => $request->promo,
            'home_section' => $request->home_section,
            'is_featured' => $request->has('is_featured') ? 1 : 0,
            'status' => $request->status ?? ($request->stok > 0 ? 'Aktif' : 'Tidak Aktif'),
            'available_sizes' => $this->parseCommaSeparated($request->input('available_sizes')), 
            'available_colors' => $this->parseCommaSeparated($request->input('available_colors')), 
            'available_size_stocks' => $this->parseKeyValuePairs($request->input('available_size_stocks')), 
            'available_color_stocks' => $this->parseKeyValuePairs($request->input('available_color_stocks')),
        ]);

        return redirect()->route('product.index')->with('success', 'Katalog produk berhasil diperbarui!');
    }

    public function destroy($id) 
    { 
        Product::findOrFail($id)->delete(); 
        return redirect()->back()->with('success', 'Produk berhasil dihapus.'); 
    }

    private function parseCommaSeparated(?string $value): ?array 
    { 
        return empty(trim((string)$value)) ? null : array_values(array_filter(array_map('trim', explode(',', $value)))); 
    }

    private function parseKeyValuePairs(?string $value): ?array 
    {
        if (empty(trim((string)$value))) { return null; }
        $res = [];
        foreach (explode(',', $value) as $e) {
            if (!str_contains($e, ':')) continue;
            [$k, $v] = array_map('trim', explode(':', $e, 2) + [1 => '']);
            if ($k !== '') { $res[$k] = is_numeric($v) ? (int)$v : $v; }
        }
        return $res === [] ? null : $res;
    }

    public function generateDescription(Request $request)
    {
        $request->validate(['nama_produk' => 'required|string']);
        try {
            $client = new \GuzzleHttp\Client(['verify' => false]);
            $response = $client->post('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=' . env('GEMINI_API_KEY'), [
                'headers' => ['Content-Type' => 'application/json'],
                'json' => ['contents' => [['parts' => [['text' => "Buatkan deskripsi produk hijab untuk produk bernama '{$request->nama_produk}'. Deskripsi harus menarik, singkat 2-3 kalimat, dan cocok untuk toko online hijab. Gunakan bahasa Indonesia."]]]]]
            ]);

            $data = json_decode($response->getBody(), true);
            return response()->json(['deskripsi' => $data['candidates'][0]['content']['parts'][0]['text']]);
        } catch (\Exception $e) { return response()->json(['error' => $e->getMessage()], 500); }
    }
}