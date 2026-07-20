<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Order extends Model
{
    use HasFactory;

    protected $table = 'orders';
    protected $primaryKey = 'id_order';
    public $incrementing = true;
    protected $keyType = 'int';

    // // 💡 Kolom 'warna' kini resmi didukung agar pilihan variasi hijab dari Flutter/Web tersimpan sempurna
    protected $fillable = [
        'user_id',
        'nama_pelanggan',
        'no_whatsapp',
        'email',
        'alamat_pengiriman',
        'id_produk',
        'jumlah_beli',
        'total_harga',
        'ukuran',
        'warna',             // // 💡 BARU: Berhasil diintegrasikan ke dalam sistem order terpadu
        'metode_pengiriman',
        'catatan',
        'status_pembayaran',
        'status_produk',
        'id_admin',
        'bukti_transfer',
        'validated_at',
    ];

    protected function casts(): array
    {
        return [
            'total_harga' => 'decimal:2',
            'created_at' => 'datetime',
            'updated_at' => 'datetime',
            'validated_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id', 'id');
    }

    public function payments(): HasMany
    {
        return $this->hasMany(Payment::class, 'order_id', 'id_order');
    }
}