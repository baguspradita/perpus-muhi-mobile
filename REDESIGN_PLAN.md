# Rencana Redesain: Perpustakaan Muhi Mobile App

---

## 1. Keputusan Desain (Best Practice untuk Tema Perpustakaan)

### 1.1 Tipografi — **Outfit + DM Sans**
| Peran | Font | Alasan |
|-------|------|--------|
| **Heading/Display** | **Outfit** (Variable: 100-900) | Geometris, modern, karakter kuat tanpa terlalu "desain". Cocok untuk brand perpustakaan modern yang *approachable*. *(Catatan: Satoshi awalnya dipilih namun tidak tersedia di Google Fonts — Outfit sebagai pengganti dengan karakter geometric serupa.)* |
| **Body/UI** | **DM Sans** (Variable: 400-700) | Neutral, legible di ukuran kecil, metrics mirip Outfit → harmonic pairing. Lebih ringan dari Inter. |
| **Angka/Data** | **JetBrains Mono** (tabular-nums) | Monospace untuk statistik, ISBN, tanggal — rata sempurna. |

**Implementasi**: `google_fonts` sudah ada → gunakan `outfit`, `dm_sans`, `jetbrains_mono`. Gunakan variable font (single file, multi-weight).

---

### 1.2 Palet Warna — **Deep Navy + Warm Amber**
```dart
// Primary: Deep Navy (trust, knowledge, academia)
primary: #1A2A4A           // Primary action, app bar, key UI
primaryContainer: #D6E4F0  // Subtle backgrounds, hover states
onPrimary: #FFFFFF

// Accent: Warm Amber (warmth, highlights, CTAs) — single accent only
accent: #D4A843            // Primary CTA, focus ring, active states
accentContainer: #FFF8E7   // Highlight backgrounds
onAccent: #1A2A4A

// Semantic (status only, bukan UI)
success: #059669
warning: #D97706
danger: #DC2626
info: #2563EB

// Neutral Scale (warm gray tinted navy)
surface: #F8FAFC           // Base background
surfaceContainer: #F1F5F9  // Cards, inputs
surfaceVariant: #E2E8F0    // Dividers, disabled
outline: #94A3B8           // Borders
onSurface: #0F172A         // Primary text
onSurfaceVariant: #475569  // Secondary text
```

**Tidak ada dark mode** → palet single-mode, konsisten.

---

### 1.3 Cover Buku — **Generator Prosedural SVG**
| Pendekatan | Keuntungan |
|------------|------------|
| **SVG Generator (Rekomendasi)** | • Konsisten 100% dengan brand<br>• Zero dependency eksternal<br>• Offline-first, instant render<br>• Customizable per genre/kategori<br>• File size < 2KB per cover |
| Picsum/Unsplash | Varietas tapi inkonsisten, butuh network, loading state |

**Desain Template SVG** (3 varian, rotate by book ID):
1. **Spine Minimal** — Garis vertikal + tipografi judul vertikal
2. **Geometric Blocks** — Blok warna navy/amber abstract
3. **Iconic** — Ikon genre (novel, sains, sejarah, dll) + pattern subtle

---

## 2. Scope: Semua Screen (15 Layar)

| Kategori | Layar | Prioritas |
|----------|-------|-----------|
| **Auth** | Splash, Login, Register | P1 |
| **Core** | Home, Katalog, Book Detail | P1 |
| **Peminjaman** | Daftar Pinjaman, Riwayat | P1 |
| **Profile** | Profile, Edit Profile, Change Password, Notifications | P1 |
| **Static** | FAQ, About, Identification | P2 |

---

## 3. Rencana Implementasi 5 Fase

---

### **FASE 1: FONDASI** (Foundation Tokens)
**Target**: Design system tokens yang baru — tidak ada breaking change pada layout.

