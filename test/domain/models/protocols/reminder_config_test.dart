import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fur_friend_diary/src/domain/models/protocols/reminder_config.dart';

void main() {
  group('ReminderConfig', () {
    late ReminderConfig testConfig;

    setUp(() {
      testConfig = ReminderConfig(
        id: 'config_001',
        petId: 'pet_luna_123',
        eventType: 'vaccination',
        reminderDays: [1, 7],
        isEnabled: true,
        createdAt: DateTime(2025, 1, 1, 12, 0),
      );
    });

    test('should create ReminderConfig with all required fields', () {
      expect(testConfig.id, 'config_001');
      expect(testConfig.petId, 'pet_luna_123');
      expect(testConfig.eventType, 'vaccination');
      expect(testConfig.reminderDays, [1, 7]);
      expect(testConfig.isEnabled, true);
      expect(testConfig.customTitle, isNull);
      expect(testConfig.customMessage, isNull);
      expect(testConfig.createdAt, DateTime(2025, 1, 1, 12, 0));
      expect(testConfig.updatedAt, isNull);
    });

    test('should create ReminderConfig with optional fields', () {
      final config = ReminderConfig(
        id: 'config_002',
        petId: 'pet_max_456',
        eventType: 'custom',
        reminderDays: [1, 7, 14],
        isEnabled: false,
        customTitle: 'Nail Trimming',
        customMessage: 'Time to trim those nails!',
        createdAt: DateTime(2025, 1, 15, 10, 30),
        updatedAt: DateTime(2025, 1, 16, 14, 0),
      );

      expect(config.id, 'config_002');
      expect(config.petId, 'pet_max_456');
      expect(config.eventType, 'custom');
      expect(config.reminderDays, [1, 7, 14]);
      expect(config.isEnabled, false);
      expect(config.customTitle, 'Nail Trimming');
      expect(config.customMessage, 'Time to trim those nails!');
      expect(config.createdAt, DateTime(2025, 1, 15, 10, 30));
      expect(config.updatedAt, DateTime(2025, 1, 16, 14, 0));
    });

    test('should create ReminderConfig with default isEnabled=true', () {
      final config = ReminderConfig(
        id: 'config_003',
        petId: 'pet_bella_789',
        eventType: 'appointment',
        reminderDays: [1],
      );

      expect(config.isEnabled, true);
    });

    test('should create ReminderConfig with default createdAt=now', () {
      final now = DateTime.now();
      final config = ReminderConfig(
        id: 'config_004',
        petId: 'pet_rocky_101',
        eventType: 'medication',
        reminderDays: [3, 7],
      );

      expect(config.createdAt.difference(now).inSeconds, lessThan(1));
    });

    test('should create ReminderConfig with eventType=vaccination', () {
      final config = ReminderConfig(
        id: 'vac_001',
        petId: 'pet_123',
        eventType: 'vaccination',
        reminderDays: [1, 7],
      );

      expect(config.eventType, 'vaccination');
    });

    test('should create ReminderConfig with eventType=deworming', () {
      final config = ReminderConfig(
        id: 'dew_001',
        petId: 'pet_123',
        eventType: 'deworming',
        reminderDays: [1, 7, 30],
      );

      expect(config.eventType, 'deworming');
    });

    test('should create ReminderConfig with eventType=appointment', () {
      final config = ReminderConfig(
        id: 'apt_001',
        petId: 'pet_123',
        eventType: 'appointment',
        reminderDays: [1, 7],
      );

      expect(config.eventType, 'appointment');
    });

    test('should create ReminderConfig with eventType=medication', () {
      final config = ReminderConfig(
        id: 'med_001',
        petId: 'pet_123',
        eventType: 'medication',
        reminderDays: [3, 7],
      );

      expect(config.eventType, 'medication');
    });

    test('should create ReminderConfig with eventType=custom and customTitle', () {
      final config = ReminderConfig(
        id: 'cust_001',
        petId: 'pet_123',
        eventType: 'custom',
        reminderDays: [7],
        customTitle: 'Flea Check',
      );

      expect(config.eventType, 'custom');
      expect(config.customTitle, 'Flea Check');
    });

    test('should create ReminderConfig with single reminderDay', () {
      final config = ReminderConfig(
        id: 'rem_001',
        petId: 'pet_123',
        eventType: 'vaccination',
        reminderDays: [1],
      );

      expect(config.reminderDays, [1]);
      expect(config.reminderDays.length, 1);
    });

    test('should create ReminderConfig with multiple reminderDays', () {
      final config = ReminderConfig(
        id: 'rem_002',
        petId: 'pet_123',
        eventType: 'vaccination',
        reminderDays: [1, 7, 14, 30],
      );

      expect(config.reminderDays, [1, 7, 14, 30]);
      expect(config.reminderDays.length, 4);
    });

    test('should create ReminderConfig with reminderDays including zero', () {
      final config = ReminderConfig(
        id: 'rem_003',
        petId: 'pet_123',
        eventType: 'vaccination',
        reminderDays: [0, 1, 7],
      );

      expect(config.reminderDays, [0, 1, 7]);
    });

    test('should create custom event with valid customTitle', () {
      final config = ReminderConfig(
        id: 'custom_valid',
        petId: 'pet_123',
        eventType: 'custom',
        reminderDays: [7],
        customTitle: 'Grooming Appointment',
      );

      expect(config.eventType, 'custom');
      expect(config.customTitle, 'Grooming Appointment');
    });

    test('should create non-custom event without customTitle', () {
      final config = ReminderConfig(
        id: 'non_custom',
        petId: 'pet_123',
        eventType: 'vaccination',
        reminderDays: [1, 7],
      );

      expect(config.eventType, 'vaccination');
      expect(config.customTitle, isNull);
    });

    test('should copyWith correctly update fields', () {
      final updated = testConfig.copyWith(
        eventType: 'medication',
        isEnabled: false,
        customTitle: 'Updated Title',
      );

      expect(updated.id, testConfig.id); // unchanged
      expect(updated.petId, testConfig.petId); // unchanged
      expect(updated.eventType, 'medication'); // changed
      expect(updated.reminderDays, testConfig.reminderDays); // unchanged
      expect(updated.isEnabled, false); // changed
      expect(updated.customTitle, 'Updated Title'); // changed
    });

    test('should copyWith preserve unchanged fields', () {
      final updated = testConfig.copyWith(
        isEnabled: false,
      );

      expect(updated.id, testConfig.id);
      expect(updated.petId, testConfig.petId);
      expect(updated.eventType, testConfig.eventType);
      expect(updated.reminderDays, testConfig.reminderDays);
      expect(updated.isEnabled, false); // only this changed
      expect(updated.customTitle, testConfig.customTitle);
      expect(updated.customMessage, testConfig.customMessage);
      expect(updated.createdAt, testConfig.createdAt);
    });

    test('should copyWith update reminderDays list', () {
      final updated = testConfig.copyWith(
        reminderDays: [1, 7, 14, 30],
      );

      expect(updated.reminderDays, [1, 7, 14, 30]);
      expect(testConfig.reminderDays, [1, 7]); // original unchanged
    });

    test('should convert to JSON with all fields', () {
      final config = ReminderConfig(
        id: 'json_001',
        petId: 'pet_json_123',
        eventType: 'custom',
        reminderDays: [1, 7, 14],
        isEnabled: false,
        customTitle: 'Custom Event',
        customMessage: 'Custom message here',
        createdAt: DateTime(2025, 1, 10, 9, 0),
        updatedAt: DateTime(2025, 1, 11, 10, 0),
      );

      final json = config.toJson();

      expect(json['id'], 'json_001');
      expect(json['petId'], 'pet_json_123');
      expect(json['eventType'], 'custom');
      expect(json['reminderDays'], [1, 7, 14]);
      expect(json['isEnabled'], false);
      expect(json['customTitle'], 'Custom Event');
      expect(json['customMessage'], 'Custom message here');
      expect(json['createdAt'], '2025-01-10T09:00:00.000');
      expect(json['updatedAt'], '2025-01-11T10:00:00.000');
    });

    test('should convert to JSON with null optional fields', () {
      final json = testConfig.toJson();

      expect(json['id'], 'config_001');
      expect(json['petId'], 'pet_luna_123');
      expect(json['eventType'], 'vaccination');
      expect(json['reminderDays'], [1, 7]);
      expect(json['isEnabled'], true);
      expect(json['customTitle'], isNull);
      expect(json['customMessage'], isNull);
      expect(json['createdAt'], '2025-01-01T12:00:00.000');
      expect(json['updatedAt'], isNull);
    });

    test('should serialize List<int> reminderDays in JSON', () {
      final config = ReminderConfig(
        id: 'list_test',
        petId: 'pet_123',
        eventType: 'vaccination',
        reminderDays: [1, 7, 14, 30],
      );

      final json = config.toJson();

      expect(json['reminderDays'], isList);
      expect(json['reminderDays'], [1, 7, 14, 30]);
      expect(json['reminderDays'].length, 4);
    });

    test('should create from JSON with all fields', () {
      final json = {
        'id': 'from_json_001',
        'petId': 'pet_from_json_123',
        'eventType': 'medication',
        'reminderDays': [3, 7],
        'isEnabled': false,
        'customTitle': 'Med Reminder',
        'customMessage': 'Take medication',
        'createdAt': '2025-01-20T08:30:00.000',
        'updatedAt': '2025-01-21T09:00:00.000',
      };

      final config = ReminderConfig.fromJson(json);

      expect(config.id, 'from_json_001');
      expect(config.petId, 'pet_from_json_123');
      expect(config.eventType, 'medication');
      expect(config.reminderDays, [3, 7]);
      expect(config.isEnabled, false);
      expect(config.customTitle, 'Med Reminder');
      expect(config.customMessage, 'Take medication');
      expect(config.createdAt, DateTime(2025, 1, 20, 8, 30));
      expect(config.updatedAt, DateTime(2025, 1, 21, 9, 0));
    });

    test('should create from JSON with missing optional fields', () {
      final json = {
        'id': 'min_json_001',
        'petId': 'pet_min_123',
        'eventType': 'vaccination',
        'reminderDays': [1, 7],
      };

      final config = ReminderConfig.fromJson(json);

      expect(config.id, 'min_json_001');
      expect(config.petId, 'pet_min_123');
      expect(config.eventType, 'vaccination');
      expect(config.reminderDays, [1, 7]);
      expect(config.isEnabled, true); // default
      expect(config.customTitle, isNull);
      expect(config.customMessage, isNull);
      expect(config.createdAt, isNotNull); // uses DateTime.now()
      expect(config.updatedAt, isNull);
    });

    test('should round-trip JSON serialization correctly', () {
      final json = testConfig.toJson();
      final fromJson = ReminderConfig.fromJson(json);
      final jsonAgain = fromJson.toJson();

      expect(jsonAgain, json);
    });

    test('should implement equality for same data', () {
      final config1 = ReminderConfig(
        id: 'eq_001',
        petId: 'pet_eq_123',
        eventType: 'vaccination',
        reminderDays: [1, 7],
        isEnabled: true,
        createdAt: DateTime(2025, 1, 1),
      );

      final config2 = ReminderConfig(
        id: 'eq_001',
        petId: 'pet_eq_123',
        eventType: 'vaccination',
        reminderDays: [1, 7],
        isEnabled: true,
        createdAt: DateTime(2025, 1, 1),
      );

      expect(config1, equals(config2));
    });

    test('should implement inequality for different data', () {
      final config1 = ReminderConfig(
        id: 'eq_001',
        petId: 'pet_eq_123',
        eventType: 'vaccination',
        reminderDays: [1, 7],
      );

      final config2 = ReminderConfig(
        id: 'eq_002', // different id
        petId: 'pet_eq_123',
        eventType: 'vaccination',
        reminderDays: [1, 7],
      );

      expect(config1, isNot(equals(config2)));
    });

    test('should implement equality with List<int> field comparison', () {
      final config1 = ReminderConfig(
        id: 'list_eq_001',
        petId: 'pet_123',
        eventType: 'vaccination',
        reminderDays: [1, 7, 14],
      );

      final config2 = ReminderConfig(
        id: 'list_eq_001',
        petId: 'pet_123',
        eventType: 'vaccination',
        reminderDays: [1, 7, 14],
      );

      final config3 = ReminderConfig(
        id: 'list_eq_001',
        petId: 'pet_123',
        eventType: 'vaccination',
        reminderDays: [1, 7, 30], // different list
      );

      expect(config1, equals(config2));
      expect(config1, isNot(equals(config3)));
    });

    test('should have consistent hashCode for equal objects', () {
      final config1 = ReminderConfig(
        id: 'hash_001',
        petId: 'pet_hash_123',
        eventType: 'vaccination',
        reminderDays: [1, 7],
        isEnabled: true,
      );

      final config2 = ReminderConfig(
        id: 'hash_001',
        petId: 'pet_hash_123',
        eventType: 'vaccination',
        reminderDays: [1, 7],
        isEnabled: true,
      );

      expect(config1.hashCode, equals(config2.hashCode));
    });

    test('should have meaningful toString', () {
      final str = testConfig.toString();

      expect(str, contains('ReminderConfig'));
      expect(str, contains('config_001'));
      expect(str, contains('pet_luna_123'));
      expect(str, contains('vaccination'));
      expect(str, contains('[1, 7]'));
      expect(str, contains('true'));
    });
  });

  group('ReminderConfig Assertions', () {
    test('should throw AssertionError for invalid eventType', () {
      expect(
        () => ReminderConfig(
          id: 'invalid_001',
          petId: 'pet_123',
          eventType: 'invalid_type', // invalid
          reminderDays: [1, 7],
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('should throw AssertionError for empty reminderDays list', () {
      expect(
        () => ReminderConfig(
          id: 'empty_001',
          petId: 'pet_123',
          eventType: 'vaccination',
          reminderDays: [], // empty list
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('should throw AssertionError when custom eventType without customTitle', () {
      expect(
        () => ReminderConfig(
          id: 'custom_no_title',
          petId: 'pet_123',
          eventType: 'custom',
          reminderDays: [7],
          // customTitle is null
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('should throw AssertionError when custom eventType with empty customTitle', () {
      expect(
        () => ReminderConfig(
          id: 'custom_empty_title',
          petId: 'pet_123',
          eventType: 'custom',
          reminderDays: [7],
          customTitle: '', // empty string
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('Helper Methods', () {
    group('reminderDescription getter', () {
      test('should describe single day reminder', () {
        final config = ReminderConfig(
          id: 'desc_001',
          petId: 'pet_123',
          eventType: 'vaccination',
          reminderDays: [1],
        );

        expect(config.reminderDescription, '1 day before');
      });

      test('should describe week reminder', () {
        final config = ReminderConfig(
          id: 'desc_002',
          petId: 'pet_123',
          eventType: 'vaccination',
          reminderDays: [7],
        );

        expect(config.reminderDescription, '1 week before');
      });

      test('should describe two weeks reminder', () {
        final config = ReminderConfig(
          id: 'desc_003',
          petId: 'pet_123',
          eventType: 'vaccination',
          reminderDays: [14],
        );

        expect(config.reminderDescription, '2 weeks before');
      });

      test('should describe month reminder', () {
        final config = ReminderConfig(
          id: 'desc_004',
          petId: 'pet_123',
          eventType: 'vaccination',
          reminderDays: [30],
        );

        expect(config.reminderDescription, '1 month before');
      });

      test('should describe on the day reminder', () {
        final config = ReminderConfig(
          id: 'desc_005',
          petId: 'pet_123',
          eventType: 'vaccination',
          reminderDays: [0],
        );

        expect(config.reminderDescription, 'on the day');
      });

      test('should describe two reminders with "and"', () {
        final config = ReminderConfig(
          id: 'desc_006',
          petId: 'pet_123',
          eventType: 'vaccination',
          reminderDays: [1, 7],
        );

        expect(config.reminderDescription, '1 day before and 1 week before');
      });

      test('should describe three+ reminders with commas and "and"', () {
        final config = ReminderConfig(
          id: 'desc_007',
          petId: 'pet_123',
          eventType: 'vaccination',
          reminderDays: [1, 7, 14],
        );

        expect(config.reminderDescription, '1 day before, 1 week before, and 2 weeks before');
      });

      test('should describe arbitrary days reminder', () {
        final config = ReminderConfig(
          id: 'desc_008',
          petId: 'pet_123',
          eventType: 'vaccination',
          reminderDays: [5],
        );

        expect(config.reminderDescription, '5 days before');
      });

      test('should describe complex reminder schedule', () {
        final config = ReminderConfig(
          id: 'desc_009',
          petId: 'pet_123',
          eventType: 'deworming',
          reminderDays: [3, 7, 30],
        );

        expect(config.reminderDescription, '3 days before, 1 week before, and 1 month before');
      });

      test('should sort reminderDays in description', () {
        final config = ReminderConfig(
          id: 'desc_010',
          petId: 'pet_123',
          eventType: 'vaccination',
          reminderDays: [14, 1, 7], // unsorted
        );

        expect(config.reminderDescription, '1 day before, 1 week before, and 2 weeks before');
      });

      test('should describe four reminders', () {
        final config = ReminderConfig(
          id: 'desc_011',
          petId: 'pet_123',
          eventType: 'vaccination',
          reminderDays: [1, 7, 14, 30],
        );

        expect(config.reminderDescription, '1 day before, 1 week before, 2 weeks before, and 1 month before');
      });
    });

    group('earliestReminderDays getter', () {
      test('should return single reminder day', () {
        final config = ReminderConfig(
          id: 'earliest_001',
          petId: 'pet_123',
          eventType: 'vaccination',
          reminderDays: [7],
        );

        expect(config.earliestReminderDays, 7);
      });

      test('should return maximum of multiple reminder days', () {
        final config = ReminderConfig(
          id: 'earliest_002',
          petId: 'pet_123',
          eventType: 'vaccination',
          reminderDays: [1, 7, 14],
        );

        expect(config.earliestReminderDays, 14);
      });

      test('should find max in unsorted list', () {
        final config = ReminderConfig(
          id: 'earliest_003',
          petId: 'pet_123',
          eventType: 'vaccination',
          reminderDays: [14, 1, 7], // unsorted
        );

        expect(config.earliestReminderDays, 14);
      });

      test('should return max when zero is included', () {
        final config = ReminderConfig(
          id: 'earliest_004',
          petId: 'pet_123',
          eventType: 'vaccination',
          reminderDays: [0, 7],
        );

        expect(config.earliestReminderDays, 7);
      });

      test('should return zero when only zero in list', () {
        final config = ReminderConfig(
          id: 'earliest_005',
          petId: 'pet_123',
          eventType: 'vaccination',
          reminderDays: [0],
        );

        expect(config.earliestReminderDays, 0);
      });

      test('should return max for complex schedule', () {
        final config = ReminderConfig(
          id: 'earliest_006',
          petId: 'pet_123',
          eventType: 'deworming',
          reminderDays: [1, 7, 14, 30],
        );

        expect(config.earliestReminderDays, 30);
      });
    });

    group('isCustom getter', () {
      test('should return true when eventType is custom', () {
        final config = ReminderConfig(
          id: 'custom_001',
          petId: 'pet_123',
          eventType: 'custom',
          reminderDays: [7],
          customTitle: 'Custom Event',
        );

        expect(config.isCustom, true);
      });

      test('should return false when eventType is vaccination', () {
        final config = ReminderConfig(
          id: 'vac_001',
          petId: 'pet_123',
          eventType: 'vaccination',
          reminderDays: [1, 7],
        );

        expect(config.isCustom, false);
      });

      test('should return false when eventType is deworming', () {
        final config = ReminderConfig(
          id: 'dew_001',
          petId: 'pet_123',
          eventType: 'deworming',
          reminderDays: [1, 7],
        );

        expect(config.isCustom, false);
      });

      test('should return false when eventType is appointment', () {
        final config = ReminderConfig(
          id: 'apt_001',
          petId: 'pet_123',
          eventType: 'appointment',
          reminderDays: [1, 7],
        );

        expect(config.isCustom, false);
      });

      test('should return false when eventType is medication', () {
        final config = ReminderConfig(
          id: 'med_001',
          petId: 'pet_123',
          eventType: 'medication',
          reminderDays: [3, 7],
        );

        expect(config.isCustom, false);
      });
    });
  });

  group('Hive Serialization', () {
    setUpAll(() async {
      // Initialize Hive for testing with temp directory
      Hive.init('test_hive_db');

      // Register adapter
      if (!Hive.isAdapterRegistered(29)) {
        Hive.registerAdapter(ReminderConfigAdapter());
      }
    });

    tearDownAll(() async {
      await Hive.close();
    });

    test('should serialize and deserialize ReminderConfig with basic fields', () async {
      final testBox = await Hive.openBox<ReminderConfig>('test_reminder_configs');

      try {
        final config = ReminderConfig(
          id: 'hive_basic_001',
          petId: 'pet_luna_123',
          eventType: 'vaccination',
          reminderDays: [1, 7],
          isEnabled: true,
          createdAt: DateTime(2025, 1, 1, 12, 0),
        );

        // Save to Hive
        await testBox.put('test_key', config);

        // Retrieve from Hive
        final retrieved = testBox.get('test_key');

        expect(retrieved, isNotNull);
        expect(retrieved!.id, config.id);
        expect(retrieved.petId, config.petId);
        expect(retrieved.eventType, config.eventType);
        expect(retrieved.reminderDays, config.reminderDays);
        expect(retrieved.isEnabled, config.isEnabled);
        expect(retrieved.customTitle, config.customTitle);
        expect(retrieved.customMessage, config.customMessage);
        expect(retrieved.createdAt, config.createdAt);
        expect(retrieved.updatedAt, config.updatedAt);
      } finally {
        await testBox.clear();
        await testBox.close();
        await Hive.deleteBoxFromDisk('test_reminder_configs');
      }
    });

    test('should handle complex ReminderConfig with all fields in Hive', () async {
      final testBox = await Hive.openBox<ReminderConfig>('test_complex_reminder_configs');

      try {
        final config = ReminderConfig(
          id: 'hive_complex_001',
          petId: 'pet_max_456',
          eventType: 'custom',
          reminderDays: [1, 7, 14, 30],
          isEnabled: false,
          customTitle: 'Nail Trimming',
          customMessage: 'Time to trim those nails!',
          createdAt: DateTime(2025, 1, 15, 10, 30),
          updatedAt: DateTime(2025, 1, 16, 14, 0),
        );

        await testBox.put('complex_key', config);
        final retrieved = testBox.get('complex_key');

        expect(retrieved, isNotNull);
        expect(retrieved!.id, 'hive_complex_001');
        expect(retrieved.petId, 'pet_max_456');
        expect(retrieved.eventType, 'custom');
        expect(retrieved.reminderDays, [1, 7, 14, 30]);
        expect(retrieved.reminderDays.length, 4);
        expect(retrieved.isEnabled, false);
        expect(retrieved.customTitle, 'Nail Trimming');
        expect(retrieved.customMessage, 'Time to trim those nails!');
        expect(retrieved.createdAt, DateTime(2025, 1, 15, 10, 30));
        expect(retrieved.updatedAt, DateTime(2025, 1, 16, 14, 0));

        // Verify helper methods work after round-trip
        expect(retrieved.isCustom, true);
        expect(retrieved.earliestReminderDays, 30);
        expect(retrieved.reminderDescription, contains('1 day before'));
      } finally {
        await testBox.clear();
        await testBox.close();
        await Hive.deleteBoxFromDisk('test_complex_reminder_configs');
      }
    });

    test('should persist all event types correctly in Hive', () async {
      final testBox = await Hive.openBox<ReminderConfig>('test_event_types');

      try {
        final eventTypes = ['vaccination', 'deworming', 'appointment', 'medication', 'custom'];

        for (int i = 0; i < eventTypes.length; i++) {
          final eventType = eventTypes[i];
          final config = ReminderConfig(
            id: 'event_$i',
            petId: 'pet_$i',
            eventType: eventType,
            reminderDays: [1, 7],
            customTitle: eventType == 'custom' ? 'Custom Title' : null,
          );

          await testBox.put('key_$i', config);
          final retrieved = testBox.get('key_$i');

          expect(retrieved, isNotNull);
          expect(retrieved!.eventType, eventType);
          expect(retrieved.isCustom, eventType == 'custom');
        }
      } finally {
        await testBox.clear();
        await testBox.close();
        await Hive.deleteBoxFromDisk('test_event_types');
      }
    });
  });
}
