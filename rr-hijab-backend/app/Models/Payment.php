<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Payment extends Model
{
    use HasFactory;

    protected $table = 'payments';

    protected $fillable = [
        'order_id',
        'user_id',
        'transaction_id',
        'amount',
        'payment_type',
        'snap_token',
        'status',
        'midtrans_response',
        'qr_code_url',
        'deeplink_redirect',
        'expired_at',
        'paid_at',
    ];

    protected $casts = [
        'midtrans_response' => 'array',
        'amount' => 'decimal:2',
        'expired_at' => 'datetime',
        'paid_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];
}
