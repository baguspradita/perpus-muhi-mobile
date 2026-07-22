import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dependency_injection/injection_container.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/peminjaman_entity.dart';
import '../../domain/usecases/peminjaman_usecases.dart';

class PeminjamanState {
  final bool isLoading;
  final List<PeminjamanEntity> peminjaman;
  final String errorMessage;

  const PeminjamanState({
    this.isLoading = false,
    this.peminjaman = const [],
    this.errorMessage = '',
  });

  PeminjamanState copyWith({
    bool? isLoading,
    List<PeminjamanEntity>? peminjaman,
    String? errorMessage,
  }) {
    return PeminjamanState(
      isLoading: isLoading ?? this.isLoading,
      peminjaman: peminjaman ?? this.peminjaman,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
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

  Future<void> loadPeminjaman({String? status, bool isRiwayat = false}) async {
    state = state.copyWith(isLoading: true, errorMessage: '');

    Either<Failure, List<PeminjamanEntity>> result;
    if (isRiwayat) {
      result = await _getRiwayatPeminjamanUseCase(status: status);
    } else {
      result = await _getPeminjamanListUseCase(status: status);
    }

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (list) {
        state = state.copyWith(isLoading: false, peminjaman: list, errorMessage: '');
      },
    );
  }

  Future<void> kembaliPeminjaman(int id) async {
    final result = await _kembaliPeminjamanUseCase(id);
    result.fold(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
      (_) {
        loadPeminjaman();
      },
    );
  }
}

final peminjamanProvider = StateNotifierProvider<PeminjamanNotifier, PeminjamanState>((ref) {
  return PeminjamanNotifier(
    getPeminjamanListUseCase: sl<GetPeminjamanListUseCase>(),
    getRiwayatPeminjamanUseCase: sl<GetRiwayatPeminjamanUseCase>(),
    kembaliPeminjamanUseCase: sl<KembaliPeminjamanUseCase>(),
  )..loadPeminjaman();
});
