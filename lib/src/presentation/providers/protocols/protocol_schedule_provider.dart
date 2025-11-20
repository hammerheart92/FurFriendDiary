import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/upcoming_care_event.dart';
import '../../../data/services/protocols/protocol_engine_service.dart';
import '../../../data/services/protocols/schedule_models.dart';
import '../../../data/repositories/protocols/vaccination_protocol_repository_impl.dart';
import '../../../data/repositories/protocols/deworming_protocol_repository_impl.dart';
import '../../../data/repositories/medication_repository_impl.dart';
import '../../../data/repositories/appointment_repository_impl.dart';
import '../../../data/local/hive_manager.dart';

part 'protocol_schedule_provider.g.dart';

// ============================================================================
// UPCOMING CARE AGGREGATOR PROVIDER
// ============================================================================

/// Unified upcoming care events provider - aggregates all types of care
///
/// This provider combines vaccination schedules, deworming schedules,
/// appointments, and medications into a single type-safe list sorted by date.
///
/// Usage:
/// ```dart
/// final upcomingEvents = await ref.read(upcomingCareProvider(
///   petId: 'pet-123',
///   daysAhead: 90,
/// ).future);
/// ```
@riverpod
Future<List<UpcomingCareEvent>> upcomingCare(
  UpcomingCareRef ref, {
  required String petId,
  int daysAhead = 90,
}) async {
  final protocolEngine = ref.watch(protocolEngineServiceProvider);

  // Get pet profile with protocol assignments from Hive
  final petBox = HiveManager.instance.petProfileBox;
  final pet = petBox.get(petId);
  if (pet == null) return [];

  final List<UpcomingCareEvent> events = [];
  final endDate = DateTime.now().add(Duration(days: daysAhead));

  // 1. Generate vaccination schedule (if protocol assigned)
  if (pet.vaccinationProtocolId != null) {
    final vaccinationRepo = ref.watch(vaccinationProtocolRepositoryProvider);
    final protocol = await vaccinationRepo.getById(pet.vaccinationProtocolId!);

    if (protocol != null) {
      try {
        final schedule = await protocolEngine.generateVaccinationSchedule(
          protocol: protocol,
          pet: pet,
        );

        // Convert to VaccinationEvent and filter by date range
        events.addAll(
          schedule
              .where((entry) => entry.scheduledDate.isBefore(endDate))
              .map((entry) => VaccinationEvent(entry)),
        );
      } catch (e) {
        // Log error but continue with other events
        print('Error generating vaccination schedule: $e');
      }
    }
  }

  // 2. Generate deworming schedule (if protocol assigned)
  if (pet.dewormingProtocolId != null) {
    final dewormingRepo = ref.watch(dewormingProtocolRepositoryProvider);
    final protocol = await dewormingRepo.getById(pet.dewormingProtocolId!);

    if (protocol != null) {
      try {
        final schedule = await protocolEngine.generateDewormingSchedule(
          protocol: protocol,
          pet: pet,
        );

        events.addAll(
          schedule
              .where((entry) => entry.scheduledDate.isBefore(endDate))
              .map((entry) => DewormingEvent(entry)),
        );
      } catch (e) {
        // Log error but continue with other events
        print('Error generating deworming schedule: $e');
      }
    }
  }

  // 3. Add existing appointments
  try {
    final appointmentRepo = ref.watch(appointmentRepositoryProvider);
    final appointments = await appointmentRepo.getAppointmentsByPetId(petId);
    events.addAll(
      appointments
          .where((appt) => appt.appointmentDate.isBefore(endDate))
          .map((appt) => AppointmentEvent(appt)),
    );
  } catch (e) {
    print('Error loading appointments: $e');
  }

  // 4. Add upcoming medications (active medications within date range)
  try {
    final medicationRepo = ref.watch(medicationRepositoryProvider);
    final medications = await medicationRepo.getMedicationsByPetId(petId);

    // Filter active medications that end within the date range
    events.addAll(
      medications
          .where((med) =>
            med.isActive &&
            med.endDate != null &&
            med.endDate!.isBefore(endDate) &&
            med.endDate!.isAfter(DateTime.now())
          )
          .map((med) => MedicationEvent(med)),
    );
  } catch (e) {
    print('Error loading medications: $e');
  }

  // 5. Sort by date and return
  events.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  return events;
}

// ============================================================================
// INDIVIDUAL SCHEDULE PROVIDERS
// ============================================================================

