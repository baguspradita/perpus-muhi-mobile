import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final String nama;
  final String email;
  final String role;
  final String? noTelp;
  final String? alamat;
  final String? nisn;
  final String? nip;
  final String? mapel;
  final String? jurusan;
  final int? jurusanId;
  final int? kelas;

  const UserEntity({
    required this.id,
    required this.nama,
    required this.email,
    required this.role,
    this.noTelp,
    this.alamat,
    this.nisn,
    this.nip,
    this.mapel,
    this.jurusan,
    this.jurusanId,
    this.kelas,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] as Map<String, dynamic>? ?? json;
    return UserEntity(
      id: _parseInt(userData['id']),
      nama: userData['nama'] as String? ?? '',
      email: userData['email'] as String? ?? '',
      role: userData['role'] as String? ?? '',
      noTelp: userData['no_telp'] as String?,
      alamat: userData['alamat'] as String?,
      nisn: userData['nisn'] as String?,
      nip: userData['nip'] as String?,
      mapel: userData['mapel'] as String?,
      jurusan: userData['jurusan'] as String?,
      jurusanId: _parseIntNullable(userData['jurusan_id']),
      kelas: _parseIntNullable(userData['kelas']),
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'role': role,
      'no_telp': noTelp,
      'alamat': alamat,
      'nisn': nisn,
      'nip': nip,
      'mapel': mapel,
      'jurusan': jurusan,
      'jurusan_id': jurusanId,
      'kelas': kelas,
    };
  }

  @override
  List<Object?> get props => [id, nama, email, role, noTelp, alamat, nisn, nip, mapel, jurusan, jurusanId, kelas];
}