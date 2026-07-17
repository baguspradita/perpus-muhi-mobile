import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/auth_token_entity.dart';
import '../../domain/entities/user_entity.dart';

class AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSource(this._apiClient);

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

    final response = await _apiClient.post<Map<String, dynamic>>(
      '/auth/register',
      data: formData,
    );

    if (response.success && response.data != null) {
      final data = response.data!;
      return AuthTokenEntity(
        accessToken: data['data']?['token'] as String? ?? '',
        tokenType: 'bearer',
        expiresIn: 3600,
      );
    }

    throw ServerException(response.message);
  }

  Future<AuthTokenEntity> login({
    required String email,
    required String password,
  }) async {
    final formData = <String, dynamic>{
      'email': email,
      'password': password,
    };

    final response = await _apiClient.post<Map<String, dynamic>>(
      '/auth/login',
      data: formData,
    );

    if (response.success && response.data != null) {
      final data = response.data!;
      return AuthTokenEntity(
        accessToken: data['data']?['token'] as String? ?? '',
        tokenType: 'bearer',
        expiresIn: 3600,
      );
    }

    throw ServerException(response.message);
  }

  Future<void> logout(String token) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/auth/logout',
      data: {'token': token},
    );

    if (!response.success) {
      throw ServerException(response.message);
    }
  }

  Future<UserEntity?> getCurrentUser() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '/auth/me',
    );

    if (response.success && response.data != null) {
      final userData = response.data!['data'] as Map<String, dynamic>?;
      if (userData != null) {
        return UserEntity.fromJson(userData);
      }
    }

    return null;
  }
}