<?php

// File: app/Http/Middleware/IsAdmin.php
// Middleware ini memeriksa apakah user memiliki akses admin sebelum melanjutkan request.

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Symfony\Component\HttpFoundation\Response;
use Illuminate\Support\Facades\Auth;

class IsAdmin
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        // 💡 PERBAIKAN: Mengambil user aktif dari multi-guard agar akurat saat diakses via Web maupun API Token Sanctum
        $user = Auth::guard('admin')->user() ?? Auth::guard('sanctum')->user() ?? $request->user();
        
        // Jika tidak ada user yang login, tolak akses dengan status 401.
        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized',
            ], 401);
        }

        // Jika user adalah instance dari model Admin, cek kolom role internalnya langsung
        if ($user instanceof \App\Models\Admin) {
            $isAdmin = in_array($user->role, ['admin', 'super_admin'], true);
        } else {
            // Jika akun berada di tabel users, lakukan pengecekan cross-check ke tabel admins berdasarkan kesamaan email
            $isAdmin = DB::table('admins')
                ->where('email', $user->email)
                ->whereIn('role', ['admin', 'super_admin'])
                ->exists();

            // 💡 TAMBAHAN SAFETY: Jika di tabel users sendiri kolom role-nya sudah bernilai super_admin/admin, langsung loloskan
            if (!$isAdmin && isset($user->role) && in_array($user->role, ['admin', 'super_admin'], true)) {
                $isAdmin = true;
            }
        }
        
        // Jika user tidak memiliki hak akses admin atau super_admin, tolak dengan status 403.
        if (!$isAdmin) {
            return response()->json([
                'success' => false,
                'message' => 'Forbidden - Admin access required',
            ], 403);
        }

        return $next($request);
    }
}