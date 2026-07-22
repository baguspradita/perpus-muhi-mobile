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

  factory BukuEntity.fromJson(Map<String, dynamic> json) {
    return BukuEntity(
      id: _parseInt(json['id']),
      judul: json['judul'] as String? ?? '',
      penulis: json['nama_penulis'] as String? ?? json['penulis'] as String? ?? '',
      penerbit: json['penerbit'] as String? ?? '',
      tahunTerbit: _parseInt(json['tahun_terbit']),
      jumlah: _parseInt(json['jumlah']),
      hurufJudulAwal: json['huruf_judul_awal'] as String?,
      nomorSalinan: json['nomor_salinan'] as String?,
      status: json['status'] as String? ?? 'tersedia',
      namaKategori: json['kategori'] as String? ?? json['nama_kategori'] as String?,
      namaSubjek: json['subjek'] as String? ?? json['nama_subjek'] as String?,
      namaLokasi: json['lokasi'] as String? ?? json['nama_lokasi'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, judul, penulis, penerbit, tahunTerbit, jumlah, status];
}
