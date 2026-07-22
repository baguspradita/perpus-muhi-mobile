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

  factory DashboardEntity.fromJson(Map<String, dynamic> json) {
    return DashboardEntity(
      totalBuku: json['total_buku'] as int? ?? 0,
      totalAnggota: json['total_anggota'] as int? ?? 0,
      bukuDipinjam: json['buku_dipinjam'] as int? ?? 0,
      peminjamanAktif: json['peminjaman_aktif'] as int? ?? 0,
      peminjamanTerlambat: json['peminjaman_terlambat'] as int? ?? 0,
      totalPeminjaman: json['total_peminjaman'] as int? ?? 0,
      anggotaSiswa: json['anggota_siswa'] as int? ?? 0,
      anggotaGuru: json['anggota_guru'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [
    totalBuku, totalAnggota, bukuDipinjam, peminjamanAktif,
    peminjamanTerlambat, totalPeminjaman, anggotaSiswa, anggotaGuru,
  ];
}
