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

  final Map<String, List<BukuEntity>> _bukuCache = {};
  Map<String, dynamic>? _filtersCache;

  KatalogNotifier({
    required GetAllBukuUseCase getAllBukuUseCase,
    required GetFiltersUseCase getFiltersUseCase,
  }) : _getAllBukuUseCase = getAllBukuUseCase,
       _getFiltersUseCase = getFiltersUseCase,
       super(const KatalogState());

  String _bukuCacheKey({String? search, int? kategoriId}) {
    return 'kategori=$kategoriId|search=${search ?? ''}';
  }

  Future<void> loadData({String? search, int? kategoriId, bool refresh = false}) async {
    final cacheKey = _bukuCacheKey(search: search, kategoriId: kategoriId);

    // Serve from cache unless refresh (drag-to-refresh / retry) is requested.
    if (!refresh && _bukuCache.containsKey(cacheKey)) {
      state = state.copyWith(
        isLoading: false,
        bukuList: _bukuCache[cacheKey]!,
        errorMessage: '',
        searchQuery: search ?? '',
      );
      return;
    }

    // Parameter change (new category/search, not cached) → full spinner.
    // Explicit refresh (drag / retry) keeps existing data visible (no flicker).
    state = state.copyWith(
      isLoading: !refresh && !_bukuCache.containsKey(cacheKey),
      errorMessage: '',
      searchQuery: search ?? '',
    );

    final booksResult = await _getAllBukuUseCase(
      search: search,
      kategoriId: kategoriId,
    );

    booksResult.fold(
      (failure) {
        // Keep cached data for this exact query on failed refresh; otherwise
        // surface the error (replacing the grid).
        final cached = _bukuCache[cacheKey];
        state = state.copyWith(
          isLoading: false,
          bukuList: cached ?? [],
          errorMessage: cached != null ? '' : failure.message,
        );
      },
      (list) {
        _bukuCache[cacheKey] = list;
        state = state.copyWith(
          isLoading: false,
          bukuList: list,
          errorMessage: '',
        );
      },
    );
  }

  Future<void> loadFilters({bool refresh = false}) async {
    if (!refresh && _filtersCache != null) {
      state = state.copyWith(
        isFiltersLoading: false,
        filters: _filtersCache!,
        errorMessage: '',
      );
      return;
    }

    state = state.copyWith(isFiltersLoading: true);

    final result = await _getFiltersUseCase.call();

    result.fold(
      (failure) {
        state = state.copyWith(isFiltersLoading: false);
      },
      (filters) {
        _filtersCache = filters;
        state = state.copyWith(
          isFiltersLoading: false,
          filters: filters,
          errorMessage: '',
        );
      },
    );
  }

  void clearCache() {
    _bukuCache.clear();
    _filtersCache = null;
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
