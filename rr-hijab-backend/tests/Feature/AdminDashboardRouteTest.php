<?php

namespace Tests\Feature;

use App\Models\Admin;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class AdminDashboardRouteTest extends TestCase
{
    public function test_super_admin_can_access_admin_dashboard(): void
    {
        $admin = Admin::create([
            'username' => 'test_super_admin',
            'email' => 'test-super-admin@example.com',
            'password' => Hash::make('password123'),
            'role' => 'super_admin',
        ]);

        $response = $this->actingAs($admin, 'admin')->get('/admin/dashboard');

        $response->assertStatus(200);
    }

    public function test_super_admin_can_promote_admin_to_super_admin(): void
    {
        $superAdmin = Admin::create([
            'username' => 'super_admin_promoter',
            'email' => 'super-admin-promoter@example.com',
            'password' => Hash::make('password123'),
            'role' => 'super_admin',
        ]);

        $admin = Admin::create([
            'username' => 'regular_admin',
            'email' => 'regular-admin@example.com',
            'password' => Hash::make('password123'),
            'role' => 'admin',
        ]);

        $response = $this->actingAs($superAdmin, 'admin')->put('/admin/manage/' . $admin->id_admin, [
            'username' => 'regular_admin_updated',
            'email' => 'regular-admin-updated@example.com',
            'role' => 'super_admin',
        ]);

        $response->assertRedirect();
        $this->assertDatabaseHas('admins', [
            'id_admin' => $admin->id_admin,
            'username' => 'regular_admin_updated',
            'email' => 'regular-admin-updated@example.com',
            'role' => 'super_admin',
        ]);
    }
}
