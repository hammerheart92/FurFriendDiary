// File: test/integration/vaccination_event_box_test.dart
// Coverage: VaccinationEvent Hive box integration test
// Focus Areas:
// - VaccinationEvent model serialization/deserialization
// - Hive box CRUD operations
// - Field persistence verification
// - Data integrity across box operations

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:fur_friend_diary/src/data/local/hive_manager.dart';
import 'package:fur_friend_diary/src/domain/models/vaccination_event.dart';

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

/// Integration test for VaccinationEvent Hive box
///
/// This test validates that VaccinationEvent can be properly:
/// 1. Saved to Hive box
/// 2. Retrieved from Hive box
/// 3. All fields persist correctly
/// 4. Deleted from Hive box
/// 5. Data persists across box close/reopen
void main() {
  group('VaccinationEvent Box Integration Test', () {
    late Directory testDirectory;
    late Box<VaccinationEvent> vaccinationBox;

    setUp(() async {
      // Step 1: Create temporary directory for test Hive storage
      testDirectory = await Directory.systemTemp.createTemp('vaccination_event_test_');
      print('Test directory: ${testDirectory.path}');

      // Step 2: Mock PathProvider to use test directory
      PathProviderPlatform.instance = MockPathProviderPlatform(testDirectory.path);

      // Step 3: Initialize Hive with test directory
      Hive.init(testDirectory.path);

      // Step 4: Register VaccinationEvent adapter (typeId 30)
      if (!Hive.isAdapterRegistered(30)) {
        Hive.registerAdapter(VaccinationEventAdapter());
      }

      // Step 5: Open the vaccination events box (without encryption for testing)
      vaccinationBox = await Hive.openBox<VaccinationEvent>(
        HiveManager.vaccinationEventBoxName,
      );

      print('Setup completed - Box opened: ${vaccinationBox.isOpen}');
    });

    tearDown(() async {
      // Step 1: Close all Hive boxes
      await Hive.close();

      // Step 2: Delete test directory
      if (await testDirectory.exists()) {
        await testDirectory.delete(recursive: true);
      }

      print('Cleanup completed');
    });

    test('should save, retrieve, and delete VaccinationEvent correctly', () async {
      // ========================================================================
      // PHASE 1: CREATE SAMPLE VACCINATION EVENT
      // ========================================================================
      print('\n PHASE 1: Creating sample VaccinationEvent...');

      final testEvent = VaccinationEvent(
        petId: 'test-pet-123',
        vaccineType: 'DHPPiL',
        administeredDate: DateTime(2024, 3, 15, 10, 30),
        nextDueDate: DateTime(2025, 3, 15),
        batchNumber: 'LOT-2024-ABC123',
        veterinarianName: 'Dr. Smith',
        clinicName: 'Happy Pets Veterinary Clinic',
        notes: 'First puppy vaccination - no adverse reactions',
        isFromProtocol: true,
        protocolId: 'canine-core-ro-eu-v1',
        protocolStepIndex: 0,
        certificatePhotoUrls: ['photos/vaccine_cert_001.jpg', 'photos/vaccine_cert_002.jpg'],
      );

      print('Created VaccinationEvent:');
      print('  ID: ${testEvent.id}');
      print('  Pet ID: ${testEvent.petId}');
      print('  Vaccine Type: ${testEvent.vaccineType}');
      print('  Administered Date: ${testEvent.administeredDate}');

      // ========================================================================
      // PHASE 2: SAVE TO HIVE BOX
      // ========================================================================
      print('\n PHASE 2: Saving to Hive box...');

      await vaccinationBox.put(testEvent.id, testEvent);

      // Verify box length increased
      expect(vaccinationBox.length, equals(1),
        reason: 'Box should contain exactly 1 event');

      print('Saved to box - Length: ${vaccinationBox.length}');

      // ========================================================================
      // PHASE 3: RETRIEVE FROM HIVE BOX
      // ========================================================================
      print('\n PHASE 3: Retrieving from Hive box...');

      final retrievedEvent = vaccinationBox.get(testEvent.id);

      expect(retrievedEvent, isNotNull, reason: 'Event should be retrievable');

      print('Retrieved VaccinationEvent:');
      print('  ID: ${retrievedEvent!.id}');
      print('  Vaccine Type: ${retrievedEvent.vaccineType}');

      // ========================================================================
      // PHASE 4: VERIFY ALL FIELDS PERSISTED CORRECTLY
      // ========================================================================
      print('\n PHASE 4: Verifying all fields...');

      // Core identification fields
      expect(retrievedEvent.id, equals(testEvent.id),
        reason: 'ID should persist');
      expect(retrievedEvent.petId, equals('test-pet-123'),
        reason: 'petId should persist');

      // Vaccine information
      expect(retrievedEvent.vaccineType, equals('DHPPiL'),
        reason: 'vaccineType should persist');
      expect(retrievedEvent.administeredDate, equals(DateTime(2024, 3, 15, 10, 30)),
        reason: 'administeredDate should persist with exact time');
      expect(retrievedEvent.nextDueDate, equals(DateTime(2025, 3, 15)),
        reason: 'nextDueDate should persist');

      // Veterinary details
      expect(retrievedEvent.batchNumber, equals('LOT-2024-ABC123'),
        reason: 'batchNumber should persist');
      expect(retrievedEvent.veterinarianName, equals('Dr. Smith'),
        reason: 'veterinarianName should persist');
      expect(retrievedEvent.clinicName, equals('Happy Pets Veterinary Clinic'),
        reason: 'clinicName should persist');

      // Documentation
      expect(retrievedEvent.notes, equals('First puppy vaccination - no adverse reactions'),
        reason: 'notes should persist');

      // Protocol linkage
      expect(retrievedEvent.isFromProtocol, isTrue,
        reason: 'isFromProtocol should persist as true');
      expect(retrievedEvent.protocolId, equals('canine-core-ro-eu-v1'),
        reason: 'protocolId should persist');
      expect(retrievedEvent.protocolStepIndex, equals(0),
        reason: 'protocolStepIndex should persist');

      // Certificate photos (List<String>)
      expect(retrievedEvent.certificatePhotoUrls, isNotNull,
        reason: 'certificatePhotoUrls should persist');
      expect(retrievedEvent.certificatePhotoUrls!.length, equals(2),
        reason: 'Should have 2 photo URLs');
      expect(retrievedEvent.certificatePhotoUrls![0], equals('photos/vaccine_cert_001.jpg'),
        reason: 'First photo URL should persist');
      expect(retrievedEvent.certificatePhotoUrls![1], equals('photos/vaccine_cert_002.jpg'),
        reason: 'Second photo URL should persist');

      // Metadata
      expect(retrievedEvent.createdAt, isNotNull,
        reason: 'createdAt should be set');

      print('All fields verified successfully!');
      print('  vaccineType: ${retrievedEvent.vaccineType}');
      print('  batchNumber: ${retrievedEvent.batchNumber}');
      print('  veterinarianName: ${retrievedEvent.veterinarianName}');
      print('  clinicName: ${retrievedEvent.clinicName}');
      print('  isFromProtocol: ${retrievedEvent.isFromProtocol}');
      print('  protocolId: ${retrievedEvent.protocolId}');
      print('  certificatePhotoUrls: ${retrievedEvent.certificatePhotoUrls}');

      // ========================================================================
      // PHASE 5: TEST UPDATE (copyWith)
      // ========================================================================
      print('\n PHASE 5: Testing update with copyWith...');

      final updatedEvent = retrievedEvent.copyWith(
        notes: 'Updated notes - Annual booster completed',
        updatedAt: DateTime.now(),
      );

      await vaccinationBox.put(updatedEvent.id, updatedEvent);

      final afterUpdate = vaccinationBox.get(updatedEvent.id);
      expect(afterUpdate!.notes, equals('Updated notes - Annual booster completed'),
        reason: 'Updated notes should persist');
      expect(afterUpdate.updatedAt, isNotNull,
        reason: 'updatedAt should be set after update');
      // Original fields should remain unchanged
      expect(afterUpdate.vaccineType, equals('DHPPiL'),
        reason: 'vaccineType should not change');
      expect(afterUpdate.petId, equals('test-pet-123'),
        reason: 'petId should not change');

      print('Update verified - notes changed, other fields preserved');

      // ========================================================================
      // PHASE 6: DELETE FROM HIVE BOX
      // ========================================================================
      print('\n PHASE 6: Deleting from Hive box...');

      await vaccinationBox.delete(testEvent.id);

      // Verify deletion
      expect(vaccinationBox.length, equals(0),
        reason: 'Box should be empty after deletion');

      final deletedEvent = vaccinationBox.get(testEvent.id);
      expect(deletedEvent, isNull,
        reason: 'Deleted event should not be retrievable');

      print('Deletion verified - Box is empty');

      // ========================================================================
      // PHASE 7: SUMMARY
      // ========================================================================
      print('\n VACCINATION EVENT BOX TEST PASSED!');
      print('----------------------------------------');
      print('1. VaccinationEvent created with all fields');
      print('2. Saved to Hive box successfully');
      print('3. Retrieved from box successfully');
      print('4. All 14 fields verified correctly');
      print('5. Update with copyWith works');
      print('6. Deletion works correctly');
      print('----------------------------------------');
    });

    test('should persist data across box close and reopen', () async {
      // ========================================================================
      // PHASE 1: CREATE AND SAVE EVENT
      // ========================================================================
      print('\n PERSISTENCE TEST: Creating and saving event...');

      final testEvent = VaccinationEvent(
        petId: 'persistence-test-pet',
        vaccineType: 'Rabies',
        administeredDate: DateTime(2024, 6, 1),
        batchNumber: 'RAB-2024-XYZ',
        veterinarianName: 'Dr. Johnson',
        clinicName: 'City Vet Clinic',
        isFromProtocol: false,
      );

      await vaccinationBox.put(testEvent.id, testEvent);
      final eventId = testEvent.id;

      print('Event saved with ID: $eventId');

      // ========================================================================
      // PHASE 2: CLOSE BOX (SIMULATE APP SHUTDOWN)
      // ========================================================================
      print('\n PERSISTENCE TEST: Closing box (simulating app shutdown)...');

      await vaccinationBox.close();
      expect(vaccinationBox.isOpen, isFalse, reason: 'Box should be closed');

      print('Box closed');

      // ========================================================================
      // PHASE 3: REOPEN BOX (SIMULATE APP RESTART)
      // ========================================================================
      print('\n PERSISTENCE TEST: Reopening box (simulating app restart)...');

      final reopenedBox = await Hive.openBox<VaccinationEvent>(
        HiveManager.vaccinationEventBoxName,
      );

      expect(reopenedBox.isOpen, isTrue, reason: 'Box should reopen');
      print('Box reopened - Length: ${reopenedBox.length}');

      // ========================================================================
      // PHASE 4: VERIFY DATA PERSISTED
      // ========================================================================
      print('\n PERSISTENCE TEST: Verifying data persisted...');

      expect(reopenedBox.length, equals(1),
        reason: 'Box should still contain 1 event after reopen');

      final persistedEvent = reopenedBox.get(eventId);
      expect(persistedEvent, isNotNull, reason: 'Event should persist across restart');
      expect(persistedEvent!.petId, equals('persistence-test-pet'));
      expect(persistedEvent.vaccineType, equals('Rabies'));
      expect(persistedEvent.batchNumber, equals('RAB-2024-XYZ'));
      expect(persistedEvent.veterinarianName, equals('Dr. Johnson'));
      expect(persistedEvent.clinicName, equals('City Vet Clinic'));
      expect(persistedEvent.isFromProtocol, isFalse);

      print('Data persisted correctly across box close/reopen!');

      // Update reference for tearDown
      vaccinationBox = reopenedBox;
    });

    test('should handle null optional fields correctly', () async {
      // ========================================================================
      // TEST: MINIMAL VACCINATION EVENT (only required fields)
      // ========================================================================
      print('\n NULL FIELDS TEST: Creating minimal event...');

      final minimalEvent = VaccinationEvent(
        petId: 'minimal-test-pet',
        vaccineType: 'FVRCP',
        administeredDate: DateTime(2024, 4, 20),
        // All optional fields left as null/default
      );

      await vaccinationBox.put(minimalEvent.id, minimalEvent);

      final retrieved = vaccinationBox.get(minimalEvent.id);
      expect(retrieved, isNotNull);

      // Verify required fields
      expect(retrieved!.petId, equals('minimal-test-pet'));
      expect(retrieved.vaccineType, equals('FVRCP'));
      expect(retrieved.administeredDate, equals(DateTime(2024, 4, 20)));

      // Verify optional fields are null/default
      expect(retrieved.nextDueDate, isNull);
      expect(retrieved.batchNumber, isNull);
      expect(retrieved.veterinarianName, isNull);
      expect(retrieved.clinicName, isNull);
      expect(retrieved.notes, isNull);
      expect(retrieved.isFromProtocol, isFalse); // default value
      expect(retrieved.protocolId, isNull);
      expect(retrieved.protocolStepIndex, isNull);
      expect(retrieved.updatedAt, isNull);
      expect(retrieved.certificatePhotoUrls, isNull);

      // createdAt should be auto-set
      expect(retrieved.createdAt, isNotNull);

      print('Minimal event with null optional fields works correctly!');
    });

    test('should handle multiple events in box', () async {
      // ========================================================================
      // TEST: MULTIPLE EVENTS
      // ========================================================================
      print('\n MULTIPLE EVENTS TEST: Creating multiple events...');

      final events = [
        VaccinationEvent(
          petId: 'pet-1',
          vaccineType: 'DHPPiL',
          administeredDate: DateTime(2024, 1, 15),
        ),
        VaccinationEvent(
          petId: 'pet-1',
          vaccineType: 'Rabies',
          administeredDate: DateTime(2024, 2, 15),
        ),
        VaccinationEvent(
          petId: 'pet-2',
          vaccineType: 'FVRCP',
          administeredDate: DateTime(2024, 3, 15),
        ),
      ];

      // Save all events
      for (final event in events) {
        await vaccinationBox.put(event.id, event);
      }

      expect(vaccinationBox.length, equals(3),
        reason: 'Box should contain 3 events');

      // Query by iteration
      final allEvents = vaccinationBox.values.toList();
      expect(allEvents.length, equals(3));

      // Filter by petId (simulating repository query)
      final pet1Events = allEvents.where((e) => e.petId == 'pet-1').toList();
      expect(pet1Events.length, equals(2),
        reason: 'pet-1 should have 2 vaccination events');

      final pet2Events = allEvents.where((e) => e.petId == 'pet-2').toList();
      expect(pet2Events.length, equals(1),
        reason: 'pet-2 should have 1 vaccination event');

      print('Multiple events test passed!');
      print('  Total events: ${allEvents.length}');
      print('  pet-1 events: ${pet1Events.length}');
      print('  pet-2 events: ${pet2Events.length}');
    });

    test('toJson and fromJson should work correctly', () async {
      // ========================================================================
      // TEST: JSON SERIALIZATION
      // ========================================================================
      print('\n JSON TEST: Testing toJson/fromJson...');

      final originalEvent = VaccinationEvent(
        petId: 'json-test-pet',
        vaccineType: 'Bordetella',
        administeredDate: DateTime(2024, 5, 10, 14, 30),
        nextDueDate: DateTime(2025, 5, 10),
        batchNumber: 'BOR-123',
        veterinarianName: 'Dr. Brown',
        clinicName: 'Pet Wellness Center',
        notes: 'Kennel cough vaccine',
        isFromProtocol: true,
        protocolId: 'canine-extended-v1',
        protocolStepIndex: 2,
        certificatePhotoUrls: ['cert1.jpg'],
      );

      // Convert to JSON
      final json = originalEvent.toJson();
      expect(json, isA<Map<String, dynamic>>());
      expect(json['vaccineType'], equals('Bordetella'));
      expect(json['petId'], equals('json-test-pet'));
      expect(json['isFromProtocol'], isTrue);
      expect(json['certificatePhotoUrls'], equals(['cert1.jpg']));

      print('toJson works correctly');

      // Convert back from JSON
      final fromJsonEvent = VaccinationEvent.fromJson(json);
      expect(fromJsonEvent.id, equals(originalEvent.id));
      expect(fromJsonEvent.petId, equals(originalEvent.petId));
      expect(fromJsonEvent.vaccineType, equals(originalEvent.vaccineType));
      expect(fromJsonEvent.administeredDate, equals(originalEvent.administeredDate));
      expect(fromJsonEvent.nextDueDate, equals(originalEvent.nextDueDate));
      expect(fromJsonEvent.batchNumber, equals(originalEvent.batchNumber));
      expect(fromJsonEvent.veterinarianName, equals(originalEvent.veterinarianName));
      expect(fromJsonEvent.clinicName, equals(originalEvent.clinicName));
      expect(fromJsonEvent.notes, equals(originalEvent.notes));
      expect(fromJsonEvent.isFromProtocol, equals(originalEvent.isFromProtocol));
      expect(fromJsonEvent.protocolId, equals(originalEvent.protocolId));
      expect(fromJsonEvent.protocolStepIndex, equals(originalEvent.protocolStepIndex));
      expect(fromJsonEvent.certificatePhotoUrls, equals(originalEvent.certificatePhotoUrls));

      print('fromJson works correctly - round-trip successful!');
    });
  });
}
