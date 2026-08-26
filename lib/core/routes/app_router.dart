import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/pages/home_page.dart';
import '../../presentation/pages/login_page.dart';
import '../../presentation/pages/register_page.dart';
import '../../presentation/pages/splash_page.dart';
import '../../presentation/pages/katalog/katalog_screen.dart';
import '../../presentation/pages/katalog/book_detail_screen.dart';
import '../../presentation/pages/peminjaman/peminjaman_list_screen.dart';
import '../../presentation/pages/profile/profile_screen.dart';
import '../../presentation/pages/profile/edit_profile_screen.dart';
import '../../presentation/pages/profile/change_password_screen.dart';
import '../../presentation/pages/profile/notification_screen.dart';
import '../../presentation/pages/about_screen.dart';
import '../../presentation/pages/faq_screen.dart';
import '../../presentation/pages/identification_screen.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/widgets/scaffold_with_nav_bar.dart';
import '../../domain/entities/buku_entity.dart';
import '../routes/route_names.dart';

class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(Ref ref) {
    ref.listen(authNotifierProvider, (_, __) {
      notifyListeners();
    });
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteNames.splash,
    refreshListenable: GoRouterRefreshNotifier(ref),
    redirect: (context, state) {
      final isAuthenticated =
          ProviderScope.containerOf(context).read(authNotifierProvider).isAuthenticated;

      final isAuthRoute = state.matchedLocation == RouteNames.login ||
          state.matchedLocation == RouteNames.register ||
          state.matchedLocation == RouteNames.splash;

      // If not authenticated and trying to access protected route, redirect to login
      if (!isAuthenticated && !isAuthRoute) {
        return RouteNames.login;
      }

      // If authenticated and on auth route (except splash), redirect to home
      if (isAuthenticated && isAuthRoute && state.matchedLocation != RouteNames.splash) {
        return RouteNames.home;
      }

      return null;
    },
    routes: [
    GoRoute(
      path: RouteNames.splash,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: RouteNames.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: RouteNames.register,
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: RouteNames.notifications,
      builder: (context, state) => const NotificationScreen(),
    ),
    GoRoute(
      path: RouteNames.editProfile,
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: RouteNames.changePassword,
      builder: (context, state) => const ChangePasswordScreen(),
    ),
    GoRoute(
      path: RouteNames.about,
      builder: (context, state) => const AboutScreen(),
    ),
    GoRoute(
      path: RouteNames.faq,
      builder: (context, state) => const FaqScreen(),
    ),
    GoRoute(
      path: RouteNames.identification,
      builder: (context, state) => const IdentificationScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => ScaffoldWithNavBar(child: child),
      routes: [
        GoRoute(
          path: RouteNames.home,
          builder: (context, state) => const HomePage(),
        ),
GoRoute(
      path: RouteNames.katalog,
      builder: (context, state) => const KatalogScreen(),
    ),
    GoRoute(
      path: RouteNames.bookDetail,
      builder: (context, state) {
        final bookId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        // We need to fetch the book data first, but for now we'll use extra
        final book = state.extra as BukuEntity?;
        if (book == null) {
          return const Scaffold(body: Center(child: Text('Buku tidak ditemukan')));
        }
        return BookDetailScreen(book: book);
      },
    ),
        GoRoute(
          path: RouteNames.peminjaman,
          builder: (context, state) => const PeminjamanScreen(),
        ),
        GoRoute(
          path: RouteNames.profile,
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Halaman tidak ditemukan: ${state.uri.toString()}'),
    ),
  ),
  );
});