| Task | File | Detail |
|------|------|--------|
| 1.1 Update `pubspec.yaml` | `pubspec.yaml` | Tambah fonts: Satoshi, DM Sans, JetBrains Mono |
| 1.2 Redefinisi palet warna | `app_colors.dart` | Ganti ke Deep Navy + Amber scale; hapus secondary/tertiary; tambah semantic-only colors |
| 1.3 Typography system baru | `app_typography.dart` | Scale baru: Display/Headline (Satoshi), Body/Label (DM Sans), Data (JetBrains Mono + tabular-nums); tambah weight 500/600 |
| 1.4 Spacing & Radius refine | `app_spacing.dart`, `app_radius.dart` | Optical spacing scale; radius tiers: xs(4)/sm(8)/md(12)/lg(16)/xl(24)/2xl(32) — pill hanya badge |
| 1.5 Theme update | `app_theme.dart` | Apply tokens baru ke `ColorScheme`, `TextTheme`, component themes; tambah `focusRing` color; shadow tinted (navy-based) |
| 1.6 Noise overlay utility | `lib/core/theme/app_effects.dart` (baru) | `NoiseOverlay` widget + `AppGradients` untuk ambient radial gradient |

**Verifikasi**: `flutter analyze` + visual regression pada halaman kosong.

---

### **FASE 2: KOMPONEN INTI** (Core Components)
**Target**: Semua widget reusable mengadopsi bahasa visual baru.

| Task | File | Perubahan Kunci |
|------|------|-----------------|
| 2.1 Button system | `app_button.dart` | 3 varian: **Filled** (navy), **Tonal** (navy 10%), **Text** (navy); radius 16px; **spring press** (scale 0.98); focus ring amber; loading state skeleton |
| 2.2 Input fields | `app_text_field.dart` | Border 1px outline; focus ring amber 2px; label float animation; error inline (bukan snackbar); helper text support |
| 2.3 Badge system | `app_badge.dart` | Square radius 8px; 3 varian: Primary (navy), Accent (amber), Semantic (success/warning/danger); uppercase → sentence case |
| 2.4 Card system | `app_card.dart` (baru) | **Elevation-only** (no border); 3 level: flat (bg only), raised (shadow), outlined (border only); radius 16px |
| 2.5 StatCard redesign | `stat_card.dart` | Icon di lingkaran accent 10% bg; value pakai JetBrains Mono tabular; hapus border; shadow tinted navy |
| 2.6 BookCard redesign | `book_card.dart` | Cover pakai **SVG Generator**; CTA bottom-aligned (pinjam/baca); grid & detail mode konsisten; hero animation ready |
| 2.7 Search Bar | `app_search_bar.dart` | Focus ring; clear button; loading shimmer internal |
| 2.8 Empty/Error/Loading | `empty_state.dart`, `loading_shimmer.dart` | Copy direct (no "Oops!"); shimmer match final layout shape; illustration style konsisten |
| 2.9 Avatar & Chips | `user_avatar.dart`, `category_chips.dart` | Avatar: squircle (radius 24% size); Chips: tonal style, selected = filled navy |

**Verifikasi**: Storybook/widget test per komponen; `flutter test`.

---

### **FASE 3: HALAMAN UTAMA** (Key Screens Layout)
**Target**: Layout asimetris, masonry, visual hierarchy.

| Task | File | Perubahan Kunci |
|------|------|-----------------|
| 3.1 Home Page | `home_page.dart` | **Hero Section**: Greeting + featured book (cover besar, CTA pinjam) — asymmetric<br>**Stats**: 1 wide card + 2 compact (bukan 3 sama)<br>**Sections**: Zigzag 2-col (rekomendasi kiri, buku baru kanan) → alternatif horizontal scroll |
| 3.2 Katalog Screen | `katalog_screen.dart` | **Masonry Grid**: `SliverGridDelegateWithMaxCrossAxisExtent` (max 180px) → tinggi auto<br>**Filter chips**: Tonal style, sticky header saat scroll<br>**Search**: Expandable, focus ring |
| 3.3 Book Detail | `book_detail_screen.dart` | Cover hero (parallax subtle); info hierarchy: judul → penulis → metadata → sinopsis → CTA sticky bottom; related books horizontal |
| 3.4 Peminjaman List & Riwayat | `peminjaman_list_screen.dart`, `riwayat_screen.dart` | List card: cover thumb + info + status badge + CTA (kembalikan/perpanjang); empty state ilustratif |
| 3.5 Profile Screen | `profile_screen.dart` | Header: avatar XL + stats row (dipinjam/riwayat) bottom-aligned; Menu: tonal cards, icon circle accent 10%; Logout: danger tonal |

