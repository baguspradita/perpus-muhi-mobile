import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/dependency_injection/injection_container.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'domain/repositories/notification_repository.dart';
import 'domain/usecases/notification_usecases.dart';
import 'presentation/providers/notification_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await initDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        notificationRepositoryProvider.overrideWithValue(sl<NotificationRepository>()),
        getNotificationsUseCaseProvider.overrideWithValue(sl<GetNotificationsUseCase>()),
        markNotificationAsReadUseCaseProvider.overrideWithValue(sl<MarkNotificationAsReadUseCase>()),
        markAllNotificationsAsReadUseCaseProvider.overrideWithValue(sl<MarkAllNotificationsAsReadUseCase>()),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          final router = ref.watch(routerProvider);
          return MaterialApp.router(
            title: 'Perpustakaan Muhi',
            theme: AppTheme.lightTheme,
            routerConfig: router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}