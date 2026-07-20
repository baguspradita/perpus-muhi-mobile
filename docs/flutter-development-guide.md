# 📱 Flutter App — Perpustakaan Muhi

Panduan bertahap pengembangan aplikasi Flutter untuk Perpustakaan Muhi.

---

## 1. Setup Project

### 1.1 Create Project
```bash
flutter create --org com.perpusmuhi perpustakaan_muhi
cd perpustakaan_muhi
```

### 1.2 Add Dependencies
```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  dio: ^5.0.0                    # HTTP client
  flutter_secure_storage: ^9.0.0 # Simpan token
  provider: ^6.0.0               # State management
  intl: ^0.19.0                  # Format tanggal & rupiah
  shimmer: ^3.0.0               # Loading skeleton
  cached_network_image: ^3.3.0   # Cache gambar
  connectivity_plus: ^5.0.0     # Deteksi koneksi
```

```bash
flutter pub get
```

### 1.3 Copy API Client & Models
Copy dari `docs/flutter-api-guide.md` → `lib/`:

```
lib/
├── models/
│   ├── api_response.dart
│   ├── user.dart
│   ├── buku.dart
│   ├── peminjaman.dart
│   └── dashboard.dart
├── services/
│   ├── api_client.dart      # Dio setup + interceptor
│   ├── auth_service.dart
│   ├── buku_service.dart
│   ├── peminjaman_service.dart
│   └── dashboard_service.dart
├── providers/
│   ├── auth_provider.dart
│   ├── buku_provider.dart
│   └── peminjaman_provider.dart
├── screens/
│   ├── splash_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home_screen.dart
│   ├── buku/
│   │   ├── katalog_screen.dart
│   │   └── detail_buku_screen.dart
│   ├── peminjaman/
│   │   └── peminjaman_list_screen.dart
│   ├── riwayat/
│   │   └── riwayat_list_screen.dart
│   ├── profile/
│   │   └── profile_screen.dart
│   └── petugas/                    # Hanya untuk role petugas
│       ├── jurusan_screen.dart
│       ├── kategori_screen.dart
│       ├── subjek_screen.dart
│       ├── lokasi_screen.dart
│       ├── master_buku_screen.dart
│       ├── siswa_screen.dart
│       └── guru_screen.dart
└── widgets/
    ├── buku_card.dart
    ├── loading_shimmer.dart
    └── empty_state.dart
```

---

## 2. Phase 1: Auth & Splash

### Tujuan
Halaman splash, cek token, login & register.

### Screens
| Screen | Route | Auth |
|--------|-------|------|
| `SplashScreen` | `/` | No |
| `LoginScreen` | `/login` | No |
| `RegisterScreen` | `/register` | No |

### File yang dibuat