**Verifikasi**: Hot reload test di device/emulator; cek overflow, accessibility (semantics).

---

### **FASE 4: LAYAR AUTH & STATIS** (Auth & Static Screens)
**Target**: Konsistensi visual end-to-end.

| Task | File | Perubahan Kunci |
|------|------|-----------------|
| 4.1 Splash | `splash_page.dart` | Logo + wordmark (Satoshi); ambient gradient bg; stagger fade-in |
| 4.2 Login & Register | `login_page.dart`, `register_page.dart` | Centered card (max 400px); tonal bg; input focus ring; button filled navy; link text accent amber; illustration/svg decorative |
| 4.3 Notifications | `notification_screen.dart` | List tile: icon leading + content + time trailing; unread = navy bg 5%; empty state ilustratif |
| 4.4 Edit Profile / Change Password | `edit_profile_screen.dart`, `change_password_screen.dart` | Form layout konsisten; validation inline; save button sticky bottom |
| 4.5 FAQ & About | `faq_screen.dart`, `about_screen.dart` | FAQ: expandable list (bukan accordion default); About: brand illustration + version + legal links |
| 4.6 Identification | `identification_screen.dart` | Card layout: QR/barcode user + info; clean, print-ready |

**Verifikasi**: Flow auth end-to-end; form validation; keyboard handling.

---

### **FASE 5: POLISH & ACCESSIBILITY** (Final Polish)
**Target**: Premium feel, a11y compliant, performa.

| Task | Status | Detail |
|------|--------|--------|
| 5.1 **Staggered Entrance** | ✅ | `StaggeredListView` / `StaggeredGridView` wrapper + `StaggerCell` per-item (80ms delay, slide-up + fade, reduce-motion) pada Home, Katalog, Peminjaman |
| 5.2 **Focus System** | ✅ | `FocusTraversalOrder` di root (`ScaffoldWithNavBar`), visible focus ring (amber 2px, offset 2px) via `FocusableAction`, skip-to-content link di app root |
| 5.3 **Shadow & Depth** | ✅ | 6 sisa `Colors.black` diganti `AppColors.shadowPrimary` (navy 10%) di Profile, Book Detail, Book Scroll Widgets |
| 5.4 **Noise Overlay** | ✅ | `NoiseOverlay` (opacity 0.03) diterapkan global via `MaterialApp.builder`; asset `assets/images/noise.png` dibuat |
| 5.5 **Ambient Gradients** | ✅ | `AppGradients.heroCenterRadial` di Home hero, Book Detail hero, Login hero |
| 5.6 **Typography Polish** | ✅ | Data menggunakan `AppTypography.data*` (tabular-nums, JetBrains Mono); heading line-height dipertahankan; `text-wrap: balance` tidak tersedia di Flutter |
| 5.7 **Motion** | ✅ | `AppButton` spring press (`springOut`), bottom sheet spring entrance via `SpringSheet`, reduce-motion respected di semua animasi |
| 5.8 **Icon Audit** | ❌ | Phosphor Icons (duotone) **dicoba** tapi `phosphor_flutter` 2.1.0 inkompatibel dengan Dart 3.12 (`IconData` final). **Dibatalkan**, tetap pakai Material Icons (sudah konsisten) |
| 5.9 **Performance** | ✅ | `const` constructors ditambah; `RepaintBoundary` (via `StaggerCell` dan list items); image caching via `cached_network_image` sudah ada |
| 5.10 **Golden Tests** | ⏭️ | Dilewati (setup butuh env test & deps `golden_toolkit`); verifikasi manual `flutter analyze` + `flutter build web --release` |

**Verifikasi**: Accessibility scanner (flutter_a11y); performance profile (flutter run --profile); golden test pass.

---

## 4. Dependensi Baru (minimal)

| Package | Versi | Alasan |
|---------|-------|--------|
| `google_fonts` | ^6.2.1 | Sudah ada — gunakan untuk Satoshi, DM Sans, JetBrains Mono |
| `phosphor_flutter` | ^2.0.0 | Icon set duotone konsisten |
| `flutter_svg` | ^2.0.10 | Render cover SVG prosedural |
| `animate_do` | ^3.3.4 | Staggered entrance animations (ringan, deklaratif) |

*Tidak migrasi framework/styling library.*

