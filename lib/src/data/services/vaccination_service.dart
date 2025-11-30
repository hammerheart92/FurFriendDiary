import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';
import '../../domain/models/vaccination_event.dart';
import '../../domain/models/pet_profile.dart';
import '../../domain/models/protocols/vaccination_protocol.dart';
import '../../domain/repositories/vaccination_repository.dart';
import '../../domain/repositories/protocols/vaccination_protocol_repository.dart';
import '../repositories/vaccination_repository_impl.dart';
import '../repositories/protocols/vaccination_protocol_repository_impl.dart';
import 'protocols/protocol_engine_service.dart';
import 'protocols/schedule_models.dart';

part 'vaccination_service.g.dart';

/// Summary statistics for a pet's vaccinations
class VaccinationSummary {
  final int totalVaccinations;
  final int upcomingCount;
  final int overdueCount;
  final int completedThisYear;
  final DateTime? nextDueDate;
  final String? nextDueVaccineType;
  final List<String> overdueVaccineTypes;

  const VaccinationSummary({
    required this.totalVaccinations,
    required this.upcomingCount,
    required this.overdueCount,
    required this.completedThisYear,
    this.nextDueDate,
    this.nextDueVaccineType,
    this.overdueVaccineTypes = const [],
  });

  bool get hasOverdue => overdueCount > 0;
  bool get hasUpcoming => upcomingCount > 0;
  bool get isUpToDate => overdueCount == 0;
}

/// Service layer for vaccination business logic
///
/// Provides methods to:
/// - Generate vaccination events from protocols
/// - Track vaccination completion
/// - Schedule boosters
/// - Get vaccination statistics
class VaccinationService {
  final VaccinationRepository vaccinationRepository;
  final VaccinationProtocolRepository protocolRepository;
  final ProtocolEngineService protocolEngine;
  final Logger logger;

  VaccinationService({
    required this.vaccinationRepository,
    required this.protocolRepository,
    required this.protocolEngine,
    Logger? logger,
  }) : logger = logger ?? Logger();

  // ============================================================================
  // CORE METHOD 1: Generate Vaccinations from Protocol
  // ============================================================================

  /// Generate vaccination events from a protocol for a pet
  ///
  /// **Algorithm:**
  /// 1. Load the vaccination protocol by ID
  /// 2. Use ProtocolEngineService to generate schedule entries
  /// 3. Convert schedule entries to VaccinationEvent objects
  /// 4. Save events to repository
  ///
  /// **Returns:**
  /// List of created VaccinationEvent objects
  Future<List<VaccinationEvent>> generateVaccinationsFromProtocol({
    required PetProfile pet,
    required String protocolId,
    int lookAheadMonths = 12,
  }) async {
    try {
      // Load the protocol
      final protocol = await protocolRepository.getById(protocolId);
      if (protocol == null) {
        logger.e('Protocol not found: $protocolId');
        return [];
      }

      // Generate schedule using protocol engine
      final scheduleEntries = await protocolEngine.generateVaccinationSchedule(
        pet: pet,
        protocol: protocol,
      );

      // Filter to only include entries within look-ahead window
      final now = DateTime.now();
      final endDate = DateTime(
        now.year,
        now.month + lookAheadMonths,
        now.day,
      );

      final filteredEntries = scheduleEntries.where((entry) {
        return entry.scheduledDate.isBefore(endDate);
      }).toList();

      // Convert to VaccinationEvent objects
      final events = <VaccinationEvent>[];
      for (int i = 0; i < filteredEntries.length; i++) {
        final entry = filteredEntries[i];
        final event = VaccinationEvent(
          petId: pet.id,
          vaccineType: entry.vaccineName,
          administeredDate: entry.scheduledDate,
          nextDueDate: _calculateNextDueDate(entry, protocol),
          notes: entry.notes,
          isFromProtocol: true,
          protocolId: protocolId,
          protocolStepIndex: entry.stepIndex,
        );
        events.add(event);

        // Save to repository
        await vaccinationRepository.addVaccination(event);
      }

      logger.i(
          'Generated ${events.length} vaccination events for pet ${pet.id} from protocol $protocolId');
      return events;
    } catch (e) {
      logger.e('Failed to generate vaccinations from protocol: $e');
      rethrow;
    }
  }

  /// Calculate next due date based on protocol step
  DateTime? _calculateNextDueDate(
    VaccinationScheduleEntry entry,
    VaccinationProtocol protocol,
  ) {
    if (entry.stepIndex >= protocol.steps.length) return null;

    final step = protocol.steps[entry.stepIndex];

    // If there's a recurring schedule, use that
    if (step.recurring != null) {
      return protocolEngine.addMonths(
        entry.scheduledDate,
        step.recurring!.intervalMonths,
      );
    }

    // If there's a next step, use that date
    if (entry.stepIndex + 1 < protocol.steps.length) {
      final nextStep = protocol.steps[entry.stepIndex + 1];
      if (nextStep.intervalDays != null) {
        return entry.scheduledDate.add(Duration(days: nextStep.intervalDays!));
      }
    }

    return null;
  }

  // ============================================================================
  // CORE METHOD 2: Mark Vaccination as Completed
  // ============================================================================

