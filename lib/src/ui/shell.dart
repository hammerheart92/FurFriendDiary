import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  int _indexFor(String location) {
    return switch (location) {
      '/' => 0,
      '/walks' => 1,
      '/meds' => 2,
      '/appointments' => 3,
      '/reports' => 4,
      '/settings' => 5,
      _ => 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _indexFor(location);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          const paths = [
            '/',
            '/walks',
            '/meds',
            '/appointments',
            '/reports',
            '/settings'
          ];
          context.go(paths[i]);
        },
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.restaurant), label: l10n.navFeedings),
          NavigationDestination(
              icon: const Icon(Icons.pets), label: l10n.navWalks),
          NavigationDestination(
              icon: const Icon(Icons.medical_services), label: l10n.navMeds),
          NavigationDestination(
              icon: const Icon(Icons.event), label: l10n.navAppts),
          NavigationDestination(
              icon: const Icon(Icons.bar_chart), label: l10n.navReports),
          NavigationDestination(
              icon: const Icon(Icons.settings), label: l10n.navSettings),
        ],
      ),
    );
  }
}