/// Generate vaccination schedule for a specific pet
///
/// Returns calculated vaccination dates based on the pet's assigned protocol.
/// Returns empty list if no protocol is assigned or pet not found.
///
/// Usage:
/// ```dart
/// final schedule = await ref.read(vaccinationScheduleProvider('pet-123').future);
/// ```
@riverpod
Future<List<VaccinationScheduleEntry>> vaccinationSchedule(
  VaccinationScheduleRef ref,
  String petId,
) async {
  final protocolEngine = ref.watch(protocolEngineServiceProvider);

  final petBox = HiveManager.instance.petProfileBox;
  final pet = petBox.get(petId);
  if (pet == null || pet.vaccinationProtocolId == null) return [];

  final vaccinationRepo = ref.watch(vaccinationProtocolRepositoryProvider);
  final protocol = await vaccinationRepo.getById(pet.vaccinationProtocolId!);
  if (protocol == null) return [];

  return await protocolEngine.generateVaccinationSchedule(
    protocol: protocol,
    pet: pet,
  );
}

/// Generate deworming schedule for a specific pet
///
/// Returns calculated deworming treatment dates based on the pet's assigned protocol.
/// Returns empty list if no protocol is assigned or pet not found.
///
/// Usage:
/// ```dart
/// final schedule = await ref.read(dewormingScheduleProvider('pet-123').future);
/// ```
@riverpod
Future<List<DewormingScheduleEntry>> dewormingSchedule(
  DewormingScheduleRef ref,
  String petId,
) async {
  final protocolEngine = ref.watch(protocolEngineServiceProvider);

  final petBox = HiveManager.instance.petProfileBox;
  final pet = petBox.get(petId);
  if (pet == null || pet.dewormingProtocolId == null) return [];

  final dewormingRepo = ref.watch(dewormingProtocolRepositoryProvider);
  final protocol = await dewormingRepo.getById(pet.dewormingProtocolId!);
  if (protocol == null) return [];

  return await protocolEngine.generateDewormingSchedule(
    protocol: protocol,
    pet: pet,
  );
}

/// Generate appointment suggestions for a specific pet
///
/// Analyzes due protocols and suggests consolidated vet appointments.
/// Groups multiple protocols that are due around the same time.
///
/// Usage:
/// ```dart
/// final suggestions = await ref.read(appointmentSuggestionsProvider('pet-123').future);
/// ```
@riverpod
Future<List<AppointmentSuggestion>> appointmentSuggestions(
  AppointmentSuggestionsRef ref,
  String petId,
) async {
  final protocolEngine = ref.watch(protocolEngineServiceProvider);

  final petBox = HiveManager.instance.petProfileBox;
  final pet = petBox.get(petId);
  if (pet == null) return [];

  return await protocolEngine.suggestNextAppointment(
    pet: pet,
  );
}

// ============================================================================
// FILTERED UPCOMING CARE PROVIDERS
// ============================================================================

/// Get upcoming care events filtered by event type
///
/// Usage:
/// ```dart
/// final vaccinations = await ref.read(upcomingCareByTypeProvider(
///   petId: 'pet-123',
///   eventType: 'vaccination',
/// ).future);
/// ```
@riverpod
Future<List<UpcomingCareEvent>> upcomingCareByType(
  UpcomingCareByTypeRef ref, {
  required String petId,
  required String eventType,
  int daysAhead = 90,
}) async {
  final allEvents = await ref.watch(upcomingCareProvider(
    petId: petId,
    daysAhead: daysAhead,
  ).future);

  return allEvents.where((event) => event.eventType == eventType).toList();
}

/// Get only overdue care events
///
/// Usage:
/// ```dart
/// final overdueEvents = await ref.read(overdueCareProvider('pet-123').future);
/// ```
@riverpod
Future<List<UpcomingCareEvent>> overdueCare(
  OverdueCareRef ref,
  String petId,
) async {
  final allEvents = await ref.watch(upcomingCareProvider(
    petId: petId,
    daysAhead: 365, // Look back up to a year
  ).future);

  final now = DateTime.now();
  return allEvents
      .where((event) => event.scheduledDate.isBefore(now))
      .toList();
}

/// Get care events due soon (within specified days)
///
/// Usage:
/// ```dart
/// final dueSoon = await ref.read(dueSoonCareProvider(
///   petId: 'pet-123',
///   daysAhead: 7,
/// ).future);
/// ```
@riverpod
Future<List<UpcomingCareEvent>> dueSoonCare(
  DueSoonCareRef ref, {
  required String petId,
  int daysAhead = 7,
}) async {
  final allEvents = await ref.watch(upcomingCareProvider(
    petId: petId,
    daysAhead: daysAhead,
  ).future);

  return allEvents;
}
