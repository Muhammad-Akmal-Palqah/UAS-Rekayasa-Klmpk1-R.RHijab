<?php

namespace Tests\Feature;

use Tests\TestCase;

class FlutterAdminUserViewTest extends TestCase
{
    public function test_user_view_renders_created_at_without_error(): void
    {
        $users = collect([(object) [
            'id' => 1,
            'name' => 'Test User',
            'email' => 'test@example.com',
            'created_at' => '2024-01-15 10:00:00',
        ]]);

        $view = view('admin.flutter_crud_user', [
            'users' => $users,
            'search' => '',
        ]);

        $html = $view->render();

        $this->assertStringContainsString('Test User', $html);
        $this->assertStringContainsString('15 Jan 2024', $html);
    }

    public function test_user_view_contains_add_and_edit_controls(): void
    {
        $users = collect();

        $view = view('admin.flutter_crud_user', [
            'users' => $users,
            'search' => '',
        ]);

        $html = $view->render();

        $this->assertStringContainsString('Tambah User', $html);
        $this->assertStringContainsString('Edit Data', $html);
    }
}
