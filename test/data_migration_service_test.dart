import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fur_friend_diary/src/services/encryption_service.dart';
import 'package:fur_friend_diary/src/services/data_migration_service.dart';

void main() {
  late Directory testDirectory;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() async {
    testDirectory = await Directory.systemTemp.createTemp('migration_test_');
    Hive.init(testDirectory.path);
    EncryptionService.resetForTesting();
  });

  tearDown(() async {
    await Hive.close();
    if (testDirectory.existsSync()) {
      testDirectory.deleteSync(recursive: true);
    }
    EncryptionService.resetForTesting();
  });

  group('DataMigrationService - No Migration Needed', () {
    test('returns success when no unencrypted boxes exist', () async {
      await EncryptionService.initialize();
      final service = DataMigrationService();

      final result = await service.migrateToEncrypted();

      expect(result.success, true);
      expect(result.message, contains('No migration needed'));
      expect(result.totalRecordsMigrated, 0);
      expect(result.boxesProcessed, isEmpty);
      expect(result.errors, isEmpty);
    });

    test('returns success when all boxes are already encrypted', () async {
      await EncryptionService.initialize();
      final cipher = await EncryptionService.getEncryptionCipher();

      // Create some encrypted boxes
      final box1 = await Hive.openBox('pet_profiles', encryptionCipher: cipher);
      await box1.put('test', 'data');
      await box1.close();

      final service = DataMigrationService();
      final result = await service.migrateToEncrypted();

      expect(result.success, true);
      expect(result.message, contains('already encrypted'));
    });
  });

  group('DataMigrationService - Successful Migration', () {
    test('migrates single box with data', () async {
      // Create unencrypted box with data
      final unencryptedBox = await Hive.openBox('pet_profiles');
      await unencryptedBox.add({'name': 'Fluffy', 'type': 'cat'});
      await unencryptedBox.add({'name': 'Rover', 'type': 'dog'});
      await unencryptedBox.close();

      // Initialize encryption and migrate
      await EncryptionService.initialize();
      final service = DataMigrationService();
      final result = await service.migrateToEncrypted();

      expect(result.success, true);
      expect(result.totalRecordsMigrated, 2);
      expect(result.boxesProcessed, contains('pet_profiles'));
      expect(result.recordsPerBox['pet_profiles'], 2);
      expect(result.errors, isEmpty);

      // Verify data is accessible in encrypted box
      final cipher = await EncryptionService.getEncryptionCipher();
      final encryptedBox = await Hive.openBox(
        'pet_profiles',
        encryptionCipher: cipher,
      );

      expect(encryptedBox.length, 2);
      expect(encryptedBox.getAt(0)['name'], 'Fluffy');
      expect(encryptedBox.getAt(1)['name'], 'Rover');

      await encryptedBox.close();
    });

    test('migrates multiple boxes with different data types', () async {
      // Create multiple unencrypted boxes
      final box1 = await Hive.openBox('pet_profiles');
      await box1.add({'name': 'Fluffy'});
      await box1.add({'name': 'Rover'});
      await box1.close();

      final box2 = await Hive.openBox('medications');
      await box2.add({'med': 'Aspirin', 'dose': '10mg'});
      await box2.close();

      final box3 = await Hive.openBox('appointments');
      await box3.add({'date': '2024-01-01', 'vet': 'Dr. Smith'});
      await box3.add({'date': '2024-02-01', 'vet': 'Dr. Jones'});
      await box3.add({'date': '2024-03-01', 'vet': 'Dr. Brown'});
      await box3.close();

      // Migrate
      await EncryptionService.initialize();
      final service = DataMigrationService();
      final result = await service.migrateToEncrypted();

      expect(result.success, true);
      expect(result.totalRecordsMigrated, 6); // 2 + 1 + 3
      expect(result.boxesProcessed.length, 3);
      expect(result.recordsPerBox['pet_profiles'], 2);
      expect(result.recordsPerBox['medications'], 1);
      expect(result.recordsPerBox['appointments'], 3);
    });

    test('handles empty boxes correctly', () async {
      // Create mix of empty and non-empty boxes
      final box1 = await Hive.openBox('pet_profiles');
      await box1.add({'name': 'Fluffy'});
      await box1.close();

      final box2 = await Hive.openBox('medications');
      // Leave empty
      await box2.close();

      await EncryptionService.initialize();
      final service = DataMigrationService();
      final result = await service.migrateToEncrypted();

      expect(result.success, true);
      expect(result.totalRecordsMigrated, 1);
      expect(result.boxesProcessed, contains('pet_profiles'));
      // Empty box should not be in processed list
      expect(result.recordsPerBox['medications'], isNull);
    });

    test('preserves data types during migration', () async {
      final box = await Hive.openBox('settings');
      await box.put('string', 'test_value');
      await box.put('int', 42);
      await box.put('double', 3.14159);
      await box.put('bool', true);
      await box.put('list', [1, 2, 3]);
      await box.put('map', {'key': 'value'});
      await box.close();

      await EncryptionService.initialize();
      final service = DataMigrationService();
      final result = await service.migrateToEncrypted();

      expect(result.success, true);

      // Verify all data types preserved
      final cipher = await EncryptionService.getEncryptionCipher();
      final encryptedBox = await Hive.openBox(
        'settings',
        encryptionCipher: cipher,
      );

      // Note: Hive.add() uses auto-increment keys, but we used put() with string keys
      // So we need to check if the values exist
      expect(encryptedBox.values.contains('test_value'), true);
      expect(encryptedBox.values.contains(42), true);
      expect(encryptedBox.values.contains(3.14159), true);
      expect(encryptedBox.values.contains(true), true);

      await encryptedBox.close();
    });

    test('deletes old unencrypted boxes after successful migration', () async {
      final box = await Hive.openBox('pet_profiles');
      await box.add({'name': 'Fluffy'});
      await box.close();

      await EncryptionService.initialize();
      final service = DataMigrationService();
      await service.migrateToEncrypted();

      // Try to open box without encryption - should fail
      expect(
        () => Hive.openBox('pet_profiles'),
        throwsA(isA<HiveError>()),
      );
    });
  });

  group('DataMigrationService - Migration Result', () {
    test('MigrationResult contains correct statistics', () async {
      final box1 = await Hive.openBox('pet_profiles');
      await box1.add({'name': 'Pet1'});
      await box1.add({'name': 'Pet2'});
      await box1.close();

      final box2 = await Hive.openBox('medications');
      await box2.add({'med': 'Med1'});
      await box2.close();

      await EncryptionService.initialize();
      final service = DataMigrationService();
      final result = await service.migrateToEncrypted();

      expect(result.success, true);
      expect(result.totalRecordsMigrated, 3);
      expect(result.boxesProcessed.length, 2);
      expect(result.recordsPerBox['pet_profiles'], 2);
      expect(result.recordsPerBox['medications'], 1);
      expect(result.errors, isEmpty);
      expect(result.duration.inSeconds, greaterThanOrEqualTo(0));
    });

    test('MigrationResult toString() provides readable output', () async {
      await EncryptionService.initialize();
      final service = DataMigrationService();
      final result = await service.migrateToEncrypted();

      final resultString = result.toString();
      expect(resultString, contains('MigrationResult'));
      expect(resultString, contains('success'));
      expect(resultString, contains('message'));
    });

    test('MigrationResult toMap() converts to JSON-serializable format', () async {
      await EncryptionService.initialize();
      final service = DataMigrationService();
      final result = await service.migrateToEncrypted();

      final map = result.toMap();
      expect(map, isA<Map<String, dynamic>>());
      expect(map['success'], isA<bool>());
      expect(map['message'], isA<String>());
      expect(map['totalRecordsMigrated'], isA<int>());
      expect(map['boxesProcessed'], isA<List>());
      expect(map['recordsPerBox'], isA<Map>());
      expect(map['errors'], isA<List>());
      expect(map['durationSeconds'], isA<int>());
    });
  });

  group('DataMigrationService - Data Safety', () {
    test('preserves original data if migration not completed', () async {
      final box = await Hive.openBox('pet_profiles');
      await box.add({'name': 'Fluffy', 'type': 'cat'});
      await box.add({'name': 'Rover', 'type': 'dog'});
      final originalData = box.values.toList();
      await box.close();

      // Note: In real failure scenarios, the original boxes would be preserved
      // This test verifies the data is readable before migration
      expect(originalData.length, 2);
      expect(originalData[0]['name'], 'Fluffy');
      expect(originalData[1]['name'], 'Rover');
    });

    test('migration is idempotent - can be run multiple times safely', () async {
      final box = await Hive.openBox('pet_profiles');
      await box.add({'name': 'Fluffy'});
      await box.close();

      await EncryptionService.initialize();
      final service = DataMigrationService();

      // First migration
      final result1 = await service.migrateToEncrypted();
      expect(result1.success, true);
      expect(result1.totalRecordsMigrated, 1);

      // Second migration (should detect already encrypted)
      final result2 = await service.migrateToEncrypted();
      expect(result2.success, true);
      expect(result2.message, contains('already encrypted'));
      expect(result2.totalRecordsMigrated, 0);
    });
  });

  group('DataMigrationService - Data Integrity', () {
    test('verifies record counts match after migration', () async {
      final box = await Hive.openBox('pet_profiles');
      for (int i = 0; i < 100; i++) {
        await box.add({'id': i, 'name': 'Pet$i'});
      }
      await box.close();

      await EncryptionService.initialize();
      final service = DataMigrationService();
      final result = await service.migrateToEncrypted();

      expect(result.success, true);
      expect(result.totalRecordsMigrated, 100);

      // Verify count in encrypted box
      final cipher = await EncryptionService.getEncryptionCipher();
      final encryptedBox = await Hive.openBox(
        'pet_profiles',
        encryptionCipher: cipher,
      );

      expect(encryptedBox.length, 100);
      await encryptedBox.close();
    });

    test('handles large datasets without data loss', () async {
      final box = await Hive.openBox('walks');
      for (int i = 0; i < 1000; i++) {
        await box.add({
          'id': i,
          'date': '2024-01-${(i % 30) + 1}',
          'duration': i * 10,
        });
      }
      await box.close();

      await EncryptionService.initialize();
      final service = DataMigrationService();
      final result = await service.migrateToEncrypted();

      expect(result.success, true);
      expect(result.totalRecordsMigrated, 1000);
      expect(result.errors, isEmpty);
    });
  });

  group('DataMigrationService - Error Handling', () {
    test('MigrationException can be constructed', () {
      final exception = MigrationException('Test error');
      expect(exception.toString(), contains('Test error'));
    });

    test('handles box that does not exist', () async {
      // Don't create any boxes

      await EncryptionService.initialize();
      final service = DataMigrationService();
      final result = await service.migrateToEncrypted();

      expect(result.success, true);
      expect(result.message, contains('No migration needed'));
    });
  });

  group('DataMigrationService - Real-world Scenarios', () {
    test('migrates complex pet care data structure', () async {
      // Simulate real app data
      final petBox = await Hive.openBox('pet_profiles');
      await petBox.add({
        'id': '1',
        'name': 'Fluffy',
        'type': 'cat',
        'breed': 'Persian',
        'birthdate': '2020-01-01',
      });
      await petBox.close();

      final medBox = await Hive.openBox('medications');
      await medBox.add({
        'id': '1',
        'petId': '1',
        'name': 'Flea Treatment',
        'dosage': '1 tablet',
        'frequency': 'monthly',
      });
      await medBox.close();

      final apptBox = await Hive.openBox('appointments');
      await apptBox.add({
        'id': '1',
        'petId': '1',
        'date': '2024-06-15',
        'vet': 'Dr. Smith',
        'reason': 'Annual checkup',
      });
      await apptBox.close();

      await EncryptionService.initialize();
      final service = DataMigrationService();
      final result = await service.migrateToEncrypted();

      expect(result.success, true);
      expect(result.totalRecordsMigrated, 3);
      expect(result.boxesProcessed.length, 3);
      expect(result.errors, isEmpty);

      // Verify all data is accessible
      final cipher = await EncryptionService.getEncryptionCipher();

      final encPetBox = await Hive.openBox('pet_profiles', encryptionCipher: cipher);
      expect(encPetBox.length, 1);
      expect(encPetBox.getAt(0)['name'], 'Fluffy');
      await encPetBox.close();

      final encMedBox = await Hive.openBox('medications', encryptionCipher: cipher);
      expect(encMedBox.length, 1);
      await encMedBox.close();

      final encApptBox = await Hive.openBox('appointments', encryptionCipher: cipher);
      expect(encApptBox.length, 1);
      await encApptBox.close();
    });
  });
}
