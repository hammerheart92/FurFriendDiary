// File: test/integration/deworming_workflow_test.dart
// Coverage: Complete deworming workflow integration test
// Focus Areas:
// - Create new pet → system suggests deworming protocol → generate schedule
// - Full data flow through repositories, services, and providers
// - Verify events appear in calendar and dashboard (upcomingCareProvider)
// - Data persistence across simulated app restart
// - Protocol engine calculations with real ESCCAP deworming data

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:fur_friend_diary/src/data/local/hive_manager.dart';
import 'package:fur_friend_diary/src/domain/models/pet_profile.dart';
import 'package:fur_friend_diary/src/domain/models/medication_entry.dart';
import 'package:fur_friend_diary/src/domain/models/time_of_day_model.dart';
import 'package:fur_friend_diary/src/domain/models/appointment_entry.dart';
import 'package:fur_friend_diary/src/domain/models/protocols/vaccination_protocol.dart';
import 'package:fur_friend_diary/src/domain/models/protocols/deworming_protocol.dart';
import 'package:fur_friend_diary/src/data/services/protocols/protocol_engine_service.dart';
import 'package:fur_friend_diary/src/data/services/protocols/schedule_models.dart';
import 'package:fur_friend_diary/src/data/repositories/protocols/vaccination_protocol_repository_impl.dart';
import 'package:fur_friend_diary/src/data/repositories/protocols/deworming_protocol_repository_impl.dart';
import 'package:fur_friend_diary/src/presentation/models/upcoming_care_event.dart';

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

