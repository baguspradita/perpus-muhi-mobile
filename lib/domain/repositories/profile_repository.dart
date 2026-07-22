import 'package:dartz/dartz.dart';

import '../entities/user_entity.dart';
import '../../core/errors/failures.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserEntity>> show();
  Future<Either<Failure, UserEntity>> update({
    String? nama,
    String? noTelp,
    String? alamat,
  });
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  });
}
