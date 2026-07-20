import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNavBar({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/katalog')) return 1;
    if (location.startsWith('/peminjaman')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(RouteNames.home);
        break;
      case 1:
        context.go('/katalog');
        break;
      case 2:
        context.go('/peminjaman');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(context, index),
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryContainer,
        surfaceTintColor: Colors.transparent,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.primary),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book, color: AppColors.primary),
            label: 'Katalog',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history, color: AppColors.primary),
            label: 'Peminjaman',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person, color: AppColors.primary),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