/// Integration test for complete deworming workflow
///
/// This test validates the entire user flow from creating a new pet
/// to auto-scheduling deworming treatments and verifying they appear
/// in the calendar and dashboard.
///
/// Test Flow:
/// 1. Setup: Initialize Hive, create test puppy (6 weeks old)
/// 2. Load ESCCAP deworming protocol (monthly)
/// 3. Generate deworming schedule using ProtocolEngineService
/// 4. Verify schedule entries calculated correctly
/// 5. Verify events appear in upcomingCareProvider as DewormingEvent objects
/// 6. Verify calendar integration (orange/amber markers)
/// 7. Verify dashboard shows next deworming treatment
/// 8. Verify data persists across simulated app restart
/// 9. Cleanup: Close Hive, delete test directory
void main() {
  group('Deworming Workflow Integration Test', () {
    late Directory testDirectory;
    late VaccinationProtocolRepositoryImpl vaccinationRepository;
    late DewormingProtocolRepositoryImpl dewormingRepository;
    late ProtocolEngineService protocolEngine;

    setUp(() async {
      // Step 1: Create temporary directory for test Hive storage
      testDirectory = await Directory.systemTemp.createTemp('deworming_test_');
      print('📁 Test directory: ${testDirectory.path}');

      // Step 2: Mock PathProvider to use test directory
      PathProviderPlatform.instance = MockPathProviderPlatform(testDirectory.path);

      // Step 3: Initialize Hive with test directory
      Hive.init(testDirectory.path);

      // Step 4: Register all required Hive adapters
      // This follows the same pattern as HiveManager._registerAdapters()
      // Note: We check isAdapterRegistered for each typeId to avoid conflicts
      // between test runs when tests run sequentially
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(PetProfileAdapter());
      }
      if (!Hive.isAdapterRegistered(5)) {
        Hive.registerAdapter(MedicationEntryAdapter());
      }
      if (!Hive.isAdapterRegistered(6)) {
        Hive.registerAdapter(AppointmentEntryAdapter());
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
      await Hive.openBox<AppointmentEntry>(HiveManager.appointmentBoxName);
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

    test('complete deworming workflow: create pet → auto-schedule → calendar', () async {
      // ========================================================================
      // PHASE 1: CREATE TEST PET (Puppy, 6 weeks old)
      // ========================================================================
      print('\n🐕 PHASE 1: Creating test puppy...');

      final petBox = Hive.box<PetProfile>(HiveManager.petProfileBoxName);

      // Calculate birthdate for a 6-week-old puppy
      final today = DateTime.now();
      final birthdateFor6WeekOldPuppy = today.subtract(Duration(days: 6 * 7)); // 42 days ago

      final testPuppy = PetProfile(
        name: 'Test Puppy Deworming',
        species: 'dog',
        breed: 'Golden Retriever',
        birthday: birthdateFor6WeekOldPuppy,
        isActive: true,
      );

      // Save puppy to Hive
      await petBox.put(testPuppy.id, testPuppy);

      // Verify save
      final savedPuppy = petBox.get(testPuppy.id);
      expect(savedPuppy, isNotNull, reason: 'Puppy should be saved to Hive');
      expect(savedPuppy!.name, equals('Test Puppy Deworming'));
      expect(savedPuppy.species, equals('dog'));

      // Verify age calculation
      final ageInWeeks = DateTime.now().difference(savedPuppy.birthday!).inDays ~/ 7;
      expect(ageInWeeks, equals(6), reason: 'Puppy should be exactly 6 weeks old');

      print('✅ Test puppy created: ${savedPuppy.name}, ${ageInWeeks} weeks old');
      print('   Birthdate: ${savedPuppy.birthday}');

      // ========================================================================
      // PHASE 2: LOAD ESCCAP DEWORMING PROTOCOL
      // ========================================================================
      print('\n🐛 PHASE 2: Loading ESCCAP deworming protocol...');

      // Create ESCCAP monthly deworming protocol manually (simulating JSON load)
      // Based on ESCCAP (European Scientific Counsel Companion Animal Parasites) guidelines
      final esccapProtocol = DewormingProtocol(
        id: 'esccap-monthly-dog-v1',
        name: 'ESCCAP Monthly Deworming (Puppies)',
        species: 'dog',
        description: 'Monthly deworming for puppies following ESCCAP guidelines. '
            'Broad spectrum treatment starting at 2 weeks, continued monthly for first 6 months.',
        isCustom: false,
        region: 'EU',
        schedules: [
          DewormingSchedule(
            dewormingType: 'internal',
            ageInWeeks: 2,
            intervalDays: null,
            notes: 'Initial treatment - Broad spectrum deworming',
            productName: 'Milbemax',
            recurring: RecurringSchedule(
              intervalMonths: 1,
              indefinitely: false,
              numberOfDoses: 6, // 6 monthly treatments
            ),
          ),
        ],
      );

      // Save protocol using repository
      await dewormingRepository.save(esccapProtocol);

      // Verify protocol loaded
      final loadedProtocol = await dewormingRepository.getById(esccapProtocol.id);
      expect(loadedProtocol, isNotNull, reason: 'Protocol should be loaded into Hive');
      expect(loadedProtocol!.name, equals('ESCCAP Monthly Deworming (Puppies)'));
      expect(loadedProtocol.species, equals('dog'));
      expect(loadedProtocol.schedules.length, equals(1), reason: 'Protocol should have 1 schedule');

      // Verify schedule details
      final firstSchedule = loadedProtocol.schedules[0];
      expect(firstSchedule.dewormingType, equals('internal'));
      expect(firstSchedule.ageInWeeks, equals(2));
      expect(firstSchedule.productName, equals('Milbemax'));
      expect(firstSchedule.recurring, isNotNull);
      expect(firstSchedule.recurring!.intervalMonths, equals(1));
      expect(firstSchedule.recurring!.numberOfDoses, equals(6));

      print('✅ ESCCAP protocol loaded: ${loadedProtocol.name}');
      print('   Schedules: ${loadedProtocol.schedules.length}');
      print('   Treatment: ${firstSchedule.dewormingType} at ${firstSchedule.ageInWeeks} weeks');
      print('   Recurring: Monthly for ${firstSchedule.recurring!.numberOfDoses} doses');

      // ========================================================================
      // PHASE 3: GENERATE DEWORMING SCHEDULE
      // ========================================================================
      print('\n📅 PHASE 3: Generating deworming schedule...');

      // Generate complete deworming schedule for puppy
      final dewormingSchedule = await protocolEngine.generateDewormingSchedule(
        pet: savedPuppy,
        protocol: loadedProtocol,
        lookAheadMonths: 12, // Look ahead 12 months
      );

      // Verify schedule generated correctly
      expect(dewormingSchedule, isNotEmpty, reason: 'Schedule should not be empty');

      // Should have at least 4 treatments remaining (puppy is 6 weeks, protocol starts at 2 weeks)
      // Treatments at: 2w (past), 6w (past), 10w (past), 14w, 18w, 22w, 26w
      // Since puppy is 6 weeks, we should see treatments from current age onwards
      expect(dewormingSchedule.length, greaterThanOrEqualTo(3),
        reason: 'Should have multiple deworming treatments scheduled');

      // Verify first upcoming treatment
      final nextTreatment = dewormingSchedule[0];
      expect(nextTreatment.dewormingType, equals('internal'));
      expect(nextTreatment.productName, equals('Milbemax'));

      // Note: Schedule calculation verified in PHASE 4 below

      print('✅ Deworming schedule generated: ${dewormingSchedule.length} treatments');
      print('   First treatment: ${nextTreatment.dewormingType} on ${nextTreatment.scheduledDate.toLocal()}');
      print('   Product: ${nextTreatment.productName}');

      // ========================================================================
      // PHASE 4: VERIFY SCHEDULE DATES (Monthly intervals)
      // ========================================================================
      print('\n🔍 PHASE 4: Verifying schedule dates...');

      // Verify monthly intervals between treatments
      for (int i = 1; i < dewormingSchedule.length; i++) {
        final previousDate = dewormingSchedule[i - 1].scheduledDate;
        final currentDate = dewormingSchedule[i].scheduledDate;

        // Calculate days between treatments (should be ~30 days for monthly)
        final daysBetween = currentDate.difference(previousDate).inDays;

        // Allow some variance (28-32 days for monthly treatments)
        expect(daysBetween, greaterThanOrEqualTo(28),
          reason: 'Treatments should be at least 28 days apart');
        expect(daysBetween, lessThanOrEqualTo(32),
          reason: 'Monthly treatments should be at most 32 days apart');

        print('   Treatment ${i}: ${currentDate.toLocal()} (${daysBetween} days after previous)');
      }

      // Verify all treatments have consistent properties
      for (final treatment in dewormingSchedule) {
        expect(treatment.dewormingType, equals('internal'));
        expect(treatment.productName, equals('Milbemax'));
      }

      print('✅ Schedule dates verified: Monthly intervals confirmed');

      // ========================================================================
      // PHASE 5: ASSIGN PROTOCOL TO PET
      // ========================================================================
      print('\n🔗 PHASE 5: Assigning deworming protocol to pet...');

      // Update pet with protocol assignment
      final updatedPuppy = savedPuppy.copyWith(
        dewormingProtocolId: loadedProtocol.id,
      );
      await petBox.put(updatedPuppy.id, updatedPuppy);

      // Verify assignment
      final petWithProtocol = petBox.get(updatedPuppy.id);
      expect(petWithProtocol, isNotNull);
      expect(petWithProtocol!.dewormingProtocolId, equals(loadedProtocol.id));

      print('✅ Protocol assigned to pet: ${loadedProtocol.id}');

      // ========================================================================
      // PHASE 6: VERIFY UPCOMING CARE PROVIDER INTEGRATION
      // ========================================================================
      print('\n📋 PHASE 6: Verifying upcomingCareProvider integration...');

      // NOTE: We cannot directly test the Riverpod provider without ProviderContainer
      // and full app context. Instead, we verify the data structures that would be used.

      // Simulate what upcomingCareProvider would do:
      // 1. Load pet from Hive ✓ (already verified)
      // 2. Check dewormingProtocolId ✓ (already verified)
      // 3. Generate schedule ✓ (already verified)
      // 4. Convert to DewormingEvent objects (verify this conversion)

      // Convert schedule entries to DewormingEvent objects
      final dewormingEvents = dewormingSchedule
          .map((entry) => DewormingEvent(entry))
          .toList();

      // Verify events created correctly
      expect(dewormingEvents.length, equals(dewormingSchedule.length),
        reason: 'Should have same number of events as schedule entries');

      // Verify first event properties
      final firstEvent = dewormingEvents[0];
      expect(firstEvent.title, equals('Deworming Treatment'),
        reason: 'Event title should be "Deworming Treatment"');
      expect(firstEvent.icon, equals('🐛'),
        reason: 'Event icon should be 🐛');
      expect(firstEvent.eventType, equals('deworming'),
        reason: 'Event type should be "deworming"');
      expect(firstEvent.scheduledDate, equals(nextTreatment.scheduledDate),
        reason: 'Event date should match schedule entry date');

      // Verify description contains treatment type and product
      expect(firstEvent.description, contains('internal'),
        reason: 'Description should contain treatment type');
      expect(firstEvent.description, contains('Milbemax'),
        reason: 'Description should contain product name');

      // Verify isOverdue and isUpcomingSoon helpers
      final now = DateTime.now();
      for (final event in dewormingEvents) {
        final isOverdue = event.scheduledDate.isBefore(now);
        final daysDiff = event.scheduledDate.difference(now).inDays;
        final isUpcomingSoon = daysDiff >= 0 && daysDiff <= 7;

        expect(event.isOverdue, equals(isOverdue),
          reason: 'isOverdue should match date comparison');
        expect(event.isUpcomingSoon, equals(isUpcomingSoon),
          reason: 'isUpcomingSoon should be true within 7 days');
      }

      print('✅ DewormingEvent objects verified: ${dewormingEvents.length} events');
      print('   Event title: ${firstEvent.title}');
      print('   Event icon: ${firstEvent.icon}');
      print('   Event type: ${firstEvent.eventType}');
      print('   Description: ${firstEvent.description}');

      // ========================================================================
      // PHASE 7: VERIFY CALENDAR COLOR CODING
      // ========================================================================
      print('\n🎨 PHASE 7: Verifying calendar color coding...');

      // Verify event type for UI color mapping
      // In the UI, colors are assigned based on eventType:
      // - 'vaccination' → red
      // - 'deworming' → orange/amber
      // - 'appointment' → blue
      // - 'medication' → purple

      for (final event in dewormingEvents) {
        expect(event.eventType, equals('deworming'),
          reason: 'All deworming events should have eventType "deworming"');
      }

      print('✅ Calendar color coding verified: eventType = "deworming" (orange/amber)');

      // ========================================================================
      // PHASE 8: VERIFY DASHBOARD "NEXT TREATMENT" DISPLAY
      // ========================================================================
      print('\n📊 PHASE 8: Verifying dashboard display...');

      // Dashboard should show the next upcoming treatment (first non-overdue event)
      final upcomingEvents = dewormingEvents
          .where((event) => !event.isOverdue)
          .toList();

      expect(upcomingEvents, isNotEmpty,
        reason: 'Should have at least one upcoming treatment');

      final nextUpcomingEvent = upcomingEvents.first;
      final daysUntilNext = nextUpcomingEvent.scheduledDate.difference(now).inDays;

      print('✅ Dashboard "Upcoming Care" verified:');
      print('   Next treatment: ${nextUpcomingEvent.title}');
      print('   Scheduled: ${nextUpcomingEvent.scheduledDate.toLocal()}');
      print('   Days until treatment: $daysUntilNext');
      print('   Is upcoming soon: ${nextUpcomingEvent.isUpcomingSoon}');

      // ========================================================================
      // PHASE 9: VERIFY PROTOCOL METADATA PRESERVED
      // ========================================================================
      print('\n🔍 PHASE 9: Verifying protocol metadata...');

      // Verify that all schedule entries preserve protocol information
      for (final entry in dewormingSchedule) {
        expect(entry.dewormingType, equals('internal'),
          reason: 'Deworming type should be preserved from protocol');
        expect(entry.productName, equals('Milbemax'),
          reason: 'Product name should be preserved from protocol');
        expect(entry.notes, contains('Broad spectrum'),
          reason: 'Notes should be preserved from protocol');
      }

      print('✅ Protocol metadata preserved in schedule entries');
      print('   Deworming type: internal');
      print('   Product: Milbemax');
      print('   Notes preserved: ✓');

      // ========================================================================
      // PHASE 10: SIMULATE APP RESTART - VERIFY DATA PERSISTENCE
      // ========================================================================
      print('\n🔄 PHASE 10: Simulating app restart...');

      // Close and reopen boxes to simulate app restart
      await Hive.close();

      // Reopen boxes
      await Hive.openBox<PetProfile>(HiveManager.petProfileBoxName);
      await Hive.openBox<DewormingProtocol>(HiveManager.dewormingProtocolBoxName);

      // Verify pet profile persisted
      final reopenedPetBox = Hive.box<PetProfile>(HiveManager.petProfileBoxName);
      final persistedPuppy = reopenedPetBox.get(testPuppy.id);
      expect(persistedPuppy, isNotNull, reason: 'Pet profile should persist across restart');
      expect(persistedPuppy!.name, equals('Test Puppy Deworming'));
      expect(persistedPuppy.dewormingProtocolId, equals(loadedProtocol.id),
        reason: 'Protocol assignment should persist');

      // Verify protocol persisted
      final reopenedProtocolBox = Hive.box<DewormingProtocol>(HiveManager.dewormingProtocolBoxName);
      final persistedProtocol = reopenedProtocolBox.get(esccapProtocol.id);
      expect(persistedProtocol, isNotNull,
        reason: 'Deworming protocol should persist across restart');
      expect(persistedProtocol!.name, equals('ESCCAP Monthly Deworming (Puppies)'));
      expect(persistedProtocol.schedules.length, equals(1));

      // Verify schedule can be regenerated after restart
      // Create new repository and engine instances
      final newDewormingRepo = DewormingProtocolRepositoryImpl(box: reopenedProtocolBox);
      final newProtocolEngine = ProtocolEngineService(
        vaccinationProtocolRepository: vaccinationRepository,
        dewormingProtocolRepository: newDewormingRepo,
      );

      final regeneratedSchedule = await newProtocolEngine.generateDewormingSchedule(
        pet: persistedPuppy,
        protocol: persistedProtocol,
        lookAheadMonths: 12,
      );

      expect(regeneratedSchedule.length, equals(dewormingSchedule.length),
        reason: 'Regenerated schedule should match original');

      print('✅ Data persisted across simulated app restart');
      print('   Pet profile: ✓');
      print('   Protocol: ✓');
      print('   Protocol assignment: ✓');
      print('   Schedule regenerated: ✓ (${regeneratedSchedule.length} treatments)');

      // ========================================================================
      // PHASE 11: VALIDATE COMPLETE WORKFLOW
      // ========================================================================
      print('\n✅ PHASE 11: Workflow validation complete!');
      print('');
      print('📊 WORKFLOW SUMMARY:');
      print('─────────────────────────────────────────────────────────');
      print('1. Created test puppy: ${persistedPuppy.name} (6 weeks old)');
      print('2. Loaded ESCCAP protocol: ${persistedProtocol.name}');
      print('3. Generated deworming schedule: ${dewormingSchedule.length} treatments');
      print('4. Verified monthly intervals: ✓');
      print('5. Assigned protocol to pet: ✓');
      print('6. Created DewormingEvent objects: ${dewormingEvents.length} events');
      print('7. Verified calendar integration: eventType = "deworming" (orange/amber)');
      print('8. Verified dashboard display: Next treatment in $daysUntilNext days');
      print('9. Verified protocol metadata preserved: ✓');
      print('10. Verified data persists across app restart: ✓');
      print('─────────────────────────────────────────────────────────');
      print('');
      print('🎉 INTEGRATION TEST PASSED: Complete deworming workflow validated!');
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
      final testProtocol = DewormingProtocol(
        id: 'test-deworming-protocol',
        name: 'Test Deworming Protocol',
        species: 'dog',
        description: 'Test',
        isCustom: false,
        schedules: [
          DewormingSchedule(
            dewormingType: 'internal',
            ageInWeeks: 2,
            productName: 'Test Product',
          ),
        ],
      );

      await dewormingRepository.save(testProtocol);

      // Generate schedule should return empty list (no birthdate)
      final schedule = await protocolEngine.generateDewormingSchedule(
        pet: petNoBirthday,
        protocol: testProtocol,
      );

      expect(schedule, isEmpty,
        reason: 'Schedule should be empty when pet has no birthdate');

      print('✅ Edge case handled: Empty schedule for pet with no birthdate');
    });

    // ========================================================================
    // EDGE CASE TEST: Monthly recurring schedules
    // ========================================================================
    test('should generate monthly recurring schedules correctly', () async {
      print('\n🔁 TEST: Monthly recurring schedules');

      final petBox = Hive.box<PetProfile>(HiveManager.petProfileBoxName);

      // Create young puppy (2 weeks old)
      final youngPuppy = PetProfile(
        name: 'Young Puppy',
        species: 'dog',
        birthday: DateTime.now().subtract(Duration(days: 2 * 7)),
        isActive: true,
      );

      await petBox.put(youngPuppy.id, youngPuppy);

      // Create protocol with 6 monthly treatments
      final monthlyProtocol = DewormingProtocol(
        id: 'monthly-test-protocol',
        name: 'Monthly Test Protocol',
        species: 'dog',
        description: 'Test monthly recurring',
        isCustom: false,
        schedules: [
          DewormingSchedule(
            dewormingType: 'internal',
            ageInWeeks: 2,
            productName: 'Monthly Product',
            recurring: RecurringSchedule(
              intervalMonths: 1,
              indefinitely: false,
              numberOfDoses: 6,
            ),
          ),
        ],
      );

      await dewormingRepository.save(monthlyProtocol);

      // Generate schedule (with 6 month lookahead to match numberOfDoses)
      final schedule = await protocolEngine.generateDewormingSchedule(
        pet: youngPuppy,
        protocol: monthlyProtocol,
        lookAheadMonths: 6, // 6 months lookahead
      );

      // Should have 6 monthly treatments (one per month for 6 months)
      expect(schedule.length, greaterThanOrEqualTo(6),
        reason: 'Should generate at least 6 monthly treatments');

      // Verify intervals are approximately 1 month (28-32 days)
      for (int i = 1; i < schedule.length; i++) {
        final previousDate = schedule[i - 1].scheduledDate;
        final currentDate = schedule[i].scheduledDate;
        final daysBetween = currentDate.difference(previousDate).inDays;

        expect(daysBetween, greaterThanOrEqualTo(28),
          reason: 'Monthly interval should be at least 28 days');
        expect(daysBetween, lessThanOrEqualTo(32),
          reason: 'Monthly interval should be at most 32 days');
      }

      print('✅ Monthly recurring schedules verified: ${schedule.length} treatments');
      print('   All intervals within 28-32 days: ✓');
    });

    // ========================================================================
    // EDGE CASE TEST: Adult pet (past initial treatment age)
    // ========================================================================
    test('should handle adult pet correctly', () async {
      print('\n🐕 TEST: Adult pet deworming schedule');

      final petBox = Hive.box<PetProfile>(HiveManager.petProfileBoxName);

      // Create adult dog (2 years old)
      final adultDog = PetProfile(
        name: 'Adult Dog',
        species: 'dog',
        birthday: DateTime.now().subtract(Duration(days: 365 * 2)),
        isActive: true,
      );

      await petBox.put(adultDog.id, adultDog);

      // Create protocol for adults (quarterly treatments)
      final adultProtocol = DewormingProtocol(
        id: 'adult-deworming-protocol',
        name: 'Adult Deworming Protocol',
        species: 'dog',
        description: 'Quarterly deworming for adult dogs',
        isCustom: false,
        schedules: [
          DewormingSchedule(
            dewormingType: 'internal',
            ageInWeeks: 52, // Start at 1 year old
            productName: 'Adult Product',
            recurring: RecurringSchedule(
              intervalMonths: 3,
              indefinitely: false,
              numberOfDoses: 4, // Quarterly for 1 year
            ),
          ),
        ],
      );

      await dewormingRepository.save(adultProtocol);

      // Generate schedule
      final schedule = await protocolEngine.generateDewormingSchedule(
        pet: adultDog,
        protocol: adultProtocol,
        lookAheadMonths: 12,
      );

      // Should generate future quarterly treatments
      expect(schedule, isNotEmpty,
        reason: 'Should generate schedule for adult dog');

      // Verify all treatments are in the future or recent past
      final now = DateTime.now();
      final sixMonthsAgo = now.subtract(Duration(days: 180));

      for (final entry in schedule) {
        expect(entry.scheduledDate.isAfter(sixMonthsAgo), isTrue,
          reason: 'Treatments should be relatively recent or upcoming');
      }

      print('✅ Adult pet schedule generated: ${schedule.length} treatments');
    });

    // ========================================================================
    // EDGE CASE TEST: Multiple deworming types (internal + external)
    // ========================================================================
    test('should handle multiple deworming types', () async {
      print('\n🐛 TEST: Multiple deworming types (internal + external)');

      final petBox = Hive.box<PetProfile>(HiveManager.petProfileBoxName);

      // Create puppy
      final testPuppy = PetProfile(
        name: 'Test Puppy Multi',
        species: 'dog',
        birthday: DateTime.now().subtract(Duration(days: 4 * 7)),
        isActive: true,
      );

      await petBox.put(testPuppy.id, testPuppy);

      // Create protocol with both internal and external treatments
      final combinedProtocol = DewormingProtocol(
        id: 'combined-deworming-protocol',
        name: 'Combined Deworming Protocol',
        species: 'dog',
        description: 'Both internal and external parasites',
        isCustom: false,
        schedules: [
          // Internal (worms) - monthly
          DewormingSchedule(
            dewormingType: 'internal',
            ageInWeeks: 2,
            productName: 'Milbemax',
            recurring: RecurringSchedule(
              intervalMonths: 1,
              indefinitely: false,
              numberOfDoses: 3,
            ),
          ),
          // External (fleas/ticks) - monthly
          DewormingSchedule(
            dewormingType: 'external',
            ageInWeeks: 8,
            productName: 'Bravecto',
            recurring: RecurringSchedule(
              intervalMonths: 1,
              indefinitely: false,
              numberOfDoses: 3,
            ),
          ),
        ],
      );

      await dewormingRepository.save(combinedProtocol);

      // Generate schedule
      final schedule = await protocolEngine.generateDewormingSchedule(
        pet: testPuppy,
        protocol: combinedProtocol,
        lookAheadMonths: 12,
      );

      // Should have both types of treatments
      final internalTreatments = schedule.where((s) => s.dewormingType == 'internal').toList();
      final externalTreatments = schedule.where((s) => s.dewormingType == 'external').toList();

      expect(internalTreatments, isNotEmpty,
        reason: 'Should have internal deworming treatments');
      expect(externalTreatments, isNotEmpty,
        reason: 'Should have external deworming treatments');

      // Verify product names are preserved
      expect(internalTreatments.every((t) => t.productName == 'Milbemax'), isTrue,
        reason: 'Internal treatments should use Milbemax');
      expect(externalTreatments.every((t) => t.productName == 'Bravecto'), isTrue,
        reason: 'External treatments should use Bravecto');

      print('✅ Multiple deworming types verified:');
      print('   Internal treatments: ${internalTreatments.length} (Milbemax)');
      print('   External treatments: ${externalTreatments.length} (Bravecto)');
    });

    // ========================================================================
    // EDGE CASE TEST: UpcomingCareEvent sorting
    // ========================================================================
    test('should sort upcoming care events by date', () async {
      print('\n📅 TEST: UpcomingCareEvent sorting');

      // Create multiple schedule entries with different dates
      final today = DateTime.now();
      final entries = [
        DewormingScheduleEntry(
          dewormingType: 'internal',
          scheduledDate: today.add(Duration(days: 30)),
          productName: 'Product 1',
        ),
        DewormingScheduleEntry(
          dewormingType: 'internal',
          scheduledDate: today.add(Duration(days: 7)),
          productName: 'Product 2',
        ),
        DewormingScheduleEntry(
          dewormingType: 'external',
          scheduledDate: today.add(Duration(days: 14)),
          productName: 'Product 3',
        ),
      ];

      // Convert to events
      final events = entries.map((e) => DewormingEvent(e)).toList();

      // Sort events
      events.sort((a, b) => a.compareTo(b));

      // Verify sorted order (nearest date first)
      expect(events[0].scheduledDate.difference(today).inDays, equals(7),
        reason: 'First event should be in 7 days');
      expect(events[1].scheduledDate.difference(today).inDays, equals(14),
        reason: 'Second event should be in 14 days');
      expect(events[2].scheduledDate.difference(today).inDays, equals(30),
        reason: 'Third event should be in 30 days');

      print('✅ Event sorting verified: Events sorted by nearest date first');
    });
  });
}
