import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:perpus_mobile/core/dependency_injection/injection_container.dart';
import 'package:perpus_mobile/domain/entities/notification_entity.dart';
import 'package:perpus_mobile/domain/usecases/notification_usecases.dart';
import 'package:perpus_mobile/presentation/pages/katalog/katalog_screen.dart';
import 'package:perpus_mobile/presentation/pages/peminjaman/peminjaman_list_screen.dart';
import 'package:perpus_mobile/presentation/pages/profile/notification_screen.dart';
import 'package:perpus_mobile/presentation/providers/notification_provider.dart';
import 'package:perpus_mobile/presentation/widgets/loading_shimmer.dart';

// Seeded notifier: starts with data, no-ops all async actions.
class _SeededNotifier extends NotificationNotifier {
  _SeededNotifier(
    GetNotificationsUseCase g,
    MarkNotificationAsReadUseCase m,
    MarkAllNotificationsAsReadUseCase a,
    GetUnreadCountUseCase u,
  ) : super(
          getNotificationsUseCase: g,
          markAsReadUseCase: m,
          markAllAsReadUseCase: a,
          getUnreadCountUseCase: u,
        ) {
    debugPrint('_SeededNotifier: initial state notifications = ${state.notifications.length}');
    state = state.copyWith(
      isLoading: false,
      notifications: [
        NotificationEntity(
          id: '1',
          title: 'Buku berhasil dikembalikan',
          message: 'Test',
          type: NotificationType.success,
          isRead: false,
          createdAt: 'Baru saja',
          actionUrl: '/peminjaman/123',
        ),
      ],
    );
    debugPrint('_SeededNotifier: after set state notifications = ${state.notifications.length}');
  }

  @override
  Future<void> loadNotifications({bool refresh = false}) async {
    debugPrint('_SeededNotifier.loadNotifications called');
  }

  @override
  Future<void> loadMore() async {}
  @override
  Future<void> markAsRead(String id) async {}
  @override
  Future<void> markAllAsRead() async {}
  @override
  Future<void> loadUnreadCount() async {}
  @override
  void clearError() {}
}

GoRouter _testRouter() => GoRouter(
      initialLocation: '/notifications',
      routes: [
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationScreen(),
        ),
        GoRoute(
          path: '/peminjaman',
          builder: (context, state) => const PeminjamanScreen(),
        ),
        GoRoute(
          path: '/katalog',
          builder: (context, state) => const KatalogScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('HOME'))),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(child: Text('ERROR: ${state.uri}')),
      ),
    );

void main() {
  testWidgets('tap notification with actionUrl navigates without throwing',
      (tester) async {
    await initDependencies();

    final g = GetIt.I<GetNotificationsUseCase>();
    final m = GetIt.I<MarkNotificationAsReadUseCase>();
    final a = GetIt.I<MarkAllNotificationsAsReadUseCase>();
    final u = GetIt.I<GetUnreadCountUseCase>();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationProvider
              .overrideWith((ref) => _SeededNotifier(g, m, a, u)),
        ],
        child: MaterialApp.router(
          routerConfig: _testRouter(),
          title: 'Test',
          theme: ThemeData(useMaterial3: true),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(); // fire post-frame callback
    await tester.pump(const Duration(milliseconds: 100));

    // Read provider state directly.
    final container = ProviderScope.containerOf(
      tester.element(find.byType(NotificationScreen)),
    );
    final notifierState = container.read(notificationProvider);
    print('--- Provider state notifications: ${notifierState.notifications.length}');
    if (notifierState.notifications.isNotEmpty) {
      print('   First title: ${notifierState.notifications.first.title}');
    }

    debugDumpApp();
    print('--- has Notifikasi: '
        '${find.text('Notifikasi').evaluate().length}');
    print('--- has Belum Ada: '
        '${find.text('Belum Ada Notifikasi').evaluate().length}');
    print('--- has Gagal: '
        '${find.text('Gagal Memuat Notifikasi').evaluate().length}');
    print('--- has ListView: '
        '${find.byType(ListView).evaluate().length}');
    print('--- has shimmer: '
        '${find.byType(LoadingShimmer).evaluate().length}');
    print('--- all text in ListView:');
    final texts = find.descendant(
      of: find.byType(ListView),
      matching: find.byType(Text),
    ).evaluate();
    for (final e in texts) {
      final widget = e.widget as Text;
      print('   Text: "${widget.data}"');
    }
    print('--- all Container in ListView: '
        '${find.descendant(of: find.byType(ListView), matching: find.byType(Container)).evaluate().length}');

    // Tap the notification item (has actionUrl /peminjaman/123).
    final target = find.text('Buku berhasil dikembalikan');
    expect(target, findsOneWidget);
    await tester.tap(target);
    await tester.pump(const Duration(seconds: 2));
  });
}