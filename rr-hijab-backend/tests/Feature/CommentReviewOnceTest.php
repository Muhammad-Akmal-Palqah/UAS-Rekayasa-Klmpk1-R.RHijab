<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;
use App\Models\User;

class CommentReviewOnceTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_submit_only_one_review_per_product(): void
    {
        $user = User::factory()->create([
            'email' => 'review@example.com',
        ]);

        $productId = DB::table('products')->insertGetId([
            'nama_produk' => 'Test Product',
            'deskripsi' => 'Test',
            'harga' => 100000,
            'stok' => 10,
            'status' => 'Aktif',
            'link_foto' => 'https://example.com/product.jpg',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $login = $this->postJson('/api/login', [
            'email' => $user->email,
            'password' => 'password',
        ]);

        $token = $login->json('token');
        $headers = ['Authorization' => 'Bearer ' . $token];

        $payload = [
            'komentar' => 'Produk bagus',
            'rating' => 5,
        ];

        $first = $this->withHeaders($headers)->postJson("/api/products/{$productId}/comments", $payload);
        $first->assertStatus(201);

        $second = $this->withHeaders($headers)->postJson("/api/products/{$productId}/comments", $payload);
        $second->assertStatus(409);
        $second->assertJsonPath('message', 'Anda sudah pernah memberikan ulasan untuk produk ini.');
        $this->assertDatabaseCount('comments', 1);
    }
}
