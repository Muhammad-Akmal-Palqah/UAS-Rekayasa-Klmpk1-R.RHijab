<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\User; 
use App\Models\Admin;
use Illuminate\Support\Facades\Hash; 
use Illuminate\Support\Facades\Storage;

class AuthController extends Controller
{
    public function showLogin() { return view('auth.login'); }

    // 💡 PROSES LOGIN: Mendukung Web (Admin & Pelanggan) dan API Mobile (Sanctum Token)
    public function login(Request $request)
    {
        $credentials = $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        // Intersept rute jika request meminta format JSON (Aplikasi HP Flutter)
        if ($request->wantsJson() || $request->is('api/*')) {
            $user = User::where('email', $credentials['email'])->first();

            if ($user && Hash::check($credentials['password'], $user->password)) {
                $token = $user->createToken('api-token')->plainTextToken; // Pembuatan token Sanctum

                return response()->json([
                    'success' => true,
                    'message' => 'Login berhasil.',
                    'user' => ['id' => $user->id, 'name' => $user->name, 'email' => $user->email, 'photo' => $user->photo, 'phone' => $user->phone],
                    'token' => $token,
                ]);
            }

            return response()->json(['success' => false, 'message' => 'Email atau password salah.'], 401);
        }

        // Jalur login aplikasi Web Admin (Guard Admin)
        if (Auth::guard('admin')->attempt($credentials)) {
            Auth::shouldUse('admin');
            $request->session()->regenerate();
            return redirect()->intended('/admin/dashboard');
        }

        // Jalur login aplikasi Web Pelanggan (Guard Web)
        if (Auth::attempt($credentials)) {
            Auth::shouldUse('web');
            $request->session()->regenerate();
            return redirect()->intended('/pesan-hijab');
        }

        return back()->withErrors(['email' => 'Email atau password salah atau tidak terdaftar.']);
    }

    public function logout(Request $request)
    {
        Auth::guard('admin')->logout();
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();
        return redirect('/login');
    }

    public function showRegister() { return view('auth.register'); }

    // 💡 PROSES REGISTER: Memisahkan akun otomatis berdasarkan struktur domain email
    public function register(Request $request)
    {
        $email = $request->input('email');
        $isApiRequest = $request->wantsJson() || $request->is('api/*');

        // Pendaftaran khusus via API Flutter (Selalu didaftarkan sebagai role user/pelanggan)
        if ($isApiRequest) {
            $request->validate([
                'name' => 'required|string|max:255',
                'email' => 'required|email|unique:users,email',
                'password' => 'required|min:6',
            ]);

            $user = User::create([
                'name' => $request->name,
                'email' => $email,
                'password' => Hash::make($request->password),
                'role' => 'user',
            ]);

            $token = $user->createToken('api-token')->plainTextToken;

            return response()->json([
                'success' => true,
                'message' => 'Akun berhasil dibuat!',
                'user' => ['id' => $user->id, 'name' => $user->name, 'email' => $user->email, 'role' => $user->role],
                'token' => $token,
            ], 201);
        }

        // Pendaftaran dari Web: Jika berakhiran @rrhijab.com otomatis menjadi Admin, selain itu Pelanggan
        $isAdminEmail = str_ends_with($email, '@rrhijab.com');
        $targetTable = $isAdminEmail ? 'admins' : 'users';

        $request->validate([
            'email' => "required|email|unique:{$targetTable},email",
            'password' => 'required|min:6',
        ]);

        $hashedPassword = Hash::make($request->password);
        $generatedName = explode('@', $email)[0];
        $name = $request->input('name', $generatedName);

        if ($isAdminEmail) {
            Admin::create([
                'username' => $generatedName,
                'email' => $email,
                'password' => $hashedPassword,
                'role' => 'admin',
            ]);
            $message = 'Akun Admin berhasil dibuat! Silakan masuk.';
        } {
            User::create([
                'name' => $name,
                'email' => $email,
                'password' => $hashedPassword,
                'role' => 'user',
            ]);
            $message = 'Akun Pelanggan berhasil dibuat! Silakan masuk.';
        }

        return redirect('/login')->with('success', $message);
    }

    public function forgotPassword(Request $request)
    {
        $request->validate(['email' => 'required|email', 'password' => 'required|min:6']);
        $user = User::where('email', $request->email)->first();

        if (!$user) { return response()->json(['success' => false, 'message' => 'Email tidak ditemukan.'], 404); }

        $user->password = Hash::make($request->password);
        $user->save();

        return response()->json(['success' => true, 'message' => 'Password berhasil diperbarui.']);
    }

    public function updateProfile(Request $request)
    {
        $user = $request->user();
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email,' . $user->id,
            'password' => 'nullable|min:6',
            'photo' => 'nullable|file|image|max:2048',
            'phone' => 'nullable|string|max:20',
        ]);

        $user->name = $request->input('name');
        $user->email = $request->input('email');
        $user->phone = $request->filled('phone') ? $request->input('phone') : null;

        if ($request->filled('password')) { $user->password = Hash::make($request->input('password')); }

        // Mencegah eskalasi hak akses ilegal dari modifikasi request profil
        $user->role = $user->role === 'super_admin' ? 'super_admin' : ($user->role === 'admin' ? 'admin' : 'user');

        if ($request->hasFile('photo')) {
            $photoPath = $request->file('photo')->store('profile_photos', 'public');
            $user->photo = Storage::url($photoPath);
        } elseif ($request->has('photo') && $request->input('photo') !== '') {
            $user->photo = $request->input('photo');
        }

        $user->save();
        return response()->json(['success' => true, 'message' => 'Profil berhasil diperbarui.', 'user' => ['id' => $user->id, 'name' => $user->name, 'email' => $user->email, 'photo' => $user->photo, 'phone' => $user->phone]]);
    }
}