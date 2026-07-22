import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/profile_repository.dart';

class ShowProfileUseCase {
  final ProfileRepository _repository;

  ShowProfileUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call() async {
    return _repository.show();
  }
}

class UpdateProfileUseCase {
  final ProfileRepository _repository;

  UpdateProfileUseCase(this._repository);

  Future<Either<Failure, UserEntity>> call({
    String? nama,
    String? noTelp,
    String? alamat,
  }) async {
    return _repository.update(
      nama: nama,
      noTelp: noTelp,
      alamat: alamat,
    );
  }
}

class UpdatePasswordUseCase {
  final ProfileRepository _repository;

  UpdatePasswordUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    return _repository.updatePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      newPasswordConfirmation: newPasswordConfirmation,
    );
  }
}
