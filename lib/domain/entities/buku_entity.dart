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

  BukuEntity copyWith({
    int? id,
    String? judul,
    String? penulis,
    String? penerbit,
    int? tahunTerbit,
    int? jumlah,
    int? totalSalinan,
    int? stokTersedia,
    String? hurufJudulAwal,
    String? nomorSalinan,
    String? status,
    String? namaKategori,
    int? kategoriId,
    String? namaSubjek,
    int? subjekId,
    String? namaLokasi,
    int? lokasiId,
    String? coverUrl,
    String? deskripsi,
    double? rating,
  }) {
    return BukuEntity(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      penulis: penulis ?? this.penulis,
      penerbit: penerbit ?? this.penerbit,
      tahunTerbit: tahunTerbit ?? this.tahunTerbit,
      jumlah: jumlah ?? this.jumlah,
      totalSalinan: totalSalinan ?? this.totalSalinan,
      stokTersedia: stokTersedia ?? this.stokTersedia,
      hurufJudulAwal: hurufJudulAwal ?? this.hurufJudulAwal,
      nomorSalinan: nomorSalinan ?? this.nomorSalinan,
      status: status ?? this.status,
      namaKategori: namaKategori ?? this.namaKategori,
      kategoriId: kategoriId ?? this.kategoriId,
      namaSubjek: namaSubjek ?? this.namaSubjek,
      subjekId: subjekId ?? this.subjekId,
      namaLokasi: namaLokasi ?? this.namaLokasi,
      lokasiId: lokasiId ?? this.lokasiId,
      coverUrl: coverUrl ?? this.coverUrl,
      deskripsi: deskripsi ?? this.deskripsi,
      rating: rating ?? this.rating,
    );
  }

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
    // Beberapa endpoint (cth. buku populer) membungkus data buku di dalam
    // objek "buku" dan menggunakan "first_buku_id". Gabungkan agar semua
    // field dapat diambil dari struktur mana pun.
    final nested = json['buku'];
    final Map<String, dynamic> j =
        nested is Map<String, dynamic> ? {...json, ...nested} : json;

    final kategori = (j['kategori'] ?? json['kategori']) as Map<String, dynamic>?;
    final subjek = (j['subjek'] ?? json['subjek']) as Map<String, dynamic>?;
    final lokasi = (j['lokasi'] ?? json['lokasi']) as Map<String, dynamic>?;

    // Hitung stok & total salinan dari array "salinan" bila tersedia
    // (endpoint detail mengembalikannya). Endpoint populer kini juga
    // mengembalikan stok_tersedia/total_salinan di level atas.
    int? parsedStok;
    int? parsedTotal;
    final salinan = json['salinan'] as List?;
    if (salinan != null) {
      int stok = 0;
      int total = 0;
      for (final s in salinan) {
        final sm = s as Map<String, dynamic>;
        final jumlah = _parseInt(sm['jumlah']);
        total += 1;
        if (sm['status'] == 'aktif') stok += jumlah;
      }
      parsedStok = stok;
      parsedTotal = total;
    }

    // Fallback untuk endpoint lama (jika stok_tersedia tidak ada):
    // gunakan jumlah dari buku nested.
    final jumlahValue = _parseInt(j['jumlah'] ?? json['jumlah']);

    return BukuEntity(
      id: _parseInt(json['id'] ??
          json['first_id'] ??
          json['first_buku_id'] ??
          j['id']),
      judul: j['judul'] as String? ?? json['judul'] as String? ?? '',
      penulis: j['nama_penulis'] as String? ??
          j['penulis'] as String? ??
          json['nama_penulis'] as String? ??
          json['penulis'] as String? ??
          '',
      penerbit: j['penerbit'] as String? ?? json['penerbit'] as String? ?? '',
      tahunTerbit: _parseInt(j['tahun_terbit'] ?? json['tahun_terbit']),
      jumlah: jumlahValue,
      totalSalinan: _parseIntNullable(json['total_salinan']) ?? parsedTotal ?? 1,
      stokTersedia: _parseIntNullable(json['stok_tersedia']) ?? parsedStok ?? (jumlahValue > 0 ? jumlahValue : null),
      hurufJudulAwal:
          j['huruf_judul_awal'] as String? ?? json['huruf_judul_awal'] as String?,
      nomorSalinan: (j['nomor_salinan'] ??
              j['nomorSalinan'] ??
              j['nomor'] ??
              j['copy_number'] ??
              json['nomor_salinan'] ??
              json['nomorSalinan'])
          ?.toString(),
      status: j['status'] as String? ?? json['status'] as String? ?? 'aktif',
      namaKategori: _extractString(kategori) ??
          j['nama_kategori'] as String? ??
          json['nama_kategori'] as String?,
      kategoriId: _extractId(kategori) ??
          _parseIntNullable(j['kategori_id'] ?? json['kategori_id']),
      namaSubjek: _extractString(subjek),
      subjekId: _extractId(subjek),
      namaLokasi: _extractString(lokasi),
      lokasiId: _extractId(lokasi) ??
          _parseIntNullable(j['lokasi_id'] ?? json['lokasi_id']),
      coverUrl: j['cover_url'] as String? ??
          j['gambar'] as String? ??
          j['cover'] as String? ??
          json['cover_url'] as String? ??
          json['gambar'] as String? ??
          json['cover'] as String?,
      deskripsi: j['deskripsi'] as String? ??
          j['sinopsis'] as String? ??
          j['description'] as String? ??
          json['deskripsi'] as String? ??
          json['sinopsis'] as String? ??
          json['description'] as String?,
      rating: (j['rating'] as num?)?.toDouble() ??
          (j['average_rating'] as num?)?.toDouble() ??
          (json['rating'] as num?)?.toDouble() ??
          (json['average_rating'] as num?)?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [id, judul, penulis, penerbit, tahunTerbit, jumlah, status, coverUrl, deskripsi, rating];
}
