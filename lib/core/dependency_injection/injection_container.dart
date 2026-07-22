import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:logger/logger.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/buku_remote_datasource.dart';
import '../../data/datasources/peminjaman_remote_datasource.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/buku_repository_impl.dart';
import '../../data/repositories/peminjaman_repository_impl.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/buku_repository.dart';
import '../../domain/repositories/peminjaman_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../domain/usecases/buku_usecases.dart';
import '../../domain/usecases/peminjaman_usecases.dart';
import '../../domain/usecases/profile_usecases.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../errors/error_handler.dart';
import '../errors/exceptions.dart';
import '../network/api_client.dart';
import '../network/network_info.dart';
import '../services/local_storage_service.dart';

final sl = GetIt.instance;
final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

Future<void> initDependencies() async {
  // ═══════════════════════════════════════════
  // External
  // ═══════════════════════════════════════════
  sl.registerLazySingleton<InternetConnection>(() => InternetConnection());
  sl.registerLazySingleton<Dio>(() => _createDio());
  sl.registerLazySingleton<LocalStorageService>(() => LocalStorageServiceImpl());

  // ═══════════════════════════════════════════
  // Core
  // ═══════════════════════════════════════════
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(internetConnection: sl()),
  );
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl<Dio>()));

  // ═══════════════════════════════════════════
  // Data Sources
  // ═══════════════════════════════════════════
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(sl<ApiClient>()),
  );
  sl.registerLazySingleton<BukuRemoteDataSource>(
    () => BukuRemoteDataSource(sl<ApiClient>()),
  );
  sl.registerLazySingleton<PeminjamanRemoteDataSource>(
    () => PeminjamanRemoteDataSource(sl<ApiClient>()),
  );
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSource(sl<ApiClient>()),
  );

  // ═══════════════════════════════════════════
  // Repositories
  // ═══════════════════════════════════════════
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
          remoteDataSource: sl<AuthRemoteDataSource>(),
          localStorageService: sl<LocalStorageService>(),
        ),
  );
  sl.registerLazySingleton<BukuRepository>(
    () => BukuRepositoryImpl(remoteDataSource: sl<BukuRemoteDataSource>()),
  );
  sl.registerLazySingleton<PeminjamanRepository>(
    () => PeminjamanRepositoryImpl(remoteDataSource: sl<PeminjamanRemoteDataSource>()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl<ProfileRemoteDataSource>()),
  );

  // ═══════════════════════════════════════════
  // Use Cases
  // ═══════════════════════════════════════════
  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<GetProfileUseCase>(
    () => GetProfileUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<AutoLoginUseCase>(
    () => AutoLoginUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<GetAllBukuUseCase>(
    () => GetAllBukuUseCase(sl<BukuRepository>()),
  );
  sl.registerLazySingleton<GetBukuByIdUseCase>(
    () => GetBukuByIdUseCase(sl<BukuRepository>()),
  );
  sl.registerLazySingleton<GetFiltersUseCase>(
    () => GetFiltersUseCase(sl<BukuRepository>()),
  );
  sl.registerLazySingleton<GetPeminjamanListUseCase>(
    () => GetPeminjamanListUseCase(sl<PeminjamanRepository>()),
  );
  sl.registerLazySingleton<GetRiwayatPeminjamanUseCase>(
    () => GetRiwayatPeminjamanUseCase(sl<PeminjamanRepository>()),
  );
  sl.registerLazySingleton<GetDashboardUseCase>(
    () => GetDashboardUseCase(sl<PeminjamanRepository>()),
  );
  sl.registerLazySingleton<CreatePeminjamanUseCase>(
    () => CreatePeminjamanUseCase(sl<PeminjamanRepository>()),
  );
  sl.registerLazySingleton<KembaliPeminjamanUseCase>(
    () => KembaliPeminjamanUseCase(sl<PeminjamanRepository>()),
  );
  sl.registerLazySingleton<ShowProfileUseCase>(
    () => ShowProfileUseCase(sl<ProfileRepository>()),
  );
  sl.registerLazySingleton<UpdateProfileUseCase>(
    () => UpdateProfileUseCase(sl<ProfileRepository>()),
  );
  sl.registerLazySingleton<UpdatePasswordUseCase>(
    () => UpdatePasswordUseCase(sl<ProfileRepository>()),
  );
}

// ═══════════════════════════════════════════════════════
// Dio Factory — single source of truth untuk HTTP client
// ═══════════════════════════════════════════════════════
Dio _createDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.connectTimeout),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
      sendTimeout: const Duration(milliseconds: AppConstants.apiTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.addAll([
    _AuthInterceptor(),
    _LoggingInterceptor(),
  ]);

  return dio;
}

// ═══════════════════════════════════════════════════════
// Auth Interceptor — inject Bearer token + autohapus saat 401
// ═══════════════════════════════════════════════════════
class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await sl<LocalStorageService>().read('access_token');
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException dioException, ErrorInterceptorHandler handler) async {
    final appException = mapDioExceptionToAppException(dioException);

    if (appException is UnauthorizedException) {
      await sl<LocalStorageService>().delete('access_token');
      _logger.w('Token expired / unauthorized — token removed');
    }

    _logger.e(
      'API Error [${dioException.response?.statusCode}]',
      error: dioException.message,
    );

    handler.next(dioException);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }
}

// ═══════════════════════════════════════════════════════
// Logging Interceptor — log errors untuk debugging
// ═══════════════════════════════════════════════════════
class _LoggingInterceptor extends Interceptor {
  @override
  void onError(DioException dioException, ErrorInterceptorHandler handler) {
    _logger.e(
      'HTTP ${dioException.response?.statusCode} ${dioException.requestOptions.method.toUpperCase()} '
      '${dioException.requestOptions.uri}',
      error: dioException.message,
    );
    handler.next(dioException);
  }
}