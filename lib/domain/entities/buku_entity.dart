import 'package:equatable/equatable.dart';

class BukuEntity extends Equatable {
  final int id;
  final String judul;
  final String penulis;
  final String penerbit;
  final int tahunTerbit;
  final int jumlah;
  final int? totalSalinan;
  final int? stokTersedia;
  final String? hurufJudulAwal;
  final String? nomorSalinan;
  final String status;
  final String? namaKategori;
  final int? kategoriId;
  final String? namaSubjek;
  final int? subjekId;
  final String? namaLokasi;
  final int? lokasiId;
  final String? coverUrl;
  final String? deskripsi;
  final double? rating;

  const BukuEntity({
    required this.id,
    required this.judul,
    required this.penulis,
    required this.penerbit,
    required this.tahunTerbit,
    required this.jumlah,
    this.totalSalinan,
    this.stokTersedia,
    this.hurufJudulAwal,
    this.nomorSalinan,
    this.status = 'aktif',
    this.namaKategori,
    this.kategoriId,
    this.namaSubjek,
    this.subjekId,
    this.namaLokasi,
    this.lokasiId,
    this.coverUrl,
    this.deskripsi,
    this.rating,
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
    if (value is String) return int.tryParse(value);
    return null;
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

  static int? _extractId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is Map<String, dynamic>) return value['id'] as int?;
    if (value is String) return int.tryParse(value);
    return null;
  }

  factory BukuEntity.fromJson(Map<String, dynamic> json) {
    final kategori = json['kategori'] as Map<String, dynamic>?;
    final subjek = json['subjek'] as Map<String, dynamic>?;
    final lokasi = json['lokasi'] as Map<String, dynamic>?;

    return BukuEntity(
      id: _parseInt(json['id'] ?? json['first_id']),
      judul: json['judul'] as String? ?? '',
      penulis: json['nama_penulis'] as String? ?? json['penulis'] as String? ?? '',
      penerbit: json['penerbit'] as String? ?? '',
      tahunTerbit: _parseInt(json['tahun_terbit']),
      jumlah: _parseInt(json['jumlah']),
      totalSalinan: _parseIntNullable(json['total_salinan']),
      stokTersedia: _parseIntNullable(json['stok_tersedia']),
      hurufJudulAwal: json['huruf_judul_awal'] as String?,
      nomorSalinan: (json['nomor_salinan'] ?? json['nomorSalinan'] ?? json['nomor'] ?? json['copy_number'])?.toString(),
      status: json['status'] as String? ?? 'aktif',
      namaKategori: _extractString(kategori) ??
          json['nama_kategori'] as String? ??
          json['kategori'] as String?,
      kategoriId: _extractId(kategori),
      namaSubjek: _extractString(subjek),
      subjekId: _extractId(subjek),
      namaLokasi: _extractString(lokasi),
      lokasiId: _extractId(lokasi),
      coverUrl: json['cover_url'] as String? ?? json['gambar'] as String? ?? json['cover'] as String?,
      deskripsi: json['deskripsi'] as String? ?? json['sinopsis'] as String? ?? json['description'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? (json['average_rating'] as num?)?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [id, judul, penulis, penerbit, tahunTerbit, jumlah, status, coverUrl, deskripsi, rating];
}
