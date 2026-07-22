import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dependency_injection/injection_container.dart';
import '../../domain/entities/buku_entity.dart';
import '../../domain/usecases/buku_usecases.dart';

class KatalogState {
  final bool isLoading;
  final List<BukuEntity> bukuList;
  final String errorMessage;
  final String searchQuery;

  const KatalogState({
    this.isLoading = false,
    this.bukuList = const [],
    this.errorMessage = '',
    this.searchQuery = '',
  });

  KatalogState copyWith({
    bool? isLoading,
    List<BukuEntity>? bukuList,
    String? errorMessage,
    String? searchQuery,
  }) {
    return KatalogState(
      isLoading: isLoading ?? this.isLoading,
      bukuList: bukuList ?? this.bukuList,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class KatalogNotifier extends StateNotifier<KatalogState> {
  final GetAllBukuUseCase _getAllBukuUseCase;

  KatalogNotifier({required GetAllBukuUseCase getAllBukuUseCase})
      : _getAllBukuUseCase = getAllBukuUseCase,
        super(const KatalogState());

  Future<void> loadBuku({String? search}) async {
    state = state.copyWith(isLoading: true, errorMessage: '', searchQuery: search ?? '');

    final result = await _getAllBukuUseCase(search: search);

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (list) {
        state = state.copyWith(isLoading: false, bukuList: list, errorMessage: '');
      },
    );
  }
}

final katalogProvider = StateNotifierProvider<KatalogNotifier, KatalogState>((ref) {
  return KatalogNotifier(
    getAllBukuUseCase: sl<GetAllBukuUseCase>(),
  )..loadBuku();
});
