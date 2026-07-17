import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../presentation/pages/home_page.dart';
import '../../presentation/pages/login_page.dart';
import '../../presentation/pages/register_page.dart';
import '../../presentation/pages/splash_page.dart';
import '../routes/route_names.dart';

final router = GoRouter(
  initialLocation: RouteNames.splash,
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
      path: RouteNames.home,
      builder: (context, state) => const HomePage(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Halaman tidak ditemukan: ${state.uri.toString()}'),
    ),
  ),
  redirect: (context, state) {
    // Protected routes - redirect to login if not authenticated
    // Note: The splash handles initial auth check, this is for deep links
    return null;
  },
);