---

## 5. File Baru yang Akan Dibuat

```
lib/core/theme/
├── app_effects.dart          # NoiseOverlay, AppGradients, ShadowTokens
├── app_breakpoints.dart      # Responsive breakpoints (mobile/tablet/desktop)
└── app_motion.dart           # Spring curves, duration tokens

lib/presentation/widgets/
├── procedural_book_cover.dart # SVG Generator (3 template)
├── staggered_list.dart        # StaggeredListView/GridView wrapper
├── focusable_action.dart      # Focus ring wrapper
└── skip_to_content.dart       # Accessibility skip link

lib/presentation/pages/
└── book_detail_screen.dart    # (Jika belum ada, dari katalog_screen.dart extra)
```

---

## 6. Urutan Eksekusi & Review Points

| Fase | Estimasi | Review Point |
|------|----------|--------------|
| 1. Fondasi | 2-3 jam | **Checkpoint 1**: Token konsisten, `flutter analyze` clean, no visual regression pada halaman dummy |
| 2. Komponen | 3-4 jam | **Checkpoint 2**: Widget catalog / storybook — semua komponen render benar di light mode |
| 3. Halaman Utama | 4-5 jam | **Checkpoint 3**: Home, Katalog, Book Detail, Peminjaman — layout responsif, no overflow |
| 4. Auth & Statis | 2-3 jam | **Checkpoint 4**: Flow auth lengkap, form validasi, static pages konsisten |
| 5. Polish | 2-3 jam | **Checkpoint 5 (Final)**: a11y pass, golden test pass, performance OK |

**Total estimasi**: ~13-18 jam kerja.

---

## 7. Catatan Teknis Penting

1. **Backward Compatibility**: Semua widget既有 API (props) dipertahankan — hanya internal visual yang berubah.
2. **Riverpod/Providers**: Tidak terpengaruh — hanya UI layer.
3. **go_router**: Routes tidak berubah.
4. **Testing**: Jalankan `flutter test` setelah setiap fase; tambah widget test untuk komponen baru.
5. **Git Strategy**: Branch `redesign/fase-{1-5}` → PR per fase → merge ke `main` setelah review.

---

## 8. Status Eksekusi

- [x] **Fase 1: Fondasi** — ✅ *Selesai*
  - [x] 1.1 Update `pubspec.yaml` (google_fonts: Outfit, DM Sans, JetBrains Mono)
  - [x] 1.2 Redefinisi palet warna `app_colors.dart` (Deep Navy + Amber)
  - [x] 1.3 Typography system baru `app_typography.dart`
  - [x] 1.4 Spacing & Radius refine (`app_spacing.dart`, `app_radius.dart`)
  - [x] 1.5 Theme update `app_theme.dart`
  - [x] 1.6 Noise overlay utility `app_effects.dart` + bonus `app_breakpoints.dart`, `app_motion.dart`
  - **Catatan**: Satoshi tidak tersedia di Google Fonts → diganti **Outfit** (geometric, karakter serupa). Verifikasi: `flutter analyze` 0 error.
- [x] **Fase 2: Komponen Inti** — ✅ *Selesai*
  - [x] 2.1 Button system (filled/tonal/text + danger, spring press scale 0.98)
  - [x] 2.2 Input fields (border 1px, focus ring amber, helper text)
  - [x] 2.3 Badge system (square 8px, sentence case)
  - [x] 2.4 Card system (elevation-only: flat/raised/outlined)
  - [x] 2.5 StatCard redesign (icon circle accent, JetBrains Mono tabular)
  - [x] 2.6 BookCard redesign (procedural cover generator, info bottom-aligned) + file baru `procedural_book_cover.dart`
  - [x] 2.7 Search Bar (focus ring, clear button, loading internal)
  - [x] 2.8 Empty/Error/Loading states (ilustrasi branded, shimmer composite)
  - [x] 2.9 Avatar & Chips (squircle 24%, tonal style)
  - **Verifikasi**: `flutter analyze` 0 error; `flutter build web --release` sukses. Backward compatibility terjaga via legacy alias.
