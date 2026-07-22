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

  factory PeminjamanEntity.fromJson(Map<String, dynamic> json) {
    final detailsList = json['details'] as List? ?? json['detail_peminjaman'] as List? ?? [];
    return PeminjamanEntity(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      userName: json['user_name'] as String? ?? json['nama'] as String? ?? '',
      userRole: json['user_role'] as String? ?? json['role'] as String?,
      tglPinjam: json['tgl_pinjam'] as String? ?? '',
      tglJatuhTempo: json['tgl_jatuh_tempo'] as String? ?? '',
      tglKembali: json['tgl_kembali'] as String?,
      status: json['status'] as String? ?? '',
      denda: json['denda'] as int?,
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
    return DetailPeminjamanEntity(
      id: json['id'] as int? ?? 0,
      bukuId: json['buku_id'] as int? ?? 0,
      judulBuku: json['judul_buku'] as String? ?? json['judul'] as String? ?? '',
      jumlah: json['jumlah'] as int? ?? 1,
      idEksamplar: json['id_eksamplar'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, bukuId, judulBuku, jumlah];
}
