
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ui/shell.dart';
import '../../ui/screens/feedings_screen.dart';
import '../../ui/screens/walks_screen.dart';
import '../../ui/screens/meds_screen.dart';
import '../../ui/screens/appointments_screen.dart';
import '../../ui/screens/reports_screen.dart';
import '../../ui/screens/settings_screen.dart';
import '../../ui/screens/premium_screen.dart';
import '../screens/pet_profile_setup_screen.dart';
import '../providers/pet_profile_provider.dart';

GoRouter createRouter() => GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    print("🔍 DEBUG: Router redirect called, location: ${state.matchedLocation}");
    
    // Check if we need to create a ProviderContainer to access the provider
    try {
      // Create a temporary container to check setup status
      final container = ProviderContainer();
      final hasSetupAsync = await container.read(hasCompletedSetupProvider.future);
      container.dispose();
      
      print("🔍 DEBUG: Setup completed: $hasSetupAsync");
      
      // If setup is not completed and not already on profile-setup, redirect there
      if (!hasSetupAsync && state.matchedLocation != '/profile-setup') {
        print("🔍 DEBUG: Redirecting to profile setup");
        return '/profile-setup';
      }
      
      // If setup is completed and on profile-setup, redirect to main app
      if (hasSetupAsync && state.matchedLocation == '/profile-setup') {
        print("🔍 DEBUG: Setup completed, redirecting to main app");
        return '/';
      }
      
    } catch (e) {
      print("🚨 ERROR: Router redirect failed: $e");
      // If there's an error, assume setup is needed
      if (state.matchedLocation != '/profile-setup') {
        return '/profile-setup';
      }
    }
    
    return null;
  },
  routes: [
    GoRoute(
      path: '/profile-setup',
      builder: (context, state) => const PetProfileSetupScreen(),
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
