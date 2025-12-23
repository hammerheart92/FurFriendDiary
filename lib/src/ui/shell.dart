import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
import '../../theme/tokens/colors.dart';

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

    // Theme detection
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

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
        backgroundColor: surfaceColor,
        indicatorColor: DesignColors.highlightTeal.withOpacity(0.15),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined, color: secondaryText),
            selectedIcon:
                Icon(Icons.home, color: DesignColors.highlightTeal),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: Icon(Icons.pets_outlined, color: secondaryText),
            selectedIcon:
                Icon(Icons.pets, color: DesignColors.highlightTeal),
            label: l10n.navWalks,
          ),
          NavigationDestination(
            icon: Icon(Icons.medical_services_outlined, color: secondaryText),
            selectedIcon:
                Icon(Icons.medical_services, color: DesignColors.highlightTeal),
            label: l10n.navMeds,
          ),
          NavigationDestination(
            icon: Icon(Icons.event_outlined, color: secondaryText),
            selectedIcon:
                Icon(Icons.event, color: DesignColors.highlightTeal),
            label: l10n.navAppts,
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined, color: secondaryText),
            selectedIcon:
                Icon(Icons.bar_chart, color: DesignColors.highlightTeal),
            label: l10n.navReports,
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined, color: secondaryText),
            selectedIcon:
                Icon(Icons.settings, color: DesignColors.highlightTeal),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}
