import 'package:equatable/equatable.dart';

class PeminjamanEntity extends Equatable {
  final int id;
  final int userId;
  final String userName;
  final String? userRole;
  final String tglPinjam;
  final String tglJatuhTempo;
  final String? tglKembali;
  final String status;
  final int? denda;
  final List<DetailPeminjamanEntity> details;

  const PeminjamanEntity({
    required this.id,
    required this.userId,
    required this.userName,
    this.userRole,
    required this.tglPinjam,
    required this.tglJatuhTempo,
    this.tglKembali,
    required this.status,
    this.denda,
    this.details = const [],
  });

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static int? _parseIntNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      if (value.contains('.')) return double.tryParse(value)?.toInt();
      return int.tryParse(value);
    }
    return null;
  }

  factory PeminjamanEntity.fromJson(Map<String, dynamic> json) {
    final detailsList = json['details'] as List? ?? json['detail_peminjaman'] as List? ?? [];
    final user = json['user'] as Map<String, dynamic>?;
    final pengembalian = json['pengembalian'] as Map<String, dynamic>?;
    return PeminjamanEntity(
      id: _parseInt(json['id']),
      userId: _parseInt(user?['id'] ?? json['user_id']),
      userName: user?['nama'] as String? ?? json['user_name'] as String? ?? json['nama'] as String? ?? '',
      userRole: user?['role'] as String? ?? json['user_role'] as String?,
      tglPinjam: json['tgl_pinjam'] as String? ?? '',
      tglJatuhTempo: json['tgl_jatuh_tempo'] as String? ?? '',
      tglKembali: pengembalian?['tgl_kembali'] as String? ?? json['tgl_kembali'] as String?,
      status: json['status'] as String? ?? '',
      denda: pengembalian?['denda'] != null ? _parseIntNullable(pengembalian!['denda']) : _parseIntNullable(json['denda']),
      details: detailsList.map((e) => DetailPeminjamanEntity.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  @override
  List<Object?> get props => [id, userId, userName, tglPinjam, status];

  static const int _dendaPerHari = 1000;

  int hitungDenda() {
    // 1. Sudah dikembalikan → denda sudah lunas
    if (tglKembali != null) return 0;

    // 2. Status kembali → denda sudah lunas
    final s = status.toLowerCase();
    if (s == 'kembali' || s == 'dikembalikan' || s == 'selesai') return 0;

    // 3. Cek denda dari API (untuk buku terlambat yang belum kembali)
    final apiDenda = denda ?? 0;
    if (apiDenda > 0) return apiDenda;

    // 4. Hitung manual dari keterlambatan
    if (tglJatuhTempo.isEmpty) return 0;

    final now = DateTime.now();
    final jatuhTempo = DateTime.tryParse(tglJatuhTempo);
    if (jatuhTempo == null) return 0;

    final today = DateTime(now.year, now.month, now.day);
    final jatuh = DateTime(jatuhTempo.year, jatuhTempo.month, jatuhTempo.day);

    if (today.isAfter(jatuh)) {
      final hariTerlambat = today.difference(jatuh).inDays;
      return hariTerlambat * _dendaPerHari;
    }

    return 0;
  }
}

class DetailPeminjamanEntity extends Equatable {
  final int id;
  final int bukuId;
  final String judulBuku;
  final int jumlah;
  final String? idEksamplar;

  const DetailPeminjamanEntity({
    required this.id,
    required this.bukuId,
    required this.judulBuku,
    required this.jumlah,
    this.idEksamplar,
  });

  factory DetailPeminjamanEntity.fromJson(Map<String, dynamic> json) {
    final buku = json['buku'] as Map<String, dynamic>?;
    return DetailPeminjamanEntity(
      id: json['id'] as int? ?? 0,
      bukuId: json['buku_id'] as int? ?? 0,
      judulBuku: buku?['judul'] as String? ?? json['judul_buku'] as String? ?? '',
      jumlah: json['jumlah'] as int? ?? 1,
      idEksamplar: json['id_eksamplar'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, bukuId, judulBuku, jumlah];
}
