import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dependency_injection/injection_container.dart';
import '../../domain/entities/buku_entity.dart';
import '../../domain/usecases/buku_usecases.dart';

class KatalogState {
  final bool isLoading;
  final List<BukuEntity> bukuList;
  final Map<String, dynamic> filters;
  final String errorMessage;
  final String searchQuery;

  const KatalogState({
    this.isLoading = false,
    this.bukuList = const [],
    this.filters = const {},
    this.errorMessage = '',
    this.searchQuery = '',
  });

  KatalogState copyWith({
    bool? isLoading,
    List<BukuEntity>? bukuList,
    Map<String, dynamic>? filters,
    String? errorMessage,
    String? searchQuery,
  }) {
    return KatalogState(
      isLoading: isLoading ?? this.isLoading,
      bukuList: bukuList ?? this.bukuList,
      filters: filters ?? this.filters,
      errorMessage: errorMessage ?? this.errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class KatalogNotifier extends StateNotifier<KatalogState> {
  final GetAllBukuUseCase _getAllBukuUseCase;
  final GetFiltersUseCase _getFiltersUseCase;

  KatalogNotifier({
    required GetAllBukuUseCase getAllBukuUseCase,
    required GetFiltersUseCase getFiltersUseCase,
  })  : _getAllBukuUseCase = getAllBukuUseCase,
        _getFiltersUseCase = getFiltersUseCase,
        super(const KatalogState());

  Future<void> loadData({String? search}) async {
    // Load books
    state = state.copyWith(isLoading: true, errorMessage: '', searchQuery: search ?? '');

    final booksResult = await _getAllBukuUseCase(search: search);

    booksResult.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (list) {
        // Load filters after books
        _loadFilters();
        state = state.copyWith(
          isLoading: false,
          bukuList: list,
          errorMessage: '',
        );
      },
    );
  }

  Future<void> _loadFilters() async {
    final result = await _getFiltersUseCase.call();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (filters) {
        state = state.copyWith(
          isLoading: false,
          filters: filters,
          errorMessage: '',
        );
      },
    );
  }
}

final katalogProvider = StateNotifierProvider<KatalogNotifier, KatalogState>((ref) {
  return KatalogNotifier(
    getAllBukuUseCase: sl<GetAllBukuUseCase>(),
    getFiltersUseCase: sl<GetFiltersUseCase>(),
  )..loadData();
});
