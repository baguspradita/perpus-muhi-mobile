import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dependency_injection/injection_container.dart';
import '../../core/services/local_storage_service.dart';
import '../../domain/entities/auth_token_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/auth_usecases.dart';

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String errorMessage;
  final UserEntity? user;
  final AuthTokenEntity? authToken;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.errorMessage = '',
    this.user,
    this.authToken,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? errorMessage,
    UserEntity? user,
    AuthTokenEntity? authToken,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      errorMessage: errorMessage ?? this.errorMessage,
      user: user ?? this.user,
      authToken: authToken ?? this.authToken,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetProfileUseCase _getProfileUseCase;
  bool _initialized = false;

  AuthNotifier({
    required this._loginUseCase,
    required this._registerUseCase,
    required this._logoutUseCase,
    required this._getProfileUseCase,
  })  : super(const AuthState());

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    state = state.copyWith(isLoading: true);

    final token = await sl<LocalStorageService>().read('access_token');
    if (token == null || token.isEmpty) {
      state = state.copyWith(isLoading: false, isAuthenticated: false);
      return;
    }

    // Retry up to 3 times if API fails (network may be slow after hot restart)
    for (int attempt = 0; attempt < 3; attempt++) {
      final result = await _getProfileUseCase();
      bool success = false;

      result.fold(
        (failure) {
          print('initialize attempt ${attempt + 1} failed: ${failure.message}');
        },
        (user) {
          if (user.role == 'petugas') {
            state = state.copyWith(
              isLoading: false,
              isAuthenticated: false,
              errorMessage: 'Akun petugas tidak dapat mengakses aplikasi mobile. Silakan gunakan website admin.',
            );
            sl<LocalStorageService>().delete('access_token');
            success = true; // stop retrying
          } else {
            state = state.copyWith(isLoading: false, isAuthenticated: true, user: user);
            success = true;
          }
        },
      );

      if (success) return;

      // Wait before retry (increasing delay)
      if (attempt < 2) {
        await Future.delayed(Duration(milliseconds: 1000 * (attempt + 1)));
      }
    }

    // All retries failed - keep token but mark as unauthenticated
    print('All initialize attempts failed. Keeping token for next retry.');
    state = state.copyWith(isLoading: false, isAuthenticated: false);
  }

  void clearError() {
    state = state.copyWith(errorMessage: '');
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: '');

    final result = await _loginUseCase(email: email, password: password);

    return result.fold(
      (failure) async {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (authToken) async {
        await sl<LocalStorageService>().write('access_token', authToken.accessToken);
        state = state.copyWith(isLoading: false, authToken: authToken, isAuthenticated: true, errorMessage: '');
        await loadUserProfile();
        if (state.user?.role == 'petugas') {
          await sl<LocalStorageService>().delete('access_token');
          state = const AuthState(
            isLoading: false,
            isAuthenticated: false,
            errorMessage: 'Akses tidak diizinkan: akun petugas tidak dapat menggunakan aplikasi mobile. Silakan gunakan website admin.',
          );
          return false;
        }
        return true;
      },
    );
  }

  Future<bool> register({
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
    state = state.copyWith(isLoading: true, errorMessage: '');

    final result = await _registerUseCase(
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

    return result.fold(
      (failure) async {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        return false;
      },
      (authToken) async {
        await sl<LocalStorageService>().write('access_token', authToken.accessToken);
        state = state.copyWith(isLoading: false, authToken: authToken, isAuthenticated: true, errorMessage: '');
        await loadUserProfile();
        if (state.user?.role == 'petugas') {
          await sl<LocalStorageService>().delete('access_token');
          state = const AuthState(
            isLoading: false,
            isAuthenticated: false,
            errorMessage: 'Akses tidak diizinkan: akun petugas tidak dapat mengakses aplikasi mobile. Silakan gunakan website admin.',
          );
          return false;
        }
        return true;
      },
    );
  }

Future<void> loadUserProfile() async {
    print('=== loadUserProfile START ===');
    final result = await _getProfileUseCase();
    result.fold(
      (failure) {
        print('loadUserProfile FAILED: ${failure.message} (${failure.runtimeType})');
        if (state.isAuthenticated) {
          state = state.copyWith(errorMessage: failure.message);
        } else {
          state = state.copyWith(isAuthenticated: false, errorMessage: failure.message);
        }
      },
      (user) {
        print('loadUserProfile SUCCESS: ${user.nama} (${user.role})');
        state = state.copyWith(user: user, isAuthenticated: true);
      },
    );
    print('=== loadUserProfile END ===');
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, errorMessage: '');

    final result = await _logoutUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (_) {
        state = const AuthState();
      },
    );
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(
    loginUseCase: sl<LoginUseCase>(),
    registerUseCase: sl<RegisterUseCase>(),
    logoutUseCase: sl<LogoutUseCase>(),
    getProfileUseCase: sl<GetProfileUseCase>(),
  )..initialize(),
);
