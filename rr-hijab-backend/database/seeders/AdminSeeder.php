<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class AdminSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        DB::table('admins')->insert([
            'username' => 'admin_rrh_akmal', // Username Anda untuk login nanti
            'email' => 'admin@rrhijab.com',
            'password' => Hash::make('admin@rrhijab123'), // Password di-hash demi keamanan standar SRS
            'role' => 'super_admin', // Super admin default untuk setup sistem
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }
}
