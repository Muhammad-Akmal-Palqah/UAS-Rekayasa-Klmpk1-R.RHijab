<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Carbon;

class BusinessHour extends Model
{
    protected $table = 'business_hours';

    protected $fillable = [
        'open_time',
        'close_time',
        'open_days',
        'enabled',
    ];

    protected $casts = [
        'open_days' => 'array',
        'enabled' => 'boolean',
    ];

    public static function current(): self
    {
        if (! Schema::hasTable('business_hours')) {
            return new self([
                'open_time' => config('business_hours.open_time', '09:00'),
                'close_time' => config('business_hours.close_time', '17:00'),
                'open_days' => config('business_hours.open_days', ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday']),
                'enabled' => true,
            ]);
        }

        return self::first() ?? self::create([
            'open_time' => config('business_hours.open_time', '09:00'),
            'close_time' => config('business_hours.close_time', '17:00'),
            'open_days' => config('business_hours.open_days', ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday']),
            'enabled' => true,
        ]);
    }

    public function isOpenAt(?Carbon $now = null): bool
    {
        // Hanya cek flag enabled, tanpa logika waktu atau hari
        return (bool) $this->enabled;
    }
}
