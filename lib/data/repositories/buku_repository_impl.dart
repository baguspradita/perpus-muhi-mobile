import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/error_handler.dart';
import '../../data/datasources/buku_remote_datasource.dart';
import '../../domain/entities/buku_entity.dart';
import '../../domain/repositories/buku_repository.dart';

class BukuRepositoryImpl implements BukuRepository {
  final BukuRemoteDataSource _remoteDataSource;

  BukuRepositoryImpl({required BukuRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<BukuEntity>>> getAllBuku({
    String? search,
    int? kategoriId,
    int? lokasiId,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final books = await _remoteDataSource.getAllBuku(
        search: search,
        kategoriId: kategoriId,
        lokasiId: lokasiId,
        page: page,
        perPage: perPage,
      );
      return Right(books);
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure('Terjadi kesalahan: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, BukuEntity>> getBukuById(int id) async {
    try {
      final book = await _remoteDataSource.getBukuById(id);
      return Right(book);
    } on AppException catch (e) {
      return Left(mapExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure('Terjadi kesalahan: ${e.toString()}'));
    }
  }
}
