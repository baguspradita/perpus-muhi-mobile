# 📱 Flutter API Reference — Perpustakaan Muhi

Dokumen ini adalah panduan lengkap untuk Flutter developer mengonsumsi REST API Perpustakaan Muhi.

---

## 1. Setup Dio Client

```dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static const String baseUrl = 'http://10.0.2.2:8000/api'; // Android emulator
  // static const String baseUrl = 'http://localhost:8000/api'; // iOS simulator / web
  
  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await _storage.delete(key: 'token');
          // Navigator.pushReplacement ke LoginScreen
        }
        handler.next(error);
      },
    ));
  }

  Dio get dio => _dio;
}
```

---

## 2. Alur Autentikasi

```
[App Start]
    │
    ├── Cek token di SecureStorage
    │     ├── Ada → GET /api/auth/me → valid? → Dashboard
    │     │                   └── invalid → Login
    │     └── Tidak ada → Login
    │
    ├── Register (opsional, siswa/guru)
    │     ├── GET /api/jurusan/aktif → dropdown jurusan
    │     └── POST /api/auth/register
    │
    ├── Login
    │     └── POST /api/auth/login → simpan token + user
    │
    └── Logout
          └── POST /api/auth/logout → hapus token
```

---

## 3. Endpoint Reference

### 🔓 Public Endpoints (Tanpa Token)

| Method | Endpoint | Keterangan |
|--------|----------|------------|
| `GET` | `/api/jurusan/aktif` | Daftar jurusan untuk dropdown register |
| `GET` | `/api/buku` | Katalog buku (public) |
| `GET` | `/api/buku/{id}` | Detail buku |
| `GET` | `/api/buku/filters` | Filter kategori & subjek |

### 🔒 Authenticated Endpoints (Perlu Token)

#### Auth
| Method | Endpoint | Keterangan | Role |
|--------|----------|------------|------|
| `POST` | `/api/auth/register` | Register siswa/guru | Public |
| `POST` | `/api/auth/login` | Login | Public |
| `POST` | `/api/auth/logout` | Logout | Auth |
| `GET` | `/api/auth/me` | Profil user saat ini | Auth |

#### Profile
| Method | Endpoint | Keterangan |
|--------|----------|------------|
| `GET` | `/api/profile` | Lihat profil |
| `PUT` | `/api/profile` | Update profil |
| `PUT` | `/api/profile/password` | Update password |

#### Peminjaman
| Method | Endpoint | Keterangan | Role |
|--------|----------|------------|------|
| `GET` | `/api/peminjaman` | Daftar peminjaman saya | Siswa/Guru |
| `GET` | `/api/peminjaman/{id}` | Detail peminjaman | Siswa/Guru |
| `POST` | `/api/peminjaman` | Buat peminjaman baru | Petugas |
| `POST` | `/api/peminjaman/{id}/kembali` | Kembalikan buku | Petugas |

#### Riwayat
| Method | Endpoint | Keterangan | Role |
|--------|----------|------------|------|
| `GET` | `/api/riwayat-peminjaman` | Riwayat saya | Siswa/Guru |
| `GET` | `/api/riwayat-peminjaman/{id}` | Detail riwayat saya | Siswa/Guru |
| `GET` | `/api/riwayat-peminjaman-all` | Semua riwayat (dengan statistik) | Petugas |
| `GET` | `/api/riwayat-peminjaman-all/{id}` | Detail riwayat anggota | Petugas |

#### Dashboard
| Method | Endpoint | Keterangan |
|--------|----------|------------|
| `GET` | `/api/dashboard` | Statistik dashboard |

#### Master Data (Petugas Only)
| Method | Endpoint | Keterangan |
|--------|----------|------------|
| `GET/POST/PUT/DELETE` | `/api/jurusan` | CRUD Jurusan |
| `GET/POST/PUT/DELETE` | `/api/kategori-buku` | CRUD Kategori Buku |
| `GET/POST/PUT/DELETE` | `/api/subjek-buku` | CRUD Subjek Buku |
| `GET/POST/PUT/DELETE` | `/api/lokasi` | CRUD Lokasi |
| `GET/POST/PUT/DELETE` | `/api/master-buku` | CRUD Buku |
| `GET` | `/api/master-buku/{id}/label` | Cetak Label Buku |

