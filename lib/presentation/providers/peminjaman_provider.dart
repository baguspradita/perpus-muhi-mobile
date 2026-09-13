import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dependency_injection/injection_container.dart';
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
  final CreatePeminjamanUseCase _createPeminjamanUseCase;
  final KembaliPeminjamanUseCase _kembaliPeminjamanUseCase;

  PeminjamanNotifier({
    required GetPeminjamanListUseCase getPeminjamanListUseCase,
    required GetRiwayatPeminjamanUseCase getRiwayatPeminjamanUseCase,
    required CreatePeminjamanUseCase createPeminjamanUseCase,
    required KembaliPeminjamanUseCase kembaliPeminjamanUseCase,
  })  : _getPeminjamanListUseCase = getPeminjamanListUseCase,
        _getRiwayatPeminjamanUseCase = getRiwayatPeminjamanUseCase,
        _createPeminjamanUseCase = createPeminjamanUseCase,
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
    await _fetchPeminjamanAktif(status: status);
  }

  Future<void> _fetchPeminjamanAktif({String? status}) async {
    final result = await _getPeminjamanListUseCase(status: status);

    result.fold(
      (failure) {
        // Jangan hapus data yang tampil jika sudah ada daftar sebelumnya;
        // error hanya ditampilkan saat list benar-benar kosong.
        if (state.peminjamanAktif.isEmpty) {
          state = state.copyWith(isLoading: false, errorMessage: failure.message);
        } else {
          state = state.copyWith(isLoading: false);
        }
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
    await _fetchPeminjamanRiwayat(status: status);
  }

  Future<void> _fetchPeminjamanRiwayat({String? status}) async {
    final result = await _getRiwayatPeminjamanUseCase(status: status);

    result.fold(
      (failure) {
        if (state.peminjamanRiwayat.isEmpty) {
          state = state.copyWith(isLoading: false, errorMessage: failure.message);
        } else {
          state = state.copyWith(isLoading: false);
        }
      },
      (list) {
        // Hanya tampilkan peminjaman yang sudah selesai/dikembalikan
        final filtered = list.where((loan) {
          final returned =
              loan.tglKembali != null && loan.tglKembali!.isNotEmpty;
          final s = loan.status.toLowerCase();
          final statusReturned =
              s == 'kembali' || s == 'dikembalikan' || s == 'selesai';
          return returned || statusReturned;
        }).toList();

        state = state.copyWith(
            isLoading: false, peminjamanRiwayat: filtered, errorMessage: '');
      },
    );
  }

  Future<void> loadAllData() async {
    state = state.copyWith(isLoading: true, errorMessage: '');
    
    await Future.wait([
      _fetchPeminjamanAktif(),
      _fetchPeminjamanRiwayat(),
    ]);
    
    state = state.copyWith(isLoading: false);
  }

  /// Refresh senyap: ambil data terbaru tanpa menyalakan isLoading (tanpa shimmer)
  Future<void> refreshPeminjamanAktif({String? status}) =>
      _fetchPeminjamanAktif(status: status);

  Future<void> refreshPeminjamanRiwayat({String? status}) =>
      _fetchPeminjamanRiwayat(status: status);

  Future<void> refreshAllData() async {
    await Future.wait([
      _fetchPeminjamanAktif(),
      _fetchPeminjamanRiwayat(),
    ]);
  }

  Future<void> createPeminjaman({
    required int userId,
    required List<int> bukuIds,
    required String tglPinjam,
    required String tglJatuhTempo,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: '');

    final result = await _createPeminjamanUseCase(
      userId: userId,
      bukuIds: bukuIds,
      tglPinjam: tglPinjam,
      tglJatuhTempo: tglJatuhTempo,
    );

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (_) {
        loadAllData();
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
    createPeminjamanUseCase: sl<CreatePeminjamanUseCase>(),
    kembaliPeminjamanUseCase: sl<KembaliPeminjamanUseCase>(),
  )..loadAllData();
});
