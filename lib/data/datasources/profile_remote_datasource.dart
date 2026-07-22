import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../domain/entities/user_entity.dart';

class ProfileRemoteDataSource {
  final ApiClient _apiClient;

  ProfileRemoteDataSource(this._apiClient);

  Future<UserEntity> show() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConstants.profile,
    );

    if (response.success && response.data != null) {
      final userData = response.data!['data'] as Map<String, dynamic>?;
      if (userData != null) {
        return UserEntity.fromJson({'user': userData});
      }
    }

    throw Exception(response.message);
  }

  Future<UserEntity> update({
    String? nama,
    String? noTelp,
    String? alamat,
  }) async {
    final body = <String, dynamic>{};
    if (nama != null) body['nama'] = nama;
    if (noTelp != null) body['no_telp'] = noTelp;
    if (alamat != null) body['alamat'] = alamat;

    final response = await _apiClient.put<Map<String, dynamic>>(
      ApiConstants.profile,
      data: body,
    );

    if (response.success && response.data != null) {
      final userData = response.data!['data'] as Map<String, dynamic>?;
      if (userData != null) {
        return UserEntity.fromJson({'user': userData});
      }
    }

    throw Exception(response.message);
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    final response = await _apiClient.put(
      ApiConstants.profilePassword,
      data: {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPasswordConfirmation,
      },
    );

    if (!response.success) {
      throw Exception(response.message);
    }
  }
}
