import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/models/pet_profile.dart';
import '../../../domain/models/protocols/vaccination_protocol.dart';
import '../../../domain/models/protocols/deworming_protocol.dart';
import '../../../domain/models/medication_entry.dart';
import '../../../domain/models/appointment_entry.dart';
import '../../../domain/repositories/protocols/vaccination_protocol_repository.dart';
import '../../../domain/repositories/protocols/deworming_protocol_repository.dart';
import '../../repositories/protocols/vaccination_protocol_repository_impl.dart';
import '../../repositories/protocols/deworming_protocol_repository_impl.dart';
import 'schedule_models.dart';

part 'protocol_engine_service.g.dart';

/// Core business logic service for smart scheduling
///
/// ProtocolEngineService is the "brain" of Phase 1: Smart Scheduling.
/// It provides methods to:
/// - Calculate vaccination dates based on pet age and protocol definitions
/// - Generate complete deworming schedules automatically
/// - Suggest upcoming appointments based on due protocols
/// - Link protocols to actual medication/appointment entries
///
/// This service does NOT persist data - it only generates calculated schedules
/// and suggestions. The presentation layer is responsible for saving to repositories.
class ProtocolEngineService {
  final VaccinationProtocolRepository vaccinationProtocolRepository;
  final DewormingProtocolRepository dewormingProtocolRepository;
  final Logger logger;

  ProtocolEngineService({
    required this.vaccinationProtocolRepository,
    required this.dewormingProtocolRepository,
    Logger? logger,
  }) : logger = logger ?? Logger();

  // ============================================================================
  // CORE METHOD 1: Calculate Next Vaccination Date
  // ============================================================================

  /// Calculate the next vaccination date for a pet based on protocol and step
  ///
  /// **Algorithm:**
  /// 1. If this is the first dose: `birthdate + ageInWeeks`
  /// 2. If this is a booster: `lastDoseDate + intervalDays`
  /// 3. Validate pet has a birthdate
  /// 4. Validate step index is valid
  ///
  /// **Returns:**
  /// - `DateTime` with the calculated date
  /// - `null` if pet has no birthdate or step is invalid
  ///
  /// **Example:**
  /// ```dart
  /// final service = ref.read(protocolEngineServiceProvider);
  /// final date = await service.calculateNextVaccinationDate(
  ///   pet: myPuppy,
  ///   protocol: rabiesProtocol,
  ///   stepIndex: 0, // First dose
  /// );
  /// // Returns: puppy.birthday + 16 weeks
  /// ```
  Future<DateTime?> calculateNextVaccinationDate({
    required PetProfile pet,
    required VaccinationProtocol protocol,
    required int stepIndex,
    DateTime? lastAdministeredDate,
  }) async {
    // Step 1: Validate inputs
    if (pet.birthday == null) {
      logger.w(
          'Cannot calculate vaccination date: Pet ${pet.id} has no birthdate');
      return null;
    }

    if (stepIndex < 0 || stepIndex >= protocol.steps.length) {
      logger.e('Invalid step index $stepIndex for protocol ${protocol.id}');
      return null;
    }

    final step = protocol.steps[stepIndex];

    // Step 2: Calculate base date
    DateTime calculatedDate;

    // Determine if this is an age-based or interval-based step
    // Age-based steps: Calculate from birthday + ageInWeeks
    // Interval-based steps: Calculate from last dose + intervalDays
    final isAgeBased = step.intervalDays == null;

    if (isAgeBased || lastAdministeredDate == null) {
      // Age-based dose: Calculate from birthdate + ageInWeeks
      calculatedDate = pet.birthday!.add(Duration(days: step.ageInWeeks * 7));
      logger.d(
          'First dose calculation for ${step.vaccineName}: ${pet.birthday} + ${step.ageInWeeks} weeks = $calculatedDate');
    } else {
      // Interval-based dose: Calculate from last dose + intervalDays
      if (step.intervalDays == null) {
        logger.e(
            'Step $stepIndex has no intervalDays for booster calculation');
        return null;
      }
      calculatedDate =
          lastAdministeredDate.add(Duration(days: step.intervalDays!));
      logger.d(
          'Booster calculation for ${step.vaccineName}: $lastAdministeredDate + ${step.intervalDays} days = $calculatedDate');
    }

    // Step 3: Log if date is in the future (pet too young)
    final now = DateTime.now();
    if (calculatedDate.isAfter(now)) {
      logger.i(
          'Vaccination date $calculatedDate is in the future (pet is ${calculateAgeInWeeks(pet.birthday)} weeks old)');
    }

    return calculatedDate;
  }

