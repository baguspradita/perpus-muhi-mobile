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

  AuthNotifier({
    required this._loginUseCase,
    required this._registerUseCase,
    required this._logoutUseCase,
    required this._getProfileUseCase,
  })  : super(const AuthState());

  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);

    // Cek token dari SecureStorage dulu — kalau kosong, skip API call
    final token = await sl<LocalStorageService>().read('access_token');
    if (token == null || token.isEmpty) {
      state = state.copyWith(isLoading: false, isAuthenticated: false);
      return;
    }

    // Token ada → validasi ke server (getProfile)
    final result = await _getProfileUseCase();
    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, isAuthenticated: false);
      },
      (user) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
        );
      },
    );
  }

  void clearError() {
    state = state.copyWith(errorMessage: '');
  }

  Future<void> register({
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

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (authToken) {
        state = state.copyWith(
          isLoading: false,
          authToken: authToken,
          isAuthenticated: true,
          errorMessage: '',
        );
      },
    );
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: '');

    final result = await _loginUseCase(email: email, password: password);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (authToken) async {
        state = state.copyWith(
          isLoading: false,
          authToken: authToken,
          isAuthenticated: true,
          errorMessage: '',
        );
        await loadUserProfile();
      },
    );
  }

  Future<void> loadUserProfile() async {
    final result = await _getProfileUseCase();
    result.fold(
      (failure) {
        state = state.copyWith(
          isAuthenticated: false,
          errorMessage: failure.message,
        );
      },
      (user) {
        state = state.copyWith(user: user);
      },
    );
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, errorMessage: '');

    final result = await _logoutUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
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
  ),
);