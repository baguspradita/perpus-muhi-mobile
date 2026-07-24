import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dependency_injection/injection_container.dart';
import '../../domain/entities/buku_entity.dart';
import '../../domain/usecases/buku_usecases.dart';

class DashboardBukuState {
  final bool isLoading;
  final List<BukuEntity> rekomendasiBuku;
  final List<BukuEntity> bukuBaru;
  final List<BukuEntity> bukuPopuler;
  final String errorMessage;

  const DashboardBukuState({
    this.isLoading = false,
    this.rekomendasiBuku = const [],
    this.bukuBaru = const [],
    this.bukuPopuler = const [],
    this.errorMessage = '',
  });

  DashboardBukuState copyWith({
    bool? isLoading,
    List<BukuEntity>? rekomendasiBuku,
    List<BukuEntity>? bukuBaru,
    List<BukuEntity>? bukuPopuler,
    String? errorMessage,
  }) {
    return DashboardBukuState(
      isLoading: isLoading ?? this.isLoading,
      rekomendasiBuku: rekomendasiBuku ?? this.rekomendasiBuku,
      bukuBaru: bukuBaru ?? this.bukuBaru,
      bukuPopuler: bukuPopuler ?? this.bukuPopuler,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class DashboardBukuNotifier extends StateNotifier<DashboardBukuState> {
  final GetRekomendasiBukuUseCase _getRekomendasiBukuUseCase;
  final GetBukuBaruUseCase _getBukuBaruUseCase;
  final GetBukuPopulerUseCase _getBukuPopulerUseCase;

  DashboardBukuNotifier({
    required GetRekomendasiBukuUseCase getRekomendasiBukuUseCase,
    required GetBukuBaruUseCase getBukuBaruUseCase,
    required GetBukuPopulerUseCase getBukuPopulerUseCase,
  })  : _getRekomendasiBukuUseCase = getRekomendasiBukuUseCase,
        _getBukuBaruUseCase = getBukuBaruUseCase,
        _getBukuPopulerUseCase = getBukuPopulerUseCase,
        super(const DashboardBukuState());

  Future<void> loadDashboardData() async {
    state = state.copyWith(isLoading: true, errorMessage: '');

    // Load rekomendasi buku
    final rekomendasiResult = await _getRekomendasiBukuUseCase.call();
    // Load buku baru
    final bukuBaruResult = await _getBukuBaruUseCase.call();
    // Load buku populer
    final bukuPopulerResult = await _getBukuPopulerUseCase.call();

    rekomendasiResult.fold(
      (failure) {
        print('Failed to load rekomendasi buku: ${failure.message}');
      },
      (list) {
        state = state.copyWith(
          rekomendasiBuku: list,
          errorMessage: '',
        );
      },
    );

    bukuBaruResult.fold(
      (failure) {
        print('Failed to load buku baru: ${failure.message}');
      },
      (list) {
        state = state.copyWith(
          bukuBaru: list,
          errorMessage: '',
        );
      },
    );

    bukuPopulerResult.fold(
      (failure) {
        print('Failed to load buku populer: ${failure.message}');
      },
      (list) {
        state = state.copyWith(
          bukuPopuler: list,
          isLoading: false,
          errorMessage: '',
        );
      },
    );
  }
}

final dashboardBukuProvider = StateNotifierProvider<DashboardBukuNotifier, DashboardBukuState>((ref) {
  return DashboardBukuNotifier(
    getRekomendasiBukuUseCase: sl<GetRekomendasiBukuUseCase>(),
    getBukuBaruUseCase: sl<GetBukuBaruUseCase>(),
    getBukuPopulerUseCase: sl<GetBukuPopulerUseCase>(),
  )..loadDashboardData();
});