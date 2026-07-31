import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dependency_injection/injection_container.dart';
import '../../domain/entities/buku_entity.dart';
import '../../domain/usecases/buku_usecases.dart';

class KatalogState {
  final bool isLoading;
  final bool isFiltersLoading;
  final List<BukuEntity> bukuList;
  final Map<String, dynamic> filters;
  final String errorMessage;
  final String searchQuery;

  const KatalogState({
    this.isLoading = false,
    this.isFiltersLoading = false,
    this.bukuList = const [],
    this.filters = const {},
    this.errorMessage = '',
    this.searchQuery = '',
  });

  KatalogState copyWith({
    bool? isLoading,
    bool? isFiltersLoading,
    List<BukuEntity>? bukuList,
    Map<String, dynamic>? filters,
    String? errorMessage,
    String? searchQuery,
  }) {
    return KatalogState(
      isLoading: isLoading ?? this.isLoading,
      isFiltersLoading: isFiltersLoading ?? this.isFiltersLoading,
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
  }) : _getAllBukuUseCase = getAllBukuUseCase,
       _getFiltersUseCase = getFiltersUseCase,
       super(const KatalogState());

  Future<void> loadData({String? search, int? kategoriId}) async {
    // Load books
    state = state.copyWith(
      isLoading: true,
      errorMessage: '',
      searchQuery: search ?? '',
    );

    final booksResult = await _getAllBukuUseCase(
      search: search,
      kategoriId: kategoriId,
    );

    booksResult.fold(
      (failure) {
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
      },
      (list) {
        state = state.copyWith(
          isLoading: false,
          bukuList: list,
          errorMessage: '',
        );
      },
    );
  }

  Future<void> loadFilters() async {
    state = state.copyWith(isFiltersLoading: true);

    final result = await _getFiltersUseCase.call();

    result.fold(
      (failure) {
        state = state.copyWith(isFiltersLoading: false);
      },
      (filters) {
        state = state.copyWith(
          isFiltersLoading: false,
          filters: filters,
          errorMessage: '',
        );
      },
    );
  }
}

final katalogProvider = StateNotifierProvider<KatalogNotifier, KatalogState>((
  ref,
) {
  final notifier = KatalogNotifier(
    getAllBukuUseCase: sl<GetAllBukuUseCase>(),
    getFiltersUseCase: sl<GetFiltersUseCase>(),
  );
  notifier.loadFilters();
  notifier.loadData();
  return notifier;
});
