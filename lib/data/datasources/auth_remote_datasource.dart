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

      // DEBUG: Log full response
      print('=== /auth/me RESPONSE ===');
      print('Status: ${response.statusCode}');
      print('Body keys: ${body?.keys}');
      print('Body: $body');

      if (body == null) {
        print('Body is null');
        return null;
      }

      // Check success - handle both bool and string
      final success = body['success'];
      final isSuccess = success == true || success == 'true';
      if (!isSuccess) {
        print('API returned success=false: $body');
        return null;
      }

      // Extract user data from various possible formats
      final Map<String, dynamic>? userData = _extractUserData(body);

      if (userData == null) {
        print('Could not extract user data from: $body');
        // Fallback: try to parse body directly if it has user-like fields
        if (body.containsKey('id') || body.containsKey('nama') || body.containsKey('email') || body.containsKey('name') || body.containsKey('role')) {
          print('Trying fallback: parse body directly');
          return UserEntity.fromJson({'user': body});
        }
        return null;
      }

      print('Extracted userData: $userData');

      final userEntity = UserEntity.fromJson({'user': userData});
      print('Created UserEntity: nama=${userEntity.nama}, email=${userEntity.email}, role=${userEntity.role}, nisn=${userEntity.nisn}, nip=${userEntity.nip}');

      return userEntity;
    } on DioException catch (e) {
      print('DioException in getCurrentUser: ${e.message}');
      print('Response: ${e.response?.data}');
      rethrow;
    } catch (e, stack) {
      print('Error in getCurrentUser: $e');
      print('Stack: $stack');
      rethrow;
    }
  }

  Map<String, dynamic>? _extractUserData(Map<String, dynamic> body) {
    // Try multiple nested paths in order of likelihood
    
    // 1. data.user
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      final user = data['user'];
      if (user is Map<String, dynamic>) {
        print('Found user in data.user');
        return user;
      }

      // Format 2: data has user fields directly
      if (data.containsKey('id') || data.containsKey('nama') || data.containsKey('email') || data.containsKey('name') || data.containsKey('role')) {
        print('Found user in data directly');
        return data;
      }

      // 2. data.data (double nested)
      final nestedData = data['data'];
      if (nestedData is Map<String, dynamic>) {
        if (nestedData.containsKey('id') || nestedData.containsKey('nama') || nestedData.containsKey('email') || nestedData.containsKey('name') || nestedData.containsKey('role')) {
          print('Found user in data.data');
          return nestedData;
        }
      }
    }

    // 3. user at root
    final rootUser = body['user'];
    if (rootUser is Map<String, dynamic>) {
      print('Found user in root user');
      return rootUser;
    }

    // 4. Check if body itself has user fields
    if (body.containsKey('id') || body.containsKey('nama') || body.containsKey('email') || body.containsKey('name') || body.containsKey('role')) {
      print('Found user fields in body directly');
      return body;
    }

    // 5. Check data.user.data (triple nested)
    if (data is Map<String, dynamic>) {
      final userData = data['user'];
      if (userData is Map<String, dynamic>) {
        final deepData = userData['data'];
        if (deepData is Map<String, dynamic>) {
          if (deepData.containsKey('id') || deepData.containsKey('nama') || deepData.containsKey('email') || deepData.containsKey('name')) {
            print('Found user in data.user.data');
            return deepData;
          }
        }
      }
    }

    // 6. Try data.data.user
    if (data is Map<String, dynamic>) {
      final dataData = data['data'];
      if (dataData is Map<String, dynamic>) {
        final user = dataData['user'];
        if (user is Map<String, dynamic>) {
          print('Found user in data.data.user');
          return user;
        }
      }
    }

    return null;
  }
}
