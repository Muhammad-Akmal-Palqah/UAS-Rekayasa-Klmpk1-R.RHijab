<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;

class FetchOrdersOwnershipTest extends TestCase
{
    public function test_fetch_orders_returns_only_authenticated_users_orders()
    {
        // Test runs against the project's configured DB (migrations must be applied)
        // Create two users
        $userA = User::factory()->create(['email' => 'a@example.com', 'password' => Hash::make('password')]);
        $userB = User::factory()->create(['email' => 'b@example.com', 'password' => Hash::make('password')]);

        // Use the flutter connection to insert orders for both users
// Use default DB connection after unifying Flutter data into main database
        $f = DB::connection();

        $orderAId = $f->table('orders')->insertGetId([
            'user_id' => $userA->id,
            'nama_pelanggan' => 'User A',
            'no_whatsapp' => '081234',
            'email' => $userA->email,
            'alamat_pengiriman' => 'Alamat A',
            'id_produk' => 1,
            'jumlah_beli' => 1,
            'total_harga' => 100,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $orderBId = $f->table('orders')->insertGetId([
            'user_id' => $userB->id,
            'nama_pelanggan' => 'User B',
            'no_whatsapp' => '082345',
            'email' => $userB->email,
            'alamat_pengiriman' => 'Alamat B',
            'id_produk' => 1,
            'jumlah_beli' => 1,
            'total_harga' => 200,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // Login as userA via API to get token
        $loginA = $this->postJson('/api/login', ['email' => $userA->email, 'password' => 'password']);
        $tokenA = $loginA->json('token');

        $responseA = $this->withHeaders(['Authorization' => 'Bearer ' . $tokenA])->getJson('/api/orders');
        $responseA->assertStatus(200);
        $dataA = $responseA->json('data');
        $this->assertCount(1, $dataA);
        $this->assertEquals('User A', $dataA[0]['nama_pelanggan']);

        // Login as userB
        $loginB = $this->postJson('/api/login', ['email' => $userB->email, 'password' => 'password']);
        $tokenB = $loginB->json('token');

        $responseB = $this->withHeaders(['Authorization' => 'Bearer ' . $tokenB])->getJson('/api/orders');
        $responseB->assertStatus(200);
        $dataB = $responseB->json('data');
        $this->assertCount(1, $dataB);
        $this->assertEquals('User B', $dataB[0]['nama_pelanggan']);
    }
}

