<?php
require 'vendor/autoload.php';
$app = require 'bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

$username = 'admin_rrhijab';
$email = 'admin@rrhijab.com';
$password = 'admin@rrhijab123';

$existing = DB::table('admins')->where('email', $email)->orWhere('username', $username)->first();

if ($existing) {
    DB::table('admins')->where('id_admin', $existing->id_admin)->update([
        'username' => $username,
        'email' => $email,
        'password' => Hash::make($password),
        'role' => 'super_admin',
        'updated_at' => now(),
    ]);
    echo "UPDATED\n";
} else {
    DB::table('admins')->insert([
        'username' => $username,
        'email' => $email,
        'password' => Hash::make($password),
        'role' => 'super_admin',
        'created_at' => now(),
        'updated_at' => now(),
    ]);
    echo "CREATED\n";
}

$row = DB::table('admins')->where('email', $email)->first();
echo json_encode([
    'username' => $row->username,
    'email' => $row->email,
    'role' => $row->role,
], JSON_UNESCAPED_SLASHES) . PHP_EOL;