  // ============================================================================
  // CORE METHOD 2: Generate Full Vaccination Schedule
  // ============================================================================

  /// Generate a complete vaccination schedule for a pet based on a protocol
  ///
  /// **Returns:**
  /// A list of `VaccinationScheduleEntry` containing:
  /// - Step index
  /// - Vaccine name
  /// - Calculated date
  /// - Notes
  /// - Is required flag
  ///
  /// **Important:**
  /// This does NOT create MedicationEntry records - it only generates the plan
  /// for review by the user before confirmation.
  ///
  /// **Example:**
  /// ```dart
  /// final schedule = await service.generateVaccinationSchedule(
  ///   pet: myPuppy,
  ///   protocol: canineCoreFrotocol,
  /// );
  /// // Returns: [
  /// //   VaccinationScheduleEntry(DHPPiL at 6 weeks),
  /// //   VaccinationScheduleEntry(DHPPiL at 9 weeks),
  /// //   VaccinationScheduleEntry(Rabies at 16 weeks),
  /// //   ...
  /// // ]
  /// ```
  Future<List<VaccinationScheduleEntry>> generateVaccinationSchedule({
    required PetProfile pet,
    required VaccinationProtocol protocol,
    List<DateTime>? alreadyAdministeredDates,
  }) async {
    final scheduleEntries = <VaccinationScheduleEntry>[];

    DateTime? lastAdministeredDate;
    for (int i = 0; i < protocol.steps.length; i++) {
      final step = protocol.steps[i];

      // Use provided date if available, otherwise calculate
      if (alreadyAdministeredDates != null &&
          i < alreadyAdministeredDates.length) {
        lastAdministeredDate = alreadyAdministeredDates[i];
      }

      // Determine if this is an age-based or interval-based step
      // Age-based steps have ageInWeeks defined and should calculate from birthday
      // Interval-based steps have intervalDays defined and should calculate from last dose
      final isIntervalBased = step.intervalDays != null;

      final calculatedDate = await calculateNextVaccinationDate(
        pet: pet,
        protocol: protocol,
        stepIndex: i,
        lastAdministeredDate: isIntervalBased ? lastAdministeredDate : null,
      );

      if (calculatedDate == null) {
        logger.w(
            'Skipping step $i for protocol ${protocol.id}: Could not calculate date');
        continue;
      }

      print('🔧 [ENGINE] Protocol: ${protocol.name}');
      print('🔧 [ENGINE] Step ${i + 1}: ${step.vaccineName}');
      print('🔧 [ENGINE] notes: ${step.notes}');
      print('🔧 [ENGINE] notesRo: ${step.notesRo}');

      scheduleEntries.add(VaccinationScheduleEntry(
        stepIndex: i,
        vaccineName: step.vaccineName,
        scheduledDate: calculatedDate,
        notes: step.notes,
        notesRo: step.notesRo,
        isRequired: step.isRequired,
      ));

      lastAdministeredDate = calculatedDate;

      // Handle recurring schedules (annual boosters)
      if (step.recurring != null) {
        final recurring = step.recurring!;
        // For indefinite schedules, generate 3 future doses
        // For limited schedules, use numberOfDoses
        final dosesToSchedule =
            recurring.indefinitely ? 3 : (recurring.numberOfDoses ?? 0);

        for (int j = 0; j < dosesToSchedule; j++) {
          final recurringDate = addMonths(
            calculatedDate,
            recurring.intervalMonths * (j + 1),
          );

          scheduleEntries.add(VaccinationScheduleEntry(
            stepIndex: i,
            vaccineName: '${step.vaccineName} (Booster ${j + 1})',
            scheduledDate: recurringDate,
            notes: 'Annual/periodic booster',
            isRequired: step.isRequired,
          ));
        }
      }
    }

    logger.i(
        'Generated ${scheduleEntries.length} vaccination schedule entries for pet ${pet.id} using protocol ${protocol.name}');
    return scheduleEntries;
  }

