import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/buku_entity.dart';
import '../repositories/buku_repository.dart';

class GetAllBukuUseCase {
  final BukuRepository _repository;

  GetAllBukuUseCase(this._repository);

  Future<Either<Failure, List<BukuEntity>>> call({
    String? search,
    int? kategoriId,
    int? lokasiId,
    int page = 1,
    int perPage = 20,
  }) async {
    return _repository.getAllBuku(
      search: search,
      kategoriId: kategoriId,
      lokasiId: lokasiId,
      page: page,
      perPage: perPage,
    );
  }
}

class GetBukuByIdUseCase {
  final BukuRepository _repository;

  GetBukuByIdUseCase(this._repository);

  Future<Either<Failure, BukuEntity>> call(int id) async {
    return _repository.getBukuById(id);
  }
}

class GetFiltersUseCase {
  final BukuRepository _repository;

  GetFiltersUseCase(this._repository);

  Future<Either<Failure, Map<String, dynamic>>> call() async {
    return _repository.getFilters();
  }
}