  /// Mark a scheduled vaccination as completed
  ///
  /// Updates the vaccination record with:
  /// - Actual administered date
  /// - Optional veterinarian and clinic info
  /// - Optional batch number
  /// - Updated timestamp
  Future<VaccinationEvent> markVaccinationAsCompleted({
    required String vaccinationId,
    required DateTime completedDate,
    String? veterinarianName,
    String? clinicName,
    String? batchNumber,
    String? notes,
    List<String>? certificatePhotoUrls,
  }) async {
    try {
      final existing = await vaccinationRepository.getVaccinationById(vaccinationId);
      if (existing == null) {
        throw Exception('Vaccination not found: $vaccinationId');
      }

      final updated = existing.copyWith(
        administeredDate: completedDate,
        veterinarianName: veterinarianName ?? existing.veterinarianName,
        clinicName: clinicName ?? existing.clinicName,
        batchNumber: batchNumber ?? existing.batchNumber,
        notes: notes ?? existing.notes,
        certificatePhotoUrls: certificatePhotoUrls ?? existing.certificatePhotoUrls,
        updatedAt: DateTime.now(),
      );

      await vaccinationRepository.updateVaccination(updated);
      logger.i('Marked vaccination $vaccinationId as completed on $completedDate');
      return updated;
    } catch (e) {
      logger.e('Failed to mark vaccination as completed: $e');
      rethrow;
    }
  }

  // ============================================================================
  // CORE METHOD 3: Schedule Next Booster
  // ============================================================================

  /// Schedule the next booster vaccination
  ///
  /// Creates a new VaccinationEvent for the booster with:
  /// - Same vaccine type as original
  /// - Scheduled for the specified date
  /// - Linked to same protocol (if applicable)
  Future<VaccinationEvent> scheduleNextBooster({
    required String vaccinationId,
    required DateTime nextBoosterDate,
    String? notes,
  }) async {
    try {
      final existing = await vaccinationRepository.getVaccinationById(vaccinationId);
      if (existing == null) {
        throw Exception('Vaccination not found: $vaccinationId');
      }

      // Update the existing vaccination's nextDueDate
      final updatedExisting = existing.copyWith(
        nextDueDate: nextBoosterDate,
        updatedAt: DateTime.now(),
      );
      await vaccinationRepository.updateVaccination(updatedExisting);

      // Create new booster event
      final boosterEvent = VaccinationEvent(
        petId: existing.petId,
        vaccineType: existing.vaccineType,
        administeredDate: nextBoosterDate,
        notes: notes ?? 'Booster for ${existing.vaccineType}',
        isFromProtocol: existing.isFromProtocol,
        protocolId: existing.protocolId,
        protocolStepIndex: existing.protocolStepIndex != null
            ? existing.protocolStepIndex! + 1
            : null,
      );

      await vaccinationRepository.addVaccination(boosterEvent);
      logger.i('Scheduled booster vaccination for ${existing.vaccineType} on $nextBoosterDate');
      return boosterEvent;
    } catch (e) {
      logger.e('Failed to schedule booster: $e');
      rethrow;
    }
  }

  // ============================================================================
  // CORE METHOD 4: Get Vaccination Summary
  // ============================================================================

  /// Get a summary of vaccination statistics for a pet
  Future<VaccinationSummary> getVaccinationSummaryForPet(String petId) async {
    try {
      final allVaccinations = await vaccinationRepository.getVaccinationsByPetId(petId);
      final upcoming = await vaccinationRepository.getUpcomingVaccinations(petId);
      final overdue = await vaccinationRepository.getOverdueVaccinations(petId);

      // Count vaccinations completed this year
      final now = DateTime.now();
      final startOfYear = DateTime(now.year, 1, 1);
      final completedThisYear = allVaccinations.where((v) {
        return v.administeredDate.isAfter(startOfYear) &&
            v.administeredDate.isBefore(now);
      }).length;

      // Find next due vaccination
      DateTime? nextDueDate;
      String? nextDueVaccineType;
      if (upcoming.isNotEmpty) {
        // upcoming is already sorted by nextDueDate (soonest first)
        final nextDue = upcoming.first;
        nextDueDate = nextDue.nextDueDate;
        nextDueVaccineType = nextDue.vaccineType;
      }

      // Get overdue vaccine types
      final overdueVaccineTypes = overdue.map((v) => v.vaccineType).toSet().toList();

      final summary = VaccinationSummary(
        totalVaccinations: allVaccinations.length,
        upcomingCount: upcoming.length,
        overdueCount: overdue.length,
        completedThisYear: completedThisYear,
        nextDueDate: nextDueDate,
        nextDueVaccineType: nextDueVaccineType,
        overdueVaccineTypes: overdueVaccineTypes,
      );

      logger.i('Generated vaccination summary for pet $petId: '
          '${summary.totalVaccinations} total, '
          '${summary.upcomingCount} upcoming, '
          '${summary.overdueCount} overdue');

      return summary;
    } catch (e) {
      logger.e('Failed to get vaccination summary: $e');
      rethrow;
    }
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Check if a specific vaccine type is due for a pet
  Future<bool> isVaccineDue(String petId, String vaccineType) async {
    final lastVaccination = await vaccinationRepository.getLastVaccinationByType(
      petId,
      vaccineType,
    );

    if (lastVaccination == null) {
      return true; // Never vaccinated
    }

    if (lastVaccination.nextDueDate == null) {
      return false; // No next due date set
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return lastVaccination.nextDueDate!.isBefore(today) ||
        lastVaccination.nextDueDate!.isAtSameMomentAs(today);
  }

  /// Get all available vaccine types that have been administered to a pet
  Future<List<String>> getVaccineTypesForPet(String petId) async {
    final vaccinations = await vaccinationRepository.getVaccinationsByPetId(petId);
    return vaccinations.map((v) => v.vaccineType).toSet().toList();
  }
}

// ============================================================================
// RIVERPOD PROVIDER
// ============================================================================

@riverpod
VaccinationService vaccinationService(VaccinationServiceRef ref) {
  return VaccinationService(
    vaccinationRepository: ref.watch(vaccinationRepositoryProvider),
    protocolRepository: ref.watch(vaccinationProtocolRepositoryProvider),
    protocolEngine: ref.watch(protocolEngineServiceProvider),
  );
}
