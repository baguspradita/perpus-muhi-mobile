import 'package:flutter/foundation.dart' show kIsWeb;

abstract class ApiConstants {
  static const String _host = '127.0.0.1';
  static const int _port = 8000;

  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:$_port/api';
    }
    return 'http://$_host:$_port/api';
  }

  static String get hostUrl {
    return 'http://$_host:$_port';
  }

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String profile = '/profile';
  static const String profilePassword = '/profile/password';

  static const String bukuFilters = '/buku/filters';
  static const String buku = '/buku';
  static const String jurusanAktif = '/jurusan/aktif';

  static const String peminjaman = '/peminjaman';
  static const String riwayatPeminjaman = '/riwayat-peminjaman';
  static const String riwayatPeminjamanAll = '/riwayat-peminjaman-all';

  static const String dashboard = '/dashboard';
  static const String dashboardRekomendasi = '/dashboard/rekomendasi';
  static const String dashboardBukuBaru = '/dashboard/buku-baru';
  static const String dashboardBukuPopuler = '/dashboard/buku-populer';

  static const String jurusan = '/jurusan';
  static const String kategoriBuku = '/kategori-buku';
  static const String subjekBuku = '/subjek-buku';
  static const String lokasi = '/lokasi';
  static const String masterBuku = '/master-buku';
  static const String siswa = '/siswa';
  static const String guru = '/guru';
}
