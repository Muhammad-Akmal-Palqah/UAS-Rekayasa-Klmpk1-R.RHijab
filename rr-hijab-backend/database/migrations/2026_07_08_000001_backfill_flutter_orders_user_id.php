<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
// Use default DB connection after unifying Flutter data into main database
        $flutter = DB::connection();

        // Backfill user_id on flutter.orders by matching users.email -> users.id
        // Use a safe row-by-row update to remain DB-agnostic.
        $users = DB::table('users')->select('id', 'email')->get();
        foreach ($users as $u) {
            if ($u->email === null) continue;
            $flutter->table('orders')
                ->whereNull('user_id')
                ->where('email', $u->email)
                ->update(['user_id' => $u->id]);
        }
    }

    public function down(): void
    {
        // Revert: set user_id = null where it matches a user email (best-effort)
// Use default DB connection after unifying Flutter data into main database
        $flutter = DB::connection();
        $users = DB::table('users')->select('id', 'email')->get();
        foreach ($users as $u) {
            if ($u->email === null) continue;
            $flutter->table('orders')
                ->where('user_id', $u->id)
                ->where('email', $u->email)
                ->update(['user_id' => null]);
        }
    }
};