- [ ] **Fase 3: Halaman Utama** — ✅ *Selesai*
  - [x] 3.1 Home Page: Hero Section asimetris (greeting + featured book cover besar + CTA Pinjam), Stats (1 wide + 2 compact), 3 seksi horizontal scroll
  - [x] 3.2 Katalog Screen: Masonry grid 2-kolom (auto-height), sticky header (search + filter chips), focus ring
  - [x] 3.3 Book Detail: Cover hero (zoom parallax), info hierarchy, related books horizontal ("Buku Serupa"), CTA sticky bottom
  - [x] 3.4 Peminjaman List: Cover thumb prosedural, status badge (AppBadge), CTA "Kembalikan", empty state ilustratif
  - [x] 3.5 Riwayat Screen: Card konsisten, cover prosedural, AppBadge status, empty state ilustratif
  - [x] 3.6 Profile Screen: Avatar XL + stats row bottom-aligned, menu tonal (icon circle accent 10%), Logout danger tonal
  - [x] Bonus: `AppButtonType.accent` (amber CTA) ditambah ke sistem button
  - **Verifikasi**: `flutter analyze` 0 error; `flutter build web --release` sukses. Backward compatibility terjaga.
- [ ] **Fase 4: Auth & Statis** — ✅ *Selesai*
  - [x] 4.1 Splash: ambient radial gradient bg, wordmark (Outfit/Satoshi) via `AppTypography`
  - [x] 4.2 Login & Register: centered card (max 400/480), ambient gradient, decorative book illustration, link text **accent amber**, input focus ring
  - [x] 4.3 Notifications: unread = navy bg 5% (`primary` 0.05) + colored border, empty/error state ilustratif (`EmptyState`)
  - [x] 4.4 Edit Profile / Change Password: form konsisten, validation inline, **save button sticky bottom bar**
  - [x] 4.5 FAQ (expandable) & About: brand illustration, versi chip, **legal links** (Privasi/Syarat/Hubungi)
  - [x] 4.6 Identification: print-ready card (white, border) + **barcode prosedural** dari NISN/NIP
  - **Verifikasi**: `flutter analyze` 0 error; `flutter build web --release` sukses.
- [x] **Fase 5: Polish & Accessibility** — ✅ *Selesai*
  - [x] 5.1 **Staggered Entrance** — `StaggeredListView` / `StaggeredGridView` wrapper + `StaggerCell` per-item (80ms delay, slide-up + fade, reduce-motion) di Home, Katalog, Peminjaman
  - [x] 5.2 **Focus System** — `FocusTraversalOrder` di root (`ScaffoldWithNavBar`), visible focus ring (amber 2px, offset 2px) via `FocusableAction`, skip-to-content link di app root
  - [x] 5.3 **Shadow & Depth** — 6 sisa `Colors.black` diganti `AppColors.shadowPrimary` (navy 10%) di Profile, Book Detail, Book Scroll Widgets
  - [x] 5.4 **Noise Overlay** — `NoiseOverlay` (opacity 0.03) diterapkan global via `MaterialApp.builder`; asset `assets/images/noise.png` dibuat
  - [x] 5.5 **Ambient Gradients** — `AppGradients.heroCenterRadial` di Home hero, Book Detail hero, Login hero
  - [x] 5.6 **Typography Polish** — Data menggunakan `AppTypography.data*` (tabular-nums, JetBrains Mono); heading line-height dipertahankan; `text-wrap: balance` tidak tersedia di Flutter
  - [x] 5.7 **Motion** — `AppButton` spring press (`springOut`), bottom sheet spring entrance via `SpringSheet`, reduce-motion respected di semua animasi
  - [ ] 5.8 **Icon Audit** — Phosphor Icons (duotone) **dicoba** tapi `phosphor_flutter` 2.1.0 inkompatibel dengan Dart 3.12 (`IconData` final). **Dibatalkan**, tetap pakai Material Icons (sudah konsisten)
  - [x] 5.9 **Performance** — `const` constructors ditambah; `RepaintBoundary` (via `StaggerCell` dan list items); image caching via `cached_network_image` sudah ada
  - [ ] 5.10 **Golden Tests** — Dilewati (setup butuh env test & deps `golden_toolkit`); verifikasi manual `flutter analyze` + `flutter build web --release`

---

*Dokumen ini dibuat sebagai panduan implementasi redesign sistematis untuk Perpustakaan Muhi Mobile App.*