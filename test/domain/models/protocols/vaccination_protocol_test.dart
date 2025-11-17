import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fur_friend_diary/src/domain/models/protocols/vaccination_protocol.dart';

void main() {
  group('VaccinationProtocol', () {
    late VaccinationProtocol testProtocol;
    late List<VaccinationStep> testSteps;

    setUp(() {
      testSteps = [
        VaccinationStep(
          vaccineName: 'DHPPiL',
          ageInWeeks: 6,
          notes: 'First dose',
          isRequired: true,
        ),
        VaccinationStep(
          vaccineName: 'DHPPiL',
          ageInWeeks: 9,
          intervalDays: 21,
          notes: 'Second dose',
          isRequired: true,
        ),
        VaccinationStep(
          vaccineName: 'Rabies',
          ageInWeeks: 16,
          notes: 'First rabies vaccine',
          isRequired: true,
          recurring: RecurringSchedule(
            intervalMonths: 12,
            indefinitely: true,
          ),
        ),
      ];

      testProtocol = VaccinationProtocol(
        id: 'canine_core_standard',
        name: 'Canine Core Vaccination Protocol',
        species: 'dog',
        steps: testSteps,
        description: 'Standard core vaccine schedule for dogs',
        isCustom: false,
        region: 'Romania/EU',
      );
    });

    test('should create VaccinationProtocol with required fields', () {
      expect(testProtocol.id, 'canine_core_standard');
      expect(testProtocol.name, 'Canine Core Vaccination Protocol');
      expect(testProtocol.species, 'dog');
      expect(testProtocol.steps.length, 3);
      expect(testProtocol.description, 'Standard core vaccine schedule for dogs');
      expect(testProtocol.isCustom, false);
      expect(testProtocol.region, 'Romania/EU');
      expect(testProtocol.createdAt, isNotNull);
    });

    test('should create VaccinationProtocol with default createdAt', () {
      final now = DateTime.now();
      final protocol = VaccinationProtocol(
        id: 'test_id',
        name: 'Test Protocol',
        species: 'cat',
        steps: [],
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
      expect(updated.steps, testProtocol.steps); // unchanged
    });

    test('should convert to JSON correctly', () {
      final json = testProtocol.toJson();

      expect(json['id'], 'canine_core_standard');
      expect(json['name'], 'Canine Core Vaccination Protocol');
      expect(json['species'], 'dog');
      expect(json['description'], 'Standard core vaccine schedule for dogs');
      expect(json['isCustom'], false);
      expect(json['region'], 'Romania/EU');
      expect(json['steps'], isList);
      expect(json['steps'].length, 3);
      expect(json['createdAt'], isNotNull);
    });

    test('should create from JSON correctly', () {
      final json = testProtocol.toJson();
      final fromJson = VaccinationProtocol.fromJson(json);

      expect(fromJson.id, testProtocol.id);
      expect(fromJson.name, testProtocol.name);
      expect(fromJson.species, testProtocol.species);
      expect(fromJson.description, testProtocol.description);
      expect(fromJson.isCustom, testProtocol.isCustom);
      expect(fromJson.region, testProtocol.region);
      expect(fromJson.steps.length, testProtocol.steps.length);
      expect(fromJson.createdAt, testProtocol.createdAt);
    });

    test('should round-trip JSON serialization correctly', () {
      final json = testProtocol.toJson();
      final fromJson = VaccinationProtocol.fromJson(json);
      final jsonAgain = fromJson.toJson();

      expect(jsonAgain, json);
    });

    test('should implement equality correctly', () {
      final protocol1 = VaccinationProtocol(
        id: 'test_id',
        name: 'Test Protocol',
        species: 'dog',
        steps: [],
        description: 'Test',
        isCustom: false,
      );

      final protocol2 = VaccinationProtocol(
        id: 'test_id',
        name: 'Test Protocol',
        species: 'dog',
        steps: [],
        description: 'Test',
        isCustom: false,
      );

      final protocol3 = VaccinationProtocol(
        id: 'different_id',
        name: 'Test Protocol',
        species: 'dog',
        steps: [],
        description: 'Test',
        isCustom: false,
      );

      expect(protocol1, equals(protocol2));
      expect(protocol1, isNot(equals(protocol3)));
    });

    test('should have consistent hashCode', () {
      final protocol1 = VaccinationProtocol(
        id: 'test_id',
        name: 'Test Protocol',
        species: 'dog',
        steps: [],
        description: 'Test',
        isCustom: false,
      );

      final protocol2 = VaccinationProtocol(
        id: 'test_id',
        name: 'Test Protocol',
        species: 'dog',
        steps: [],
        description: 'Test',
        isCustom: false,
      );

      expect(protocol1.hashCode, equals(protocol2.hashCode));
    });

    test('should have meaningful toString', () {
      final str = testProtocol.toString();

      expect(str, contains('VaccinationProtocol'));
      expect(str, contains('canine_core_standard'));
      expect(str, contains('Canine Core Vaccination Protocol'));
      expect(str, contains('dog'));
      expect(str, contains('Romania/EU'));
    });
  });

  group('VaccinationStep', () {
    test('should create VaccinationStep with required fields', () {
      final step = VaccinationStep(
        vaccineName: 'DHPPiL',
        ageInWeeks: 6,
        notes: 'First dose',
        isRequired: true,
      );

      expect(step.vaccineName, 'DHPPiL');
      expect(step.ageInWeeks, 6);
      expect(step.intervalDays, isNull);
      expect(step.notes, 'First dose');
      expect(step.isRequired, true);
      expect(step.recurring, isNull);
    });

    test('should create VaccinationStep with intervalDays', () {
      final step = VaccinationStep(
        vaccineName: 'DHPPiL',
        ageInWeeks: 9,
        intervalDays: 21,
        notes: 'Second dose',
        isRequired: true,
      );

      expect(step.vaccineName, 'DHPPiL');
      expect(step.ageInWeeks, 9);
      expect(step.intervalDays, 21);
    });

    test('should create VaccinationStep with recurring schedule', () {
      final step = VaccinationStep(
        vaccineName: 'Rabies',
        ageInWeeks: 52,
        isRequired: true,
        recurring: RecurringSchedule(
          intervalMonths: 12,
          indefinitely: true,
        ),
      );

      expect(step.recurring, isNotNull);
      expect(step.recurring!.intervalMonths, 12);
      expect(step.recurring!.indefinitely, true);
    });

    test('should default isRequired to true', () {
      final step = VaccinationStep(
        vaccineName: 'Optional Vaccine',
        ageInWeeks: 10,
      );

      expect(step.isRequired, true);
    });

    test('should copyWith correctly', () {
      final step = VaccinationStep(
        vaccineName: 'DHPPiL',
        ageInWeeks: 6,
        isRequired: true,
      );

      final updated = step.copyWith(
        notes: 'Updated notes',
        intervalDays: 21,
      );

      expect(updated.vaccineName, step.vaccineName); // unchanged
      expect(updated.ageInWeeks, step.ageInWeeks); // unchanged
      expect(updated.notes, 'Updated notes'); // changed
      expect(updated.intervalDays, 21); // changed
    });

    test('should convert to JSON correctly', () {
      final step = VaccinationStep(
        vaccineName: 'DHPPiL',
        ageInWeeks: 6,
        intervalDays: 21,
        notes: 'First dose',
        isRequired: true,
      );

      final json = step.toJson();

      expect(json['vaccineName'], 'DHPPiL');
      expect(json['ageInWeeks'], 6);
      expect(json['intervalDays'], 21);
      expect(json['notes'], 'First dose');
      expect(json['isRequired'], true);
    });

    test('should create from JSON correctly', () {
      final json = {
        'vaccineName': 'Rabies',
        'ageInWeeks': 16,
        'intervalDays': null,
        'notes': 'First rabies vaccine',
        'isRequired': true,
      };

      final step = VaccinationStep.fromJson(json);

      expect(step.vaccineName, 'Rabies');
      expect(step.ageInWeeks, 16);
      expect(step.intervalDays, isNull);
      expect(step.notes, 'First rabies vaccine');
      expect(step.isRequired, true);
    });

    test('should handle missing isRequired in JSON (default to true)', () {
      final json = {
        'vaccineName': 'Test',
        'ageInWeeks': 10,
      };

      final step = VaccinationStep.fromJson(json);

      expect(step.isRequired, true);
    });

    test('should implement equality correctly', () {
      final step1 = VaccinationStep(
        vaccineName: 'DHPPiL',
        ageInWeeks: 6,
        notes: 'Test',
        isRequired: true,
      );

      final step2 = VaccinationStep(
        vaccineName: 'DHPPiL',
        ageInWeeks: 6,
        notes: 'Test',
        isRequired: true,
      );

      final step3 = VaccinationStep(
        vaccineName: 'Rabies',
        ageInWeeks: 6,
        notes: 'Test',
        isRequired: true,
      );

      expect(step1, equals(step2));
      expect(step1, isNot(equals(step3)));
    });
  });

  group('RecurringSchedule', () {
    test('should create RecurringSchedule for indefinite recurrence', () {
      final schedule = RecurringSchedule(
        intervalMonths: 12,
        indefinitely: true,
      );

      expect(schedule.intervalMonths, 12);
      expect(schedule.indefinitely, true);
      expect(schedule.numberOfDoses, isNull);
    });

    test('should create RecurringSchedule with limited doses', () {
      final schedule = RecurringSchedule(
        intervalMonths: 6,
        indefinitely: false,
        numberOfDoses: 3,
      );

      expect(schedule.intervalMonths, 6);
      expect(schedule.indefinitely, false);
      expect(schedule.numberOfDoses, 3);
    });

    test('should throw assertion error when not indefinite and no numberOfDoses', () {
      expect(
        () => RecurringSchedule(
          intervalMonths: 12,
          indefinitely: false,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('should convert to JSON correctly', () {
      final schedule = RecurringSchedule(
        intervalMonths: 12,
        indefinitely: true,
      );

      final json = schedule.toJson();

      expect(json['intervalMonths'], 12);
      expect(json['indefinitely'], true);
      expect(json['numberOfDoses'], isNull);
    });

    test('should create from JSON correctly', () {
      final json = {
        'intervalMonths': 6,
        'indefinitely': false,
        'numberOfDoses': 3,
      };

      final schedule = RecurringSchedule.fromJson(json);

      expect(schedule.intervalMonths, 6);
      expect(schedule.indefinitely, false);
      expect(schedule.numberOfDoses, 3);
    });

    test('should implement equality correctly', () {
      final schedule1 = RecurringSchedule(
        intervalMonths: 12,
        indefinitely: true,
      );

      final schedule2 = RecurringSchedule(
        intervalMonths: 12,
        indefinitely: true,
      );

      final schedule3 = RecurringSchedule(
        intervalMonths: 6,
        indefinitely: true,
      );

      expect(schedule1, equals(schedule2));
      expect(schedule1, isNot(equals(schedule3)));
    });
  });

  group('Hive Serialization', () {
    setUpAll(() async {
      // Initialize Hive for testing with temp directory
      Hive.init('test_hive_db');

      // Register adapters
      if (!Hive.isAdapterRegistered(22)) {
        Hive.registerAdapter(VaccinationProtocolAdapter());
      }
      if (!Hive.isAdapterRegistered(23)) {
        Hive.registerAdapter(VaccinationStepAdapter());
      }
      if (!Hive.isAdapterRegistered(24)) {
        Hive.registerAdapter(RecurringScheduleAdapter());
      }
    });

    tearDownAll(() async {
      await Hive.close();
    });

    test('should serialize and deserialize VaccinationProtocol with Hive', () async {
      final testBox = await Hive.openBox<VaccinationProtocol>('test_protocols');

      try {
        final protocol = VaccinationProtocol(
          id: 'test_protocol',
          name: 'Test Protocol',
          species: 'dog',
          steps: [
            VaccinationStep(
              vaccineName: 'Test Vaccine',
              ageInWeeks: 8,
              isRequired: true,
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
        expect(retrieved.steps.length, protocol.steps.length);
        expect(retrieved.steps[0].vaccineName, protocol.steps[0].vaccineName);
        expect(retrieved.description, protocol.description);
        expect(retrieved.isCustom, protocol.isCustom);
      } finally {
        await testBox.clear();
        await testBox.close();
        await Hive.deleteBoxFromDisk('test_protocols');
      }
    });

    test('should handle complex protocol with recurring steps in Hive', () async {
      final testBox = await Hive.openBox<VaccinationProtocol>('test_complex_protocols');

      try {
        final protocol = VaccinationProtocol(
          id: 'complex_protocol',
          name: 'Complex Protocol',
          species: 'cat',
          steps: [
            VaccinationStep(
              vaccineName: 'FVRCP',
              ageInWeeks: 6,
              isRequired: true,
            ),
            VaccinationStep(
              vaccineName: 'FVRCP',
              ageInWeeks: 9,
              intervalDays: 21,
              notes: 'Second dose',
              isRequired: true,
            ),
            VaccinationStep(
              vaccineName: 'Rabies',
              ageInWeeks: 52,
              isRequired: true,
              recurring: RecurringSchedule(
                intervalMonths: 12,
                indefinitely: true,
              ),
            ),
          ],
          description: 'Complex feline protocol',
          isCustom: false,
          region: 'EU',
        );

        await testBox.put('complex_key', protocol);
        final retrieved = testBox.get('complex_key');

        expect(retrieved, isNotNull);
        expect(retrieved!.steps.length, 3);
        expect(retrieved.steps[2].recurring, isNotNull);
        expect(retrieved.steps[2].recurring!.intervalMonths, 12);
        expect(retrieved.steps[2].recurring!.indefinitely, true);
      } finally {
        await testBox.clear();
        await testBox.close();
        await Hive.deleteBoxFromDisk('test_complex_protocols');
      }
    });
  });
}
