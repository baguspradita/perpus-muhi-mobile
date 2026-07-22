import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dependency_injection/injection_container.dart';
import '../../domain/entities/dashboard_entity.dart';
import '../../domain/usecases/peminjaman_usecases.dart';

class DashboardState {
  final bool isLoading;
  final DashboardEntity? dashboard;
  final String errorMessage;

  const DashboardState({
    this.isLoading = false,
    this.dashboard,
    this.errorMessage = '',
  });

  DashboardState copyWith({
    bool? isLoading,
    DashboardEntity? dashboard,
    String? errorMessage,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      dashboard: dashboard ?? this.dashboard,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final GetDashboardUseCase _getDashboardUseCase;

  DashboardNotifier({required GetDashboardUseCase getDashboardUseCase})
      : _getDashboardUseCase = getDashboardUseCase,
        super(const DashboardState());

  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true, errorMessage: '');

    final result = await _getDashboardUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (dashboard) {
        state = state.copyWith(
          isLoading: false,
          dashboard: dashboard,
          errorMessage: '',
        );
      },
    );
  }
}

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier(
    getDashboardUseCase: sl<GetDashboardUseCase>(),
  )..loadDashboard();
});
