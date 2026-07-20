<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class CommentCrudController extends Controller
{
    // 💡 READ KOMENTAR: Menampilkan seluruh komentar ulasan produk di halaman admin web
    public function index(Request $request)
    {
        $search = $request->input('search');

        // Menggunakan Query Builder terpadu untuk join data relasional
        $comments = DB::table('comments')
            ->join(
                'users', 
                'comments.user_id', 
                '=', 
                'users.id'
                )

            ->join(
                'products', 
                'comments.id_produk', 
                '=', 
                'products.id_produk')

            ->select(
                'comments.*', 
                'users.name as user_name', 
                'products.nama_produk as product_name',
                'comments.image_url as comment_image_url'
                )

            ->when($search, function ($query, $search) {
                return $query->where(function ($q) use ($search) {
                    $q->where('users.name', 'like', "%{$search}%")
                      ->orWhere('products.nama_produk', 'like', "%{$search}%")
                      ->orWhere('comments.komentar', 'like', "%{$search}%");
                }); // Mengelompokkan parameter orWhere agar pencarian presisi
            })
            ->orderByDesc('comments.created_at')
            ->paginate(10);

        return view('admin.crud_comments', compact('comments', 'search'));
    }

    // 💡 DESTROY KOMENTAR: Moderasi admin untuk menghapus komentar spam/tidak pantas
    public function destroy($id)
    {
        DB::table('comments')->where('id', $id)->delete();
        return redirect()->route('comment.index')->with('success', 'Komentar berhasil dihapus.');
    }

    public function store(Request $request)
{
    // 1. Validasi input
    $request->validate([
        'id_produk' => 'required',
        'komentar'  => 'required',
        'rating'    => 'required|integer',
        'image'     => 'nullable|image|mimes:jpeg,png,jpg|max:2048',
    ]);

    // 2. CEK DUPLIKASI: Apakah user sudah pernah komentar di produk ini?
    $exists = DB::table('comments')
        ->where('user_id', $request->user()->id)
        ->where('id_produk', $request->id_produk)
        ->exists();

    if ($exists) {
        return response()->json([
            'message' => 'Anda sudah pernah memberikan ulasan untuk produk ini.'
        ], 409); // 409 Conflict: user mencoba melakukan hal yang sudah ada
    }

    // 3. Proses upload foto (jika ada)
    $path = null;
    if ($request->hasFile('image')) {
        $path = $request->file('image')->store('comments', 'public');
    }

    // 4. Simpan data
    DB::table('comments')->insert([
        'user_id'    => $request->user()->id,
        'id_produk'  => $request->id_produk,
        'komentar'   => $request->komentar,
        'rating'     => $request->rating,
        'image_url'  => $path,
        'created_at' => now(),
        'updated_at' => now(),
    ]);

    return response()->json(['message' => 'Ulasan berhasil dikirim.'], 201);
}
public function checkStatus($id_produk, Request $request)
{
    $exists = DB::table('comments')
        ->where('user_id', $request->user()->id)
        ->where('id_produk', $id_produk)
        ->exists();
    return response()->json(['has_commented' => $exists]);
}
}