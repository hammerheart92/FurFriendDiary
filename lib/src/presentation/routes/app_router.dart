import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../ui/shell.dart';
import '../../ui/screens/home_screen.dart';
import '../../ui/screens/walks_screen.dart';
import '../../ui/screens/medications_screen.dart';
import '../../ui/screens/add_medication_screen.dart';
import '../../ui/screens/medication_detail_screen.dart';
import '../../ui/screens/appointments_screen.dart';
import '../../ui/screens/reports_screen.dart';
import '../../ui/screens/settings_screen.dart';
import '../../ui/screens/profile_edit_screen.dart';
import '../../ui/screens/terms_screen.dart';
import '../screens/pet_profile_setup_screen.dart';
import '../screens/pet_profile_screen.dart';
import '../screens/photo_gallery_screen.dart';
import '../screens/photo_detail_screen.dart';
import '../screens/medication_inventory_screen.dart';
import '../screens/purchase_history_screen.dart';
import '../screens/vet_list_screen.dart';
import '../screens/add_vet_screen.dart';
import '../screens/vet_detail_screen.dart';
import '../screens/reports_dashboard_screen.dart';
import '../screens/protocols/calendar_view_screen.dart';
import '../screens/protocols/deworming_protocol_selection_screen.dart';
import '../screens/protocols/deworming_schedule_screen.dart';
import '../screens/vaccinations/vaccination_form_screen.dart';
import '../screens/vaccinations/vaccination_timeline_screen.dart';
import '../screens/vaccinations/vaccination_detail_screen.dart';
import '../providers/pet_profile_provider.dart';
import '../../domain/models/pet_profile.dart';
import '../../domain/models/vaccination_event.dart';

final logger = Logger();

/// Provider for GoRouter - ensures router persists across app rebuilds
/// This prevents navigation state from being reset when locale/theme changes
final routerProvider = Provider<GoRouter>((ref) {
  return createRouter();
});

