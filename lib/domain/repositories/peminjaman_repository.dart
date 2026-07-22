import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/peminjaman_entity.dart';
import '../entities/dashboard_entity.dart';

abstract class PeminjamanRepository {
  Future<Either<Failure, List<PeminjamanEntity>>> getPeminjamanList({
    String? status,
    int page = 1,
    int perPage = 20,
  });

  Future<Either<Failure, PeminjamanEntity>> getPeminjamanById(int id);

  Future<Either<Failure, List<PeminjamanEntity>>> getRiwayatPeminjaman({
    String? status,
    int page = 1,
    int perPage = 20,
  });

  Future<Either<Failure, DashboardEntity>> getDashboard();

  Future<Either<Failure, void>> createPeminjaman({
    required int userId,
    required List<int> bukuIds,
    required String tglPinjam,
    required String tglJatuhTempo,
  });

  Future<Either<Failure, void>> kembaliPeminjaman(int id);
}
