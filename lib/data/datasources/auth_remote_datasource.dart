import 'package:dio/dio.dart';

import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/auth_token_entity.dart';
import '../../domain/entities/user_entity.dart';

class AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSource(this._apiClient);

  Future<AuthTokenEntity> _handleAuthResponse(String path, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        path,
        data: data,
        options: Options(validateStatus: (s) => s != null && s < 500),
      );

      final body = response.data;
      if (body == null) throw ServerException('Response kosong dari server');

      final success = body['success'] as bool? ?? false;
      if (!success) {
        final errors = body['errors'] as Map<String, dynamic>?;
        if (errors != null && errors.isNotEmpty) {
          throw ValidationException(
            body['message'] as String? ?? 'Validation Error',
            errors: errors,
            statusCode: response.statusCode,
          );
        }
        throw ServerException(body['message'] as String? ?? 'Gagal');
      }

      final responseData = body['data'] as Map<String, dynamic>?;
      if (responseData == null) throw ServerException('Data tidak ditemukan');

      return AuthTokenEntity(
        accessToken: responseData['token'] as String? ?? '',
        tokenType: 'bearer',
        expiresIn: 3600,
      );
    } on ServerException {
      rethrow;
    } on ValidationException {
      rethrow;
    }
  }

  Future<AuthTokenEntity> register({
    required String nama,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String noTelp,
    required String alamat,
    required String role,
    String? nisn,
    String? jurusanId,
    String? kelas,
    String? nip,
    String? mapel,
  }) async {
    final formData = <String, dynamic>{
      'nama': nama,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'no_telp': noTelp,
      'alamat': alamat,
      'role': role,
    };

    if (role == 'siswa') {
      formData['nisn'] = nisn;
      formData['jurusan_id'] = jurusanId;
      formData['kelas'] = kelas;
    } else {
      formData['nip'] = nip;
      formData['mapel'] = mapel;
    }

    return _handleAuthResponse('/auth/register', formData);
  }

  Future<AuthTokenEntity> login({
    required String email,
    required String password,
  }) async {
    return _handleAuthResponse('/auth/login', {
      'email': email,
      'password': password,
    });
  }

  Future<void> logout(String token) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/auth/logout',
        data: {'token': token},
      );

      final body = response.data;
      if (body == null) throw ServerException('Response kosong dari server');

      final success = body['success'] as bool? ?? false;
      if (!success) throw ServerException(body['message'] as String? ?? 'Gagal');
    } on ServerException {
      rethrow;
    } on DioException {
      rethrow;
    }
  }

  Future<UserEntity?> getCurrentUser() async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>('/auth/me');
      final body = response.data;
      if (body == null) return null;

      final success = body['success'] as bool? ?? false;
      if (!success) return null;

      final responseData = body['data'] as Map<String, dynamic>?;
      if (responseData == null) return null;

      final userData = responseData['user'] as Map<String, dynamic>?;
      if (userData == null) return null;

      return UserEntity.fromJson({'user': userData});
    } on DioException {
      rethrow;
    }
  }
}
