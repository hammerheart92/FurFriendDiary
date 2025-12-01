import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../models/upcoming_care_event.dart';
import '../../../data/services/protocols/protocol_engine_service.dart';
import '../../../data/services/protocols/schedule_models.dart';
import '../../../data/repositories/protocols/vaccination_protocol_repository_impl.dart';
import '../../../data/repositories/protocols/deworming_protocol_repository_impl.dart';
import '../../../data/repositories/medication_repository_impl.dart';
import '../../../data/repositories/appointment_repository_impl.dart';
import '../../../data/repositories/vaccination_repository_impl.dart';
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
  int daysAhead = 365,
}) async {
  final protocolEngine = ref.watch(protocolEngineServiceProvider);

  // Get pet profile with protocol assignments from Hive
  final petBox = HiveManager.instance.petProfileBox;
  final pet = petBox.get(petId);
  if (pet == null) return [];

  final List<UpcomingCareEvent> events = [];

  // Define date range for upcoming events
  final now = DateTime.now();
  final startDate = DateTime(now.year, now.month, now.day); // Today at midnight
  final endDate = startDate.add(Duration(days: daysAhead));

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
              .where((entry) =>
                  entry.scheduledDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
                  entry.scheduledDate.isBefore(endDate))
              .map((entry) => VaccinationEvent(entry)),
        );
      } catch (e) {
        // Silent failure - continue with other events
      }
    }
  }

  // 2. Generate deworming schedule (if protocol assigned)
  if (pet.dewormingProtocolId != null) {
    final dewormingRepo = ref.watch(dewormingProtocolRepositoryProvider);
    final protocol = await dewormingRepo.getById(pet.dewormingProtocolId!);

    if (protocol != null) {
      try {
        // Convert daysAhead to months (rounded up) for protocol engine
        final lookAheadMonths = (daysAhead / 30).ceil();

        final schedule = await protocolEngine.generateDewormingSchedule(
          protocol: protocol,
          pet: pet,
          lookAheadMonths: lookAheadMonths,
        );

        events.addAll(
          schedule
              .where((entry) =>
                  entry.scheduledDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
                  entry.scheduledDate.isBefore(endDate))
              .map((entry) => DewormingEvent(entry)),
        );
      } catch (e) {
        // Silent failure - continue with other events
      }
    }
  }

  // 3. Add existing appointments
  try {
    final appointmentRepo = ref.watch(appointmentRepositoryProvider);
    final appointments = await appointmentRepo.getAppointmentsByPetId(petId);
    events.addAll(
      appointments
          .where((appt) =>
              appt.appointmentDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
              appt.appointmentDate.isBefore(endDate))
          .map((appt) => AppointmentEvent(appt)),
    );
  } catch (e) {
    // Silent failure - continue with other events
  }

  // 4. Add upcoming medications (active medications within date range)
  try {
    final medicationRepo = ref.watch(medicationRepositoryProvider);
    final medications = await medicationRepo.getMedicationsByPetId(petId);

    // Filter active medications that start within the date range
    events.addAll(
      medications
          .where((med) =>
            med.isActive &&
            med.startDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
            med.startDate.isBefore(endDate)
          )
          .map((med) => MedicationEvent(med)),
    );
  } catch (e) {
    // Silent failure - continue with other events
  }

  // 5. Add upcoming vaccination records (actual records with nextDueDate)
  // These are separate from protocol-generated schedules and include manually added vaccinations
  try {
    final vaccinationRepo = ref.watch(vaccinationRepositoryProvider);
    final vaccinations = await vaccinationRepo.getUpcomingVaccinations(petId);

    // Filter vaccinations with nextDueDate within the date range
    events.addAll(
      vaccinations
          .where((vax) =>
            vax.nextDueDate != null &&
            vax.nextDueDate!.isAfter(startDate.subtract(const Duration(days: 1))) &&
            vax.nextDueDate!.isBefore(endDate)
          )
          .map((vax) => VaccinationRecordEvent(vax)),
    );
  } catch (e) {
    // Silent failure - continue with other events
  }

  // 6. Sort by date and return
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

  // Generate full schedule with extended lookAhead to ensure future events are included
  // Using 24 months ensures protocols starting beyond current pet age are captured
  return await protocolEngine.generateDewormingSchedule(
    protocol: protocol,
    pet: pet,
    lookAheadMonths: 24,
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
  int daysAhead = 365,
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