#### Manajemen Anggota (Petugas Only)
| Method | Endpoint | Keterangan |
|--------|----------|------------|
| `GET/PUT/DELETE` | `/api/siswa` | CRUD Siswa |
| `PATCH` | `/api/siswa/{id}/status` | Update status siswa |
| `PATCH` | `/api/siswa/{id}/quick-status` | Quick update status |
| `GET/POST/PUT/DELETE` | `/api/guru` | CRUD Guru |
| `PATCH` | `/api/guru/{id}/status` | Update status guru |

---

## 4. Dart Models

### Basic Response
```dart
class ApiResponse {
  final bool success;
  final String message;
  final dynamic data;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
      errors: json['errors'] != null 
          ? Map<String, dynamic>.from(json['errors']) 
          : null,
    );
  }
}
```

### Pagination Response
```dart
class Pagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final String? nextPageUrl;
  final String? prevPageUrl;

  Pagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 10,
      total: json['total'] ?? 0,
      nextPageUrl: json['next_page_url'],
      prevPageUrl: json['prev_page_url'],
    );
  }
}
```

### User
```dart
class User {
  final int id;
  final String nama;
  final String email;
  final String role; // 'siswa' | 'guru' | 'petugas'
  final String? noTelp;
  final String? alamat;
  // Siswa fields
  final String? nisn;
  final int? jurusanId;
  final String? namaJurusan;
  final String? kelas;
  final String? statusSiswa;
  // Guru fields
  final String? nip;
  final String? mapel;
  final String? statusGuru;
  // Petugas fields
  final String? nipPetugas;
  final String? jabatan;

  User.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      nama = json['nama'] ?? '',
      email = json['email'] ?? '',
      role = json['role'] ?? '',
      noTelp = json['no_telp'],
      alamat = json['alamat'],
      nisn = json['nisn'],
      jurusanId = json['jurusan_id'],
      namaJurusan = json['nama_jurusan'],
      kelas = json['kelas'],
      statusSiswa = json['status_siswa'],
      nip = json['nip'],
      mapel = json['mapel'],
      statusGuru = json['status_guru'],
      nipPetugas = json['nip_petugas'],
      jabatan = json['jabatan'];
}
```

### Buku
```dart
class Buku {
  final String judul;
  final int firstId;
  final int totalSalinan;
  final int stokTersedia;
  final String? namaPenulis;
  final String? penerbit;
  final int? tahunTerbit;
  final KategoriBuku? kategori;
  final SubjekBuku? subjek;
  final LokasiBuku? lokasi;

  Buku.fromJson(Map<String, dynamic> json)
    : judul = json['judul'] ?? '',
      firstId = json['first_id'] ?? 0,
      totalSalinan = json['total_salinan'] ?? 0,
      stokTersedia = json['stok_tersedia'] ?? 0,
      namaPenulis = json['nama_penulis'],
      penerbit = json['penerbit'],
      tahunTerbit = json['tahun_terbit'],
      kategori = json['kategori'] != null 
          ? KategoriBuku.fromJson(json['kategori']) : null,
      subjek = json['subjek'] != null 
          ? SubjekBuku.fromJson(json['subjek']) : null,
      lokasi = json['lokasi'] != null 
          ? LokasiBuku.fromJson(json['lokasi']) : null;
}

class KategoriBuku {
  final int id;
  final String namaKategori;
  KategoriBuku.fromJson(Map<String, dynamic> json)
    : id = json['id'], namaKategori = json['nama_kategori'] ?? '';
}

class SubjekBuku {
  final int id;
  final String kodeDdc;
  final String namaSubjek;
  SubjekBuku.fromJson(Map<String, dynamic> json)
    : id = json['id'], kodeDdc = json['kode_ddc'] ?? '', 
      namaSubjek = json['nama_subjek'] ?? '';
}

class LokasiBuku {
  final int id;
  final String namaLokasi;
  LokasiBuku.fromJson(Map<String, dynamic> json)
    : id = json['id'], namaLokasi = json['nama_lokasi'] ?? '';
}
```

