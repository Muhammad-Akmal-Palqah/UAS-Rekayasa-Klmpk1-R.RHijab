<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AuthProfileUpdateTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_profile_can_be_updated_with_name_email_password_and_photo(): void
    {
        $user = User::factory()->create([
            'name' => 'Old Name',
            'email' => 'old@example.com',
            'password' => bcrypt('old-password'),
        ]);

        Sanctum::actingAs($user, ['*']);

        $response = $this->patchJson('/api/user', [
            'name' => 'New Name',
            'email' => 'new@example.com',
            'password' => 'new-password-123',
            'photo' => 'data:image/png;base64,abc123',
        ]);

        $response->assertOk()
            ->assertJsonPath('user.name', 'New Name')
            ->assertJsonPath('user.email', 'new@example.com')
            ->assertJsonPath('user.photo', 'data:image/png;base64,abc123');

        $this->assertDatabaseHas('users', [
            'id' => $user->id,
            'name' => 'New Name',
            'email' => 'new@example.com',
        ]);

        $user->refresh();
        $this->assertTrue(password_verify('new-password-123', $user->password));
        $this->assertSame('data:image/png;base64,abc123', $user->photo);
    }
}
