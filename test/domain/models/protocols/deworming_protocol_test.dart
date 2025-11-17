import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fur_friend_diary/src/domain/models/protocols/deworming_protocol.dart';
import 'package:fur_friend_diary/src/domain/models/protocols/vaccination_protocol.dart';

void main() {
  group('DewormingProtocol', () {
    late DewormingProtocol testProtocol;
    late List<DewormingSchedule> testSchedules;

    setUp(() {
      testSchedules = [
        DewormingSchedule(
          dewormingType: 'external',
          ageInWeeks: 8,
          notes: 'First external deworming for puppies',
          productName: 'Frontline Plus',
          recurring: RecurringSchedule(
            intervalMonths: 1,
            indefinitely: true,
          ),
        ),
        DewormingSchedule(
          dewormingType: 'internal',
          ageInWeeks: 4,
          notes: 'First internal deworming',
        ),
        DewormingSchedule(
          dewormingType: 'internal',
          ageInWeeks: 6,
          intervalDays: 14,
          notes: 'Second internal deworming',
          recurring: RecurringSchedule(
            intervalMonths: 3,
            indefinitely: true,
          ),
        ),
      ];

      testProtocol = DewormingProtocol(
        id: 'canine_standard_deworming',
        name: 'Canine Standard Deworming Protocol',
        species: 'dog',
        schedules: testSchedules,
        description: 'Standard deworming schedule for dogs in Romania/EU',
        isCustom: false,
        region: 'Romania/EU',
      );
    });

    test('should create DewormingProtocol with required fields', () {
      expect(testProtocol.id, 'canine_standard_deworming');
      expect(testProtocol.name, 'Canine Standard Deworming Protocol');
      expect(testProtocol.species, 'dog');
      expect(testProtocol.schedules.length, 3);
      expect(testProtocol.description, 'Standard deworming schedule for dogs in Romania/EU');
      expect(testProtocol.isCustom, false);
      expect(testProtocol.region, 'Romania/EU');
      expect(testProtocol.createdAt, isNotNull);
    });

    test('should create DewormingProtocol with default createdAt', () {
      final now = DateTime.now();
      final protocol = DewormingProtocol(
        id: 'test_id',
        name: 'Test Protocol',
        species: 'cat',
        schedules: [],
        description: 'Test description',
        isCustom: true,
      );

      expect(protocol.createdAt.difference(now).inSeconds, lessThan(1));
    });

    test('should copyWith correctly', () {
      final updated = testProtocol.copyWith(
        name: 'Updated Protocol',
        isCustom: true,
      );

      expect(updated.id, testProtocol.id); // unchanged
      expect(updated.name, 'Updated Protocol'); // changed
      expect(updated.species, testProtocol.species); // unchanged
      expect(updated.isCustom, true); // changed
      expect(updated.schedules, testProtocol.schedules); // unchanged
    });

    test('should convert to JSON correctly', () {
      final json = testProtocol.toJson();

      expect(json['id'], 'canine_standard_deworming');
      expect(json['name'], 'Canine Standard Deworming Protocol');
      expect(json['species'], 'dog');
      expect(json['description'], 'Standard deworming schedule for dogs in Romania/EU');
      expect(json['isCustom'], false);
      expect(json['region'], 'Romania/EU');
      expect(json['schedules'], isList);
      expect(json['schedules'].length, 3);
      expect(json['createdAt'], isNotNull);
    });

    test('should create from JSON correctly', () {
      final json = testProtocol.toJson();
      final fromJson = DewormingProtocol.fromJson(json);

      expect(fromJson.id, testProtocol.id);
      expect(fromJson.name, testProtocol.name);
      expect(fromJson.species, testProtocol.species);
      expect(fromJson.description, testProtocol.description);
      expect(fromJson.isCustom, testProtocol.isCustom);
      expect(fromJson.region, testProtocol.region);
      expect(fromJson.schedules.length, testProtocol.schedules.length);
      expect(fromJson.createdAt, testProtocol.createdAt);
    });

    test('should round-trip JSON serialization correctly', () {
      final json = testProtocol.toJson();
      final fromJson = DewormingProtocol.fromJson(json);
      final jsonAgain = fromJson.toJson();

      expect(jsonAgain, json);
    });

    test('should implement equality correctly', () {
      final protocol1 = DewormingProtocol(
        id: 'test_id',
        name: 'Test Protocol',
        species: 'dog',
        schedules: [],
        description: 'Test',
        isCustom: false,
      );

      final protocol2 = DewormingProtocol(
        id: 'test_id',
        name: 'Test Protocol',
        species: 'dog',
        schedules: [],
        description: 'Test',
        isCustom: false,
      );

      final protocol3 = DewormingProtocol(
        id: 'different_id',
        name: 'Test Protocol',
        species: 'dog',
        schedules: [],
        description: 'Test',
        isCustom: false,
      );

      expect(protocol1, equals(protocol2));
      expect(protocol1, isNot(equals(protocol3)));
    });

    test('should have consistent hashCode', () {
      final protocol1 = DewormingProtocol(
        id: 'test_id',
        name: 'Test Protocol',
        species: 'dog',
        schedules: [],
        description: 'Test',
        isCustom: false,
      );

      final protocol2 = DewormingProtocol(
        id: 'test_id',
        name: 'Test Protocol',
        species: 'dog',
        schedules: [],
        description: 'Test',
        isCustom: false,
      );

      expect(protocol1.hashCode, equals(protocol2.hashCode));
    });

    test('should have meaningful toString', () {
      final str = testProtocol.toString();

      expect(str, contains('DewormingProtocol'));
      expect(str, contains('canine_standard_deworming'));
      expect(str, contains('Canine Standard Deworming Protocol'));
      expect(str, contains('dog'));
      expect(str, contains('Romania/EU'));
    });

    test('should create protocol with empty schedules list', () {
      final protocol = DewormingProtocol(
        id: 'empty_protocol',
        name: 'Empty Protocol',
        species: 'cat',
        schedules: [],
        description: 'Protocol with no schedules yet',
        isCustom: true,
      );

      expect(protocol.schedules, isEmpty);
      expect(protocol.isCustom, true);
    });

    test('should handle JSON with missing optional fields', () {
      final json = {
        'id': 'minimal_protocol',
        'name': 'Minimal Protocol',
        'species': 'dog',
        'schedules': [],
        'description': 'Minimal protocol',
        'isCustom': true,
        'region': null,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': null,
      };

      final protocol = DewormingProtocol.fromJson(json);

      expect(protocol.id, 'minimal_protocol');
      expect(protocol.region, isNull);
      expect(protocol.updatedAt, isNull);
    });
  });

  group('DewormingSchedule', () {
    test('should create DewormingSchedule with external deworming type', () {
      final schedule = DewormingSchedule(
        dewormingType: 'external',
        ageInWeeks: 8,
        notes: 'First external deworming',
      );

      expect(schedule.dewormingType, 'external');
      expect(schedule.ageInWeeks, 8);
      expect(schedule.intervalDays, isNull);
      expect(schedule.notes, 'First external deworming');
      expect(schedule.recurring, isNull);
      expect(schedule.productName, isNull);
    });

    test('should create DewormingSchedule with internal deworming type', () {
      final schedule = DewormingSchedule(
        dewormingType: 'internal',
        ageInWeeks: 4,
        notes: 'First internal deworming for intestinal parasites',
      );

      expect(schedule.dewormingType, 'internal');
      expect(schedule.ageInWeeks, 4);
      expect(schedule.notes, 'First internal deworming for intestinal parasites');
    });

    test('should create DewormingSchedule with intervalDays and recurring', () {
      final schedule = DewormingSchedule(
        dewormingType: 'external',
        ageInWeeks: 12,
        intervalDays: 30,
        recurring: RecurringSchedule(
          intervalMonths: 1,
          indefinitely: true,
        ),
      );

      expect(schedule.intervalDays, 30);
      expect(schedule.recurring, isNotNull);
      expect(schedule.recurring!.intervalMonths, 1);
      expect(schedule.recurring!.indefinitely, true);
    });

    test('should create DewormingSchedule with productName', () {
      final schedule = DewormingSchedule(
        dewormingType: 'external',
        ageInWeeks: 8,
        productName: 'Frontline Plus',
        notes: 'Flea and tick prevention',
      );

      expect(schedule.productName, 'Frontline Plus');
      expect(schedule.dewormingType, 'external');
    });

    test('should throw AssertionError for invalid dewormingType', () {
      expect(
        () => DewormingSchedule(
          dewormingType: 'invalid',
          ageInWeeks: 8,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('should copyWith correctly', () {
      final schedule = DewormingSchedule(
        dewormingType: 'internal',
        ageInWeeks: 4,
      );

      final updated = schedule.copyWith(
        notes: 'Updated notes',
        productName: 'Drontal Plus',
      );

      expect(updated.dewormingType, schedule.dewormingType); // unchanged
      expect(updated.ageInWeeks, schedule.ageInWeeks); // unchanged
      expect(updated.notes, 'Updated notes'); // changed
      expect(updated.productName, 'Drontal Plus'); // changed
    });

    test('should convert to JSON correctly', () {
      final schedule = DewormingSchedule(
        dewormingType: 'external',
        ageInWeeks: 8,
        intervalDays: 30,
        notes: 'Monthly flea treatment',
        productName: 'Frontline Plus',
      );

      final json = schedule.toJson();

      expect(json['dewormingType'], 'external');
      expect(json['ageInWeeks'], 8);
      expect(json['intervalDays'], 30);
      expect(json['notes'], 'Monthly flea treatment');
      expect(json['productName'], 'Frontline Plus');
    });

    test('should create from JSON correctly', () {
      final json = {
        'dewormingType': 'internal',
        'ageInWeeks': 6,
        'intervalDays': null,
        'notes': 'Second internal deworming',
        'recurring': null,
        'productName': null,
      };

      final schedule = DewormingSchedule.fromJson(json);

      expect(schedule.dewormingType, 'internal');
      expect(schedule.ageInWeeks, 6);
      expect(schedule.intervalDays, isNull);
      expect(schedule.notes, 'Second internal deworming');
      expect(schedule.recurring, isNull);
      expect(schedule.productName, isNull);
    });

    test('should handle JSON with nested recurring schedule', () {
      final json = {
        'dewormingType': 'external',
        'ageInWeeks': 8,
        'intervalDays': null,
        'notes': 'Monthly treatment',
        'recurring': {
          'intervalMonths': 1,
          'indefinitely': true,
          'numberOfDoses': null,
        },
        'productName': 'Frontline',
      };

      final schedule = DewormingSchedule.fromJson(json);

      expect(schedule.recurring, isNotNull);
      expect(schedule.recurring!.intervalMonths, 1);
      expect(schedule.recurring!.indefinitely, true);
      expect(schedule.productName, 'Frontline');
    });

    test('should implement equality correctly', () {
      final schedule1 = DewormingSchedule(
        dewormingType: 'external',
        ageInWeeks: 8,
        notes: 'Test',
      );

      final schedule2 = DewormingSchedule(
        dewormingType: 'external',
        ageInWeeks: 8,
        notes: 'Test',
      );

      final schedule3 = DewormingSchedule(
        dewormingType: 'internal',
        ageInWeeks: 8,
        notes: 'Test',
      );

      expect(schedule1, equals(schedule2));
      expect(schedule1, isNot(equals(schedule3)));
    });

    test('should have consistent hashCode', () {
      final schedule1 = DewormingSchedule(
        dewormingType: 'external',
        ageInWeeks: 8,
        notes: 'Test',
        productName: 'Product A',
      );

      final schedule2 = DewormingSchedule(
        dewormingType: 'external',
        ageInWeeks: 8,
        notes: 'Test',
        productName: 'Product A',
      );

      expect(schedule1.hashCode, equals(schedule2.hashCode));
    });

    test('should have meaningful toString', () {
      final schedule = DewormingSchedule(
        dewormingType: 'external',
        ageInWeeks: 8,
        intervalDays: 30,
        productName: 'Frontline Plus',
      );

      final str = schedule.toString();

      expect(str, contains('DewormingSchedule'));
      expect(str, contains('external'));
      expect(str, contains('8'));
      expect(str, contains('30'));
      expect(str, contains('Frontline Plus'));
    });

    test('should handle quarterly internal deworming with recurring', () {
      final schedule = DewormingSchedule(
        dewormingType: 'internal',
        ageInWeeks: 12,
        notes: 'Quarterly intestinal parasite treatment',
        recurring: RecurringSchedule(
          intervalMonths: 3,
          indefinitely: true,
        ),
      );

      expect(schedule.dewormingType, 'internal');
      expect(schedule.recurring!.intervalMonths, 3);
      expect(schedule.recurring!.indefinitely, true);
    });

    test('should handle limited recurring schedule', () {
      final schedule = DewormingSchedule(
        dewormingType: 'external',
        ageInWeeks: 8,
        recurring: RecurringSchedule(
          intervalMonths: 1,
          indefinitely: false,
          numberOfDoses: 6,
        ),
      );

      expect(schedule.recurring!.indefinitely, false);
      expect(schedule.recurring!.numberOfDoses, 6);
    });
  });

  group('Hive Serialization', () {
    setUpAll(() async {
      // Initialize Hive for testing with temp directory
      Hive.init('test_hive_db');

      // Register adapters for RecurringSchedule (24), DewormingProtocol (25), DewormingSchedule (26)
      if (!Hive.isAdapterRegistered(24)) {
        Hive.registerAdapter(RecurringScheduleAdapter());
      }
      if (!Hive.isAdapterRegistered(25)) {
        Hive.registerAdapter(DewormingProtocolAdapter());
      }
      if (!Hive.isAdapterRegistered(26)) {
        Hive.registerAdapter(DewormingScheduleAdapter());
      }
    });

    tearDownAll(() async {
      await Hive.close();
    });

    test('should serialize and deserialize DewormingProtocol with Hive', () async {
      final testBox = await Hive.openBox<DewormingProtocol>('test_deworming_protocols');

      try {
        final protocol = DewormingProtocol(
          id: 'test_protocol',
          name: 'Test Deworming Protocol',
          species: 'dog',
          schedules: [
            DewormingSchedule(
              dewormingType: 'external',
              ageInWeeks: 8,
              notes: 'First external treatment',
            ),
            DewormingSchedule(
              dewormingType: 'internal',
              ageInWeeks: 4,
              notes: 'First internal treatment',
            ),
          ],
          description: 'Test description',
          isCustom: true,
        );

        // Save to Hive
        await testBox.put('test_key', protocol);

        // Retrieve from Hive
        final retrieved = testBox.get('test_key');

        expect(retrieved, isNotNull);
        expect(retrieved!.id, protocol.id);
        expect(retrieved.name, protocol.name);
        expect(retrieved.species, protocol.species);
        expect(retrieved.schedules.length, protocol.schedules.length);
        expect(retrieved.schedules[0].dewormingType, protocol.schedules[0].dewormingType);
        expect(retrieved.schedules[1].dewormingType, protocol.schedules[1].dewormingType);
        expect(retrieved.description, protocol.description);
        expect(retrieved.isCustom, protocol.isCustom);
      } finally {
        await testBox.clear();
        await testBox.close();
        await Hive.deleteBoxFromDisk('test_deworming_protocols');
      }
    });

    test('should handle complex protocol with recurring schedules and product names in Hive', () async {
      final testBox = await Hive.openBox<DewormingProtocol>('test_complex_deworming');

      try {
        final protocol = DewormingProtocol(
          id: 'complex_protocol',
          name: 'Complex Deworming Protocol',
          species: 'cat',
          schedules: [
            DewormingSchedule(
              dewormingType: 'external',
              ageInWeeks: 8,
              productName: 'Frontline Plus',
              notes: 'Monthly flea treatment',
              recurring: RecurringSchedule(
                intervalMonths: 1,
                indefinitely: true,
              ),
            ),
            DewormingSchedule(
              dewormingType: 'internal',
              ageInWeeks: 4,
              productName: 'Drontal',
              notes: 'First internal deworming',
            ),
            DewormingSchedule(
              dewormingType: 'internal',
              ageInWeeks: 6,
              intervalDays: 14,
              productName: 'Drontal',
              notes: 'Second internal deworming',
              recurring: RecurringSchedule(
                intervalMonths: 3,
                indefinitely: true,
              ),
            ),
          ],
          description: 'Complex feline deworming protocol with recurring schedules',
          isCustom: false,
          region: 'Romania/EU',
        );

        await testBox.put('complex_key', protocol);
        final retrieved = testBox.get('complex_key');

        expect(retrieved, isNotNull);
        expect(retrieved!.schedules.length, 3);
        expect(retrieved.schedules[0].recurring, isNotNull);
        expect(retrieved.schedules[0].recurring!.intervalMonths, 1);
        expect(retrieved.schedules[0].recurring!.indefinitely, true);
        expect(retrieved.schedules[0].productName, 'Frontline Plus');
        expect(retrieved.schedules[2].intervalDays, 14);
        expect(retrieved.schedules[2].recurring!.intervalMonths, 3);
        expect(retrieved.region, 'Romania/EU');
      } finally {
        await testBox.clear();
        await testBox.close();
        await Hive.deleteBoxFromDisk('test_complex_deworming');
      }
    });
  });
}
