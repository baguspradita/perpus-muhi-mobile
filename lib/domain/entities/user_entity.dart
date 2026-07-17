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
      id: userData['id'] as int? ?? 0,
      nama: userData['nama'] as String? ?? '',
      email: userData['email'] as String? ?? '',
      role: userData['role'] as String? ?? '',
      noTelp: userData['no_telp'] as String?,
      alamat: userData['alamat'] as String?,
      nisn: userData['nisn'] as String?,
      nip: userData['nip'] as String?,
      mapel: userData['mapel'] as String?,
      jurusan: userData['jurusan'] as String?,
      jurusanId: userData['jurusan_id'] as int?,
      kelas: userData['kelas'] as int?,
    );
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