  // ============================================================================
  // CORE METHOD 3: Generate Deworming Schedule
  // ============================================================================

  /// Generate age-based deworming schedule for a pet
  ///
  /// **Algorithm:**
  /// 1. Calculate pet's current age in weeks
  /// 2. For each DewormingSchedule in protocol:
  ///    - If pet age falls within startAgeWeeks to endAgeWeeks:
  ///      - Generate treatments based on intervalWeeks or recurring schedule
  /// 3. Handle external (monthly) vs internal (quarterly) separately
  ///
  /// **Parameters:**
  /// - `lookAheadMonths`: How many months into the future to generate schedule (default: 12)
  ///
  /// **Returns:**
  /// A list of scheduled deworming dates sorted by date
  ///
  /// **Example:**
  /// ```dart
  /// final schedule = await service.generateDewormingSchedule(
  ///   pet: myAdultDog,
  ///   protocol: canineDewormingProtocol,
  ///   lookAheadMonths: 6,
  /// );
  /// // Returns monthly external + quarterly internal treatments for 6 months
  /// ```
  Future<List<DewormingScheduleEntry>> generateDewormingSchedule({
    required PetProfile pet,
    required DewormingProtocol protocol,
    int lookAheadMonths = 12,
  }) async {
    if (pet.birthday == null) {
      logger.w(
          'Cannot generate deworming schedule: Pet ${pet.id} has no birthdate');
      return [];
    }

    final now = DateTime.now();
    final petAgeWeeks = calculateAgeInWeeks(pet.birthday);
    // Use addMonths() for accurate month arithmetic instead of approximating with 30 days
    final endDate = addMonths(now, lookAheadMonths);

    final scheduleEntries = <DewormingScheduleEntry>[];

    for (final schedule in protocol.schedules) {
      // Check if pet is within age range for this schedule
      if (petAgeWeeks < schedule.ageInWeeks) {
        // Schedule starts in the future (pet is too young)
        final startDate =
            pet.birthday!.add(Duration(days: schedule.ageInWeeks * 7));

        // Get max doses limit if specified
        final maxDoses = schedule.recurring?.numberOfDoses;
        int dosesGenerated = 0;

        // Generate treatments starting from scheduled age
        DateTime currentDate = startDate;
        while (currentDate.isBefore(endDate)) {
          // Stop if we've reached numberOfDoses limit
          if (maxDoses != null && dosesGenerated >= maxDoses) {
            break;
          }

          scheduleEntries.add(DewormingScheduleEntry(
            dewormingType: schedule.dewormingType,
            scheduledDate: currentDate,
            productName: schedule.productName,
            notes: schedule.notes,
            notesRo: schedule.notesRo,
          ));
          dosesGenerated++;

          // Calculate next treatment
          if (schedule.recurring != null) {
            currentDate = addMonths(currentDate, schedule.recurring!.intervalMonths);
          } else if (schedule.intervalDays != null) {
            currentDate = currentDate.add(Duration(days: schedule.intervalDays!));
          } else {
            break; // One-time treatment
          }
        }
      } else {
        // Pet is already within age range, calculate from now
        // Handle one-time treatments (include even if past - for schedule display)
        if (schedule.recurring == null && schedule.intervalDays == null) {
          // One-time treatment - add it so it shows in schedule (as past/overdue)
          final treatmentDate =
              pet.birthday!.add(Duration(days: schedule.ageInWeeks * 7));
          scheduleEntries.add(DewormingScheduleEntry(
            dewormingType: schedule.dewormingType,
            scheduledDate: treatmentDate,
            productName: schedule.productName,
            notes: schedule.notes,
            notesRo: schedule.notesRo,
          ));
          continue;
        }

        // Recurring treatment - calculate next upcoming treatment
        final startDate = pet.birthday!.add(Duration(days: schedule.ageInWeeks * 7));

        // Get max doses limit if specified
        final maxDoses = schedule.recurring?.numberOfDoses;
        int dosesGenerated = 0;

        // Find the next upcoming treatment date
        // Start from the schedule start date and iterate forward
        DateTime currentDate = startDate;

        // Fast-forward to approximate current position
        // This avoids iterating through potentially hundreds of past treatments
        if (startDate.isBefore(now)) {
          if (schedule.recurring != null) {
            // Month-based interval: calculate approximately how many treatments have passed
            final monthsSinceStart = (now.year - startDate.year) * 12 +
                                     (now.month - startDate.month);
            final intervalMonths = schedule.recurring!.intervalMonths;
            final dosesPassed = (monthsSinceStart / intervalMonths).floor();

            if (dosesPassed > 0) {
              // Jump forward to approximately current position (clamped to dose limit)
              final jumpToDose = maxDoses != null
                  ? dosesPassed.clamp(0, maxDoses - 1)
                  : dosesPassed;
              currentDate = addMonths(startDate, jumpToDose * intervalMonths);
              dosesGenerated = jumpToDose;
            }
          } else if (schedule.intervalDays != null) {
            // Day-based interval
            final daysSinceStart = now.difference(startDate).inDays;
            final dosesPassed = daysSinceStart ~/ schedule.intervalDays!;

            if (dosesPassed > 0) {
              final jumpToDose = maxDoses != null
                  ? dosesPassed.clamp(0, maxDoses - 1)
                  : dosesPassed;
              currentDate = startDate.add(Duration(days: jumpToDose * schedule.intervalDays!));
              dosesGenerated = jumpToDose;
            }
          }
        }

        // Fine-tune: advance until we find a treatment date >= now
        while (currentDate.isBefore(now)) {
          // Stop if we've exhausted all doses
          if (maxDoses != null && dosesGenerated >= maxDoses - 1) {
            // We're at the last dose, move to it
            dosesGenerated = maxDoses - 1;
            if (schedule.recurring != null) {
              currentDate = addMonths(startDate, dosesGenerated * schedule.recurring!.intervalMonths);
            } else if (schedule.intervalDays != null) {
              currentDate = startDate.add(Duration(days: dosesGenerated * schedule.intervalDays!));
            }
            break;
          }

          dosesGenerated++;
          if (schedule.recurring != null) {
            currentDate = addMonths(startDate, dosesGenerated * schedule.recurring!.intervalMonths);
          } else if (schedule.intervalDays != null) {
            currentDate = startDate.add(Duration(days: dosesGenerated * schedule.intervalDays!));
          }
        }

        // Generate from next treatment onwards (only future dates in lookahead window)
        while (currentDate.isBefore(endDate)) {
          // Stop if we've reached numberOfDoses limit
          if (maxDoses != null && dosesGenerated >= maxDoses) {
            break;
          }

          scheduleEntries.add(DewormingScheduleEntry(
            dewormingType: schedule.dewormingType,
            scheduledDate: currentDate,
            productName: schedule.productName,
            notes: schedule.notes,
            notesRo: schedule.notesRo,
          ));
          dosesGenerated++;

          // Calculate next treatment
          if (schedule.recurring != null) {
            currentDate = addMonths(startDate, dosesGenerated * schedule.recurring!.intervalMonths);
          } else if (schedule.intervalDays != null) {
            currentDate = startDate.add(Duration(days: dosesGenerated * schedule.intervalDays!));
          } else {
            break; // One-time treatment (shouldn't reach here but safeguard)
          }
        }
      }
    }

    // Sort by date
    scheduleEntries.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

    logger.i(
        'Generated ${scheduleEntries.length} deworming schedule entries for pet ${pet.id} using protocol ${protocol.name}');
    return scheduleEntries;
  }

