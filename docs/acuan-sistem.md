# Acuan Sistem Perpustakaan Muhi

## Daftar Isi
- [Arsitektur Aplikasi](#arsitektur-aplikasi)
- [Stack Teknologi](#stack-teknologi)
- [Role & Hak Akses](#role--hak-akses)
- [Autentikasi](#autentikasi)
- [API Endpoints](#api-endpoints)
- [Struktur Database](#struktur-database)
- [Alur Bisnis](#alur-bisnis)
- [Middleware & Keamanan](#middleware--keamanan)
- [Kode Response API](#kode-response-api)
- [Seeder & Data Awal](#seeder--data-awal)

---

## Arsitektur Aplikasi

```
┌──────────────────────────┐
│     Mobile App (Flutter) │ ◄─── HTTP/JSON ───┐
│  perpus_mobile            │                   │
│  - Auth (Login/Register)  │              ┌────┴──────────────┐
│  - Katalog Buku           │              │  Laravel Backend  │
│  - Peminjaman             │              │  (PHP 8.x)        │
│  - Riwayat                │              │                   │
│  - Profil                 │              │  Passport OAuth   │
└──────────────────────────┘              │  API Guard         │
                                          │  Session Guard     │
┌──────────────────────────┐              │  (Web)             │
│   Web Dashboard (Blade)  │ ◄── HTML ────┤                   │
│  - Manajemen Buku        │              │  MySQL Database    │
│  - Manajemen Anggota     │              │  (perpustakaan_muhi)│
│  - Laporan PDF           │              └────────────────────┘
│  - CRUD Master Data      │
└──────────────────────────┘
```

## Stack Teknologi

| Komponen | Teknologi |
|----------|-----------|
| **Backend** | Laravel 11.x (PHP 8.x) |
| **Database** | MySQL 8.x |
| **API Auth** | Laravel Passport (OAuth2) |
| **Web Auth** | Laravel Session |
| **Mobile** | Flutter 3.x (Dart) |
| **State Management** | Riverpod |
| **HTTP Client** | Dio |
| **PDF** | DomPDF (via web) |
| **Caching** | File Cache |

## Role & Hak Akses

| Role | Singkatan | Hak Akses API |
|------|-----------|---------------|
| **Siswa** | `siswa` | Login, Lihat katalog, Pinjam buku, Lihat riwayat/ profil sendiri |
| **Guru** | `guru` | Login, Lihat katalog, Pinjam buku, Lihat riwayat/ profil sendiri |
| **Petugas** | `petugas` | Semua hak + CRUD buku, anggota, master data, laporan, pengembalian |

---

## Autentikasi

### Alur Login (Mobile)

```
┌──────────┐     ┌──────────────┐     ┌──────────┐
│ Flutter  │     │ Laravel API  │     │ Database │
└────┬─────┘     └──────┬───────┘     └────┬─────┘
     │  POST /auth/login │                  │
     │  {email,password} │                  │
     │──────────────────►│                  │
     │                   │  SELECT * FROM   │
     │                   │  users WHERE     │
     │                   │  email = ?       │
     │                   │─────────────────►│
     │                   │◄─────────────────│
     │                   │                  │
     │                   │  Hash::check()   │
     │                   │  isUserActive()  │
     │                   │  createToken()   │
     │                   │                  │
     │  {data:{user,     │                  │
     │   token}}         │                  │
     │◄──────────────────│                  │
     │                   │                  │
     │  Simpan token di  │                  │
     │  SecureStorage    │                  │
     │                   │                  │
     │  GET /auth/me     │                  │
     │  (Bearer token)   │                  │
     │──────────────────►│                  │
     │  {data:{user}}    │                  │
     │◄──────────────────│                  │
     ▼                   ▼                  ▼
  Authenticated       Verified          Queried
```

### Endpoint Auth

| Method | Endpoint | Auth | Deskripsi |
|--------|----------|------|-----------|
| POST | `/api/auth/register` | Publik | Daftar akun baru (siswa/guru) |
| POST | `/api/auth/login` | Publik | Login, dapatkan token |
| POST | `/api/auth/logout` | Token | Logout, revoke token |
| GET | `/api/auth/me` | Token | Ambil profil user saat ini |

### Format Request Login

```json
{
  "email": "admin@mail.com",
  "password": "password"
}
```

### Format Response Login (sukses)

```json
{
  "success": true,
  "message": "Login berhasil",
  "data": {
    "user": {
      "id": 1,
      "nama": "Administrator",
      "email": "admin@mail.com",
      "role": "petugas",
      "no_telp": "081234567890",
      "alamat": "Perpustakaan Muhi"
    },
    "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9..."
  }
}
```

---

## API Endpoints

### 1. Auth (Publik)

| Method | Endpoint | Body | Response |
|--------|----------|------|----------|
| POST | `/api/auth/register` | `{nama, email, password, password_confirmation, no_telp, alamat, role, nisn/jurusan_id/kelas (siswa) \| nip/mapel (guru)}` | 201: `{user, token}` |
| POST | `/api/auth/login` | `{email, password}` | 200: `{user, token}` |
| POST | `/api/auth/logout` | `{}` (Bearer token) | 200: `{message}` |
| GET | `/api/auth/me` | - | 200: `{user}` |

### 2. Profile (Token)

| Method | Endpoint | Body | Deskripsi |
|--------|----------|------|-----------|
| GET | `/api/profile` | - | Lihat profil lengkap |
| PUT | `/api/profile` | `{nama?, no_telp?, alamat?}` | Update profil |
| PUT | `/api/profile/password` | `{current_password, new_password, new_password_confirmation}` | Ganti password |

### 3. Katalog Buku (Publik)

| Method | Endpoint | Query Params | Deskripsi |
|--------|----------|--------------|-----------|
| GET | `/api/buku` | `?search=&kategori_id=&lokasi_id=&page=&per_page=` | Cari & filter buku |
| GET | `/api/buku/{id}` | - | Detail buku |
| GET | `/api/buku/filters` | - | Data filter (kategori, lokasi, dll) |
| GET | `/api/jurusan/aktif` | - | Jurusan aktif (untuk register) |

### 4. Peminjaman (Token)

| Method | Endpoint | Auth | Deskripsi |
|--------|----------|------|-----------|
| GET | `/api/peminjaman` | Token | Daftar peminjaman (filter: `?status=`) |
| GET | `/api/peminjaman/{id}` | Token | Detail peminjaman |
| POST | `/api/peminjaman` | Token+Petugas | Buat peminjaman baru |
| POST | `/api/peminjaman/{id}/kembali` | Token+Petugas | Kembalikan buku |

**Request Buat Peminjaman:**
```json
{
  "user_id": 2,
  "buku_ids": [1, 3],
  "tgl_pinjam": "2026-07-21",
  "tgl_jatuh_tempo": "2026-08-04"
}
```

### 5. Riwayat Peminjaman (Token)

| Method | Endpoint | Auth | Deskripsi |
|--------|----------|------|-----------|
| GET | `/api/riwayat-peminjaman` | Token | Riwayat sendiri |
| GET | `/api/riwayat-peminjaman/{id}` | Token | Detail riwayat sendiri |
| GET | `/api/riwayat-peminjaman-all` | Token+Petugas | Riwayat semua anggota |
| GET | `/api/riwayat-peminjaman-all/{id}` | Token+Petugas | Detail riwayat anggota |

### 6. Dashboard (Token)

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/dashboard` | Statistik: total_buku, total_anggota, buku_dipinjam, peminjaman_aktif, peminjaman_terlambat, dll |

**Response:**
```json
{
  "success": true,
  "data": {
    "total_buku": 1245,
    "total_anggota": 890,
    "buku_dipinjam": 45,
    "peminjaman_aktif": 38,
    "peminjaman_terlambat": 7,
    "total_peminjaman": 560,
    "anggota_siswa": 800,
    "anggota_guru": 90
  }
}
```

### 7. Master Data (Token + Petugas)

#### Jurusan
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/jurusan` | Daftar semua jurusan |
| POST | `/api/jurusan` | Tambah jurusan |
| GET | `/api/jurusan/{id}` | Detail jurusan |
| PUT | `/api/jurusan/{id}` | Edit jurusan |
| DELETE | `/api/jurusan/{id}` | Hapus jurusan |
| PATCH | `/api/jurusan/{id}/status` | Ubah status (aktif/nonaktif) |

#### Kategori Buku
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/kategori-buku` | Daftar kategori |
| POST | `/api/kategori-buku` | Tambah kategori |
| GET/PUT/DELETE | `/api/kategori-buku/{id}` | Detail/Edit/Hapus |
| PATCH | `/api/kategori-buku/{id}/status` | Ubah status |

#### Subjek Buku (DDC)
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/subjek-buku` | Daftar subjek |
| POST | `/api/subjek-buku` | Tambah subjek |
| GET/PUT/DELETE | `/api/subjek-buku/{id}` | Detail/Edit/Hapus |
| PATCH | `/api/subjek-buku/{id}/status` | Ubah status |

#### Lokasi (Rak)
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/lokasi` | Daftar lokasi |
| POST | `/api/lokasi` | Tambah lokasi |
| GET/PUT/DELETE | `/api/lokasi/{id}` | Detail/Edit/Hapus |
| PATCH | `/api/lokasi/{id}/status` | Ubah status |

#### Master Buku
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/master-buku` | Daftar buku (dengan filter) |
| POST | `/api/master-buku` | Tambah buku baru |
| GET | `/api/master-buku/{id}` | Detail buku |
| PUT | `/api/master-buku/{id}` | Edit buku |
| DELETE | `/api/master-buku/{id}` | Hapus buku |
| PATCH | `/api/master-buku/{id}/status` | Aktif/nonaktifkan buku |
| GET | `/api/master-buku/{id}/label` | Cetak label buku (PDF) |

### 8. Manajemen Anggota (Token + Petugas)

#### Siswa
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/siswa` | Daftar siswa |
| GET | `/api/siswa/{id}` | Detail siswa |
| PUT | `/api/siswa/{id}` | Edit data siswa |
| DELETE | `/api/siswa/{id}` | Hapus siswa |
| PATCH | `/api/siswa/{id}/status` | Ubah status (aktif/lulus/keluar) |
| PATCH | `/api/siswa/{id}/quick-status` | Quick toggle status |

#### Guru
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/guru` | Daftar guru |
| POST | `/api/guru` | Tambah guru |
| GET | `/api/guru/{id}` | Detail guru |
| PUT | `/api/guru/{id}` | Edit guru |
| DELETE | `/api/guru/{id}` | Hapus guru |
| PATCH | `/api/guru/{id}/status` | Ubah status |

---

## Struktur Database

### Entity Relationship Diagram

```
users
├─ id, nama, email, password, alamat, no_telp, role
│
├── siswa (role = siswa)
│   ├─ id, user_id, nisn, jurusan_id, kelas, status
│   └── jurusan → id, nama_jurusan, deskripsi, status
│
├── guru (role = guru)
│   └─ id, user_id, nip, mapel, status
│
├── petugas (role = petugas)
│   └─ id, user_id, nip, jabatan, status
│
└── peminjaman
    ├─ id, user_id, tgl_pinjam, tgl_jatuh_tempo, status
    ├── detail_peminjaman
    │   └─ id, peminjaman_id, buku_id, id_eksamplar, jumlah
    │       └── buku → id, judul, nama_penulis, penerbit, tahun_terbit, jumlah, status
    │           ├── kategori_buku → id, nama_kategori, status
    │           ├── subjek_buku → id, kode_ddc, nama_subjek, status
    │           └── lokasi → id, nama_lokasi, status
    └── pengembalian
        └─ id, peminjaman_id, tgl_kembali, denda
```

### Relasi Model

| Model | Table | Relasi |
|-------|-------|--------|
| `User` | `users` | hasOne(Siswa), hasOne(Guru), hasOne(Petugas), hasMany(Peminjaman) |
| `Siswa` | `siswa` | belongsTo(User), belongsTo(Jurusan) |
| `Guru` | `guru` | belongsTo(User) |
| `Petugas` | `petugas` | belongsTo(User) |
| `Jurusan` | `jurusan` | hasMany(Siswa) |
| `Buku` | `buku` | belongsTo(KategoriBuku), belongsTo(SubjekBuku), belongsTo(Lokasi), hasMany(DetailPeminjaman) |
| `KategoriBuku` | `kategori_buku` | hasMany(Buku) |
| `SubjekBuku` | `subjek_buku` | hasMany(Buku) |
| `Lokasi` | `lokasi` | hasMany(Buku) |
| `Peminjaman` | `peminjaman` | belongsTo(User), hasMany(DetailPeminjaman), hasOne(Pengembalian) |
| `DetailPeminjaman` | `detail_peminjaman` | belongsTo(Peminjaman), belongsTo(Buku) |
| `Pengembalian` | `pengembalian` | belongsTo(Peminjaman) |

### Status Field yang Digunakan

| Tabel | Field Status | Nilai |
|-------|-------------|-------|
| `siswa` | `status` | `aktif`, `lulus`, `dikeluarkan`, `pindah` |
| `guru` | `status` | `aktif`, `nonaktif` |
| `petugas` | `status` | `aktif`, `nonaktif` |
| `buku` | `status` | `tersedia`, `dipinjam`, `rusak`, `hilang` |
| `kategori_buku` | `status` | `aktif`, `nonaktif` |
| `subjek_buku` | `status` | `aktif`, `nonaktif` |
| `lokasi` | `status` | `aktif`, `nonaktif` |
| `jurusan` | `status` | `aktif`, `nonaktif` |
| `peminjaman` | `status` | `dipinjam`, `dikembalikan`, `terlambat` |

---

## Alur Bisnis

### 1. Alur Peminjaman Buku

```
Petugas Login ─► Cari Anggota (siswa/guru)
                    │
                    ▼
              Pilih Buku dari Katalog
                    │
                    ▼
              Tentukan Tanggal Pinjam & Jatuh Tempo
                    │
                    ▼
              POST /api/peminjaman
              ────────────────►
              Validasi:
              ├─ User aktif? (status = 'aktif')
              ├─ Buku tersedia? (jumlah > 0)
              └─ Buku aktif? (status = 'tersedia')
                    │
                    ▼
              Simpan Peminjaman (status: 'dipinjam')
              Simpan DetailPeminjaman (buku_ids)
              Kurangi stok tiap buku
                    │
                    ▼
              Response: { peminjaman }
```

### 2. Alur Pengembalian Buku

```
Petugas Login ─► Cari Peminjaman Aktif
                    │
                    ▼
              POST /api/peminjaman/{id}/kembali
              ────────────────►
              Hitung Denda:
              ├─ Terlambat = hari_ini - tgl_jatuh_tempo
              └─ Denda = terlambat × Rp 1.000
                    │
                    ▼
              Update Peminjaman (status: 'dikembalikan')
              Simpan Pengembalian (tgl_kembali, denda)
              Tambah stok tiap buku
                    │
                    ▼
              Response: { tgl_kembali, denda }
```

### 3. Alur Denda

```
Rumus: Denda = max(0, selisih_hari) × Rp 1.000

Contoh:
- Tgl jatuh tempo: 4 Agustus 2026
- Tgl kembali: 10 Agustus 2026
- Terlambat: 6 hari
- Denda: 6 × Rp 1.000 = Rp 6.000
```

Jika buku dikembalikan **tepat waktu** atau **sebelum** jatuh tempo → denda = 0.

### 4. Alur Notifikasi Otomatis

```
Setiap Hari Jam 08:00 (via Scheduler)
                    │
                    ▼
              Cari semua peminjaman dengan
              status 'dipinjam' dan
              tgl_jatuh_tempo < hari_ini
                    │
                    ▼
              Buat notifikasi untuk:
              ├─ Anggota (peminjam)
              │   └─ "Buku [judul] sudah terlambat X hari"
              └─ Petugas
                  └─ "Anggota [nama] terlambat mengembalikan buku"
```

---

## Middleware & Keamanan

### Middleware Pipeline (API)

```
Request API
    │
    ▼
┌─────────────────────────────────────┐
│ HandleCors                          │
│ Origin: localhost:3000, any         │
└──────────────┬──────────────────────┘
               ▼
┌─────────────────────────────────────┐
│ LogApiRequests                      │
│ - Generate UUID (request_id)        │
│ - Log: method, url, ip, user_agent  │
│ - Log response: status, duration    │
└──────────────┬──────────────────────┘
               ▼
┌─────────────────────────────────────┐
│ ThrottleApi                         │
│ - Auth routes: 5 requests/minute    │
│ - Other routes: 60 requests/minute  │
│ - 429: "Terlalu banyak permintaan"  │
└──────────────┬──────────────────────┘
               ▼
     ┌─── [ApiAuth] ───┐  (jika perlu auth)
     │                  │
     ▼                  ▼
 Passport Valid    Invalid/Expired
     │                  │
     ▼                  ▼
  isUserActive()     401 JSON
     │           "Unauthenticated"
     ▼
  Aktif? ──Tidak──► 403 JSON
     │          "Akun tidak aktif..."
     ▼
     ┌── [PetugasOnly] ──┐  (jika perlu petugas)
     │                    │
     ▼                    ▼
  role=petugas       role≠petugas
     │                    │
     ▼                    ▼
  Lanjutkan           403 JSON
                  "Akses ditolak"
```

### Daftar Middleware

| Nama | Class | Fungsi |
|------|-------|--------|
| `auth.api` | `ApiAuth` | Authentikasi via Passport + cek status aktif |
| `petugas` | `PetugasOnly` | Cek role = petugas |
| `log.api` | `LogApiRequests` | Logging request/response API |
| `throttle.api` | `ThrottleApi` | Rate limiting (5 auth, 60 lainnya) |
| `web` | `CheckUserStatus` | Middleware web: logout jika user nonaktif |

---

## Kode Response API

### Format Sukses

```json
{
  "success": true,
  "message": "Login berhasil",
  "data": { ... }
}
```

### Format Error

```json
{
  "success": false,
  "message": "Email atau password salah.",
  "errors": {
    "email": ["Email wajib diisi."]
  }
}
```

### Daftar Kode Status

| Kode | Arti | Contoh Kasus |
|------|------|-------------|
| **200** | OK | Login sukses, data ditemukan |
| **201** | Created | Register sukses |
| **400** | Bad Request | Request tidak valid |
| **401** | Unauthorized | Token salah/kadaluarsa |
| **403** | Forbidden | Bukan petugas, akun tidak aktif |
| **404** | Not Found | Data tidak ditemukan |
| **405** | Method Not Allowed | Method HTTP salah |
| **422** | Validation Error | Input tidak valid |
| **429** | Too Many Requests | Rate limit exceeded |
| **500** | Server Error | Exception tidak terduga |

### Exception Handler (ApiExceptionHandler)

| Exception | Kode | Pesan |
|-----------|------|-------|
| `ValidationException` | 422 | Pesan validasi + detail error |
| `ModelNotFoundException` | 404 | "Data tidak ditemukan." |
| `NotFoundHttpException` | 404 | "Endpoint tidak ditemukan." |
| `MethodNotAllowedHttpException` | 405 | "Method tidak diizinkan." |
| `AuthenticationException` | 401 | "Unauthenticated" |
| `HttpException` | varies | Pesan sesuai exception |
| `Throwable` (generic) | 500 | "Terjadi kesalahan sistem." |

---

## Seeder & Data Awal

### Akun Bawaan (Seeder)

| Email | Password | Role | Nama |
|-------|----------|------|------|
| `admin@mail.com` | `password` | petugas | Administrator |
| `petugas1@mail.com` | `password` | petugas | Petugas Satu |
| `budi@mail.com` | `password` | siswa | Budi Santoso |
| `susi@mail.com` | `password` | siswa | Susi Susanti |
| `ahsanal@mail.com` | `password` | siswa | Ahsan Al-Farisi |
| `dewi@mail.com` | `password` | siswa | Dewi Lestari |
| `drsahmad@mail.com` | `password` | guru | Drs. Ahmad Sahal |

### Data Master (Seeder)

**Jurusan:**
| ID | Nama Jurusan | Status |
|----|-------------|--------|
| 1 | Rekayasa Perangkat Lunak (RPL) | aktif |
| 2 | Teknik Informatika (TI) | aktif |
| 3 | Sistem Informasi (SI) | aktif |
| 4 | Akuntansi (AK) | aktif |
| 5 | Pemasaran (PM) | aktif |

**Kategori Buku:**
| ID | Nama Kategori |
|----|--------------|
| 1 | Fiksi |
| 2 | Sains |
| 3 | Teknologi |
| 4 | Sejarah |

**Lokasi (Rak):**
| ID | Nama Lokasi |
|----|-------------|
| 1 | Rak A1 |
| 2 | Rak A2 |
| 3 | Rak B1 |
| 4 | Rak B2 |
| 5 | Lemari Kaca |

---

## Catatan untuk Development

### Menjalankan Backend

```bash
cd web-backend-perpus

# Install dependencies
composer install

# Copy environment
cp .env.example .env
# (edit .env -> DB_DATABASE=perpustakaan_muhi, DB_USERNAME=root, DB_PASSWORD=)

# Generate key & passport
php artisan key:generate
php artisan passport:install

# Migrate & seed
php artisan migrate:fresh --seed

# Jalankan server
php artisan serve --host=0.0.0.0 --port=8000

# Untuk scheduler (notifikasi otomatis):
php artisan schedule:work
```

### Menjalankan Mobile App

```bash
cd perpus_mobile

# Install dependencies
flutter pub get

# Generate code (jika ada perubahan model)
dart run build_runner build

# Jalankan di emulator/device
flutter run
```

### Jalur File Penting

```
web-backend-perpus/
├── app/
│   ├── Http/
│   │   ├── Controllers/Api/   → Controller untuk Mobile API
│   │   ├── Controllers/        → Controller untuk Web
│   │   └── Middleware/          → Middleware (ApiAuth, PetugasOnly, dll)
│   ├── Models/                 → Semua model Eloquent
│   ├── Traits/                 → ChecksUserStatus, ApiResponse
│   ├── Exceptions/             → ApiExceptionHandler
│   └── Notifications/          → Notifikasi otomatis
├── config/
│   ├── auth.php                → Konfigurasi guard (web, api/passport)
│   ├── passport.php            → Passport keys
│   ├── database.php            → Koneksi database
│   └── cors.php                → CORS
├── database/
│   ├── migrations/             → Semua migration
│   └── seeders/                → Data awal
├── routes/
│   ├── api.php                 → Route API (mobile)
│   └── web.php                 → Route Web (dashboard)
└── storage/logs/
    ├── laravel.log             → Log aplikasi
    └── api-{date}.log          → Log API requests

perpus_mobile/
├── lib/
│   ├── core/                   → Konfigurasi, network, theme, dll
│   ├── data/                   → Data sources & repositories
│   ├── domain/                 → Entities, use cases, repositories
│   └── presentation/           → Providers, pages, widgets
└── pubspec.yaml                → Dependencies Flutter
```

---

> Dokumen ini dibuat sebagai acuan pengembangan sistem Perpustakaan Muhi.
> Update terakhir: 21 Juli 2026
