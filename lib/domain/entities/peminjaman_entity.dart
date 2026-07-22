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
