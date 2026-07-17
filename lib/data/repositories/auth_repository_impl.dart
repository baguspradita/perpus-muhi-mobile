import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/services/local_storage_service.dart';
import '../../domain/entities/auth_token_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final LocalStorageService _localStorageService;

  AuthRepositoryImpl({
    required this._remoteDataSource,
    required this._localStorageService,
  });

  @override
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
  }) async {
    try {
      final authToken = await _remoteDataSource.register(
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

      await _localStorageService.write('access_token', authToken.accessToken);

      return Right(authToken);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, errors: e.errors));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Terjadi kesalahan yang tidak diketahui: $e'));
    }
  }

  @override
  Future<Either<Failure, AuthTokenEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final authToken = await _remoteDataSource.login(
        email: email,
        password: password,
      );

      await _localStorageService.write('access_token', authToken.accessToken);

      return Right(authToken);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, errors: e.errors));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Terjadi kesalahan yang tidak diketahui: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remoteDataSource.logout(
        await _localStorageService.read('access_token') ?? '',
      );
      await _localStorageService.delete('access_token');
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      await _localStorageService.delete('access_token');
      return Left(ServerFailure('Terjadi kesalahan yang tidak diketahui: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getProfile() async {
    try {
      final userModel = await _remoteDataSource.getCurrentUser();

      if (userModel == null) {
        return Left(UnauthorizedFailure('User tidak ditemukan'));
      }

      return Right(userModel);
    } on UnauthorizedException catch (e) {
      await _localStorageService.delete('access_token');
      return Left(UnauthorizedFailure(e.message, statusCode: e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Terjadi kesalahan yang tidak diketahui: $e'));
    }
  }
}