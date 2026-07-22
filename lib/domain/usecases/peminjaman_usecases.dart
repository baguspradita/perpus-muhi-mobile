import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/peminjaman_entity.dart';
import '../entities/dashboard_entity.dart';
import '../repositories/peminjaman_repository.dart';

class GetPeminjamanListUseCase {
  final PeminjamanRepository _repository;

  GetPeminjamanListUseCase(this._repository);

  Future<Either<Failure, List<PeminjamanEntity>>> call({
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    return _repository.getPeminjamanList(
      status: status,
      page: page,
      perPage: perPage,
    );
  }
}

class GetRiwayatPeminjamanUseCase {
  final PeminjamanRepository _repository;

  GetRiwayatPeminjamanUseCase(this._repository);

  Future<Either<Failure, List<PeminjamanEntity>>> call({
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    return _repository.getRiwayatPeminjaman(
      status: status,
      page: page,
      perPage: perPage,
    );
  }
}

class GetDashboardUseCase {
  final PeminjamanRepository _repository;

  GetDashboardUseCase(this._repository);

  Future<Either<Failure, DashboardEntity>> call() async {
    return _repository.getDashboard();
  }
}

class CreatePeminjamanUseCase {
  final PeminjamanRepository _repository;

  CreatePeminjamanUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required int userId,
    required List<int> bukuIds,
    required String tglPinjam,
    required String tglJatuhTempo,
  }) async {
    return _repository.createPeminjaman(
      userId: userId,
      bukuIds: bukuIds,
      tglPinjam: tglPinjam,
      tglJatuhTempo: tglJatuhTempo,
    );
  }
}

class KembaliPeminjamanUseCase {
  final PeminjamanRepository _repository;

  KembaliPeminjamanUseCase(this._repository);

  Future<Either<Failure, void>> call(int id) async {
    return _repository.kembaliPeminjaman(id);
  }
}
