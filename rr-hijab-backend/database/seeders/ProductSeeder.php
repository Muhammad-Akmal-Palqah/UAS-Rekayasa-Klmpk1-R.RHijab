<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class ProductSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        DB::table('products')->insert([
            [
                'nama_produk' => 'Hijab Bella Square',
                'deskripsi' => 'Hijab segi empat ternyaman bahan Pollycotton premium ukuran 115x115 cm.',
                'kategori' => 'Segi Empat',
                'harga' => 25000.00,
                'link_foto' => 'https://images.unsplash.com/photo-1609357505561-eb983637cba8?q=80&w=400',
                'stok' => 50,
                'status' => 'Aktif',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'nama_produk' => 'Pashmina Ceruty Baby Doll',
                'deskripsi' => 'Pashmina mudah dibentuk dengan tekstur pasir lembut dan jatuh pas dipakai.',
                'kategori' => 'Pashmina',
                'harga' => 35000.00,
                'link_foto' => 'https://images.unsplash.com/photo-1618244972963-dbee1a7edc95?q=80&w=400',
                'stok' => 30,
                'status' => 'Aktif',
                'created_at' => now(),
                'updated_at' => now(),
            ]
        ]);
    }
}
