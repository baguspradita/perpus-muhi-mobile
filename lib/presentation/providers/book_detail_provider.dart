import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dependency_injection/injection_container.dart';
import '../../domain/entities/buku_entity.dart';
import '../../domain/usecases/buku_usecases.dart';

class BookDetailState {
  final bool isLoading;
  final BukuEntity? book;
  final String errorMessage;

  const BookDetailState({
    this.isLoading = false,
    this.book,
    this.errorMessage = '',
  });

  BookDetailState copyWith({
    bool? isLoading,
    BukuEntity? book,
    String? errorMessage,
  }) {
    return BookDetailState(
      isLoading: isLoading ?? this.isLoading,
      book: book ?? this.book,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class BookDetailNotifier extends StateNotifier<BookDetailState> {
  final GetBukuByIdUseCase _getBukuByIdUseCase;

  BookDetailNotifier(this._getBukuByIdUseCase)
      : super(const BookDetailState());

  Future<void> loadBuku(int id) async {
    state = state.copyWith(isLoading: true, errorMessage: '');

    final result = await _getBukuByIdUseCase.call(id);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (book) {
        state = state.copyWith(
          isLoading: false,
          book: book,
          errorMessage: '',
        );
      },
    );
  }
}

final bookDetailProvider =
    StateNotifierProvider.family<BookDetailNotifier, BookDetailState, int>(
  (ref, id) {
    return BookDetailNotifier(sl<GetBukuByIdUseCase>());
  },
);
