// File: test/integration/vaccination_workflow_test.dart
// Coverage: Complete vaccination workflow integration test
// Focus Areas:
// - Log vaccine → auto-schedule next dose → verify reminder scheduled
// - Full data flow through repositories, services, and providers
// - Data persistence across simulated app restart
// - Protocol engine calculations with real DHPPiL vaccination data

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:fur_friend_diary/src/data/local/hive_manager.dart';
import 'package:fur_friend_diary/src/domain/models/pet_profile.dart';
import 'package:fur_friend_diary/src/domain/models/medication_entry.dart';
import 'package:fur_friend_diary/src/domain/models/time_of_day_model.dart';
import 'package:fur_friend_diary/src/domain/models/protocols/vaccination_protocol.dart';
import 'package:fur_friend_diary/src/domain/models/protocols/deworming_protocol.dart';
import 'package:fur_friend_diary/src/data/services/protocols/protocol_engine_service.dart';
import 'package:fur_friend_diary/src/data/services/protocols/schedule_models.dart';
import 'package:fur_friend_diary/src/data/repositories/protocols/vaccination_protocol_repository_impl.dart';
import 'package:fur_friend_diary/src/data/repositories/protocols/deworming_protocol_repository_impl.dart';

/// Mock PathProvider for testing
class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  final String path;

  MockPathProviderPlatform(this.path);

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return path;
  }

  @override
  Future<String?> getTemporaryPath() async {
    return path;
  }
}