### Peminjaman
```dart
class Peminjaman {
  final int id;
  final String tglPinjam;
  final String tglJatuhTempo;
  final String status; // 'dipinjam' | 'kembali'
  final UserMinimal user;
  final List<DetailPeminjaman> detailPeminjaman;
  final Pengembalian? pengembalian;

  Peminjaman.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      tglPinjam = json['tgl_pinjam'] ?? '',
      tglJatuhTempo = json['tgl_jatuh_tempo'] ?? '',
      status = json['status'] ?? '',
      user = UserMinimal.fromJson(json['user']),
      detailPeminjaman = (json['detail_peminjaman'] as List? ?? [])
          .map((e) => DetailPeminjaman.fromJson(e)).toList(),
      pengembalian = json['pengembalian'] != null
          ? Pengembalian.fromJson(json['pengembalian']) : null;
}

class DetailPeminjaman {
  final int id;
  final BukuMinimal buku;
  final int jumlah;
  final String? idEksamplar;

  DetailPeminjaman.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      buku = BukuMinimal.fromJson(json['buku']),
      jumlah = json['jumlah'] ?? 1,
      idEksamplar = json['id_eksamplar'];
}

class BukuMinimal {
  final int id;
  final String judul;
  final String? namaPenulis;

  BukuMinimal.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      judul = json['judul'] ?? '',
      namaPenulis = json['nama_penulis'];
}

class Pengembalian {
  final int id;
  final String tglKembali;
  final int denda;

  Pengembalian.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      tglKembali = json['tgl_kembali'] ?? '',
      denda = json['denda'] ?? 0;
}

class UserMinimal {
  final int id;
  final String nama;
  final String role;

  UserMinimal.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      nama = json['nama'] ?? '',
      role = json['role'] ?? '';
}
```

### Dashboard
```dart
class DashboardStats {
  final int totalBuku;
  final int totalAnggota;
  final int totalPeminjaman;
  final int? peminjamanAktif;
  final int? peminjamanTerlambat;

  DashboardStats.fromJson(Map<String, dynamic> json)
    : totalBuku = json['total_buku'] ?? 0,
      totalAnggota = json['total_anggota'] ?? 0,
      totalPeminjaman = json['total_peminjaman'] ?? 0,
      peminjamanAktif = json['peminjaman_aktif'],
      peminjamanTerlambat = json['peminjaman_terlambat'];
}
```

---

## 5. Service Layer Example

### AuthService
```dart
class AuthService {
  final _api = ApiClient().dio;

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _api.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final response = await _api.post('/auth/register', data: data);
    return response.data;
  }

  Future<void> logout() async {
    await _api.post('/auth/logout');
  }

  Future<Map<String, dynamic>> getMe() async {
    final response = await _api.get('/auth/me');
    return response.data;
  }

  Future<void> saveToken(String token) async {
    await const FlutterSecureStorage().write(key: 'token', value: token);
  }

  Future<String?> getToken() async {
    return await const FlutterSecureStorage().read(key: 'token');
  }

  Future<void> clearToken() async {
    await const FlutterSecureStorage().delete(key: 'token');
  }
}
```

### BukuService
```dart
class BukuService {
  final _api = ApiClient().dio;

  Future<List<Buku>> getBuku({int? kategoriId, String? search, int page = 1}) async {
    final response = await _api.get('/buku', queryParameters: {
      if (kategoriId != null) 'kategori_id': kategoriId,
      if (search != null && search.isNotEmpty) 'search': search,
      'page': page,
    });
    
    return (response.data['data'] as List)
        .map((json) => Buku.fromJson(json))
        .toList();
  }

  Future<BukuDetail> getBukuDetail(int id) async {
    final response = await _api.get('/buku/$id');
    return BukuDetail.fromJson(response.data['data']);
  }

  Future<Map<String, dynamic>> getFilters() async {
    final response = await _api.get('/buku/filters');
    return response.data['data'];
  }
}
```

### PeminjamanService
```dart
class PeminjamanService {
  final _api = ApiClient().dio;

  Future<List<Peminjaman>> getPeminjaman({String? status, int page = 1}) async {
    final response = await _api.get('/peminjaman', queryParameters: {
      if (status != null) 'status': status,
      'page': page,
    });
    return (response.data['data'] as List)
        .map((json) => Peminjaman.fromJson(json))
        .toList();
  }

  Future<Peminjaman> getPeminjamanDetail(int id) async {
    final response = await _api.get('/peminjaman/$id');
    return Peminjaman.fromJson(response.data['data']);
  }

  Future<Map<String, dynamic>> createPeminjaman({
    required int userId,
    required List<int> bukuId,
    required String tglPinjam,
    required String tglJatuhTempo,
  }) async {
    final response = await _api.post('/peminjaman', data: {
      'user_id': userId,
      'buku_id': bukuId,
      'tgl_pinjam': tglPinjam,
      'tgl_jatuh_tempo': tglJatuhTempo,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> kembalikan(int peminjamanId) async {
    final response = await _api.post('/peminjaman/$peminjamanId/kembali');
    return response.data;
  }
}
```

