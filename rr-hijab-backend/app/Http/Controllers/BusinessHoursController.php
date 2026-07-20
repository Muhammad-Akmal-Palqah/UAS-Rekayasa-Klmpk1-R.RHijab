<?php

namespace App\Http\Controllers;

use App\Models\BusinessHour;
use Illuminate\Http\RedirectResponse;

class BusinessHoursController extends Controller
{
    // 💡 TOGGLE STATUS OPERASIONAL: Mengubah status buka/tutup toko online secara real-time
    public function toggle(): RedirectResponse
    {
        $businessHours = BusinessHour::current();

        // Jika records konfigurasi jam belum tersedia di DB, buat instant baru
        if (!$businessHours->exists) {
            $businessHours = BusinessHour::create([
                'open_time' => $businessHours->open_time,
                'close_time' => $businessHours->close_time,
                'open_days' => $businessHours->open_days,
                'enabled' => true,
            ]);
        }

        // Membalikkan nilai boolean status operasional toko
        $businessHours->enabled = !$businessHours->enabled;
        $businessHours->save();

        return redirect()->route('admin.dashboard')
            ->with('success', $businessHours->enabled ? 'Jam operasional sekarang aktif.' : 'Jam operasional sekarang dinonaktifkan.');
    }
}