<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Admin;
use Illuminate\Support\Facades\Hash;

class AdminCrudController extends Controller
{
    // 💡 TAMPILKAN DATA: Menampilkan daftar admin dengan fitur pencarian dan pagination
    public function index(Request $request)
    {
        $search = $request->input('search');
        
        // Membungkus pencarian dalam closure group agar query WHERE tidak merusak data lain
        $admins = Admin::when($search, function ($query, $search) {
            return $query->where(function($q) use ($search) {
                $q->where('username', 'like', "%{$search}%")
                  ->orWhere('email', 'like', "%{$search}%");
            });
        })->paginate(10); // Sesuai mockup: 10 entri per halaman

        return view('admin.crud_admin', compact('admins', 'search'));
    }

    // 💡 SIMPAN DATA: Menambahkan data admin baru ke database
    public function store(Request $request)
    {
        $request->validate([
            'username' => 'required|unique:admins,username',
            'email' => 'required|email|unique:admins,email',
            'password' => 'required|min:6',
        ]);

        Admin::create([
            'username' => $request->username,
            'email' => $request->email,
            'password' => Hash::make($request->password), // Enkripsi password demi keamanan
            'role' => 'admin', // Default role untuk pendaftaran via dashboard admin
        ]);

        return redirect()->back()->with('success', 'Admin berhasil ditambahkan!');
    }

    // 💡 UPDATE DATA: Memperbarui data admin yang sudah ada berdasarkan id_admin
    public function update(Request $request, $id)
    {
        $admin = Admin::findOrFail($id);

        $request->validate([
            'username' => 'required|unique:admins,username,' . $id . ',id_admin',
            'email' => 'required|email|unique:admins,email,' . $id . ',id_admin',
            'role' => 'nullable|in:admin,super_admin',
        ]);

        $admin->username = $request->username;
        $admin->email = $request->email;

        if ($request->filled('role')) {
            $admin->role = $request->role;
        }

        // Jika form password diisi, lakukan enkripsi dan update password baru
        if ($request->filled('password')) {
            $request->validate(['password' => 'min:6']);
            $admin->password = Hash::make($request->password);
        }

        $admin->save();
        return redirect()->back()->with('success', 'Data admin berhasil diperbarui!');
    }

    // 💡 HAPUS DATA: Menghapus akun admin dari sistem
    public function destroy($id)
    {
        $admin = Admin::findOrFail($id);
        $admin->delete();

        return redirect()->back()->with('success', 'Admin berhasil deleted!');
    }
}