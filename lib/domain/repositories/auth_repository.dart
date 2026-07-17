import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/auth_token_entity.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthTokenEntity>> register({
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
  });

  Future<Either<Failure, AuthTokenEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, UserEntity>> getProfile();
}