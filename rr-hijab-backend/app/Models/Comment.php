<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Comment extends Model
{
    use HasFactory;

    // Menentukan nama tabel jika tidak mengikuti konvensi jamak (default: comments)
    protected $table = 'comments';

    // Menentukan primary key jika bukan 'id'
    protected $primaryKey = 'id';

    /**
     * The attributes that are mass assignable.
     * Kita masukkan 'image_url' di sini agar bisa disimpan lewat Controller
     */
    protected $fillable = [
        'user_id',
        'id_produk',
        'komentar',
        'rating',
        'image_url', // Wajib ada agar kolom ini bisa diisi
    ];

    /**
     * Relasi ke User (Satu komentar milik satu user)
     */
    public function user()
    {
        return $this->belongsTo(User::class, 'user_id', 'id');
    }

    /**
     * Relasi ke Product (Satu komentar milik satu produk)
     */
    public function product()
    {
        return $this->belongsTo(Product::class, 'id_produk', 'id_produk');
    }
}