  // ============================================================================
  // CORE METHOD 4: Suggest Next Appointment
  // ============================================================================

  /// Suggest upcoming appointments based on due vaccinations/deworming
  ///
  /// **Algorithm:**
  /// 1. Generate vaccination schedule for all applicable protocols
  /// 2. Generate deworming schedule for all applicable protocols
  /// 3. Find entries due within suggestionWindowDays
  /// 4. Group by recommended appointment date (combine multiple vaccines if close)
  /// 5. Return appointment suggestions with pre-filled reason and notes
  ///
  /// **Parameters:**
  /// - `suggestionWindowDays`: How many days to look ahead (default: 30)
  ///
  /// **Returns:**
  /// List of appointment suggestions with combined protocols and preparation checklist
  ///
  /// **Example:**
  /// ```dart
  /// final suggestions = await service.suggestNextAppointment(
  ///   pet: myPuppy,
  ///   suggestionWindowDays: 30,
  /// );
  /// // Returns: [
  /// //   AppointmentSuggestion(
  /// //     reason: "DHPPiL vaccination + Deworming",
  /// //     suggestedDate: ...,
  /// //   )
  /// // ]
  /// ```
  Future<List<AppointmentSuggestion>> suggestNextAppointment({
    required PetProfile pet,
    int suggestionWindowDays = 30,
  }) async {
    // Get all applicable protocols for pet's species
    final vaccinationProtocols =
        await vaccinationProtocolRepository.getBySpecies(pet.species);
    final dewormingProtocols =
        await dewormingProtocolRepository.getBySpecies(pet.species);

    final allVaccinationEntries = <VaccinationScheduleEntry>[];
    final allDewormingEntries = <DewormingScheduleEntry>[];

    // Generate schedules for all predefined protocols
    for (final protocol in vaccinationProtocols.where((p) => !p.isCustom)) {
      final entries =
          await generateVaccinationSchedule(pet: pet, protocol: protocol);
      allVaccinationEntries.addAll(entries);
    }

    for (final protocol in dewormingProtocols.where((p) => !p.isCustom)) {
      final entries =
          await generateDewormingSchedule(pet: pet, protocol: protocol);
      allDewormingEntries.addAll(entries);
    }

    // Filter to entries due within window
    final now = DateTime.now();
    final windowEnd = now.add(Duration(days: suggestionWindowDays));

    final dueVaccinations = allVaccinationEntries
        .where((e) =>
            e.scheduledDate.isAfter(now) &&
            e.scheduledDate.isBefore(windowEnd))
        .toList();

    final dueDeworming = allDewormingEntries
        .where((e) =>
            e.scheduledDate.isAfter(now) &&
            e.scheduledDate.isBefore(windowEnd))
        .toList();

    if (dueVaccinations.isEmpty && dueDeworming.isEmpty) {
      logger.i(
          'No appointments suggested for pet ${pet.id} in next $suggestionWindowDays days');
      return [];
    }

    // Group by date (combine items within 7 days of each other)
    final suggestions = <AppointmentSuggestion>[];

    // Simple grouping: Find earliest date, group everything within 7 days
    if (dueVaccinations.isNotEmpty || dueDeworming.isNotEmpty) {
      final allDates = [
        ...dueVaccinations.map((e) => e.scheduledDate),
        ...dueDeworming.map((e) => e.scheduledDate),
      ];
      allDates.sort();
      final earliestDate = allDates.first;

      // Build reason string
      final reasons = <String>[];
      if (dueVaccinations.isNotEmpty) {
        final vaccineNames =
            dueVaccinations.map((e) => e.vaccineName).toSet().join(', ');
        reasons.add('Vaccinations: $vaccineNames');
      }
      if (dueDeworming.isNotEmpty) {
        final types =
            dueDeworming.map((e) => e.dewormingType).toSet().join(', ');
        reasons.add('Deworming: $types');
      }

      suggestions.add(AppointmentSuggestion(
        suggestedDate: earliestDate,
        reason: reasons.join(' + '),
        linkedProtocolIds: vaccinationProtocols.map((p) => p.id).toList(),
        dueVaccinations: dueVaccinations,
        dueDeworming: dueDeworming,
        preparationChecklist:
            _generatePreparationChecklist(dueVaccinations, dueDeworming),
      ));
    }

    logger.i(
        'Generated ${suggestions.length} appointment suggestions for pet ${pet.id}');
    return suggestions;
  }

