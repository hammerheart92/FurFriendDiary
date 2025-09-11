
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          const paths = ['/', '/walks', '/meds', '/appointments', '/reports', '/settings'];
          context.go(paths[i]);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.restaurant), label: 'Feedings'),
          NavigationDestination(icon: Icon(Icons.pets), label: 'Walks'),
          NavigationDestination(icon: Icon(Icons.medical_services), label: 'Meds'),
          NavigationDestination(icon: Icon(Icons.event), label: 'Appts'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Reports'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
