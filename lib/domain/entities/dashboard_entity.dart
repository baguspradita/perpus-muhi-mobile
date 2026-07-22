import 'package:equatable/equatable.dart';

class DashboardEntity extends Equatable {
  final int totalBuku;
  final int totalAnggota;
  final int bukuDipinjam;
  final int peminjamanAktif;
  final int peminjamanTerlambat;
  final int totalPeminjaman;
  final int anggotaSiswa;
  final int anggotaGuru;

  const DashboardEntity({
    this.totalBuku = 0,
    this.totalAnggota = 0,
    this.bukuDipinjam = 0,
    this.peminjamanAktif = 0,
    this.peminjamanTerlambat = 0,
    this.totalPeminjaman = 0,
    this.anggotaSiswa = 0,
    this.anggotaGuru = 0,
  });

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  factory DashboardEntity.fromJson(Map<String, dynamic> json) {
    return DashboardEntity(
      totalBuku: _parseInt(json['total_buku']),
      totalAnggota: _parseInt(json['total_anggota']),
      bukuDipinjam: _parseInt(json['buku_dipinjam']),
      peminjamanAktif: _parseInt(json['peminjaman_aktif']),
      peminjamanTerlambat: _parseInt(json['peminjaman_terlambat']),
      totalPeminjaman: _parseInt(json['total_peminjaman']),
      anggotaSiswa: _parseInt(json['anggota_siswa']),
      anggotaGuru: _parseInt(json['anggota_guru']),
    );
  }

  @override
  List<Object?> get props => [
    totalBuku, totalAnggota, bukuDipinjam, peminjamanAktif,
    peminjamanTerlambat, totalPeminjaman, anggotaSiswa, anggotaGuru,
  ];
}