  /// Generate a preparation checklist for an appointment
  String _generatePreparationChecklist(
    List<VaccinationScheduleEntry> vaccinations,
    List<DewormingScheduleEntry> deworming,
  ) {
    final checklist = <String>[];

    if (vaccinations.isNotEmpty) {
      checklist.add("Bring pet's vaccination card");
    }

    if (deworming.any((d) => d.dewormingType == 'internal')) {
      checklist.add('Collect stool sample if possible');
    }

    checklist.add('Note any behavioral changes since last visit');

    return checklist.join('\n• ');
  }

  // ============================================================================
  // CORE METHOD 5: Create Vaccination Medication Entry
  // ============================================================================

  /// Create a MedicationEntry from a vaccination schedule entry
  ///
  /// This bridges the protocol layer to the actual medication tracking layer.
  /// Used when user confirms a suggested vaccination schedule.
  ///
  /// **Important:**
  /// - This method does NOT save to repository - it only creates the object
  /// - The presentation layer provider will call medicationRepository.save()
  /// - Week 2: Uses `notes` field to store protocol metadata as JSON
  /// - Week 3: Will use new HiveFields (protocolId, protocolStepIndex, etc.)
  ///
  /// **Example:**
  /// ```dart
  /// final medEntry = service.createVaccinationMedicationEntry(
  ///   pet: myPuppy,
  ///   protocol: rabiesProtocol,
  ///   scheduleEntry: VaccinationScheduleEntry(...),
  /// );
  /// await medicationRepository.save(medEntry);
  /// ```
  MedicationEntry createVaccinationMedicationEntry({
    required PetProfile pet,
    required VaccinationProtocol protocol,
    required VaccinationScheduleEntry scheduleEntry,
    String? additionalNotes,
  }) {
    // Week 2: Store protocol metadata in notes as JSON
    final protocolMetadata = {
      'isVaccination': true,
      'protocolId': protocol.id,
      'protocolStepIndex': scheduleEntry.stepIndex,
      'vaccineName': scheduleEntry.vaccineName,
    };

    final notesJson = jsonEncode(protocolMetadata);
    final combinedNotes = additionalNotes != null
        ? '$additionalNotes\n\nMetadata: $notesJson'
        : 'Metadata: $notesJson';

    return MedicationEntry(
      id: const Uuid().v4(),
      petId: pet.id,
      medicationName: scheduleEntry.vaccineName,
      dosage: 'Standard vaccine dose',
      frequency: 'Once',
      startDate: scheduleEntry.scheduledDate,
      endDate: scheduleEntry.scheduledDate, // Same-day administration
      administrationMethod: 'Injection',
      notes: scheduleEntry.notes != null
          ? '${scheduleEntry.notes}\n\n$combinedNotes'
          : combinedNotes,
      isActive: true,
      createdAt: DateTime.now(),
      administrationTimes: [], // No specific times for vaccinations
    );
  }