/// Integration test for complete vaccination workflow
///
/// This test validates the entire user flow from logging a vaccination
/// to auto-scheduling the next dose and verifying reminders are created.
///
/// Test Flow:
/// 1. Setup: Initialize Hive, create test puppy (8 weeks old)
/// 2. Load DHPPiL vaccination protocol
/// 3. Generate vaccination schedule using ProtocolEngineService
/// 4. Log first vaccination dose as administered today
/// 5. Calculate next dose date (should be 4 weeks from today per DHPPiL protocol)
/// 6. Verify medication reminder created with correct date
/// 7. Verify schedule persists across simulated app restart
/// 8. Cleanup: Close Hive, delete test directory
void main() {
  group('Vaccination Workflow Integration Test', () {
    late Directory testDirectory;
    late VaccinationProtocolRepositoryImpl vaccinationRepository;
    late DewormingProtocolRepositoryImpl dewormingRepository;
    late ProtocolEngineService protocolEngine;

    setUp(() async {
      // Step 1: Create temporary directory for test Hive storage
      testDirectory = await Directory.systemTemp.createTemp('vaccination_test_');
      print('📁 Test directory: ${testDirectory.path}');

      // Step 2: Mock PathProvider to use test directory
      PathProviderPlatform.instance = MockPathProviderPlatform(testDirectory.path);

      // Step 3: Initialize Hive with test directory
      Hive.init(testDirectory.path);

      // Step 4: Register all required Hive adapters
      // This follows the same pattern as HiveManager._registerAdapters()
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(PetProfileAdapter());
      }
      if (!Hive.isAdapterRegistered(5)) {
        Hive.registerAdapter(MedicationEntryAdapter());
      }
      if (!Hive.isAdapterRegistered(13)) {
        Hive.registerAdapter(TimeOfDayModelAdapter());
      }
      if (!Hive.isAdapterRegistered(22)) {
        Hive.registerAdapter(VaccinationProtocolAdapter());
      }
      if (!Hive.isAdapterRegistered(23)) {
        Hive.registerAdapter(VaccinationStepAdapter());
      }
      if (!Hive.isAdapterRegistered(24)) {
        Hive.registerAdapter(RecurringScheduleAdapter());
      }
      if (!Hive.isAdapterRegistered(25)) {
        Hive.registerAdapter(DewormingProtocolAdapter());
      }
      if (!Hive.isAdapterRegistered(26)) {
        Hive.registerAdapter(DewormingScheduleAdapter());
      }

      // Step 5: Open boxes (without encryption for testing simplicity)
      await Hive.openBox<PetProfile>(HiveManager.petProfileBoxName);
      await Hive.openBox<MedicationEntry>(HiveManager.medicationBoxName);
      final vaccinationProtocolBox = await Hive.openBox<VaccinationProtocol>(
        HiveManager.vaccinationProtocolBoxName,
      );
      final dewormingProtocolBox = await Hive.openBox<DewormingProtocol>(
        HiveManager.dewormingProtocolBoxName,
      );

      // Step 6: Create repository instances
      vaccinationRepository = VaccinationProtocolRepositoryImpl(box: vaccinationProtocolBox);
      dewormingRepository = DewormingProtocolRepositoryImpl(box: dewormingProtocolBox);

      // Step 7: Create ProtocolEngineService with repository instances
      protocolEngine = ProtocolEngineService(
        vaccinationProtocolRepository: vaccinationRepository,
        dewormingProtocolRepository: dewormingRepository,
      );

      print('✅ Test setup completed');
    });

    tearDown(() async {
      // Step 1: Close all Hive boxes
      await Hive.close();

      // Step 2: Delete test directory
      if (await testDirectory.exists()) {
        await testDirectory.delete(recursive: true);
      }

      print('🧹 Test cleanup completed');
    });

    test('complete vaccination workflow: log → auto-schedule → reminder', () async {
      // ========================================================================
      // PHASE 1: CREATE TEST PET (Puppy, 8 weeks old)
      // ========================================================================
      print('\n🐕 PHASE 1: Creating test puppy...');

      final petBox = Hive.box<PetProfile>(HiveManager.petProfileBoxName);

      // Calculate birthdate for an 8-week-old puppy
      final today = DateTime.now();
      final birthdateFor8WeekOldPuppy = today.subtract(Duration(days: 8 * 7)); // 56 days ago

      final testPuppy = PetProfile(
        name: 'Test Puppy',
        species: 'dog',
        breed: 'Labrador Retriever',
        birthday: birthdateFor8WeekOldPuppy,
        isActive: true,
      );

      // Save puppy to Hive
      await petBox.put(testPuppy.id, testPuppy);

      // Verify save
      final savedPuppy = petBox.get(testPuppy.id);
      expect(savedPuppy, isNotNull, reason: 'Puppy should be saved to Hive');
      expect(savedPuppy!.name, equals('Test Puppy'));
      expect(savedPuppy.species, equals('dog'));

      // Verify age calculation
      final ageInWeeks = DateTime.now().difference(savedPuppy.birthday!).inDays ~/ 7;
      expect(ageInWeeks, equals(8), reason: 'Puppy should be exactly 8 weeks old');

      print('✅ Test puppy created: ${savedPuppy.name}, ${ageInWeeks} weeks old');
      print('   Birthdate: ${savedPuppy.birthday}');

      // ========================================================================
      // PHASE 2: LOAD DHPPiL VACCINATION PROTOCOL
      // ========================================================================
      print('\n💉 PHASE 2: Loading DHPPiL vaccination protocol...');

      // Create DHPPiL protocol manually (simulating JSON load)
      // Based on "Canine Core Vaccination Protocol (Romania/EU)"
      final dhppilProtocol = VaccinationProtocol(
        id: 'canine-core-ro-eu-v1',
        name: 'Canine Core Vaccination Protocol (Romania/EU)',
        species: 'dog',
        description: 'Standard Romanian/EU canine vaccination protocol following WSAVA guidelines.',
        isCustom: false,
        region: 'Romania/EU',
        steps: [
          VaccinationStep(
            vaccineName: 'DHPPiL',
            ageInWeeks: 8,
            intervalDays: null,
            notes: 'First puppy vaccination - Core protection',
            isRequired: true,
            recurring: null,
          ),
          VaccinationStep(
            vaccineName: 'DHPPiL',
            ageInWeeks: 12,
            intervalDays: null,
            notes: 'Second puppy vaccination - Booster',
            isRequired: true,
            recurring: null,
          ),
          VaccinationStep(
            vaccineName: 'DHPPiL',
            ageInWeeks: 16,
            intervalDays: null,
            notes: 'Third puppy vaccination - Final booster',
            isRequired: true,
            recurring: null,
          ),
          VaccinationStep(
            vaccineName: 'Rabies',
            ageInWeeks: 16,
            intervalDays: null,
            notes: 'Legally required in Romania/EU - First dose',
            isRequired: true,
            recurring: null,
          ),
        ],
      );

      // Save protocol using repository
      await vaccinationRepository.save(dhppilProtocol);

      // Verify protocol loaded
      final loadedProtocol = await vaccinationRepository.getById(dhppilProtocol.id);
      expect(loadedProtocol, isNotNull, reason: 'Protocol should be loaded into Hive');
      expect(loadedProtocol!.name, equals('Canine Core Vaccination Protocol (Romania/EU)'));
      expect(loadedProtocol.species, equals('dog'));
      expect(loadedProtocol.steps.length, equals(4), reason: 'Protocol should have 4 steps');

      // Verify first step is DHPPiL at 8 weeks
      final firstStep = loadedProtocol.steps[0];
      expect(firstStep.vaccineName, equals('DHPPiL'));
      expect(firstStep.ageInWeeks, equals(8));
      expect(firstStep.isRequired, isTrue);

      print('✅ DHPPiL protocol loaded: ${loadedProtocol.name}');
      print('   Steps: ${loadedProtocol.steps.length}');
      print('   First dose: ${firstStep.vaccineName} at ${firstStep.ageInWeeks} weeks');

      // ========================================================================
      // PHASE 3: GENERATE VACCINATION SCHEDULE
      // ========================================================================
      print('\n📅 PHASE 3: Generating vaccination schedule...');

      // Generate complete vaccination schedule for puppy
      final vaccinationSchedule = await protocolEngine.generateVaccinationSchedule(
        pet: savedPuppy,
        protocol: loadedProtocol,
      );

      // Verify schedule generated correctly
      expect(vaccinationSchedule, isNotEmpty, reason: 'Schedule should not be empty');
      expect(vaccinationSchedule.length, greaterThanOrEqualTo(3),
        reason: 'Should have at least 3 DHPPiL doses scheduled');

      // Verify first dose date (should be at 8 weeks = today, since puppy is exactly 8 weeks old)
      final firstDose = vaccinationSchedule[0];
      expect(firstDose.vaccineName, equals('DHPPiL'));
      expect(firstDose.stepIndex, equals(0));
      expect(firstDose.isRequired, isTrue);

      // First dose should be scheduled around today (puppy is 8 weeks old)
      final firstDoseDaysDiff = firstDose.scheduledDate.difference(today).inDays.abs();
      expect(firstDoseDaysDiff, lessThanOrEqualTo(1),
        reason: 'First dose should be scheduled for today (puppy is exactly 8 weeks old)');

      // Verify second dose date (should be at 12 weeks = 4 weeks from now)
      final secondDose = vaccinationSchedule[1];
      expect(secondDose.vaccineName, equals('DHPPiL'));
      expect(secondDose.stepIndex, equals(1));

      // Second dose should be 4 weeks after first dose
      final secondDoseExpectedDate = birthdateFor8WeekOldPuppy.add(Duration(days: 12 * 7));
      final secondDoseDaysDiff = secondDose.scheduledDate.difference(secondDoseExpectedDate).inDays.abs();
      expect(secondDoseDaysDiff, lessThanOrEqualTo(1),
        reason: 'Second dose should be scheduled at 12 weeks (4 weeks from first dose)');

      print('✅ Vaccination schedule generated: ${vaccinationSchedule.length} doses');
      print('   Dose 1: ${firstDose.vaccineName} on ${firstDose.scheduledDate.toLocal()}');
      print('   Dose 2: ${secondDose.vaccineName} on ${secondDose.scheduledDate.toLocal()}');

      // ========================================================================
      // PHASE 4: LOG FIRST VACCINATION AS ADMINISTERED TODAY
      // ========================================================================
      print('\n💊 PHASE 4: Logging first vaccination dose...');

      // Create MedicationEntry for first dose using ProtocolEngineService
      final firstDoseMedication = protocolEngine.createVaccinationMedicationEntry(
        pet: savedPuppy,
        protocol: loadedProtocol,
        scheduleEntry: firstDose,
        additionalNotes: 'Administered at local vet clinic',
      );

      // Verify medication entry created correctly
      expect(firstDoseMedication.medicationName, equals('DHPPiL'));
      expect(firstDoseMedication.petId, equals(savedPuppy.id));
      expect(firstDoseMedication.isActive, isTrue);
      expect(firstDoseMedication.administrationMethod, equals('Injection'));
      expect(firstDoseMedication.startDate, isNotNull);
      expect(firstDoseMedication.endDate, isNotNull);

      // Verify start and end dates are the same (single-day administration)
      final startDay = DateTime(
        firstDoseMedication.startDate.year,
        firstDoseMedication.startDate.month,
        firstDoseMedication.startDate.day,
      );
      final endDay = DateTime(
        firstDoseMedication.endDate!.year,
        firstDoseMedication.endDate!.month,
        firstDoseMedication.endDate!.day,
      );
      expect(endDay, equals(startDay),
        reason: 'Vaccination should be single-day administration');

      // Save medication entry to Hive
      final medicationBox = Hive.box<MedicationEntry>(HiveManager.medicationBoxName);
      await medicationBox.put(firstDoseMedication.id, firstDoseMedication);

      // Verify save
      final savedMedication = medicationBox.get(firstDoseMedication.id);
      expect(savedMedication, isNotNull, reason: 'Medication should be saved to Hive');
      expect(savedMedication!.medicationName, equals('DHPPiL'));

      print('✅ First dose logged as medication entry');
      print('   Medication ID: ${savedMedication.id}');
      print('   Administered: ${savedMedication.startDate.toLocal()}');
      print('   Notes: ${savedMedication.notes}');

      // ========================================================================
      // PHASE 5: CALCULATE NEXT DOSE DATE
      // ========================================================================
      print('\n🔮 PHASE 5: Calculating next dose date...');

      // Calculate next dose (step 1, index 1) based on first dose administration
      final nextDoseDate = await protocolEngine.calculateNextVaccinationDate(
        pet: savedPuppy,
        protocol: loadedProtocol,
        stepIndex: 1, // Second dose
        lastAdministeredDate: firstDoseMedication.startDate,
      );

      // Verify next dose date calculated
      expect(nextDoseDate, isNotNull, reason: 'Next dose date should be calculated');

      // Next dose should be at 12 weeks (4 weeks from now)
      final expectedNextDoseDate = birthdateFor8WeekOldPuppy.add(Duration(days: 12 * 7));
      final nextDoseDaysDiff = nextDoseDate!.difference(expectedNextDoseDate).inDays.abs();
      expect(nextDoseDaysDiff, lessThanOrEqualTo(1),
        reason: 'Next dose should be at 12 weeks (4 weeks from today)');

      // Verify it's approximately 4 weeks (28 days) from today
      final daysUntilNextDose = nextDoseDate.difference(today).inDays;
      expect(daysUntilNextDose, greaterThanOrEqualTo(26),
        reason: 'Next dose should be at least 26 days away');
      expect(daysUntilNextDose, lessThanOrEqualTo(30),
        reason: 'Next dose should be at most 30 days away');

      print('✅ Next dose date calculated: ${nextDoseDate.toLocal()}');
      print('   Days until next dose: $daysUntilNextDose');
      print('   Expected interval: 4 weeks (28 days)');

      // ========================================================================
      // PHASE 6: CREATE MEDICATION REMINDER FOR NEXT DOSE
      // ========================================================================
      print('\n🔔 PHASE 6: Creating medication reminder for next dose...');

      // Get second dose schedule entry
      final secondDoseScheduleEntry = vaccinationSchedule[1];

      // Create medication entry for next dose (not administered yet)
      final nextDoseMedication = protocolEngine.createVaccinationMedicationEntry(
        pet: savedPuppy,
        protocol: loadedProtocol,
        scheduleEntry: secondDoseScheduleEntry,
        additionalNotes: 'Auto-scheduled second dose',
      );

      // Verify next dose medication entry
      expect(nextDoseMedication.medicationName, equals('DHPPiL'));
      expect(nextDoseMedication.petId, equals(savedPuppy.id));
      expect(nextDoseMedication.isActive, isTrue);

      // Verify start date matches calculated next dose date
      final nextDoseStartDay = DateTime(
        nextDoseMedication.startDate.year,
        nextDoseMedication.startDate.month,
        nextDoseMedication.startDate.day,
      );
      final expectedNextDoseDay = DateTime(
        nextDoseDate.year,
        nextDoseDate.month,
        nextDoseDate.day,
      );
      expect(nextDoseStartDay, equals(expectedNextDoseDay),
        reason: 'Next dose start date should match calculated date');

      // Save next dose medication to Hive
      await medicationBox.put(nextDoseMedication.id, nextDoseMedication);

      // Verify save
      final savedNextDoseMedication = medicationBox.get(nextDoseMedication.id);
      expect(savedNextDoseMedication, isNotNull,
        reason: 'Next dose medication should be saved to Hive');
      expect(savedNextDoseMedication!.medicationName, equals('DHPPiL'));

      print('✅ Next dose medication reminder created');
      print('   Medication ID: ${savedNextDoseMedication.id}');
      print('   Scheduled for: ${savedNextDoseMedication.startDate.toLocal()}');
      print('   Notes: ${savedNextDoseMedication.notes}');

      // ========================================================================
      // PHASE 7: VERIFY MEDICATION LIST CONTAINS BOTH DOSES
      // ========================================================================
      print('\n📋 PHASE 7: Verifying medication list...');

      // Get all medications from box
      final allMedications = medicationBox.values.toList();

      // Filter for active DHPPiL vaccinations for this pet
      final dhppilVaccinations = allMedications
          .where((med) =>
            med.petId == savedPuppy.id &&
            med.medicationName == 'DHPPiL' &&
            med.isActive == true)
          .toList();

      // Verify we have 2 DHPPiL entries (first dose + next dose)
      expect(dhppilVaccinations.length, equals(2),
        reason: 'Should have 2 active DHPPiL vaccinations (first dose + next dose)');

      // Sort by start date
      dhppilVaccinations.sort((a, b) => a.startDate.compareTo(b.startDate));

      // Verify first entry is the administered dose (today)
      final firstEntry = dhppilVaccinations[0];
      final firstEntryDaysDiff = firstEntry.startDate.difference(today).inDays.abs();
      expect(firstEntryDaysDiff, lessThanOrEqualTo(1),
        reason: 'First entry should be administered today');

      // Verify second entry is the upcoming dose (4 weeks from now)
      final secondEntry = dhppilVaccinations[1];
      final daysUntilSecondEntry = secondEntry.startDate.difference(today).inDays;
      expect(daysUntilSecondEntry, greaterThanOrEqualTo(26),
        reason: 'Second entry should be at least 26 days away');
      expect(daysUntilSecondEntry, lessThanOrEqualTo(30),
        reason: 'Second entry should be at most 30 days away');

      print('✅ Medication list verified: ${dhppilVaccinations.length} DHPPiL vaccinations');
      print('   Entry 1 (Administered): ${firstEntry.startDate.toLocal()}');
      print('   Entry 2 (Upcoming): ${secondEntry.startDate.toLocal()}');

      // ========================================================================
      // PHASE 8: VERIFY PROTOCOL METADATA PRESERVED
      // ========================================================================
      print('\n🔍 PHASE 8: Verifying protocol metadata...');

      // Check that protocol metadata is stored in notes field (Week 2 implementation)
      expect(savedMedication.notes, isNotNull);
      expect(savedMedication.notes, contains('Metadata:'),
        reason: 'Notes should contain protocol metadata');
      expect(savedMedication.notes, contains('canine-core-ro-eu-v1'),
        reason: 'Notes should contain protocol ID');
      expect(savedMedication.notes, contains('DHPPiL'),
        reason: 'Notes should contain vaccine name');

      // Same for next dose
      expect(savedNextDoseMedication.notes, isNotNull);
      expect(savedNextDoseMedication.notes, contains('Metadata:'));
      expect(savedNextDoseMedication.notes, contains('canine-core-ro-eu-v1'));

      print('✅ Protocol metadata preserved in medication notes');
      print('   Protocol ID: canine-core-ro-eu-v1');
      print('   Step indices: 0 (first dose), 1 (second dose)');

      // ========================================================================
      // PHASE 9: SIMULATE APP RESTART - VERIFY DATA PERSISTENCE
      // ========================================================================
      print('\n🔄 PHASE 9: Simulating app restart...');

      // Close and reopen boxes to simulate app restart
      await Hive.close();

      // Reopen boxes
      await Hive.openBox<PetProfile>(HiveManager.petProfileBoxName);
      await Hive.openBox<MedicationEntry>(HiveManager.medicationBoxName);
      await Hive.openBox<VaccinationProtocol>(HiveManager.vaccinationProtocolBoxName);

      // Verify pet profile persisted
      final reopenedPetBox = Hive.box<PetProfile>(HiveManager.petProfileBoxName);
      final persistedPuppy = reopenedPetBox.get(testPuppy.id);
      expect(persistedPuppy, isNotNull, reason: 'Pet profile should persist across restart');
      expect(persistedPuppy!.name, equals('Test Puppy'));

      // Verify medications persisted
      final reopenedMedicationBox = Hive.box<MedicationEntry>(HiveManager.medicationBoxName);
      final persistedMedications = reopenedMedicationBox.values
          .where((med) => med.petId == testPuppy.id && med.medicationName == 'DHPPiL')
          .toList();
      expect(persistedMedications.length, equals(2),
        reason: 'Both medication entries should persist across restart');

      // Verify protocol persisted
      final reopenedProtocolBox = Hive.box<VaccinationProtocol>(HiveManager.vaccinationProtocolBoxName);
      final persistedProtocol = reopenedProtocolBox.get(dhppilProtocol.id);
      expect(persistedProtocol, isNotNull,
        reason: 'Vaccination protocol should persist across restart');
      expect(persistedProtocol!.name, equals('Canine Core Vaccination Protocol (Romania/EU)'));

      print('✅ Data persisted across simulated app restart');
      print('   Pet profile: ✓');
      print('   Medications: ✓ (${persistedMedications.length} entries)');
      print('   Protocol: ✓');

      // ========================================================================
      // PHASE 10: VALIDATE COMPLETE WORKFLOW
      // ========================================================================
      print('\n✅ PHASE 10: Workflow validation complete!');
      print('');
      print('📊 WORKFLOW SUMMARY:');
      print('─────────────────────────────────────────────────────────');
      print('1. Created test puppy: ${persistedPuppy.name} (8 weeks old)');
      print('2. Loaded DHPPiL protocol: ${persistedProtocol.name}');
      print('3. Generated vaccination schedule: ${vaccinationSchedule.length} doses');
      print('4. Logged first dose as administered');
      print('5. Calculated next dose: ~4 weeks from first dose');
      print('6. Created medication reminder for next dose');
      print('7. Verified medication list shows both doses');
      print('8. Verified protocol metadata preserved');
      print('9. Verified data persists across app restart');
      print('─────────────────────────────────────────────────────────');
      print('');
      print('🎉 INTEGRATION TEST PASSED: Complete vaccination workflow validated!');
    });

    // ========================================================================
    // EDGE CASE TEST: Pet with no birthdate
    // ========================================================================
    test('should handle pet with no birthdate gracefully', () async {
      print('\n⚠️  EDGE CASE TEST: Pet with no birthdate');

      final petBox = Hive.box<PetProfile>(HiveManager.petProfileBoxName);

      // Create pet without birthday
      final petNoBirthday = PetProfile(
        name: 'Pet No Birthday',
        species: 'dog',
        birthday: null, // No birthdate
        isActive: true,
      );

      await petBox.put(petNoBirthday.id, petNoBirthday);

      // Create minimal protocol
      final testProtocol = VaccinationProtocol(
        id: 'test-protocol',
        name: 'Test Protocol',
        species: 'dog',
        description: 'Test',
        isCustom: false,
        steps: [
          VaccinationStep(
            vaccineName: 'Test Vaccine',
            ageInWeeks: 8,
            isRequired: true,
          ),
        ],
      );

      await vaccinationRepository.save(testProtocol);

      // Generate schedule should return empty list (no birthdate)
      final schedule = await protocolEngine.generateVaccinationSchedule(
        pet: petNoBirthday,
        protocol: testProtocol,
      );

      expect(schedule, isEmpty,
        reason: 'Schedule should be empty when pet has no birthdate');

      print('✅ Edge case handled: Empty schedule for pet with no birthdate');
    });

    // ========================================================================
    // EDGE CASE TEST: Calculate next dose with invalid step index
    // ========================================================================
    test('should return null for invalid step index', () async {
      print('\n⚠️  EDGE CASE TEST: Invalid step index');

      final petBox = Hive.box<PetProfile>(HiveManager.petProfileBoxName);

      final testPet = PetProfile(
        name: 'Test Pet',
        species: 'dog',
        birthday: DateTime.now().subtract(Duration(days: 60)),
        isActive: true,
      );

      await petBox.put(testPet.id, testPet);

      // Create protocol
      final testProtocol = VaccinationProtocol(
        id: 'test-protocol-2',
        name: 'Test Protocol',
        species: 'dog',
        description: 'Test',
        isCustom: false,
        steps: [
          VaccinationStep(
            vaccineName: 'Test Vaccine',
            ageInWeeks: 8,
            isRequired: true,
          ),
        ],
      );

      await vaccinationRepository.save(testProtocol);

      // Try to calculate date with invalid step index
      final nextDate = await protocolEngine.calculateNextVaccinationDate(
        pet: testPet,
        protocol: testProtocol,
        stepIndex: 999, // Invalid index
      );

      expect(nextDate, isNull,
        reason: 'Should return null for invalid step index');

      print('✅ Edge case handled: Null returned for invalid step index');
    });

    // ========================================================================
    // EDGE CASE TEST: Verify recurring schedule handling
    // ========================================================================
    test('should generate recurring annual boosters', () async {
      print('\n🔁 TEST: Recurring annual boosters');

      final petBox = Hive.box<PetProfile>(HiveManager.petProfileBoxName);

      // Create adult dog (2 years old)
      final adultDog = PetProfile(
        name: 'Adult Dog',
        species: 'dog',
        birthday: DateTime.now().subtract(Duration(days: 365 * 2)),
        isActive: true,
      );

      await petBox.put(adultDog.id, adultDog);

      // Create protocol with recurring booster
      final protocolWithRecurring = VaccinationProtocol(
        id: 'recurring-test-protocol',
        name: 'Recurring Test Protocol',
        species: 'dog',
        description: 'Test recurring',
        isCustom: false,
        steps: [
          VaccinationStep(
            vaccineName: 'Annual Vaccine',
            ageInWeeks: 68, // 16 months
            isRequired: true,
            recurring: RecurringSchedule(
              intervalMonths: 12,
              indefinitely: true,
            ),
          ),
        ],
      );

      await vaccinationRepository.save(protocolWithRecurring);

      // Generate schedule
      final schedule = await protocolEngine.generateVaccinationSchedule(
        pet: adultDog,
        protocol: protocolWithRecurring,
      );

      // Should have initial dose + 3 recurring boosters (protocol engine generates 3 future doses)
      expect(schedule.length, equals(4),
        reason: 'Should generate initial dose + 3 recurring boosters');

      // Verify all are for Annual Vaccine
      for (final entry in schedule) {
        expect(entry.vaccineName, contains('Annual Vaccine'));
      }

      print('✅ Recurring schedule generated: ${schedule.length} doses');
      print('   Initial + 3 annual boosters');
    });
  });
}
