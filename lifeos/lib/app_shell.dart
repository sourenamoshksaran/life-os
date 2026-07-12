import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'theme/tokens/colors.dart';

/// Bottom Navigation: exactly 5 tabs — Dashboard, Tasks, Timeline, Results,
/// Life Designer (docs/03_System_Architecture.md §14, CLAUDE.md §11).
/// Command Center and Search are NOT tabs — Command Center lives inside
/// Dashboard (RFC-001 §5); Search is header-accessed (deferred, no
/// implementation yet — see IMPLEMENTATION_REPORT.md).
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        backgroundColor: LifeOSColors.card,
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) =>
            navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex),
        destinations: const [
          NavigationDestination(
              icon: Icon(PhosphorIconsRegular.squaresFour), label: 'Dashboard'),
          NavigationDestination(icon: Icon(PhosphorIconsRegular.checkSquare), label: 'Tasks'),
          NavigationDestination(icon: Icon(PhosphorIconsRegular.clockCountdown), label: 'Timeline'),
          NavigationDestination(icon: Icon(PhosphorIconsRegular.chartBar), label: 'Results'),
          NavigationDestination(icon: Icon(PhosphorIconsRegular.slidersHorizontal), label: 'Life Designer'),
        ],
      ),
    );
  }
}
