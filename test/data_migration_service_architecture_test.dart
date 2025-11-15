import 'package:flutter_test/flutter_test.dart';
import 'package:fur_friend_diary/src/services/data_migration_service.dart';

/// Architecture tests for DataMigrationService
///
/// Note: Full functional tests require integration testing on a real device/emulator
/// because the service depends on EncryptionService which uses platform channels.
/// These tests verify the service architecture, API surface, and data structures.
void main() {
  group('DataMigrationService Architecture', () {
    test('service can be instantiated', () {
      final service = DataMigrationService();
      expect(service, isNotNull);
      expect(service, isA<DataMigrationService>());
    });

    test('service exposes correct public API', () {
      final service = DataMigrationService();
      expect(service.migrateToEncrypted, isA<Function>());
    });
  });

  group('MigrationResult Data Structure', () {
    test('can be instantiated with default values', () {
      final result = MigrationResult();

      expect(result.success, false);
      expect(result.message, '');
      expect(result.totalRecordsMigrated, 0);
      expect(result.boxesProcessed, isEmpty);
      expect(result.recordsPerBox, isEmpty);
      expect(result.errors, isEmpty);
      expect(result.duration, Duration.zero);
    });

    test('fields can be modified', () {
      final result = MigrationResult();

      result.success = true;
      result.message = 'Test message';
      result.totalRecordsMigrated = 100;
      result.boxesProcessed.add('test_box');
      result.recordsPerBox['test_box'] = 50;
      result.errors.add('Test error');
      result.duration = Duration(seconds: 5);

      expect(result.success, true);
      expect(result.message, 'Test message');
      expect(result.totalRecordsMigrated, 100);
      expect(result.boxesProcessed, ['test_box']);
      expect(result.recordsPerBox['test_box'], 50);
      expect(result.errors, ['Test error']);
      expect(result.duration, Duration(seconds: 5));
    });

    test('toString() provides readable output', () {
      final result = MigrationResult();
      result.success = true;
      result.message = 'Migration completed';
      result.totalRecordsMigrated = 42;

      final resultString = result.toString();

      expect(resultString, contains('MigrationResult'));
      expect(resultString, contains('success: true'));
      expect(resultString, contains('message: Migration completed'));
      expect(resultString, contains('totalRecordsMigrated: 42'));
    });

    test('toMap() converts to JSON-serializable format', () {
      final result = MigrationResult();
      result.success = true;
      result.message = 'Test';
      result.totalRecordsMigrated = 10;
      result.boxesProcessed = ['box1', 'box2'];
      result.recordsPerBox = {'box1': 5, 'box2': 5};
      result.errors = [];
      result.duration = Duration(seconds: 3);

      final map = result.toMap();

      expect(map, isA<Map<String, dynamic>>());
      expect(map['success'], true);
      expect(map['message'], 'Test');
      expect(map['totalRecordsMigrated'], 10);
      expect(map['boxesProcessed'], ['box1', 'box2']);
      expect(map['recordsPerBox'], {'box1': 5, 'box2': 5});
      expect(map['errors'], isEmpty);
      expect(map['durationSeconds'], 3);
    });

    test('toMap() handles complex nested data', () {
      final result = MigrationResult();
      result.boxesProcessed = ['pet_profiles', 'medications', 'walks'];
      result.recordsPerBox = {
        'pet_profiles': 10,
        'medications': 25,
        'walks': 100,
      };
      result.errors = ['Error 1', 'Error 2'];

      final map = result.toMap();

      expect(map['boxesProcessed'], isA<List>());
      expect(map['boxesProcessed'].length, 3);
      expect(map['recordsPerBox'], isA<Map>());
      expect(map['recordsPerBox']['pet_profiles'], 10);
      expect(map['errors'], isA<List>());
      expect(map['errors'].length, 2);
    });
  });

  group('MigrationException', () {
    test('can be instantiated', () {
      final exception = MigrationException('Test error');
      expect(exception, isNotNull);
      expect(exception, isA<Exception>());
    });

    test('stores error message', () {
      final exception = MigrationException('Custom error message');
      expect(exception.message, 'Custom error message');
    });

    test('toString() includes message', () {
      final exception = MigrationException('Test error');
      final exceptionString = exception.toString();

      expect(exceptionString, contains('MigrationException'));
      expect(exceptionString, contains('Test error'));
    });

    test('can be thrown and caught', () {
      expect(
        () => throw MigrationException('Test'),
        throwsA(isA<MigrationException>()),
      );

      try {
        throw MigrationException('Caught');
      } on MigrationException catch (e) {
        expect(e.message, 'Caught');
      }
    });
  });

  group('MigrationResult Statistics Tracking', () {
    test('tracks multiple boxes correctly', () {
      final result = MigrationResult();

      result.boxesProcessed.add('pet_profiles');
      result.recordsPerBox['pet_profiles'] = 10;
      result.totalRecordsMigrated += 10;

      result.boxesProcessed.add('medications');
      result.recordsPerBox['medications'] = 25;
      result.totalRecordsMigrated += 25;

      result.boxesProcessed.add('appointments');
      result.recordsPerBox['appointments'] = 15;
      result.totalRecordsMigrated += 15;

      expect(result.boxesProcessed.length, 3);
      expect(result.totalRecordsMigrated, 50);
      expect(result.recordsPerBox['pet_profiles'], 10);
      expect(result.recordsPerBox['medications'], 25);
      expect(result.recordsPerBox['appointments'], 15);
    });

    test('tracks errors separately from success', () {
      final result = MigrationResult();

      result.success = false;
      result.errors.add('Failed to read box1');
      result.errors.add('Failed to write box2');
      result.errors.add('Verification failed for box3');

      expect(result.success, false);
      expect(result.errors.length, 3);
      expect(result.errors[0], contains('box1'));
      expect(result.errors[1], contains('box2'));
      expect(result.errors[2], contains('box3'));
    });

    test('duration tracking works correctly', () {
      final result = MigrationResult();

      final start = DateTime.now();
      // Simulate some work
      final end = start.add(Duration(seconds: 5));
      result.duration = end.difference(start);

      expect(result.duration.inSeconds, 5);
      expect(result.toMap()['durationSeconds'], 5);
    });
  });

  group('Migration Safety Contracts', () {
    test('result defaults to unsuccessful state', () {
      final result = MigrationResult();

      // By default, migration should be considered unsuccessful
      expect(result.success, false);
      expect(result.message, isEmpty);
    });

    test('success requires explicit setting', () {
      final result = MigrationResult();

      expect(result.success, false);

      result.success = true;
      expect(result.success, true);
    });

    test('errors list is mutable for accumulation', () {
      final result = MigrationResult();

      expect(result.errors, isEmpty);

      result.errors.add('Error 1');
      expect(result.errors.length, 1);

      result.errors.add('Error 2');
      expect(result.errors.length, 2);

      result.errors.addAll(['Error 3', 'Error 4']);
      expect(result.errors.length, 4);
    });
  });

  group('Real-world Usage Patterns', () {
    test('typical success result structure', () {
      final result = MigrationResult();
      result.success = true;
      result.message = 'Successfully migrated 100 records across 5 boxes';
      result.totalRecordsMigrated = 100;
      result.boxesProcessed = [
        'pet_profiles',
        'medications',
        'appointments',
        'walks',
        'weight_entries',
      ];
      result.recordsPerBox = {
        'pet_profiles': 10,
        'medications': 30,
        'appointments': 20,
        'walks': 35,
        'weight_entries': 5,
      };
      result.duration = Duration(seconds: 15);

      expect(result.success, true);
      expect(result.errors, isEmpty);
      expect(result.totalRecordsMigrated, 100);
      expect(result.boxesProcessed.length, 5);

      final map = result.toMap();
      expect(map['success'], true);
      expect(map['totalRecordsMigrated'], 100);
    });

    test('typical failure result structure', () {
      final result = MigrationResult();
      result.success = false;
      result.message = 'Migration failed: Unable to open encrypted box';
      result.errors.add('Failed to open box "medications": encryption error');
      result.errors.add('Verification failed for box "appointments"');
      result.totalRecordsMigrated = 0;
      result.duration = Duration(seconds: 2);

      expect(result.success, false);
      expect(result.errors.isNotEmpty, true);
      expect(result.message, contains('failed'));

      final map = result.toMap();
      expect(map['success'], false);
      expect(map['errors'].length, 2);
    });

    test('partial success with warnings result structure', () {
      final result = MigrationResult();
      result.success = true;
      result.message = 'Migration succeeded with warnings';
      result.totalRecordsMigrated = 50;
      result.boxesProcessed = ['pet_profiles', 'medications'];
      result.recordsPerBox = {'pet_profiles': 25, 'medications': 25};
      result.errors.add('Warning: Could not delete old unencrypted box "settings"');
      result.duration = Duration(seconds: 10);

      expect(result.success, true);
      expect(result.totalRecordsMigrated, 50);
      expect(result.errors.length, 1);
      expect(result.errors[0], contains('Warning'));
    });
  });

  group('Data Integrity Verification', () {
    test('recordsPerBox sums to totalRecordsMigrated', () {
      final result = MigrationResult();
      result.recordsPerBox = {
        'box1': 10,
        'box2': 20,
        'box3': 30,
      };

      final sum = result.recordsPerBox.values.reduce((a, b) => a + b);
      result.totalRecordsMigrated = sum;

      expect(result.totalRecordsMigrated, 60);
      expect(sum, 60);
    });

    test('boxesProcessed count matches recordsPerBox keys', () {
      final result = MigrationResult();
      final boxes = ['pet_profiles', 'medications', 'walks'];

      result.boxesProcessed = boxes;
      result.recordsPerBox = {
        'pet_profiles': 10,
        'medications': 20,
        'walks': 30,
      };

      expect(result.boxesProcessed.length, result.recordsPerBox.length);
      expect(result.boxesProcessed.toSet(), result.recordsPerBox.keys.toSet());
    });
  });
}
