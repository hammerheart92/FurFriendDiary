// File: test/integration/reminder_configuration_test.dart
// Coverage: Complete reminder configuration workflow integration test
// Focus Areas:
// - Create, modify, and persist reminder configurations
// - ReminderConfig CRUD operations through repository
// - Multiple configurations with different event types
// - Data persistence across simulated app restart
// - Edge cases: disabled reminders, no advance notice, all options enabled

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:fur_friend_diary/src/data/local/hive_manager.dart';
import 'package:fur_friend_diary/src/domain/models/pet_profile.dart';
import 'package:fur_friend_diary/src/domain/models/protocols/reminder_config.dart';
import 'package:fur_friend_diary/src/data/repositories/protocols/reminder_config_repository_impl.dart';

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

/// Integration test for complete reminder configuration workflow
///
/// This test validates the entire reminder configuration system from creation
/// to modification, persistence, and retrieval. Tests cover multiple event types
/// (vaccination, deworming, medication, appointment) with various configurations.
///
/// Test Flow:
/// 1. Setup: Initialize Hive, create test pet
/// 2. Create reminder configurations with different settings
/// 3. Modify configurations (enable/disable, change reminder days)
/// 4. Test data persistence across simulated app restart
/// 5. Test edge cases (no advance notice, all options enabled, disabled state)
/// 6. Cleanup: Close Hive, delete test directory
void main() {
  group('Reminder Configuration Integration Test', () {
    late Directory testDirectory;
    late Box<PetProfile> petProfileBox;
    late Box<ReminderConfig> reminderConfigBox;
    late ReminderConfigRepositoryImpl reminderConfigRepository;

    setUp(() async {
      // Step 1: Create temporary directory for test Hive storage
      testDirectory = await Directory.systemTemp.createTemp('reminder_config_test_');
      print('📁 Test directory: ${testDirectory.path}');

      // Step 2: Mock PathProvider to use test directory
      PathProviderPlatform.instance = MockPathProviderPlatform(testDirectory.path);

      // Step 3: Initialize Hive with test directory
      Hive.init(testDirectory.path);

      // Step 4: Register all required Hive adapters
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(PetProfileAdapter());
      }
      if (!Hive.isAdapterRegistered(29)) {
        Hive.registerAdapter(ReminderConfigAdapter());
      }

      // Step 5: Open boxes (without encryption for testing simplicity)
      petProfileBox = await Hive.openBox<PetProfile>(HiveManager.petProfileBoxName);
      reminderConfigBox = await Hive.openBox<ReminderConfig>(
        HiveManager.reminderConfigBoxName,
      );

      // Step 6: Create repository instance
      reminderConfigRepository = ReminderConfigRepositoryImpl(box: reminderConfigBox);

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

    test('complete reminder configuration workflow: create → modify → persist', () async {
      // ========================================================================
      // PHASE 1: CREATE TEST PET
      // ========================================================================
      print('\n🐕 PHASE 1: Creating test pet...');

      final today = DateTime.now();
      final birthdateFor8WeekOldPuppy = today.subtract(Duration(days: 8 * 7)); // 56 days ago

      final testPet = PetProfile(
        name: 'Test Puppy',
        species: 'dog',
        breed: 'Labrador Retriever',
        birthday: birthdateFor8WeekOldPuppy,
        isActive: true,
      );

      await petProfileBox.put(testPet.id, testPet);

      final savedPet = petProfileBox.get(testPet.id);
      expect(savedPet, isNotNull, reason: 'Pet should be saved to Hive');
      expect(savedPet!.name, equals('Test Puppy'));

      print('✅ Test pet created: ${savedPet.name} (ID: ${savedPet.id})');

      // ========================================================================
      // PHASE 2: CREATE DEFAULT VACCINATION REMINDER CONFIG
      // ========================================================================
      print('\n💉 PHASE 2: Creating vaccination reminder config with default settings...');

      final vaccinationConfig = ReminderConfig(
        id: 'vaccination-reminder-${DateTime.now().millisecondsSinceEpoch}',
        petId: testPet.id,
        eventType: 'vaccination',
        reminderDays: [0], // Day-of reminder only
        isEnabled: true,
      );

      await reminderConfigRepository.save(vaccinationConfig);

      // Verify save
      final savedVaccinationConfig = await reminderConfigRepository.getById(vaccinationConfig.id);
      expect(savedVaccinationConfig, isNotNull, reason: 'Vaccination config should be saved');
      expect(savedVaccinationConfig!.petId, equals(testPet.id));
      expect(savedVaccinationConfig.eventType, equals('vaccination'));
      expect(savedVaccinationConfig.reminderDays, equals([0]));
      expect(savedVaccinationConfig.isEnabled, isTrue);

      print('✅ Default vaccination config: ${vaccinationConfig.reminderDescription}');
      print('   Config ID: ${vaccinationConfig.id}');
      print('   Enabled: ${vaccinationConfig.isEnabled}');
      print('   Reminder days: ${vaccinationConfig.reminderDays}');

      // ========================================================================
      // PHASE 3: MODIFY CONFIG - ADD 1 DAY BEFORE
      // ========================================================================
      print('\n🔧 PHASE 3: Modifying config - adding 1 day advance notice...');

      final modifiedConfig = vaccinationConfig.copyWith(
        reminderDays: [0, 1], // Day-of + 1 day before
        updatedAt: DateTime.now(),
      );

      await reminderConfigRepository.save(modifiedConfig);

      final retrievedAfterUpdate = await reminderConfigRepository.getById(vaccinationConfig.id);
      expect(retrievedAfterUpdate, isNotNull);
      expect(retrievedAfterUpdate!.reminderDays, equals([0, 1]),
          reason: 'Should have day-of and 1 day before');
      expect(retrievedAfterUpdate.isEnabled, isTrue);

      print('✅ Modified config: ${retrievedAfterUpdate.reminderDescription}');
      print('   Reminder days: ${retrievedAfterUpdate.reminderDays}');

      // ========================================================================
      // PHASE 4: TOGGLE REMINDER OFF
      // ========================================================================
      print('\n🔕 PHASE 4: Disabling reminder...');

      final disabledConfig = modifiedConfig.copyWith(
        isEnabled: false,
        updatedAt: DateTime.now(),
      );

      await reminderConfigRepository.save(disabledConfig);

      final retrievedDisabled = await reminderConfigRepository.getById(vaccinationConfig.id);
      expect(retrievedDisabled, isNotNull);
      expect(retrievedDisabled!.isEnabled, isFalse, reason: 'Reminder should be disabled');
      expect(retrievedDisabled.reminderDays, equals([0, 1]),
          reason: 'Reminder days should be preserved when disabled');

      print('✅ Reminder disabled');
      print('   Enabled: ${retrievedDisabled.isEnabled}');
      print('   Preserved reminder days: ${retrievedDisabled.reminderDays}');

      // ========================================================================
      // PHASE 5: TOGGLE REMINDER BACK ON
      // ========================================================================
      print('\n🔔 PHASE 5: Re-enabling reminder...');

      final reenabledConfig = disabledConfig.copyWith(
        isEnabled: true,
        updatedAt: DateTime.now(),
      );

      await reminderConfigRepository.save(reenabledConfig);

      final retrievedReenabled = await reminderConfigRepository.getById(vaccinationConfig.id);
      expect(retrievedReenabled, isNotNull);
      expect(retrievedReenabled!.isEnabled, isTrue, reason: 'Reminder should be re-enabled');
      expect(retrievedReenabled.reminderDays, equals([0, 1]),
          reason: 'Reminder days should remain after re-enabling');

      print('✅ Reminder re-enabled');
      print('   Enabled: ${retrievedReenabled.isEnabled}');
      print('   Active reminder days: ${retrievedReenabled.reminderDays}');

      // ========================================================================
      // PHASE 6: ADD MULTIPLE ADVANCE NOTICE OPTIONS
      // ========================================================================
      print('\n📅 PHASE 6: Adding multiple advance notice options...');

      final multipleNoticeConfig = reenabledConfig.copyWith(
        reminderDays: [0, 1, 7, 14], // Day-of, 1 day, 1 week, 2 weeks before
        updatedAt: DateTime.now(),
      );

      await reminderConfigRepository.save(multipleNoticeConfig);

      final retrievedMultiple = await reminderConfigRepository.getById(vaccinationConfig.id);
      expect(retrievedMultiple, isNotNull);
      expect(retrievedMultiple!.reminderDays, equals([0, 1, 7, 14]),
          reason: 'Should have all advance notice options');
      expect(retrievedMultiple.isEnabled, isTrue);
      expect(retrievedMultiple.earliestReminderDays, equals(14),
          reason: 'Earliest reminder should be 14 days');

      print('✅ Multiple advance notices configured: ${retrievedMultiple.reminderDescription}');
      print('   Reminder days: ${retrievedMultiple.reminderDays}');
      print('   Earliest reminder: ${retrievedMultiple.earliestReminderDays} days before');

      // ========================================================================
      // PHASE 7: SIMULATE APP RESTART - VERIFY PERSISTENCE
      // ========================================================================
      print('\n🔄 PHASE 7: Simulating app restart to verify persistence...');

      // Close and reopen box
      await reminderConfigBox.close();
      reminderConfigBox = await Hive.openBox<ReminderConfig>(
        HiveManager.reminderConfigBoxName,
      );
      reminderConfigRepository = ReminderConfigRepositoryImpl(box: reminderConfigBox);

      // Retrieve config after restart
      final retrievedAfterRestart = await reminderConfigRepository.getById(vaccinationConfig.id);
      expect(retrievedAfterRestart, isNotNull, reason: 'Config should persist across restart');
      expect(retrievedAfterRestart!.petId, equals(testPet.id));
      expect(retrievedAfterRestart.eventType, equals('vaccination'));
      expect(retrievedAfterRestart.reminderDays, equals([0, 1, 7, 14]),
          reason: 'Reminder days should persist');
      expect(retrievedAfterRestart.isEnabled, isTrue, reason: 'Enabled state should persist');

      print('✅ Config persisted across app restart');
      print('   Retrieved config: ${retrievedAfterRestart.reminderDescription}');
      print('   Enabled: ${retrievedAfterRestart.isEnabled}');
    });

    test('medication reminder configuration: create and modify', () async {
      // ========================================================================
      // PHASE 1: CREATE TEST PET
      // ========================================================================
      print('\n🐕 PHASE 1: Creating test pet for medication reminders...');

      final testPet = PetProfile(
        name: 'Test Dog',
        species: 'dog',
        breed: 'Golden Retriever',
        birthday: DateTime.now().subtract(Duration(days: 365 * 2)), // 2 years old
        isActive: true,
      );

      await petProfileBox.put(testPet.id, testPet);
      print('✅ Test pet created: ${testPet.name} (ID: ${testPet.id})');

      // ========================================================================
      // PHASE 2: CREATE MEDICATION REMINDER WITH 1 DAY ADVANCE NOTICE
      // ========================================================================
      print('\n💊 PHASE 2: Creating medication reminder with 1 day advance notice...');

      final medicationConfig = ReminderConfig(
        id: 'medication-reminder-${DateTime.now().millisecondsSinceEpoch}',
        petId: testPet.id,
        eventType: 'medication',
        reminderDays: [0, 1], // Day-of + 1 day before
        isEnabled: true,
      );

      await reminderConfigRepository.save(medicationConfig);

      final savedMedicationConfig = await reminderConfigRepository.getById(medicationConfig.id);
      expect(savedMedicationConfig, isNotNull);
      expect(savedMedicationConfig!.eventType, equals('medication'));
      expect(savedMedicationConfig.reminderDays, equals([0, 1]));

      print('✅ Medication config created: ${medicationConfig.reminderDescription}');

      // ========================================================================
      // PHASE 3: MODIFY TO ADD WEEK BEFORE
      // ========================================================================
      print('\n🔧 PHASE 3: Adding 1 week advance notice...');

      final modifiedConfig = medicationConfig.copyWith(
        reminderDays: [0, 1, 7], // Day-of, 1 day, 1 week before
        updatedAt: DateTime.now(),
      );

      await reminderConfigRepository.save(modifiedConfig);

      final retrievedModified = await reminderConfigRepository.getById(medicationConfig.id);
      expect(retrievedModified, isNotNull);
      expect(retrievedModified!.reminderDays, equals([0, 1, 7]));

      print('✅ Modified medication config: ${retrievedModified.reminderDescription}');

      // ========================================================================
      // PHASE 4: DISABLE REMINDER
      // ========================================================================
      print('\n🔕 PHASE 4: Disabling medication reminder...');

      final disabledConfig = modifiedConfig.copyWith(
        isEnabled: false,
        updatedAt: DateTime.now(),
      );

      await reminderConfigRepository.save(disabledConfig);

      final retrievedDisabled = await reminderConfigRepository.getById(medicationConfig.id);
      expect(retrievedDisabled, isNotNull);
      expect(retrievedDisabled!.isEnabled, isFalse);
      expect(retrievedDisabled.reminderDays, equals([0, 1, 7]),
          reason: 'Reminder days preserved when disabled');

      print('✅ Medication reminder disabled (days preserved: ${retrievedDisabled.reminderDays})');
    });

    test('edge case: reminder with no advance notice options', () async {
      // ========================================================================
      // TEST: Create reminder that is enabled but has no specific notice times
      // This tests that the system can handle configs that might be set up for
      // future use but not currently active.
      // ========================================================================
      print('\n⚠️ EDGE CASE: Reminder enabled but no advance notice configured...');

      final testPet = PetProfile(
        name: 'Test Cat',
        species: 'cat',
        breed: 'Persian',
        birthday: DateTime.now().subtract(Duration(days: 365)), // 1 year old
        isActive: true,
      );

      await petProfileBox.put(testPet.id, testPet);

      // Note: ReminderConfig requires at least one day in reminderDays (assertion)
      // This test verifies that the minimal case (day-of only, then removed) is handled
      final appointmentConfig = ReminderConfig(
        id: 'appointment-reminder-${DateTime.now().millisecondsSinceEpoch}',
        petId: testPet.id,
        eventType: 'appointment',
        reminderDays: [0], // Start with day-of
        isEnabled: true,
      );

      await reminderConfigRepository.save(appointmentConfig);

      final savedConfig = await reminderConfigRepository.getById(appointmentConfig.id);
      expect(savedConfig, isNotNull);
      expect(savedConfig!.reminderDays, equals([0]));
      expect(savedConfig.isEnabled, isTrue);

      print('✅ Edge case handled: minimal config with day-of reminder only');
      print('   Config: ${savedConfig.reminderDescription}');
    });

    test('edge case: all advance notice options enabled', () async {
      // ========================================================================
      // TEST: Create reminder with all possible advance notice options
      // ========================================================================
      print('\n📢 EDGE CASE: All advance notice options enabled...');

      final testPet = PetProfile(
        name: 'Test Rabbit',
        species: 'rabbit',
        breed: 'Holland Lop',
        birthday: DateTime.now().subtract(Duration(days: 180)), // 6 months old
        isActive: true,
      );

      await petProfileBox.put(testPet.id, testPet);

      final dewormingConfig = ReminderConfig(
        id: 'deworming-reminder-${DateTime.now().millisecondsSinceEpoch}',
        petId: testPet.id,
        eventType: 'deworming',
        reminderDays: [0, 1, 7, 14, 30], // All common intervals
        isEnabled: true,
      );

      await reminderConfigRepository.save(dewormingConfig);

      final savedConfig = await reminderConfigRepository.getById(dewormingConfig.id);
      expect(savedConfig, isNotNull);
      expect(savedConfig!.reminderDays, equals([0, 1, 7, 14, 30]));
      expect(savedConfig.isEnabled, isTrue);
      expect(savedConfig.earliestReminderDays, equals(30),
          reason: 'Earliest reminder should be 30 days');

      print('✅ All options enabled: ${savedConfig.reminderDescription}');
      print('   Reminder days: ${savedConfig.reminderDays}');
      print('   Earliest reminder: ${savedConfig.earliestReminderDays} days before');
    });

    test('edge case: disabled reminder with preserved config', () async {
      // ========================================================================
      // TEST: Verify that disabled reminders preserve their configuration
      // for easy re-enabling without reconfiguration
      // ========================================================================
      print('\n🔕 EDGE CASE: Disabled reminder preserves configuration...');

      final testPet = PetProfile(
        name: 'Test Hamster',
        species: 'hamster',
        breed: 'Syrian',
        birthday: DateTime.now().subtract(Duration(days: 90)), // 3 months old
        isActive: true,
      );

      await petProfileBox.put(testPet.id, testPet);

      final customConfig = ReminderConfig(
        id: 'custom-reminder-${DateTime.now().millisecondsSinceEpoch}',
        petId: testPet.id,
        eventType: 'custom',
        customTitle: 'Cage Cleaning',
        customMessage: 'Time to clean the hamster cage',
        reminderDays: [0, 7], // Day-of and 1 week before
        isEnabled: false, // Start disabled
      );

      await reminderConfigRepository.save(customConfig);

      final savedDisabled = await reminderConfigRepository.getById(customConfig.id);
      expect(savedDisabled, isNotNull);
      expect(savedDisabled!.isEnabled, isFalse);
      expect(savedDisabled.reminderDays, equals([0, 7]),
          reason: 'Config should be preserved even when disabled');
      expect(savedDisabled.customTitle, equals('Cage Cleaning'));
      expect(savedDisabled.customMessage, equals('Time to clean the hamster cage'));

      print('✅ Disabled reminder created with preserved config');
      print('   Title: ${savedDisabled.customTitle}');
      print('   Preserved days: ${savedDisabled.reminderDays}');

      // Re-enable and verify config is still there
      final reenabledConfig = customConfig.copyWith(
        isEnabled: true,
        updatedAt: DateTime.now(),
      );

      await reminderConfigRepository.save(reenabledConfig);

      final retrievedReenabled = await reminderConfigRepository.getById(customConfig.id);
      expect(retrievedReenabled, isNotNull);
      expect(retrievedReenabled!.isEnabled, isTrue);
      expect(retrievedReenabled.reminderDays, equals([0, 7]),
          reason: 'Config should remain after re-enabling');
      expect(retrievedReenabled.customTitle, equals('Cage Cleaning'));

      print('✅ Re-enabled reminder retains all configuration');
    });

    test('multiple pets with different reminder configurations', () async {
      // ========================================================================
      // TEST: Verify that multiple pets can have independent reminder configs
      // and that modifications to one don't affect others
      // ========================================================================
      print('\n👥 TEST: Multiple pets with independent reminder configs...');

      // Create 3 test pets
      final pet1 = PetProfile(
        name: 'Dog 1',
        species: 'dog',
        breed: 'Beagle',
        birthday: DateTime.now().subtract(Duration(days: 365)),
        isActive: true,
      );

      final pet2 = PetProfile(
        name: 'Dog 2',
        species: 'dog',
        breed: 'Poodle',
        birthday: DateTime.now().subtract(Duration(days: 730)),
        isActive: true,
      );

      final pet3 = PetProfile(
        name: 'Cat 1',
        species: 'cat',
        breed: 'Siamese',
        birthday: DateTime.now().subtract(Duration(days: 1095)),
        isActive: true,
      );

      await petProfileBox.put(pet1.id, pet1);
      await petProfileBox.put(pet2.id, pet2);
      await petProfileBox.put(pet3.id, pet3);

      print('✅ Created 3 test pets');

      // ========================================================================
      // PHASE 1: Create different configs for each pet
      // ========================================================================
      print('\n📋 PHASE 1: Creating different configs for each pet...');

      // Pet 1: Day-of only
      final config1 = ReminderConfig(
        id: 'vaccination-pet1-${DateTime.now().millisecondsSinceEpoch}',
        petId: pet1.id,
        eventType: 'vaccination',
        reminderDays: [0],
        isEnabled: true,
      );

      // Pet 2: Day-of + 1 day before
      final config2 = ReminderConfig(
        id: 'vaccination-pet2-${DateTime.now().millisecondsSinceEpoch + 1}',
        petId: pet2.id,
        eventType: 'vaccination',
        reminderDays: [0, 1],
        isEnabled: true,
      );

      // Pet 3: Week before + day before + day-of
      final config3 = ReminderConfig(
        id: 'vaccination-pet3-${DateTime.now().millisecondsSinceEpoch + 2}',
        petId: pet3.id,
        eventType: 'vaccination',
        reminderDays: [0, 1, 7],
        isEnabled: true,
      );

      await reminderConfigRepository.save(config1);
      await reminderConfigRepository.save(config2);
      await reminderConfigRepository.save(config3);

      print('✅ Created 3 different vaccination configs');

      // ========================================================================
      // PHASE 2: Verify each config is saved correctly
      // ========================================================================
      print('\n🔍 PHASE 2: Verifying each config...');

      final retrievedConfig1 = await reminderConfigRepository.getById(config1.id);
      expect(retrievedConfig1, isNotNull);
      expect(retrievedConfig1!.petId, equals(pet1.id));
      expect(retrievedConfig1.reminderDays, equals([0]));

      final retrievedConfig2 = await reminderConfigRepository.getById(config2.id);
      expect(retrievedConfig2, isNotNull);
      expect(retrievedConfig2!.petId, equals(pet2.id));
      expect(retrievedConfig2.reminderDays, equals([0, 1]));

      final retrievedConfig3 = await reminderConfigRepository.getById(config3.id);
      expect(retrievedConfig3, isNotNull);
      expect(retrievedConfig3!.petId, equals(pet3.id));
      expect(retrievedConfig3.reminderDays, equals([0, 1, 7]));

      print('✅ All configs verified:');
      print('   Pet 1: ${retrievedConfig1.reminderDescription}');
      print('   Pet 2: ${retrievedConfig2.reminderDescription}');
      print('   Pet 3: ${retrievedConfig3.reminderDescription}');

      // ========================================================================
      // PHASE 3: Modify Pet 2 config and verify others unchanged
      // ========================================================================
      print('\n🔧 PHASE 3: Modifying Pet 2 config...');

      final modifiedConfig2 = config2.copyWith(
        isEnabled: false,
        updatedAt: DateTime.now(),
      );

      await reminderConfigRepository.save(modifiedConfig2);

      // Verify Pet 2 config was modified
      final retrievedModified2 = await reminderConfigRepository.getById(config2.id);
      expect(retrievedModified2, isNotNull);
      expect(retrievedModified2!.isEnabled, isFalse);

      // Verify Pet 1 and Pet 3 configs are unchanged
      final retrievedUnchanged1 = await reminderConfigRepository.getById(config1.id);
      expect(retrievedUnchanged1, isNotNull);
      expect(retrievedUnchanged1!.isEnabled, isTrue);
      expect(retrievedUnchanged1.reminderDays, equals([0]),
          reason: 'Pet 1 config should be unchanged');

      final retrievedUnchanged3 = await reminderConfigRepository.getById(config3.id);
      expect(retrievedUnchanged3, isNotNull);
      expect(retrievedUnchanged3!.isEnabled, isTrue);
      expect(retrievedUnchanged3.reminderDays, equals([0, 1, 7]),
          reason: 'Pet 3 config should be unchanged');

      print('✅ Pet 2 config disabled, others unchanged:');
      print('   Pet 1: Enabled=${retrievedUnchanged1.isEnabled}, Days=${retrievedUnchanged1.reminderDays}');
      print('   Pet 2: Enabled=${retrievedModified2.isEnabled}, Days=${retrievedModified2.reminderDays}');
      print('   Pet 3: Enabled=${retrievedUnchanged3.isEnabled}, Days=${retrievedUnchanged3.reminderDays}');

      // ========================================================================
      // PHASE 4: Retrieve all configs and verify count
      // ========================================================================
      print('\n📊 PHASE 4: Retrieving all configs...');

      final allConfigs = await reminderConfigRepository.getAll();
      expect(allConfigs.length, greaterThanOrEqualTo(3),
          reason: 'Should have at least 3 configs');

      // Filter by pet IDs
      final pet1Configs = allConfigs.where((c) => c.petId == pet1.id).toList();
      final pet2Configs = allConfigs.where((c) => c.petId == pet2.id).toList();
      final pet3Configs = allConfigs.where((c) => c.petId == pet3.id).toList();

      expect(pet1Configs.length, greaterThanOrEqualTo(1));
      expect(pet2Configs.length, greaterThanOrEqualTo(1));
      expect(pet3Configs.length, greaterThanOrEqualTo(1));

      print('✅ All configs retrieved:');
      print('   Total configs: ${allConfigs.length}');
      print('   Pet 1 configs: ${pet1Configs.length}');
      print('   Pet 2 configs: ${pet2Configs.length}');
      print('   Pet 3 configs: ${pet3Configs.length}');
    });

    test('query configurations by pet ID', () async {
      // ========================================================================
      // TEST: Verify repository can filter configs by pet ID
      // ========================================================================
      print('\n🔍 TEST: Querying configurations by pet ID...');

      // Create test pet
      final testPet = PetProfile(
        name: 'Multi-Config Dog',
        species: 'dog',
        breed: 'Corgi',
        birthday: DateTime.now().subtract(Duration(days: 365 * 3)),
        isActive: true,
      );

      await petProfileBox.put(testPet.id, testPet);

      // Create multiple configs for this pet
      final vaccinationConfig = ReminderConfig(
        id: 'vacc-${DateTime.now().millisecondsSinceEpoch}',
        petId: testPet.id,
        eventType: 'vaccination',
        reminderDays: [0, 7],
        isEnabled: true,
      );

      final dewormingConfig = ReminderConfig(
        id: 'deworm-${DateTime.now().millisecondsSinceEpoch + 1}',
        petId: testPet.id,
        eventType: 'deworming',
        reminderDays: [0, 1],
        isEnabled: true,
      );

      final appointmentConfig = ReminderConfig(
        id: 'appt-${DateTime.now().millisecondsSinceEpoch + 2}',
        petId: testPet.id,
        eventType: 'appointment',
        reminderDays: [0, 1, 7],
        isEnabled: false,
      );

      await reminderConfigRepository.save(vaccinationConfig);
      await reminderConfigRepository.save(dewormingConfig);
      await reminderConfigRepository.save(appointmentConfig);

      print('✅ Created 3 configs for pet ${testPet.name}');

      // Query by pet ID
      final petConfigs = await reminderConfigRepository.getByPetId(testPet.id);
      expect(petConfigs.length, greaterThanOrEqualTo(3),
          reason: 'Should have at least 3 configs for this pet');

      final enabledConfigs = petConfigs.where((c) => c.isEnabled).toList();
      final disabledConfigs = petConfigs.where((c) => !c.isEnabled).toList();

      expect(enabledConfigs.length, greaterThanOrEqualTo(2));
      expect(disabledConfigs.length, greaterThanOrEqualTo(1));

      print('✅ Query results:');
      print('   Total configs for pet: ${petConfigs.length}');
      print('   Enabled: ${enabledConfigs.length}');
      print('   Disabled: ${disabledConfigs.length}');
      print('   Event types: ${petConfigs.map((c) => c.eventType).toSet().join(', ')}');
    });

    test('custom reminder configuration with title and message', () async {
      // ========================================================================
      // TEST: Verify custom event type reminders work correctly
      // ========================================================================
      print('\n📝 TEST: Custom reminder with title and message...');

      final testPet = PetProfile(
        name: 'Test Bird',
        species: 'bird',
        breed: 'Parakeet',
        birthday: DateTime.now().subtract(Duration(days: 365)),
        isActive: true,
      );

      await petProfileBox.put(testPet.id, testPet);

      final customConfig = ReminderConfig(
        id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
        petId: testPet.id,
        eventType: 'custom',
        customTitle: 'Wing Clipping',
        customMessage: 'Schedule appointment with avian vet for wing clipping',
        reminderDays: [0, 7, 14],
        isEnabled: true,
      );

      await reminderConfigRepository.save(customConfig);

      final savedCustomConfig = await reminderConfigRepository.getById(customConfig.id);
      expect(savedCustomConfig, isNotNull);
      expect(savedCustomConfig!.eventType, equals('custom'));
      expect(savedCustomConfig.customTitle, equals('Wing Clipping'));
      expect(savedCustomConfig.customMessage,
          equals('Schedule appointment with avian vet for wing clipping'));
      expect(savedCustomConfig.isCustom, isTrue);
      expect(savedCustomConfig.reminderDays, equals([0, 7, 14]));

      print('✅ Custom reminder created:');
      print('   Title: ${savedCustomConfig.customTitle}');
      print('   Message: ${savedCustomConfig.customMessage}');
      print('   Reminder: ${savedCustomConfig.reminderDescription}');
    });
  });
}
