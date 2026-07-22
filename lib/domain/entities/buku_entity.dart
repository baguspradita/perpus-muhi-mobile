import 'package:equatable/equatable.dart';

class BukuEntity extends Equatable {
  final int id;
  final String judul;
  final String penulis;
  final String penerbit;
  final int tahunTerbit;
  final int jumlah;
  final String? hurufJudulAwal;
  final String? nomorSalinan;
  final String status;
  final String? namaKategori;
  final String? namaSubjek;
  final String? namaLokasi;

  const BukuEntity({
    required this.id,
    required this.judul,
    required this.penulis,
    required this.penerbit,
    required this.tahunTerbit,
    required this.jumlah,
    this.hurufJudulAwal,
    this.nomorSalinan,
    this.status = 'tersedia',
    this.namaKategori,
    this.namaSubjek,
    this.namaLokasi,
  });

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String? _extractString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map<String, dynamic>) {
      return value['nama_kategori'] as String? ??
          value['nama_subjek'] as String? ??
          value['nama_lokasi'] as String? ??
          value['nama'] as String?;
    }
    return value.toString();
  }

  factory BukuEntity.fromJson(Map<String, dynamic> json) {
    final kategori = json['kategori'];
    final subjek = json['subjek'];
    final lokasi = json['lokasi'];

    return BukuEntity(
      id: _parseInt(json['id'] ?? json['first_id']),
      judul: json['judul'] as String? ?? '',
      penulis: json['nama_penulis'] as String? ?? json['penulis'] as String? ?? '',
      penerbit: json['penerbit'] as String? ?? '',
      tahunTerbit: _parseInt(json['tahun_terbit']),
      jumlah: _parseInt(json['jumlah'] ?? json['total_salinan']),
      hurufJudulAwal: json['huruf_judul_awal'] as String?,
      nomorSalinan: json['nomor_salinan'] as String?,
      status: json['status'] as String? ?? 'tersedia',
      namaKategori: _extractString(kategori),
      namaSubjek: _extractString(subjek),
      namaLokasi: _extractString(lokasi),
    );
  }

  @override
  List<Object?> get props => [id, judul, penulis, penerbit, tahunTerbit, jumlah, status];
}
