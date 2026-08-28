import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dependency_injection/injection_container.dart';
import '../../domain/entities/buku_entity.dart';
import '../../domain/usecases/buku_usecases.dart';

class RelatedBooksState {
  final bool isLoading;
  final List<BukuEntity> books;
  final String errorMessage;

  const RelatedBooksState({
    this.isLoading = false,
    this.books = const [],
    this.errorMessage = '',
  });

  RelatedBooksState copyWith({
    bool? isLoading,
    List<BukuEntity>? books,
    String? errorMessage,
  }) {
    return RelatedBooksState(
      isLoading: isLoading ?? this.isLoading,
      books: books ?? this.books,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class RelatedBooksNotifier extends StateNotifier<RelatedBooksState> {
  final GetRelatedBooksUseCase _getRelatedBooksUseCase;

  RelatedBooksNotifier({required GetRelatedBooksUseCase getRelatedBooksUseCase})
      : _getRelatedBooksUseCase = getRelatedBooksUseCase,
        super(const RelatedBooksState());

  Future<void> loadRelatedBooks(int id) async {
    state = state.copyWith(isLoading: true, errorMessage: '');

    final result = await _getRelatedBooksUseCase.call(id);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (books) {
        state = state.copyWith(
          isLoading: false,
          books: books,
          errorMessage: '',
        );
      },
    );
  }
}

final relatedBooksProvider =
    StateNotifierProvider.family<RelatedBooksNotifier, RelatedBooksState, int>(
  (ref, id) {
    return RelatedBooksNotifier(
      getRelatedBooksUseCase: sl<GetRelatedBooksUseCase>(),
    )..loadRelatedBooks(id);
  },
);