GoRouter createRouter() => GoRouter(
      initialLocation: '/',
      redirect: (context, state) async {
        logger.d(
            "🔍 DEBUG: Router redirect called, location: ${state.matchedLocation}");

        // Check if we need to create a ProviderContainer to access the provider
        try {
          // Create a temporary container to check setup status
          final container = ProviderContainer();
          final hasSetupAsync =
              await container.read(hasCompletedSetupProvider.future);
          container.dispose();

          logger.d("🔍 DEBUG: Setup completed: $hasSetupAsync");

          // If setup is not completed and not already on profile-setup, redirect there
          if (!hasSetupAsync && state.matchedLocation != '/profile-setup') {
            logger.d("🔍 DEBUG: Redirecting to profile setup");
            return '/profile-setup';
          }

          // If setup is completed and on profile-setup, redirect to main app
          if (hasSetupAsync && state.matchedLocation == '/profile-setup') {
            logger.d("🔍 DEBUG: Setup completed, redirecting to main app");
            return '/';
          }
        } catch (e) {
          logger.e("🚨 ERROR: Router redirect failed: $e");
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
        // Add/Edit pet route (bypasses setup redirect guard)
        GoRoute(
          path: '/add-pet',
          builder: (context, state) {
            final petId = state.extra as String?;
            return PetProfileSetupScreen(petId: petId);
          },
        ),
        GoRoute(
          path: '/edit-pet/:petId',
          builder: (context, state) {
            final petId = state.pathParameters['petId']!;
            return PetProfileSetupScreen(petId: petId);
          },
        ),
        ShellRoute(
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
            GoRoute(path: '/walks', builder: (_, __) => const WalksScreen()),
            GoRoute(
                path: '/meds', builder: (_, __) => const MedicationsScreen()),
            GoRoute(
                path: '/appointments',
                builder: (_, __) => const AppointmentsScreen()),
            GoRoute(
                path: '/reports', builder: (_, __) => const ReportsScreen()),
            GoRoute(
                path: '/analytics',
                builder: (_, __) => const ReportsDashboardScreen()),
            GoRoute(
                path: '/settings', builder: (_, __) => const SettingsScreen()),
            GoRoute(
                path: '/profiles',
                builder: (_, __) => const PetProfileScreen()),
            GoRoute(
              path: '/calendar',
              builder: (_, __) => const CalendarViewScreen(),
            ),
          ],
        ),
        // Medication routes
        GoRoute(
          path: '/meds/add',
          builder: (context, state) => const AddMedicationScreen(),
        ),
        GoRoute(
          path: '/meds/detail/:medicationId',
          builder: (context, state) {
            final medicationId = state.pathParameters['medicationId']!;
            return MedicationDetailScreen(medicationId: medicationId);
          },
        ),
        // Medication inventory routes
        GoRoute(
          path: '/medication-inventory',
          builder: (context, state) => const MedicationInventoryScreen(),
        ),
        GoRoute(
          path: '/purchase-history/:medicationId',
          builder: (context, state) {
            final medicationId = state.pathParameters['medicationId']!;
            return PurchaseHistoryScreen(medicationId: medicationId);
          },
        ),
        // Photo gallery routes
        GoRoute(
          path: '/photo-gallery',
          builder: (context, state) => const PhotoGalleryScreen(),
        ),
        GoRoute(
          path: '/photo-detail/:photoId',
          builder: (context, state) {
            final photoId = state.pathParameters['photoId']!;
            final extra = state.extra as Map<String, dynamic>?;
            final photoIds = extra?['photoIds'] as List<String>? ?? [photoId];
            final initialIndex = extra?['initialIndex'] as int? ?? 0;
            return PhotoDetailScreen(
              photoId: photoId,
              photoIds: photoIds,
              initialIndex: initialIndex,
            );
          },
        ),
        // Settings routes
        GoRoute(
          path: '/profile-edit',
          builder: (context, state) => const ProfileEditScreen(),
        ),
        GoRoute(
          path: '/terms',
          builder: (context, state) => const TermsScreen(),
        ),
        // Vet routes
        GoRoute(
          path: '/vet-list',
          builder: (context, state) => const VetListScreen(),
        ),
        GoRoute(
          path: '/add-vet',
          builder: (context, state) => const AddVetScreen(),
        ),
        GoRoute(
          path: '/edit-vet/:vetId',
          builder: (context, state) {
            final vetId = state.pathParameters['vetId']!;
            return AddVetScreen(vetId: vetId);
          },
        ),
        GoRoute(
          path: '/vet-detail/:vetId',
          builder: (context, state) {
            final vetId = state.pathParameters['vetId']!;
            return VetDetailScreen(vetId: vetId);
          },
        ),
        // Deworming protocol routes
        GoRoute(
          path: '/deworming/select/:petId',
          builder: (context, state) {
            final pet = state.extra as PetProfile;
            return DewormingProtocolSelectionScreen(pet: pet);
          },
        ),
        GoRoute(
          path: '/deworming/schedule/:petId',
          builder: (context, state) {
            final pet = state.extra as PetProfile;
            return DewormingScheduleScreen(pet: pet);
          },
        ),
        // Vaccination routes
        GoRoute(
          path: '/vaccinations',
          builder: (context, state) => VaccinationTimelineScreen(),
        ),
        GoRoute(
          path: '/vaccinations/add/:petId',
          builder: (context, state) {
            final petId = state.pathParameters['petId']!;
            return VaccinationFormScreen(petId: petId);
          },
        ),
        GoRoute(
          path: '/vaccinations/edit/:vaccinationId',
          builder: (context, state) {
            final event = state.extra as VaccinationEvent;
            return VaccinationFormScreen(
              petId: event.petId,
              existingEvent: event,
            );
          },
        ),
        GoRoute(
          path: '/vaccinations/detail/:vaccinationId',
          builder: (context, state) {
            final vaccinationId = state.pathParameters['vaccinationId']!;
            return VaccinationDetailScreen(vaccinationId: vaccinationId);
          },
        ),
      ],
    );
