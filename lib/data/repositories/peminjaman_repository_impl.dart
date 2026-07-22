import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/error_handler.dart';
import '../../data/datasources/peminjaman_remote_datasource.dart';
import '../../domain/entities/peminjaman_entity.dart';
import '../../domain/entities/dashboard_entity.dart';
import '../../domain/repositories/peminjaman_repository.dart';

class PeminjamanRepositoryImpl implements PeminjamanRepository {
  final PeminjamanRemoteDataSource _remoteDataSource;

  PeminjamanRepositoryImpl({required PeminjamanRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<PeminjamanEntity>>> getPeminjamanList({
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final list = await _remoteDataSource.getPeminjamanList(status: status, page: page, perPage: perPage);
      return Right(list);
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure('Terjadi kesalahan: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PeminjamanEntity>> getPeminjamanById(int id) async {
    try {
      final item = await _remoteDataSource.getPeminjamanById(id);
      return Right(item);
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure('Terjadi kesalahan: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<PeminjamanEntity>>> getRiwayatPeminjaman({
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final list = await _remoteDataSource.getRiwayatPeminjaman(status: status, page: page, perPage: perPage);
      return Right(list);
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure('Terjadi kesalahan: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, DashboardEntity>> getDashboard() async {
    try {
      final dashboard = await _remoteDataSource.getDashboard();
      return Right(dashboard);
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure('Terjadi kesalahan: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> createPeminjaman({
    required int userId,
    required List<int> bukuIds,
    required String tglPinjam,
    required String tglJatuhTempo,
  }) async {
    try {
      await _remoteDataSource.createPeminjaman(userId: userId, bukuIds: bukuIds, tglPinjam: tglPinjam, tglJatuhTempo: tglJatuhTempo);
      return const Right(null);
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure('Terjadi kesalahan: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> kembaliPeminjaman(int id) async {
    try {
      await _remoteDataSource.kembaliPeminjaman(id);
      return const Right(null);
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure('Terjadi kesalahan: ${e.toString()}'));
    }
  }
}
