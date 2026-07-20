<?php

namespace Tests\Feature;

use Tests\TestCase;

class FlutterAdminProductViewTest extends TestCase
{
    public function test_product_view_renders_without_kategori_property_error(): void
    {
        $products = collect([(object) [
            'id_produk' => 1,
            'nama_produk' => 'Test Hijab',
            'link_foto' => '/storage/test.jpg',
            'harga' => 150000,
            'stok' => 10,
            'status' => 'Aktif',
            'created_at' => now(),
            'updated_at' => now(),
        ]]);

        $view = view('admin.flutter_crud_product', [
            'products' => $products,
            'search' => '',
        ]);

        $html = $view->render();

        $this->assertStringContainsString('Test Hijab', $html);
        $this->assertStringContainsString('Tambah Barang', $html);
    }
}