#### 2.1 `lib/services/auth_service.dart`
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
}
```

#### 2.2 `lib/providers/auth_provider.dart`
```dart
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  String? get error => _error;
  bool get isPetugas => _user?.role == 'petugas';

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.login(email, password);
      if (response['success']) {
        await ApiClient().saveToken(response['data']['token']);
        _user = User.fromJson(response['data']['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Koneksi gagal. Periksa internet Anda.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> checkAuth() async {
    final token = await ApiClient().getToken();
    if (token == null) return;

    try {
      final response = await _authService.getMe();
      if (response['success']) {
        _user = User.fromJson(response['data']['user']);
        notifyListeners();
      }
    } catch (_) {
      await ApiClient().clearToken();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    await ApiClient().clearToken();
    notifyListeners();
  }
}
```

#### 2.3 `lib/screens/splash_screen.dart`
```dart
class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final authProvider = context.read<AuthProvider>();

    await Future.delayed(Duration(seconds: 2)); // Minimal splash
    await authProvider.checkAuth();

    if (!mounted) return;

    if (authProvider.isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', height: 120),
            SizedBox(height: 16),
            Text('Perpustakaan Muhi',
                style: Theme.of(context).textTheme.headlineMedium),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
```

#### 2.4 `lib/screens/auth/login_screen.dart`
```dart
class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else if (authProvider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 60),
                Text('Selamat Datang',
                    style: Theme.of(context).textTheme.headlineSmall),
                SizedBox(height: 8),
                Text('Silakan masuk ke akun Anda'),
                SizedBox(height: 40),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      v!.isEmpty ? 'Email wajib diisi' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v!.isEmpty ? 'Password wajib diisi' : null,
                ),
                SizedBox(height: 24),
                Consumer<AuthProvider>(
                  builder: (context, auth, _) => SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: auth.isLoading ? null : _login,
                      child: auth.isLoading
                          ? CircularProgressIndicator()
                          : Text('Masuk'),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/register'),
                  child: Text('Belum punya akun? Daftar di sini'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

#### 2.5 `lib/screens/auth/register_screen.dart`
```dart
class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Form fields untuk register (role: siswa/guru)
  final _formKey = GlobalKey<FormState>();
  String _role = 'siswa'; // atau 'guru'
  
  // Form controllers
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _noTelpController = TextEditingController();
  final _alamatController = TextEditingController();
  // Siswa-only fields
  final _nisnController = TextEditingController();
  final _kelasController = TextEditingController();
  int? _jurusanId;
  // Guru-only fields
  final _nipController = TextEditingController();
  final _mapelController = TextEditingController();

  List<Map<String, dynamic>> _jurusanList = [];
  bool _isLoadingJurusan = true;

  @override
  void initState() {
    super.initState();
    _loadJurusan();
  }

  Future<void> _loadJurusan() async {
    try {
      final api = ApiClient().dio;
      final response = await api.get('/jurusan/aktif');
      setState(() {
        _jurusanList = List<Map<String, dynamic>>.from(
            response.data['data'] ?? []);
        _isLoadingJurusan = false;
      });
    } catch (_) {
      setState(() => _isLoadingJurusan = false);
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final data = <String, dynamic>{
      'role': _role,
      'nama': _namaController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      'password_confirmation': _passwordConfirmController.text,
      'no_telp': _noTelpController.text.trim(),
      'alamat': _alamatController.text.trim(),
    };

    if (_role == 'siswa') {
      data['nisn'] = _nisnController.text.trim();
      data['jurusan_id'] = _jurusanId;
      data['kelas'] = _kelasController.text.trim();
    } else {
      data['nip'] = _nipController.text.trim();
      data['mapel'] = _mapelController.text.trim();
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(data);

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error ?? 'Registrasi gagal')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daftar Akun')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(key: _formKey, child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown role
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'siswa', label: Text('Siswa')),
                ButtonSegment(value: 'guru', label: Text('Guru')),
              ],
              selected: {_role},
              onSelectionChanged: (v) => setState(() => _role = v.first),
            ),
            SizedBox(height: 16),
            
            // Field umum
            TextFormField(controller: _namaController,
              decoration: InputDecoration(labelText: 'Nama Lengkap'),
              validator: (v) => v!.isEmpty ? 'Nama wajib diisi' : null),
            TextFormField(controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: (v) => v!.isEmpty ? 'Email wajib diisi' : null),
            TextFormField(controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (v) => v!.length < 8 ? 'Min 8 karakter' : null),
            TextFormField(controller: _passwordConfirmController,
              decoration: InputDecoration(labelText: 'Konfirmasi Password'),
              obscureText: true,
              validator: (v) => v != _passwordController.text
                  ? 'Password tidak cocok' : null),
            TextFormField(controller: _noTelpController,
              decoration: InputDecoration(labelText: 'No. Telepon'),
              keyboardType: TextInputType.phone),
            TextFormField(controller: _alamatController,
              decoration: InputDecoration(labelText: 'Alamat'),
              maxLines: 2),
            
            SizedBox(height: 16),

            // Field spesifik role
            if (_role == 'siswa') ...[
              TextFormField(controller: _nisnController,
                decoration: InputDecoration(labelText: 'NISN'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'NISN wajib diisi' : null),
              
              if (_isLoadingJurusan)
                CircularProgressIndicator()
              else
                DropdownButtonFormField<int>(
                  value: _jurusanId,
                  decoration: InputDecoration(labelText: 'Jurusan'),
                  items: _jurusanList.map((j) => DropdownMenuItem(
                    value: j['id'], child: Text(j['nama_jurusan']),
                  )).toList(),
                  onChanged: (v) => setState(() => _jurusanId = v),
                  validator: (v) => v == null ? 'Pilih jurusan' : null,
                ),
              
              DropdownButtonFormField<String>(
                value: null,
                decoration: InputDecoration(labelText: 'Kelas'),
                items: ['10','11','12'].map((k) => DropdownMenuItem(
                  value: k, child: Text('Kelas $k'),
                )).toList(),
                onChanged: (v) => _kelasController.text = v ?? '',
                validator: (v) => v == null ? 'Pilih kelas' : null,
              ),
            ] else ...[
              TextFormField(controller: _nipController,
                decoration: InputDecoration(labelText: 'NIP'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'NIP wajib diisi' : null),
              TextFormField(controller: _mapelController,
                decoration: InputDecoration(labelText: 'Mata Pelajaran')),
            ],

            SizedBox(height: 24),
            Consumer<AuthProvider>(
              builder: (context, auth, _) => SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _register,
                  child: auth.isLoading
                      ? CircularProgressIndicator()
                      : Text('Daftar'),
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _noTelpController.dispose();
    _alamatController.dispose();
    _nisnController.dispose();
    _nipController.dispose();
    _mapelController.dispose();
    _kelasController.dispose();
    super.dispose();
  }
}
```

---

## 3. Phase 2: Dashboard & Katalog

### Tujuan
Halaman utama dengan statistik dan daftar buku.

### Screens
| Screen | Route | Auth |
|--------|-------|------|
| `HomeScreen` | `/home` | Yes |
| `KatalogScreen` | `/katalog` | Yes |
| `DetailBukuScreen` | `/buku/{id}` | Yes |

### File yang dibuat

#### 3.1 `lib/screens/home_screen.dart`
```dart
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Perpustakaan Muhi')),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) => FutureBuilder(
          future: DashboardService().getStats(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            final stats = snapshot.data!;
            return Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Card statistik
                  Row(children: [
                    _StatCard('Total Buku', stats.totalBuku.toString(),
                        Icons.book, Colors.blue),
                    SizedBox(width: 12),
                    _StatCard('Total Anggota', stats.totalAnggota.toString(),
                        Icons.people, Colors.green),
                  ]),
                  SizedBox(height: 12),
                  Row(children: [
                    if (stats.peminjamanAktif != null)
                      _StatCard('Dipinjam', stats.peminjamanAktif.toString(),
                          Icons.library_books, Colors.orange),
                    if (stats.peminjamanTerlambat != null)
                      SizedBox(width: 12),
                    if (stats.peminjamanTerlambat != null)
                      _StatCard('Terlambat', stats.peminjamanTerlambat.toString(),
                          Icons.warning, Colors.red),
                  ]),
                  SizedBox(height: 24),
                  // Menu utama
                  Expanded(child: GridView.count(
                    crossAxisCount: 3,
                    children: [
                      _MenuButton('Katalog', Icons.menu_book, () =>
                          Navigator.pushNamed(context, '/katalog')),
                      _MenuButton('Peminjaman', Icons.history, () {
                        if (auth.isPetugas) {
                          // Petugas bisa akses riwayat all
                        } else {
                          Navigator.pushNamed(context, '/riwayat');
                        }
                      }),
                      _MenuButton('Profile', Icons.person, () =>
                          Navigator.pushNamed(context, '/profile')),
                      if (auth.isPetugas) ...[
                        _MenuButton('Master', Icons.settings, () =>
                            Navigator.pushNamed(context, '/master')),
                        _MenuButton('Anggota', Icons.group, () =>
                            Navigator.pushNamed(context, '/anggota')),
                      ],
                    ],
                  )),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: NavigationBar(
        destinations: [
          NavigationDestination(icon: Icon(Icons.home), label: 'Beranda'),
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'Katalog'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Riwayat'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
        selectedIndex: 0,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  _StatCard(this.title, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              SizedBox(height: 8),
              Text(value, style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold)),
              Text(title, style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  _MenuButton(this.label, this.icon, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: Theme.of(context).primaryColor),
          SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
```

#### 3.2 `lib/screens/buku/katalog_screen.dart`
```dart
class KatalogScreen extends StatefulWidget {
  @override
  State<KatalogScreen> createState() => _KatalogScreenState();
}

class _KatalogScreenState extends State<KatalogScreen> {
  final _searchController = TextEditingController();
  final _bukuService = BukuService();
  List<Buku> _bukuList = [];
  Map<String, dynamic>? _filters;
  int? _selectedKategori;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBuku();
    _loadFilters();
  }

  Future<void> _loadBuku() async {
    setState(() => _isLoading = true);
    try {
      final response = await _bukuService.getBuku(
        kategoriId: _selectedKategori,
        search: _searchController.text.isNotEmpty
            ? _searchController.text : null,
        page: _currentPage,
      );
      // ...set state dengan response
      setState(() => _isLoading = false);
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadFilters() async {
    try {
      _filters = await _bukuService.getFilters();
      setState(() {});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Katalog Buku')),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari judul buku...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadBuku();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onSubmitted: (_) => _loadBuku(),
            ),
          ),

          // Filter chips (kategori)
          if (_filters != null)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 12),
                children: [
                  FilterChip(
                    label: Text('Semua'),
                    selected: _selectedKategori == null,
                    onSelected: (_) {
                      setState(() => _selectedKategori = null);
                      _loadBuku();
                    },
                  ),
                  ...(_filters!['kategori'] as List).map((k) =>
                    Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: FilterChip(
                        label: Text(k['nama_kategori']),
                        selected: _selectedKategori == k['id'],
                        onSelected: (_) {
                          setState(() =>
                              _selectedKategori = k['id']);
                          _loadBuku();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(height: 8),

          // List buku
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _bukuList.isEmpty
                    ? Center(child: Text('Buku tidak ditemukan'))
                    : ListView.builder(
                        itemCount: _bukuList.length,
                        itemBuilder: (context, i) => _BukuListItem(
                          buku: _bukuList[i],
                          onTap: () => Navigator.pushNamed(
                              context, '/buku/${_bukuList[i].firstId}'),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _BukuListItem extends StatelessWidget {
  final Buku buku;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 64,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(Icons.menu_book,
                color: Theme.of(context).primaryColor),
          ),
        ),
        title: Text(buku.judul, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text('${buku.namaPenulis ?? "-"} • Stok: ${buku.stokTersedia}'),
        trailing: Chip(label: Text('${buku.stokTersedia}'), visualDensity: VisualDensity.compact),
        onTap: onTap,
      ),
    );
  }
}
```

#### 3.3 `lib/screens/buku/detail_buku_screen.dart`
```dart
class DetailBukuScreen extends StatefulWidget {
  final int bukuId;
  const DetailBukuScreen({required this.bukuId});

  @override
  State<DetailBukuScreen> createState() => _DetailBukuScreenState();
}

class _DetailBukuScreenState extends State<DetailBukuScreen> {
  Map<String, dynamic>? _buku;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBuku();
  }

  Future<void> _loadBuku() async {
    try {
      final api = ApiClient().dio;
      final response = await api.get('/buku/${widget.bukuId}');
      setState(() {
        _buku = response.data['data'];
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_buku == null) return Scaffold(body: Center(child: Text('Buku tidak ditemukan')));
    
    final b = _buku!;
    return Scaffold(
      appBar: AppBar(title: Text(b['judul'] ?? 'Detail Buku')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover placeholder
            Center(
              child: Container(
                width: 160, height: 220,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.menu_book, size: 64, color: Colors.grey[400]),
              ),
            ),
            SizedBox(height: 16),

            // Info buku
            Text(b['judul'] ?? '', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: 8),
            _InfoRow('Penulis', b['nama_penulis'] ?? '-'),
            _InfoRow('Penerbit', b['penerbit'] ?? '-'),
            _InfoRow('Tahun Terbit', '${b['tahun_terbit'] ?? '-'}'),
            _InfoRow('Kategori', b['kategori']?['nama_kategori'] ?? '-'),
            _InfoRow('Subjek', b['subjek']?['nama_subjek'] ?? '-'),
            _InfoRow('Lokasi', b['lokasi']?['nama_lokasi'] ?? '-'),
            _InfoRow('Status', b['status'] == 'aktif' ? 'Tersedia' : 'Tidak tersedia'),

            SizedBox(height: 16),

            // Daftar salinan
            Text('Daftar Salinan',
                style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: 8),
            ...(b['salinan'] as List? ?? []).map((s) => Card(
              child: ListTile(
                title: Text('Nomor: ${s['nomor_salinan'] ?? '-'}'),
                subtitle: Text('Stok: ${s['jumlah'] ?? 0}'),
                trailing: Chip(
                  label: Text(s['status'] == 'aktif' ? 'Aktif' : 'Nonaktif'),
                  backgroundColor: s['status'] == 'aktif'
                      ? Colors.green[50] : Colors.red[50],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label, style: TextStyle(fontWeight: FontWeight.w500))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
```

---

## 4. Phase 3: Peminjaman & Riwayat

### Tujuan
Lihat peminjaman aktif, riwayat history.

### Screens
| Screen | Route | Auth | Role |
|--------|-------|------|------|
| `PeminjamanScreen` | `/peminjaman` | Yes | All |
| `RiwayatScreen` | `/riwayat` | Yes | Siswa/Guru |
| `RiwayatAllScreen` | `/riwayat-all` | Yes | Petugas |

### `lib/screens/peminjaman/peminjaman_list_screen.dart`
```dart
class PeminjamanListScreen extends StatefulWidget {
  @override
  State<PeminjamanListScreen> createState() => _PeminjamanListScreenState();
}

class _PeminjamanListScreenState extends State<PeminjamanListScreen> {
  final _service = PeminjamanService();
  List<Peminjaman> _list = [];
  String? _filterStatus;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.getPeminjaman(status: _filterStatus);
      setState(() { _list = data; _isLoading = false; });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Peminjaman'),
        actions: [
          PopupMenuButton<String?>(
            icon: Icon(Icons.filter_list),
            onSelected: (v) { setState(() => _filterStatus = v); _load(); },
            itemBuilder: (_) => [
              PopupMenuItem(value: null, child: Text('Semua')),
              PopupMenuItem(value: 'dipinjam', child: Text('Dipinjam')),
              PopupMenuItem(value: 'kembali', child: Text('Kembali')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _list.isEmpty
              ? Center(child: Text('Belum ada peminjaman'))
              : ListView.builder(
                  itemCount: _list.length,
                  itemBuilder: (_, i) => Card(
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: ListTile(
                      title: Text('Pinjam: ${_list[i].tglPinjam}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ..._list[i].detailPeminjaman.map((d) =>
                            Text('• ${d.buku.judul}')
                          ),
                          if (_list[i].pengembalian != null)
                            Text('Kembali: ${_list[i].pengembalian!.tglKembali}'),
                        ],
                      ),
                      trailing: Chip(
                        label: Text(_list[i].status == 'dipinjam' ? 'Dipinjam' : 'Kembali'),
                        backgroundColor: _list[i].status == 'dipinjam'
                            ? Colors.orange[50] : Colors.green[50],
                      ),
                    ),
                  ),
                ),
    );
  }
}
```

---

## 5. Phase 4: Profile

### `lib/screens/profile/profile_screen.dart`
```dart
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final user = auth.user;
          if (user == null) return Center(child: Text('Belum login'));
          
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Avatar
                CircleAvatar(radius: 48, child: Icon(Icons.person, size: 48)),
                SizedBox(height: 12),
                Text(user.nama, style: Theme.of(context).textTheme.titleLarge),
                Chip(label: Text(_roleLabel(user.role))),
                SizedBox(height: 24),
                
                // Info card
                Card(child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(children: [
                    _ProfileRow('Email', user.email),
                    _ProfileRow('No. Telepon', user.noTelp ?? '-'),
                    _ProfileRow('Alamat', user.alamat ?? '-'),
                    if (user.role == 'siswa') ...[
                      Divider(),
                      _ProfileRow('NISN', user.nisn ?? '-'),
                      _ProfileRow('Kelas', user.kelas ?? '-'),
                      _ProfileRow('Jurusan', user.namaJurusan ?? '-'),
                    ],
                    if (user.role == 'guru') ...[
                      Divider(),
                      _ProfileRow('NIP', user.nip ?? '-'),
                      _ProfileRow('Mapel', user.mapel ?? '-'),
                    ],
                  ]),
                )),
                
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showEditProfile(context, user),
                    icon: Icon(Icons.edit),
                    label: Text('Edit Profile'),
                  ),
                ),
                SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showChangePassword(context),
                    icon: Icon(Icons.lock),
                    label: Text('Ubah Password'),
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () async {
                      await auth.logout();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    },
                    icon: Icon(Icons.logout, color: Colors.red),
                    label: Text('Logout', style: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _roleLabel(String role) {
    switch(role) {
      case 'petugas': return 'Petugas Perpustakaan';
      case 'guru': return 'Guru';
      default: return 'Siswa';
    }
  }

  void _showEditProfile(BuildContext context, User user) {
    // Dialog edit profile
  }

  void _showChangePassword(BuildContext context) {
    // Dialog change password
  }
}

class _ProfileRow extends StatelessWidget {
  final String label, value;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: TextStyle(fontWeight: FontWeight.w500))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
```

---

## 6. Phase 5: Petugas Screens (Master Data & Anggota)

### Tujuan
CRUD untuk jurusan, kategori, subjek, lokasi, master buku, siswa, guru.

### Screens
| Screen | Route | Auth | Role |
|--------|-------|------|------|
| `MasterScreen` | `/master` | Yes | Petugas |
| `AnggotaScreen` | `/anggota` | Yes | Petugas |

### Navigasi (hanya petugas)
```dart
// Di home screen - tambahkan menu khusus petugas
if (auth.isPetugas) ...[
  _MenuButton('Master', Icons.settings, () =>
      Navigator.pushNamed(context, '/master')),
  _MenuButton('Anggota', Icons.group, () =>
      Navigator.pushNamed(context, '/anggota')),
]
```

---

## 7. Phase 6: Routes & Main

### `lib/main.dart`
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Perpustakaan Muhi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/':             (context) => SplashScreen(),
        '/login':        (context) => LoginScreen(),
        '/register':     (context) => RegisterScreen(),
        '/home':         (context) => HomeScreen(),
        '/katalog':      (context) => KatalogScreen(),
        '/peminjaman':   (context) => PeminjamanListScreen(),
        '/riwayat':      (context) => RiwayatListScreen(),
        '/profile':      (context) => ProfileScreen(),
        '/master':       (context) => MasterScreen(),
        '/anggota':      (context) => AnggotaScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name?.startsWith('/buku/') == true) {
          final id = int.tryParse(settings.name!.split('/').last) ?? 0;
          return MaterialPageRoute(
            builder: (_) => DetailBukuScreen(bukuId: id),
          );
        }
        return null;
      },
    );
  }
}
```

---

## 8. Checklist Development

> **Legenda:** ✅ = Sudah diimplementasikan | ⬜ = Belum diimplementasikan
>
> **Catatan Arsitektur:** Implementasi aktual di `perpus_mobile/lib` menggunakan
> **Clean Architecture** (`core/`, `data/`, `domain/`, `presentation/`) dengan
> **Riverpod** + **GoRouter** + **GetIt**, berbeda dari struktur flat di panduan ini.
> Nama file di kolom "File" mengacu pada implementasi aktual.

| Phase | Screen | File | Status |
|-------|--------|------|--------|
| **Setup** | Project + Dependencies + API Client | `core/network/api_client.dart`, `core/network/api_response.dart`, `core/constants/*`, `core/theme/*` | ✅ |
| **1. Auth** | SplashScreen | `presentation/pages/splash_page.dart` | ✅ |
| | LoginScreen | `presentation/pages/login_page.dart` | ✅ |
| | RegisterScreen | `presentation/pages/register_page.dart` | ✅ |
| | AuthProvider | `presentation/providers/auth_provider.dart` | ✅ |
| **2. Dashboard** | HomeScreen (statistik + menu) | `presentation/pages/home_page.dart` | ✅ |
| **3. Katalog** | KatalogScreen (search + filter) | `screens/buku/katalog_screen.dart` | ⬜ |
| | DetailBukuScreen | `screens/buku/detail_buku_screen.dart` | ⬜ |
| **4. Peminjaman** | PeminjamanListScreen | `screens/peminjaman/peminjaman_list_screen.dart` | ⬜ |
| | PeminjamanDetailScreen | `screens/peminjaman/peminjaman_detail_screen.dart` | ⬜ |
| **5. Riwayat** | RiwayatListScreen (saya) | `screens/riwayat/riwayat_list_screen.dart` | ⬜ |
| | RiwayatAllScreen (petugas) | `screens/riwayat/riwayat_all_screen.dart` | ⬜ |
| **6. Profile** | ProfileScreen | `screens/profile/profile_screen.dart` | ⬜ |
| | Edit Profile Dialog | `screens/profile/profile_screen.dart` | ⬜ |
| | Change Password Dialog | `screens/profile/profile_screen.dart` | ⬜ |
| **7. Master (Petugas)** | JurusanScreen | `screens/petugas/jurusan_screen.dart` | ⬜ |
| | KategoriScreen | `screens/petugas/kategori_screen.dart` | ⬜ |
| | SubjekScreen | `screens/petugas/subjek_screen.dart` | ⬜ |
| | LokasiScreen | `screens/petugas/lokasi_screen.dart` | ⬜ |
| | MasterBukuScreen | `screens/petugas/master_buku_screen.dart` | ⬜ |
| **8. Anggota (Petugas)** | SiswaScreen | `screens/petugas/siswa_screen.dart` | ⬜ |
| | GuruScreen | `screens/petugas/guru_screen.dart` | ⬜ |

---

## 9. Testing & Deployment

### Testing Flow
1. Jalankan Laravel backend di local: `php artisan serve`
2. Jalankan Flutter: `flutter run -d chrome`
3. Test semua flow: Register → Login → Katalog → Peminjaman → Profile
4. Test petugas flow: Login petugas → Master data → Manajemen anggota

### Build APK
```bash
# Build APK release
flutter build apk --release

# Build AAB (Play Store)
flutter build appbundle --release

# Build Web
flutter build web --release
```

### Production Setup
```dart
// Ganti baseUrl di api_client.dart
static const String baseUrl = 'https://perpustakaan-muhi.example.com/api';
```

---

*Dokumen ini untuk panduan developing Flutter app. Update sesuai progress.*
