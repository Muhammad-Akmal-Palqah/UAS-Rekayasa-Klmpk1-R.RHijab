<?php

// File: app/Http/Middleware/EnsureRole.php
// Middleware ini memastikan user memiliki role yang diizinkan sebelum mengakses route tertentu.

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use Illuminate\Support\Facades\Auth;

class EnsureRole
{
    /**
     * Handle an incoming request and ensure the authenticated actor has one of the allowed roles.
     *
     * Supported roles:
     * - user: end user of Flutter/Web app
     * - admin: toko/web admin yang mengelola produk, pesanan, dan komentar
     * - super_admin: pengelola sistem penuh, termasuk pembuatan akun admin baru
     */
    // 💡 PERBAIKAN: Mengubah string $roles menjadi array variadic ...$roles agar dapat menangkap 'admin,super_admin' dari route
    public function handle(Request $request, Closure $next, ...$roles): Response
    {
        // Cek user dari guard admin, sanctum, atau guard default secara berurutan.
        $user = Auth::guard('admin')->user() ?? Auth::guard('sanctum')->user() ?? Auth::user();

        // Jika tidak ada user yang login, kembalikan response unauthorized.
        if (! $user) {
            if ($request->expectsJson() || $request->is('api/*')) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized - login required to access this resource.',
                ], 401);
            }

            return redirect()->route('login');
        }

        // Ambil properti role dari model user yang berhasil ditemukan
        $currentRole = $user->role ?? null;
        
        // Fallback checks untuk model custom jika property role tidak langsung terdefinisi
        if ($currentRole === null && method_exists($user, 'isSuperAdmin') && $user->isSuperAdmin()) {
            $currentRole = 'super_admin';
        } elseif ($currentRole === null && method_exists($user, 'isAdmin') && $user->isAdmin()) {
            $currentRole = 'admin';
        }

        // 💡 PERBAIKAN LOGIKA: Jika user adalah super_admin, otomatis izinkan akses ke manapun (Bypass Mutlak)
        if ($currentRole === 'super_admin') {
            return $next($request);
        }

        // Jika role user tidak ada atau tidak termasuk di dalam daftar array $roles yang dikirim route, tolak akses.
        if (! $currentRole || ! in_array($currentRole, $roles, true)) {
            if ($request->expectsJson() || $request->is('api/*')) {
                return response()->json([
                    'success' => false,
                    'message' => 'Forbidden - you do not have the required role to access this resource.',
                ], 403);
            }

            abort(403, 'Forbidden - you do not have the required role to access this resource.');
        }

        return $next($request);
    }
}