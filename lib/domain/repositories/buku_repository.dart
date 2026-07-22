import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/buku_entity.dart';

abstract class BukuRepository {
  Future<Either<Failure, List<BukuEntity>>> getAllBuku({
    String? search,
    int? kategoriId,
    int? lokasiId,
    int page = 1,
    int perPage = 20,
  });

  Future<Either<Failure, BukuEntity>> getBukuById(int id);

  Future<Either<Failure, Map<String, dynamic>>> getFilters();
}
