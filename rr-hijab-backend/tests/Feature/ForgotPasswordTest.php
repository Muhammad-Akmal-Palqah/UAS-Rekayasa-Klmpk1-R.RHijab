<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Schema;
use Tests\TestCase;

class ForgotPasswordTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_password_can_be_reset_with_email_and_new_password(): void
    {
// Use default DB/Schema connection after unifying Flutter data into main database
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('email')->unique();
            $table->string('password');
            $table->timestamps();
        });

        $user = new User();
// Removed explicit flutter connection use so this model/query uses the default DB
        $user->name = 'Test User';
        $user->email = 'test@example.com';
        $user->password = Hash::make('old-password');
        $user->save();

        $response = $this->postJson('/api/forgot-password', [
            'email' => 'test@example.com',
            'password' => 'new-password-123',
        ]);

        $response->assertStatus(200)
            ->assertJsonPath('success', true)
            ->assertJsonPath('message', 'Password berhasil diperbarui.');

        $updatedUser = User::where('email', 'test@example.com')->first();

        $this->assertNotNull($updatedUser);
        $this->assertTrue(Hash::check('new-password-123', $updatedUser->password));
    }
}

