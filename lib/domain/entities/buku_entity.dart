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

  factory BukuEntity.fromJson(Map<String, dynamic> json) {
    return BukuEntity(
      id: json['id'] as int? ?? 0,
      judul: json['judul'] as String? ?? '',
      penulis: json['nama_penulis'] as String? ?? json['penulis'] as String? ?? '',
      penerbit: json['penerbit'] as String? ?? '',
      tahunTerbit: json['tahun_terbit'] as int? ?? 0,
      jumlah: json['jumlah'] as int? ?? 0,
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
