<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class Admin extends Authenticatable
{
    use Notifiable;

    protected $table = 'admins';
    
    // 💡 BERITAHU LARAVEL KALAU PRIMARY KEY-NYA BUKAN 'id'
    protected $primaryKey = 'id_admin'; 

    protected $fillable = [
        'username', // Sesuai kolom di phpMyAdmin
        'email',
        'password',
        'role',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Return true if the admin account is a system-level super admin.
     */
    public function isSuperAdmin(): bool
    {
        return $this->role === 'super_admin';
    }

    /**
     * Return true if the admin account is an admin or super admin.
     */
    public function isAdmin(): bool
    {
        return in_array($this->role, ['admin', 'super_admin'], true);
    }
}
