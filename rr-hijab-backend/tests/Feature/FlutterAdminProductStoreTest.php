<?php

namespace Tests\Feature;

use App\Http\Controllers\FlutterAdminController;
use Illuminate\Http\Request;
use Tests\TestCase;

class FlutterAdminProductStoreTest extends TestCase
{
    public function test_store_product_rejects_prices_above_database_limit(): void
    {
        $this->expectException(\Illuminate\Validation\ValidationException::class);

        $controller = new FlutterAdminController();
        $request = Request::create('/admin/flutter/products', 'POST', [
            'nama_produk' => 'Test Hijab',
            'deskripsi' => 'Test',
            'harga' => '33333333333',
            'stok' => '3',
            'status' => 'Aktif',
            'link_foto' => '/storage/test.jpg',
            'promo' => 'Promo',
            'is_featured' => '0',
        ]);

        $controller->storeProduct($request);
    }
}
