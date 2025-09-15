
import 'package:go_router/go_router.dart';
import 'ui/shell.dart';
import 'ui/screens/feedings_screen.dart';
import 'ui/screens/walks_screen.dart';
import 'ui/screens/meds_screen.dart';
import 'ui/screens/appointments_screen.dart';
import 'ui/screens/reports_screen.dart';
import 'ui/screens/settings_screen.dart';
import 'ui/screens/premium_screen.dart';
import 'ui/screens/profile_setup_screen.dart';

GoRouter createRouter() => GoRouter(
  initialLocation: '/profile-setup',
  routes: [
    GoRoute(
      path: '/profile-setup',
      builder: (context, state) => const ProfileSetupScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (_, __) => const FeedingsScreen()),
        GoRoute(path: '/walks', builder: (_, __) => const WalksScreen()),
        GoRoute(path: '/meds', builder: (_, __) => const MedsScreen()),
        GoRoute(path: '/appointments', builder: (_, __) => const AppointmentsScreen()),
        GoRoute(path: '/reports', builder: (_, __) => const ReportsScreen()),
        GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
        GoRoute(path: '/premium', builder: (_, __) => const PremiumScreen()),
      ],
    ),
  ],
);