  // ============================================================================
  // CORE METHOD 6: Create Protocol Appointment Entry
  // ============================================================================

  /// Create an AppointmentEntry from an appointment suggestion
  ///
  /// Bridges protocol suggestions to actual appointment tracking.
  /// User can edit the created appointment before saving.
  ///
  /// **Parameters:**
  /// - `customDate`: Override suggested date if user prefers different date
  /// - `additionalNotes`: User-added notes beyond the preparation checklist
  ///
  /// **Example:**
  /// ```dart
  /// final appointment = service.createProtocolAppointmentEntry(
  ///   pet: myPuppy,
  ///   suggestion: AppointmentSuggestion(...),
  ///   veterinarian: "Dr. Smith",
  ///   clinic: "Pet Care Clinic",
  /// );
  /// await appointmentRepository.save(appointment);
  /// ```
  AppointmentEntry createProtocolAppointmentEntry({
    required PetProfile pet,
    required AppointmentSuggestion suggestion,
    required String veterinarian,
    required String clinic,
    DateTime? customDate,
    String? additionalNotes,
  }) {
    final appointmentDate = customDate ?? suggestion.suggestedDate;

    // Week 2: Store protocol metadata in notes as JSON
    final protocolMetadata = {
      'linkedProtocolIds': suggestion.linkedProtocolIds,
      'autoSuggestedReason': suggestion.reason,
    };

    final notesJson = jsonEncode(protocolMetadata);
    final combinedNotes = additionalNotes != null
        ? '$additionalNotes\n\n${suggestion.preparationChecklist}\n\nMetadata: $notesJson'
        : '${suggestion.preparationChecklist}\n\nMetadata: $notesJson';

    return AppointmentEntry(
      id: const Uuid().v4(),
      petId: pet.id,
      veterinarian: veterinarian,
      clinic: clinic,
      appointmentDate: appointmentDate,
      appointmentTime: DateTime(
        appointmentDate.year,
        appointmentDate.month,
        appointmentDate.day,
        9, // Default 9 AM
      ),
      reason: suggestion.reason,
      notes: combinedNotes,
      isCompleted: false,
      createdAt: DateTime.now(),
    );
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Check if a pet is old enough for a specific vaccination step
  ///
  /// **Returns:** True if pet's age >= step's required age in weeks
  bool isPetOldEnough(PetProfile pet, VaccinationStep step) {
    if (pet.birthday == null) return false;

    final requiredAge = Duration(days: step.ageInWeeks * 7);
    final petAge = DateTime.now().difference(pet.birthday!);

    return petAge >= requiredAge;
  }

  /// Find the best matching vaccination protocol for a pet based on species and region
  ///
  /// **Algorithm:**
  /// 1. Get all protocols for pet's species
  /// 2. Prefer predefined protocols over custom
  /// 3. If region specified, try to find region-specific protocol
  /// 4. Fall back to first predefined protocol
  ///
  /// **Returns:** Best matching protocol or null if none found
  Future<VaccinationProtocol?> findBestVaccinationProtocol({
    required String species,
    String? region,
  }) async {
    final protocols = await vaccinationProtocolRepository.getBySpecies(species);

    // Prefer predefined protocols
    final predefined = protocols.where((p) => !p.isCustom).toList();

    if (region != null) {
      // Try to find region-specific protocol
      final regional = predefined.where((p) => p.region == region).toList();
      if (regional.isNotEmpty) {
        logger.i(
            'Found region-specific protocol for $species/$region: ${regional.first.name}');
        return regional.first;
      }
    }

    // Return first predefined protocol as fallback
    if (predefined.isNotEmpty) {
      logger.i(
          'Using default predefined protocol for $species: ${predefined.first.name}');
      return predefined.first;
    }

    // No protocols found
    logger.w('No vaccination protocols found for species: $species');
    return null;
  }

  /// Find the best matching deworming protocol for a pet based on species and region
  ///
  /// Same logic as findBestVaccinationProtocol but for deworming
  Future<DewormingProtocol?> findBestDewormingProtocol({
    required String species,
    String? region,
  }) async {
    final protocols = await dewormingProtocolRepository.getBySpecies(species);

    // Prefer predefined protocols
    final predefined = protocols.where((p) => !p.isCustom).toList();

    if (region != null) {
      // Try to find region-specific protocol
      final regional = predefined.where((p) => p.region == region).toList();
      if (regional.isNotEmpty) {
        logger.i(
            'Found region-specific deworming protocol for $species/$region: ${regional.first.name}');
        return regional.first;
      }
    }

    // Return first predefined protocol as fallback
    if (predefined.isNotEmpty) {
      logger.i(
          'Using default predefined deworming protocol for $species: ${predefined.first.name}');
      return predefined.first;
    }

    // No protocols found
    logger.w('No deworming protocols found for species: $species');
    return null;
  }

  /// Calculate pet's age in weeks from birthdate
  ///
  /// **Returns:** Age in weeks, or 0 if birthdate is null
  int calculateAgeInWeeks(DateTime? birthdate) {
    if (birthdate == null) return 0;
    return DateTime.now().difference(birthdate).inDays ~/ 7;
  }

  /// Add months to a date (handles month-end edge cases)
  ///
  /// **Example:**
  /// ```dart
  /// addMonths(DateTime(2024, 1, 31), 1) // Returns Feb 29, 2024 (not Feb 31)
  /// addMonths(DateTime(2024, 1, 15), 3) // Returns April 15, 2024
  /// ```
  DateTime addMonths(DateTime date, int months) {
    int year = date.year;
    int month = date.month + months;

    while (month > 12) {
      year++;
      month -= 12;
    }

    while (month < 1) {
      year--;
      month += 12;
    }

    // Handle day overflow (e.g., Jan 31 + 1 month = Feb 28/29)
    int day = date.day;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    if (day > daysInMonth) {
      day = daysInMonth;
    }

    return DateTime(
      year,
      month,
      day,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
  }
}

// ============================================================================
// RIVERPOD PROVIDER
// ============================================================================

@riverpod
ProtocolEngineService protocolEngineService(ProtocolEngineServiceRef ref) {
  return ProtocolEngineService(
    vaccinationProtocolRepository:
        ref.watch(vaccinationProtocolRepositoryProvider),
    dewormingProtocolRepository:
        ref.watch(dewormingProtocolRepositoryProvider),
  );
}
