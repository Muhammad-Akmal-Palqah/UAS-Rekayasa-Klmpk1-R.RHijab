<?php

namespace App\Models;

use Laravel\Sanctum\PersonalAccessToken;

class FlutterPersonalAccessToken extends PersonalAccessToken
{
    // Use default DB connection after unifying Flutter data into the main database
    protected $table = 'personal_access_tokens';
}
