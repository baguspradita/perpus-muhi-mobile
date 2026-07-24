import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../../domain/entities/buku_entity.dart';

class BukuRemoteDataSource {
  final ApiClient _apiClient;

  BukuRemoteDataSource(this._apiClient);

  Future<List<BukuEntity>> getAllBuku({
    String? search,
    int? kategoriId,
    int? lokasiId,
    int page = 1,
    int perPage = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (kategoriId != null) queryParams['kategori_id'] = kategoriId;
    if (lokasiId != null) queryParams['lokasi_id'] = lokasiId;

    try {
      final response = await _apiClient.dio.get(
        ApiConstants.buku,
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final items = data['data'] as List? ?? [];
        return items.map((e) => BukuEntity.fromJson(e as Map<String, dynamic>)).toList();
      }

      return [];
    } on DioException {
      rethrow;
    }
  }

  Future<BukuEntity> getBukuById(int id) async {
    try {
      final response = await _apiClient.dio.get('${ApiConstants.buku}/$id');
      final data = response.data;

      if (data is Map<String, dynamic> && data['data'] != null) {
        return BukuEntity.fromJson(data['data'] as Map<String, dynamic>);
      }

      throw ServerException('Data buku tidak ditemukan');
    } on DioException {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getFilters() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.bukuFilters);
      final data = response.data;

      if (data is Map<String, dynamic>) {
        return data['data'] as Map<String, dynamic>? ?? {};
      }

      return {};
    } on DioException {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getJurusanAktif() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.jurusanAktif);
      final data = response.data;

      if (data is Map<String, dynamic> && data['data'] is List) {
        return (data['data'] as List).map((e) => e as Map<String, dynamic>).toList();
      }

      return [];
    } on DioException {
      rethrow;
    }
  }

  Future<List<BukuEntity>> getRekomendasiBuku() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.dashboardRekomendasi);
      final data = response.data;

      if (data is Map<String, dynamic> && data['data'] is List) {
        return (data['data'] as List).map((e) => BukuEntity.fromJson(e as Map<String, dynamic>)).toList();
      }

      return [];
    } on DioException {
      rethrow;
    }
  }

  Future<List<BukuEntity>> getBukuBaru() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.dashboardBukuBaru);
      final data = response.data;

      if (data is Map<String, dynamic> && data['data'] is List) {
        return (data['data'] as List).map((e) => BukuEntity.fromJson(e as Map<String, dynamic>)).toList();
      }

      return [];
    } on DioException {
      rethrow;
    }
  }

  Future<List<BukuEntity>> getBukuPopuler() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.dashboardBukuPopuler);
      final data = response.data;

      if (data is Map<String, dynamic> && data['data'] is List) {
        return (data['data'] as List).map((e) => BukuEntity.fromJson(e as Map<String, dynamic>)).toList();
      }

      return [];
    } on DioException {
      rethrow;
    }
  }
}
