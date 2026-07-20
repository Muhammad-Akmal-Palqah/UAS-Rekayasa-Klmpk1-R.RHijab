# Docker Setup untuk rr-hijab-integration

Dokumen ini menjelaskan cara menjalankan Docker untuk:
- MySQL database
- Redis cache
- phpMyAdmin

Tanpa `n8n`.

## 1. Tujuan

Docker Compose pada folder `docker_baru` hanya menjalankan:
- `db` (MySQL 8.0)
- `cache` (Redis 6)
- `phpmyadmin`

Dengan konfigurasi ini, Anda bisa:
- membuka phpMyAdmin di browser
- menjalankan backend Laravel di mesin lokal
- menjalankan frontend Flutter di mesin lokal

## 2. File Docker Compose

Lokasi: `docker_baru/docker-compose.yml`

Isi utamanya:
- MySQL container pada port `3307` host
- Redis container pada port `6380` host
- phpMyAdmin pada port `8081` host

## 3. Jalankan Docker

Buka terminal di folder `docker_baru`:

```powershell
cd c:\Users\POLYTRON\rr-hijab-integration\docker_baru
docker compose up -d
```

Perintah ini akan membuat dan menjalankan ketiga container.

## 4. Akses phpMyAdmin

Buka browser:

```text
http://localhost:8081
```

Login dengan:
- Server: `db`
- Username: `root`
- Password: `rootpassword`

Jika Anda membuka phpMyAdmin dari host, server `db` tetap bisa dipakai karena sudah diatur oleh environment container.

## 5. Konfigurasi Laravel backend

Jika backend tidak dijalankan di dalam container Docker, gunakan konfigurasi database host `127.0.0.1` dan port `3307`.

Contoh `.env` untuk Laravel:

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3307
DB_DATABASE=rrhijab_db
DB_USERNAME=root
DB_PASSWORD=rootpassword

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6380
```

Lalu jalankan di folder `rr-hijab-backend`:

```powershell
cd ..\rr-hijab-backend
composer install --no-interaction --prefer-dist
php artisan key:generate
php artisan migrate --seed
php artisan storage:link
php artisan serve --host=0.0.0.0 --port=8000
```

## 6. Konfigurasi Flutter frontend

Jalankan aplikasi Flutter seperti biasa di folder `frontend`:

```powershell
cd ..\frontend
flutter pub get
flutter clean
flutter pub get
flutter run
```

Jika aplikasi Flutter memerlukan API backend, pastikan URL backend menunjuk ke server Laravel lokal, misalnya:

```text
http://127.0.0.1:8000
```

## 7. Tidak ada n8n

Docker Compose ini tidak memuat layanan `n8n`. Jadi tidak akan membuka atau menjalankan n8n.

Jika Anda ingin menambahkan n8n nanti, layanan tersebut harus ditambahkan secara eksplisit pada file `docker-compose.yml`.

## 8. Perintah tambahan

Periksa status container:

```powershell
docker compose ps
```

Matikan service:

```powershell
docker compose down
```

## 9. Catatan penting

- `phpmyadmin` hanya untuk manajemen database MySQL.
- `db` menggunakan volume `db_data_baru` untuk menyimpan data.
- Port host dibuat berbeda agar tidak tabrakan dengan instalasi lokal lain.
- Jika `php artisan migrate` gagal, cek koneksi database dan pastikan Docker `db` sudah berjalan.

---

File ini dibuat untuk membantu menjalankan Docker di laptop lain dengan fokus database dan phpMyAdmin, tanpa dependency pada `n8n`.