### DashboardService
```dart
class DashboardService {
  final _api = ApiClient().dio;

  Future<DashboardStats> getStats() async {
    final response = await _api.get('/dashboard');
    return DashboardStats.fromJson(response.data['data']);
  }
}
```

---

## 6. Error Handling

```dart
// Dio interceptor untuk handle error
_dio.interceptors.add(InterceptorsWrapper(
  onError: (error, handler) async {
    if (error.response?.statusCode == 401) {
      // Token expired/invalid → hapus token, redirect login
      await const FlutterSecureStorage().delete(key: 'token');
      // Navigasi ke login
    }
    
    if (error.response?.statusCode == 422) {
      // Validation error → tampilkan error per-field
      final errors = error.response?.data['errors'];
      if (errors != null) {
        // Parse errors['email'][0] untuk pesan pertama
      }
    }

    if (error.response?.statusCode == 429) {
      // Rate limit → tampilkan "Terlalu banyak request"
    }

    handler.next(error);
  },
));
```

### Status Code Reference

| Code | Artinya | Action Flutter |
|------|---------|----------------|
| 200 | OK | Tampilkan data |
| 201 | Created | Tampilkan notifikasi sukses |
| 400 | Bad Request | Tampilkan pesan error |
| 401 | Unauthenticated | Redirect ke Login |
| 403 | Forbidden | Tampilkan "Akses ditolak" |
| 404 | Not Found | Tampilkan "Data tidak ditemukan" |
| 422 | Validation Error | Tampilkan error per-field |
| 429 | Rate Limited | Tunggu lalu coba lagi |
| 500 | Server Error | Tampilkan "Terjadi kesalahan" |

---

## 7. Navigasi Berdasarkan Role

```dart
// Setelah login, cek role untuk navigasi
if (user.role == 'petugas') {
  // Navigation: Home, Katalog, Peminjaman, Riwayat All, Master, Anggota, Profile
} else {
  // Siswa/Guru: Home, Katalog, Riwayat Saya, Profile
}
```

---

## 8. Format Currency (Rupiah)

```dart
String formatRupiah(int amount) {
  return 'Rp ${amount.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]}.',
  )}';
}
```

---

## 9. Base URL Configuration

```dart
// Berdasarkan environment
enum Env { dev, prod }

class AppConfig {
  static const String _devUrl = 'http://10.0.2.2:8000/api';   // Android emulator
  static const String _prodUrl = 'https://perpustakaan-muhi.example.com/api';

  static String get baseUrl {
    const env = String.fromEnvironment('ENV', defaultValue: 'dev');
    return env == 'prod' ? _prodUrl : _devUrl;
  }
}

// Jalankan dengan:
// flutter run --dart-define=ENV=dev
// flutter run --dart-define=ENV=prod
```

---

## 10. Package Dependencies

```yaml
dependencies:
  dio: ^5.0.0                    # HTTP client
  flutter_secure_storage: ^9.0.0 # Simpan token
  provider: ^6.0.0               # State management (atau riverpod)
  intl: ^0.19.0                  # Format tanggal & rupiah
  shimmer: ^3.0.0               # Loading skeleton
  cached_network_image: ^3.3.0   # Cache gambar
  connectivity_plus: ^5.0.0     # Deteksi koneksi
```

---

## 11. Contoh Halaman Login

```dart
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);

    try {
      final response = await _authService.login(
        _emailController.text,
        _passwordController.text,
      );

      if (response['success']) {
        await _authService.saveToken(response['data']['token']);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Login', style: Theme.of(context).textTheme.headlineMedium),
              SizedBox(height: 32),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Masuk'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RegisterScreen()),
                ),
                child: Text('Belum punya akun? Daftar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

*Document ini untuk konsumsi Flutter developer. Update jika ada perubahan API.*
