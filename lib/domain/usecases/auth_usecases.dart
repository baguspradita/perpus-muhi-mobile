import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/auth_token_entity.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<Either<Failure, AuthTokenEntity>> call({
    required String email,
    required String password,
  }) async {
    return _repository.login(email: email, password: password);
  }
}

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<Either<Failure, AuthTokenEntity>> call({
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
  }) async {
    return _repository.register(
      nama: nama,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
      noTelp: noTelp,
      alamat: alamat,
      role: role,
      nisn: nisn,
      jurusanId: jurusanId,
      kelas: kelas,
      nip: nip,
      mapel: mapel,
    );
  }
}

class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  Future<Either<Failure, void>> call() async {
    return _repository.logout();
  }
}

class GetProfileUseCase {
  final AuthRepository _repository;

  GetProfileUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call() async {
    return _repository.getProfile();
  }
}

class AutoLoginUseCase {
  final AuthRepository _repository;

  AutoLoginUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call() async {
    return _repository.getProfile();
  }
}