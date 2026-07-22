import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../../domain/entities/peminjaman_entity.dart';
import '../../../domain/entities/dashboard_entity.dart';

class PeminjamanRemoteDataSource {
  final ApiClient _apiClient;

  PeminjamanRemoteDataSource(this._apiClient);

  Future<List<PeminjamanEntity>> getPeminjamanList({
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    if (status != null && status.isNotEmpty) queryParams['status'] = status;

    try {
      final response = await _apiClient.dio.get(
        ApiConstants.peminjaman,
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final items = data['data'] as List? ?? [];
        return items.map((e) => PeminjamanEntity.fromJson(e as Map<String, dynamic>)).toList();
      }

      return [];
    } on DioException {
      rethrow;
    }
  }

  Future<PeminjamanEntity> getPeminjamanById(int id) async {
    try {
      final response = await _apiClient.dio.get('${ApiConstants.peminjaman}/$id');
      final data = response.data;

      if (data is Map<String, dynamic> && data['data'] != null) {
        return PeminjamanEntity.fromJson(data['data'] as Map<String, dynamic>);
      }

      throw ServerException('Data peminjaman tidak ditemukan');
    } on DioException {
      rethrow;
    }
  }

  Future<List<PeminjamanEntity>> getRiwayatPeminjaman({
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    if (status != null && status.isNotEmpty) queryParams['status'] = status;

    try {
      final response = await _apiClient.dio.get(
        ApiConstants.riwayatPeminjaman,
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final items = data['data'] as List? ?? [];
        return items.map((e) => PeminjamanEntity.fromJson(e as Map<String, dynamic>)).toList();
      }

      return [];
    } on DioException {
      rethrow;
    }
  }

  Future<DashboardEntity> getDashboard() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.dashboard);
      final data = response.data;

      if (data is Map<String, dynamic> && data['data'] != null) {
        return DashboardEntity.fromJson(data['data'] as Map<String, dynamic>);
      }

      return const DashboardEntity();
    } on DioException {
      rethrow;
    }
  }

  Future<void> createPeminjaman({
    required int userId,
    required List<int> bukuIds,
    required String tglPinjam,
    required String tglJatuhTempo,
  }) async {
    try {
      await _apiClient.dio.post(
        ApiConstants.peminjaman,
        data: {
          'user_id': userId,
          'buku_id': bukuIds,
          'tgl_pinjam': tglPinjam,
          'tgl_jatuh_tempo': tglJatuhTempo,
        },
      );
    } on DioException {
      rethrow;
    }
  }

  Future<void> kembaliPeminjaman(int id) async {
    try {
      await _apiClient.dio.post('${ApiConstants.peminjaman}/$id/kembali');
    } on DioException {
      rethrow;
    }
  }
}
