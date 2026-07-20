# 🎨 Rencana Redesign UI/UX — Flutter Mobile Perpustakaan Muhi

> **Status:** Rencana
> **Arsitektur:** Clean Architecture (Riverpod + GoRouter + GetIt)
> **Target:** Tampilan clean, professional, konsisten, UX mudah dipahami
> **Date:** 2026-07-20

---

## 1. Ringkasan Keputusan

| Aspek | Keputusan |
|-------|-----------|
| **Navigasi** | Bottom Navigation Bar (4 tab: Beranda, Katalog, Peminjaman, Profil) |
| **Dark Mode** | Nanti saja |
| **Warna** | Palette baru dengan primary biru tua (#1E40AF) |
| **Prioritas** | Perbaiki screen yang sudah ada dulu, lalu buat screen baru |
| **Register** | 2-step wizard (Step 1: Data Umum, Step 2: Data Role) |
| **Navigation Persistence** | Pakai ShellRoute GoRouter |

---

## 2. Color Palette

| Token | Hex | Kegunaan |
|-------|-----|----------|
| `primary` | `#1E40AF` | Header, tombol utama, nav aktif |
| `primaryLight` | `#3B82F6` | Hover, focus ring, badge |
| `primaryContainer` | `#DBEAFE` | Latar card aksen, icon background |
| `secondary` | `#059669` | Status tersedia, sukses, kembali |
| `secondaryLight` | `#34D399` | Badge sukses ringan |
| `warning` | `#D97706` | Terlambat, deadline, peringatan |
| `warningLight` | `#FCD34D` | Badge warning ringan |
| `error` | `#DC2626` | Error, hapus, denda |
| `errorLight` | `#FCA5A5` | Badge error ringan |
| `background` | `#F8FAFC` | Latar belakang utama |
| `surface` | `#FFFFFF` | Card, input, modals, bottom nav |
| `surfaceVariant` | `#F1F5F9` | Latar card sekunder, hover state |
| `textPrimary` | `#111827` | Teks utama, heading |
| `textSecondary` | `#6B7280` | Label, caption, subtitle |
| `textHint` | `#9CA3AF` | Placeholder |
| `border` | `#E5E7EB` | Border input, card, divider |
| `divider` | `#F3F4F6` | Divider, separator |
| `shadow` | `#0000000D` | Shadow halus (opsi 5%) |

---

## 3. Spacing System

| Token | Value | Kegunaan |
|-------|-------|----------|
| `spacingXs` | 4px | Jarak antar icon + text |
| `spacingSm` | 8px | Jarak antar item kecil |
| `spacingMd` | 12px | Jarak antar komponen |
| `spacingLg` | 16px | Padding card, margin section |
| `spacingXl` | 24px | Padding horizontal screen |
| `spacingXxl` | 32px | Jarak antar section besar |
| `spacingXxxl` | 40px | Spacing header ke konten |

---

## 4. Reusable Widgets

### 4.1 `AppButton`
Location: `presentation/widgets/app_button.dart`

```dart
enum AppButtonType { primary, secondary, outline, danger }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool isLoading;
  final bool isExpanded;
  final IconData? icon;
  
  // Variasi: primary (biru), secondary (hijau), outline (border), danger (merah)
  // Loading: tampilkan CircularProgressIndicator
  // Expanded: width: double.infinity
}
```

### 4.2 `AppCard`
Location: `presentation/widgets/app_card.dart`

```dart
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  
  // Card putih dengan border halus, border-radius 16px
  // Optional onTap dengan hover effect
}
```

### 4.3 `LoadingShimmer`
Location: `presentation/widgets/loading_shimmer.dart`

```dart
class LoadingShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  
  // Skeleton loading dengan efek shimmer
  // Warna: surfaceVariant → surface → surfaceVariant
}
```

### 4.4 `EmptyState`
Location: `presentation/widgets/empty_state.dart`

```dart
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  
  // Ikon besar + judul + subtitle + tombol aksi opsional
  // Digunakan untuk list kosong, error, belum ada data
}
```

### 4.5 `SectionHeader`
Location: `presentation/widgets/section_header.dart`

```dart
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  
  // Header section dengan judul + tombol "Lihat Semua" opsional
}
```

---

## 5. Screen Redesign

### 5.1 Splash Screen
**File:** `presentation/pages/splash_page.dart`

**Saat ini:**
- Ikon default Flutter
- Teks "Perpustakaan Muhi"
- CircularProgressIndicator

**Sesudah:**
```
┌─────────────────────────────┐
│                             │
│         (background)        │
│                             │
│      ┌─────────────┐        │
│      │ Logo Muhi   │        │  ← Fade-in 0-500ms
│      │ (120x120)   │        │
│      └─────────────┘        │
│                             │
│      Perpustakaan Muhi      │  ← Slide-up + fade-in 300-800ms
│   Sistem Manajemen Buku     │
│                             │
│      ○ ○ ● ○ ○             │  ← Loading dots animasi
│                             │
└─────────────────────────────┘
```

**Perubahan:**
- Ganti icon `Icons.library_books_outlined` → `Image.asset('assets/images/logo-muhi.png')`
- Tambah tagline "Sistem Manajemen Buku"
- Ganti CircularProgressIndicator → animasi loading dots
- Tambah `FadeTransition` + `SlideTransition` untuk logo dan teks

**Assets:**
- Copy `web-backend-perpus/public/assets/logo-muhi.png` → `perpus_mobile/assets/images/logo-muhi.png`
- Update `pubspec.yaml` → `flutter.assets: - assets/images/`

---

### 5.2 Login Screen
**File:** `presentation/pages/login_page.dart`

**Saat ini:**
- Header teks biasa "Masuk ke Akun"
- Form email + password
- Error handling + loading sudah ada

**Sesudah:**
```
┌─────────────────────────────┐
│                             │
│   ┌─────────────────────┐   │
│   │  Ilustrasi/Icon     │   │  ← Ikon buku/sekali 120px
│   │  Perpustakaan       │   │     dengan primaryContainer bg
│   └─────────────────────┘   │
│                             │
│   Selamat Datang            │  ← heading1
│   Masuk ke akun Anda        │  ← textSecondary
│                             │
│   ┌─────────────────────┐   │
│   │ 📧 Email            │   │
│   └─────────────────────┘   │
│                             │
│   ┌─────────────────────┐   │
│   │ 🔒 Password 👁     │   │
│   └─────────────────────┘   │
│                             │
│   [ Lupa Password? ]        │  ← right-aligned, primary text
│                             │
│   ┌─────────────────────┐   │
│   │      MASUK          │   │  ← full-width primary button
│   └─────────────────────┘   │
│                             │
│   ┌─────────────────────┐   │
│   │ ⚠️ Error message   │   │  ← errorLight bg + error text
│   └─────────────────────┘   │
│                             │
│   Belum punya akun? Daftar  │  ← link ke register
│                             │
└─────────────────────────────┘
```

**Perubahan:**
- Tambah ilustrasi/icon di atas form (menggunakan `primaryContainer` sebagai background)
- Gunakan `AppButton` untuk tombol Masuk
- Error message tetap dengan `AppColors.error` background
- "Lupa Password?" tetap ada (aktifkan nanti atau sembunyikan)
- Gunakan `AppTypography.heading1` untuk judul

---

### 5.3 Register Screen (2-Step Wizard)
**File:** `presentation/pages/register_page.dart`

**Saat ini:**
- 12+ field tampil sekaligus
- Jurusan pakai text input manual (tidak user-friendly)

**Sesudah: 2-Step Wizard**
```
┌─────────────────────────────┐
│  Step 1 dari 2              │  ← Progress indicator
│  ● ● ○                     │
│                             │
│  Data Diri Anda             │  ← heading2
│                             │
│  ┌─────────────────────┐    │
│  │  Saya: [Siswa] [Guru]│   │  ← ChoiceChip
│  └─────────────────────┘    │
│                             │
│  ┌─────────────────────┐    │
│  │ 📝 Nama Lengkap     │    │
│  └─────────────────────┘    │
│                             │
│  ┌─────────────────────┐    │
│  │ 📧 Email            │    │
│  └─────────────────────┘    │
│                             │
│  ┌─────────────────────┐    │
│  │ 🔒 Password         │    │
│  └─────────────────────┘    │
│                             │
│  ┌─────────────────────┐    │
│  │ 🔒 Konfirmasi Pass  │    │
│  └─────────────────────┘    │
│                             │
│  ┌─────────────────────┐    │
│  │ 📱 No. Telepon      │    │
│  └─────────────────────┘    │
│                             │
│  ┌─────────────────────┐    │
│  │ 📍 Alamat           │    │
│  └─────────────────────┘    │
│                             │
│  ┌─────────────────────┐    │
│  │      LANJUT →       │    │  ← primary button
│  └─────────────────────┘    │
│                             │
│  Sudah punya akun? Masuk    │
│                             │
└─────────────────────────────┘

         ↓ ↓ ↓ Step 2 ↓ ↓ ↓

┌─────────────────────────────┐
│  Step 2 dari 2              │
│  ● ● ●                     │
│                             │
│  Data Spesifik (Siswa)      │  ← heading2
│                             │
│  ┌─────────────────────┐    │
│  │ 🔢 NISN             │    │
│  └─────────────────────┘    │
│                             │
│  ┌─────────────────────┐    │
│  │ 🎓 Jurusan ▼        │    │  ← DropdownButtonFormField
│  │ 1. Teknik Komputer  │    │     Load dari API /jurusan/aktif
│  │ 2. Akuntansi        │    │
│  │ 3. ...              │    │
│  └─────────────────────┘    │
│                             │
│  ┌─────────────────────┐    │
│  │ 📚 Kelas ▼          │    │  ← Dropdown 10/11/12
│  │ 10 / 11 / 12        │    │
│  └─────────────────────┘    │
│                             │
│  ┌─────────────────────┐    │
│  │    ← KEMBALI  DAFTAR │   │  ← 2 buttons: outline + primary
│  └─────────────────────┘    │
│                             │
└─────────────────────────────┘
```

**Teknis:**
- Simpan state step 1 di provider/variabel sementara
- Step 1 validasi dulu sebelum lanjut ke Step 2
- Step 2 submit semua data ke API sekaligus
- Jurusan load dari API `/jurusan/aktif` (sudah ada di guide)
- Kelas gunakan dropdown (10, 11, 12) bukan text input

---

### 5.4 Home Screen (Redesign Total)
**File:** `presentation/pages/home_page.dart`

**Saat ini:**
- Hanya info akun card

**Sesudah:**
```
┌─────────────────────────────┐
│  Beranda          🔔 (3)    │  ← AppBar dengan notifikasi icon
│                             │
│  Selamat pagi, Ahmad 👋     │  ← Greeting time-aware
│  Siswa • Kelas 11 TKRO      │  ← Role + info singkat
│                             │
│  ┌─────────────────────────┐│
│  │  📊 Ringkasan           ││
│  │                         ││
│  │  ┌─────┐  ┌─────┐     ││
│  │  │ 📚  │  │ ⏰  │     ││  ← Stat cards
│  │  │  2  │  │  0  │     ││     Dipinjam (warning bg)
│  │  │Dipinjam│Terlambat│  ││     Terlambat (error bg)
│  │  └─────┘  └─────┘     ││
│  └─────────────────────────┘│
│                             │
│  Menu Utama                 │  ← SectionHeader
│  ┌─────┐ ┌─────┐ ┌─────┐  │
│  │ 📚  │ │ 📖  │ │ 📋  │  │
│  │Katalog│Peminjaman│Riwayat││  ← Grid menu 3 kolom
│  └─────┘ └─────┘ └─────┘  │
│                             │
│  ┌─────┐                   │
│  │ 👤  │                   │
│  │Profil│                   │
│  └─────┘                   │
│                             │
│  [Petugas only: Master]     │  ← Muncul jika role petugas
│                             │
└─────────────────────────────┘
         │                    │
┌────────┴────────────────────┴────────┐
│ 🏠     📚     📖     👤              │
│ Beranda Katalog Peminjaman Profil     │  ← Bottom Nav Bar
└──────────────────────────────────────┘
```

**Perubahan:**
- Greeting time-aware: "Selamat pagi/siang/sore/malam, {nama}"
- Tambah badge notifikasi di AppBar (jika ada notif baru)
- Stat cards: 2 kolom (Dipinjam + Terlambat) dengan warna sesuai
- Grid menu: 3 kolom, icon + label
- Menu khusus petugas (Master) hanya tampil jika role = petugas
- Bottom Navigation Bar di bawah (dari ShellRoute)

---

## 6. Bottom Navigation + ShellRoute

### 6.1 Struktur Navigasi
```
Tab 1: 🏠 Beranda (/home)
Tab 2: 📚 Katalog (/katalog)
Tab 3: 📖 Peminjaman (/peminjaman)
Tab 4: 👤 Profil (/profil)
```

### 6.2 ShellRoute Implementation
**File:** `core/routes/app_router.dart`

```dart
ShellRoute(
  builder: (context, state, child) => ScaffoldWithNavBar(child: child),
  routes: [
    GoRoute(path: '/home', builder: ...),
    GoRoute(path: '/katalog', builder: ...),
    GoRoute(path: '/peminjaman', builder: ...),
    GoRoute(path: '/profil', builder: ...),
  ],
)
```

### 6.3 ScaffoldWithNavBar Widget
**File:** `presentation/widgets/scaffold_with_nav_bar.dart`

```dart
class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;
  
  // Scaffold dengan BottomNavigationBar
  // Index aktif berdasarkan lokasi GoRouter
  // Badge notifikasi di tab Peminjaman (jika ada)
}
```

---

## 7. Struktur File yang Dibuat/Update

```
perpus_mobile/
├── assets/
│   └── images/
│       └── logo-muhi.png              ← COPY dari web-backend-perpus
├── lib/
│   ├── core/
│   │   └── theme/
│   │       ├── app_colors.dart        ← UPDATE palette
│   │       ├── app_spacing.dart       ← BARU
│   │       └── app_theme.dart         ← UPDATE sesuai palette
│   │   └── routes/
│   │       └── app_router.dart        ← UPDATE: tambah ShellRoute
│   └── presentation/
│       ├── pages/
│       │   ├── splash_page.dart       ← UPDATE: animasi + logo
│       │   ├── login_page.dart        ← UPDATE: ilustrasi + polish
│       │   ├── register_page.dart     ← UPDATE: 2-step wizard
│       │   └── home_page.dart         ← UPDATE: redesign total
│       └── widgets/
│           ├── app_button.dart        ← BARU
│           ├── app_card.dart          ← BARU
│           ├── loading_shimmer.dart   ← BARU
│           ├── empty_state.dart       ← BARU
│           ├── section_header.dart    ← BARU
│           └── scaffold_with_nav_bar.dart ← BARU
├── pubspec.yaml                       ← UPDATE: assets
└── docs/
    ├── flutter-development-guide.md   ← PINDAH dari web-backend-perpus
    ├── flutter-api-guide.md           ← PINDAH dari web-backend-perpus
    └── flutter-ui-redesign-plan.md    ← FILE INI
```

---

## 8. Urutan Pengerjaan

| No | Task | File | Prioritas |
|----|------|------|-----------|
| 1 | Copy logo + update pubspec | `assets/images/logo-muhi.png`, `pubspec.yaml` | Tinggi |
| 2 | Update color palette & spacing | `app_colors.dart`, `app_spacing.dart`, `app_theme.dart` | Tinggi |
| 3 | Buat reusable widgets | `app_button.dart`, `app_card.dart`, `loading_shimmer.dart`, `empty_state.dart` | Tinggi |
| 4 | Perbaiki Splash (animasi + logo) | `splash_page.dart` | Sedang |
| 5 | Perbaiki Login (ilustrasi + polish) | `login_page.dart` | Sedang |
| 6 | Register → 2-step wizard + jurusan dropdown | `register_page.dart` | Besar |
| 7 | Home redesign (greeting + stats + grid menu) | `home_page.dart` | Besar |
| 8 | ShellRoute + Bottom Nav | `app_router.dart` + `scaffold_with_nav_bar.dart` | Sedang |

---

## 9. Verifikasi

- [ ] Logo tampil di Splash dengan animasi fade-in
- [ ] Login: ilustrasi muncul, form rapi, error handling jalan
- [ ] Register: step 1 → step 2, jurusan load dari API, submit berhasil
- [ ] Home: greeting time-aware, stat cards, grid menu
- [ ] Bottom Nav: 4 tab, scroll position persist, badge notif
- [ ] Semua widget reusable konsisten (AppButton, AppCard, dll)
- [ ] Tidak ada warning/error di IDE

---

*Dokumen ini untuk panduan redesign UI/UX Flutter mobile. Update sesuai progress.*
