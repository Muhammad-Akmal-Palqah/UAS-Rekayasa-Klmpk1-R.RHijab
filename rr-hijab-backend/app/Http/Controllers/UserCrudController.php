<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class UserCrudController extends Controller
{
    // 💡 VIEW USERS: Mengambil daftar seluruh data pelanggan terdaftar
    public function index(Request $request)
    {
        $search = $request->input('search');
        
        // Pembungkusan sub-query orWhere untuk mengamankan fungsionalitas fitur pencarian keyword
        $users = User::when($search, function ($query, $search) {
            return $query->where(function($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")->orWhere('email', 'like', "%{$search}%");
            });
        })->paginate(10);

        return view('admin.crud_user', compact('users', 'search'));
    }

    // 💡 CREATE USER: Menambahkan akun member baru secara manual melalui control panel web admin
    public function store(Request $request)
    {
        $request->validate(['name' => 'required|min:3', 'email' => 'required|email|unique:users,email', 'password' => 'required|min:6']);

        User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role' => 'user', // Memastikan role yang terkunci aman di level user / customer biasa
        ]);

        return redirect()->back()->with('success', 'Pelangan baru berhasil ditambahkan!');
    }

    // 💡 UPDATE USER: Mengubah data profile member dari sisi admin panel web
    public function update(Request $request, $id)
    {
        // 💡 PERBAIKAN KEAMANAN: Memvalidasi parameter rute ID wajib berupa angka numerik murni sebelum query dieksekusi
        if (!is_numeric($id)) { return redirect()->back()->with('error', 'ID Pengguna tidak valid.'); }

        $user = User::findOrFail($id);
        $request->validate(['name' => 'required|min:3', 'email' => 'required|email|unique:users,email,' . $id]);

        $user->name = $request->name;
        $user->email = $request->email;

        if ($request->filled('password')) {
            $request->validate(['password' => 'min:6']);
            $user->password = Hash::make($request->password);
        }

        $user->save();
        return redirect()->back()->with('success', 'Data pelanggan berhasil diperbarui!');
    }

    public function destroy($id)
    {
        if (!is_numeric($id)) { return redirect()->back()->with('error', 'ID tidak valid.'); }
        User::findOrFail($id)->delete();
        return redirect()->back()->with('success', 'Akun pelanggan berhasil dihapus!');
    }
}