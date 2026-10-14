import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_typography.dart';
import '../widgets/skip_to_content.dart';

class ScaffoldWithNavBar extends StatefulWidget {
  final Widget child;

  const ScaffoldWithNavBar({super.key, required this.child});

  @override
  State<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends State<ScaffoldWithNavBar> {
  late final FocusNode _contentFocusNode;

  @override
  void initState() {
    super.initState();
    _contentFocusNode = FocusNode(debugLabel: 'main-content');
  }

  @override
  void dispose() {
    _contentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: Column(
              children: [
                SkipToContent(targetFocusNode: _contentFocusNode),
                Expanded(
                  child: Focus(
                    focusNode: _contentFocusNode,
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.outlineVariant, width: 1),
            ),
          ),
          child: NavigationBar(
            selectedIndex: _calculateSelectedIndex(context),
            onDestinationSelected: (index) => _onItemTapped(context, index),
            backgroundColor: AppColors.surfaceContainerLowest,
            indicatorColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            height: 72,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            elevation: 0,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_outlined, color: AppColors.primary),
                label: 'Beranda',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_book),
                selectedIcon: Icon(Icons.menu_book, color: AppColors.primary),
                label: 'Katalog',
              ),
              NavigationDestination(
                icon: Icon(Icons.assignment_outlined),
                selectedIcon: Icon(Icons.assignment, color: AppColors.primary),
                label: 'Pinjaman',
              ),
              NavigationDestination(
                icon: Icon(Icons.person),
                selectedIcon: Icon(Icons.person, color: AppColors.primary),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }

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
        context.go(RouteNames.katalog);
        break;
      case 2:
        context.go(RouteNames.peminjaman);
        break;
      case 3:
        context.go(RouteNames.profile);
        break;
    }
  }
}
