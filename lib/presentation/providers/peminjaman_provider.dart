import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dependency_injection/injection_container.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/peminjaman_entity.dart';
import '../../domain/usecases/peminjaman_usecases.dart';

class PeminjamanState {
  final bool isLoading;
  final List<PeminjamanEntity> peminjamanAktif;
  final List<PeminjamanEntity> peminjamanRiwayat;
  final String errorMessage;

  const PeminjamanState({
    this.isLoading = false,
    this.peminjamanAktif = const [],
    this.peminjamanRiwayat = const [],
    this.errorMessage = '',
  });

  PeminjamanState copyWith({
    bool? isLoading,
    List<PeminjamanEntity>? peminjamanAktif,
    List<PeminjamanEntity>? peminjamanRiwayat,
    String? errorMessage,
  }) {
    return PeminjamanState(
      isLoading: isLoading ?? this.isLoading,
      peminjamanAktif: peminjamanAktif ?? this.peminjamanAktif,
      peminjamanRiwayat: peminjamanRiwayat ?? this.peminjamanRiwayat,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // Helpers - data langsung dari API, tidak perlu filter client-side
  List<PeminjamanEntity> get activeLoans => peminjamanAktif;
  List<PeminjamanEntity> get riwayatLoans => peminjamanRiwayat;
}

class PeminjamanNotifier extends StateNotifier<PeminjamanState> {
  final GetPeminjamanListUseCase _getPeminjamanListUseCase;
  final GetRiwayatPeminjamanUseCase _getRiwayatPeminjamanUseCase;
  final KembaliPeminjamanUseCase _kembaliPeminjamanUseCase;

  PeminjamanNotifier({
    required GetPeminjamanListUseCase getPeminjamanListUseCase,
    required GetRiwayatPeminjamanUseCase getRiwayatPeminjamanUseCase,
    required KembaliPeminjamanUseCase kembaliPeminjamanUseCase,
  })  : _getPeminjamanListUseCase = getPeminjamanListUseCase,
        _getRiwayatPeminjamanUseCase = getRiwayatPeminjamanUseCase,
        _kembaliPeminjamanUseCase = kembaliPeminjamanUseCase,
        super(const PeminjamanState());

  // Legacy method - now replaced by separate methods
  Future<void> loadPeminjaman({String? status, bool isRiwayat = false}) async {
    if (isRiwayat) {
      await loadPeminjamanRiwayat();
    } else {
      await loadPeminjamanAktif();
    }
  }

  Future<void> loadPeminjamanAktif({String? status}) async {
    state = state.copyWith(isLoading: true, errorMessage: '');

    final result = await _getPeminjamanListUseCase(status: status);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (list) {
        // Filter: exclude buku yang sudah dikembalikan (tglKembali sudah diisi)
        final filtered = list.where((loan) =>
          loan.tglKembali == null || loan.tglKembali!.isEmpty
        ).toList();
        
        state = state.copyWith(isLoading: false, peminjamanAktif: filtered, errorMessage: '');
      },
    );
  }

  Future<void> loadPeminjamanRiwayat({String? status}) async {
    state = state.copyWith(isLoading: true, errorMessage: '');

    final result = await _getRiwayatPeminjamanUseCase(status: status);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (list) {
        state = state.copyWith(isLoading: false, peminjamanRiwayat: list, errorMessage: '');
      },
    );
  }

  Future<void> loadAllData() async {
    state = state.copyWith(isLoading: true, errorMessage: '');
    
    await Future.wait([
      loadPeminjamanAktif(),
      loadPeminjamanRiwayat(),
    ]);
    
    state = state.copyWith(isLoading: false);
  }

  Future<void> kembaliPeminjaman(int id) async {
    final result = await _kembaliPeminjamanUseCase(id);
    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (_) {
        // Reload both lists after return
        loadAllData();
      },
    );
  }
}

final peminjamanProvider = StateNotifierProvider<PeminjamanNotifier, PeminjamanState>((ref) {
  return PeminjamanNotifier(
    getPeminjamanListUseCase: sl<GetPeminjamanListUseCase>(),
    getRiwayatPeminjamanUseCase: sl<GetRiwayatPeminjamanUseCase>(),
    kembaliPeminjamanUseCase: sl<KembaliPeminjamanUseCase>(),
  )..loadAllData();
});
