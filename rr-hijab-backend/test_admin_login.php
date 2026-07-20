<?php
require 'vendor/autoload.php';
$app = require 'bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

$email = 'admin@rrhijab.com';
$password = 'admin@rrhijab123';

$ok = Auth::guard('admin')->attempt([
    'email' => $email,
    'password' => $password,
]);

$user = Auth::guard('admin')->user();

echo 'AUTH=' . ($ok ? 'OK' : 'FAIL') . PHP_EOL;
echo 'USER=' . ($user ? $user->email . '|' . $user->role : 'NONE') . PHP_EOL;
