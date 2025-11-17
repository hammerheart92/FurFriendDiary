// File: test/data/repositories/protocols/reminder_config_repository_impl_test.dart
// Coverage: 30 tests covering all CRUD operations, petId filtering, enabled/disabled states, eventType filtering, combined filters, sorting
// Focus Areas: save/retrieve operations, petId filtering, enabled/disabled states, eventType filtering, combined petId+eventType filters, sorting validation

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fur_friend_diary/src/data/repositories/protocols/reminder_config_repository_impl.dart';
import 'package:fur_friend_diary/src/domain/models/protocols/reminder_config.dart';

void main() {
  group('ReminderConfigRepositoryImpl', () {
    late ReminderConfigRepositoryImpl repository;
    late Box<ReminderConfig> box;

    setUpAll(() async {
      // Initialize Hive for testing
      Hive.init('test_hive_db_reminder_config_repo');

      // Register adapters
      if (!Hive.isAdapterRegistered(29)) {
        Hive.registerAdapter(ReminderConfigAdapter());
      }
    });

    setUp(() async {
      // Open and clear box before each test
      box = await Hive.openBox<ReminderConfig>('reminder_configs');
      await box.clear();
      repository = ReminderConfigRepositoryImpl(box: box);
    });

    tearDown(() async {
      // Clean up after each test
      await box.close();
      await Hive.deleteBoxFromDisk('reminder_configs');
    });

    tearDownAll(() async {
      await Hive.close();
    });

    // Helper function to create test reminder configs
    ReminderConfig createTestConfig({
      required String id,
      required String petId,
      required String eventType,
      required bool isEnabled,
      DateTime? createdAt,
      List<int>? reminderDays,
    }) {
      return ReminderConfig(
        id: id,
        petId: petId,
        eventType: eventType,
        reminderDays: reminderDays ?? [1, 7, 14],
        isEnabled: isEnabled,
        createdAt: createdAt,
      );
    }

    group('save', () {
      test('should save reminder config to Hive box', () async {
        // Arrange
        final config = createTestConfig(
          id: 'config_1',
          petId: 'pet_1',
          eventType: 'vaccination',
          isEnabled: true,
        );

        // Act
        await repository.save(config);

        // Assert
        expect(box.length, 1);
        expect(box.get('config_1'), isNotNull);
        expect(box.get('config_1')?.eventType, 'vaccination');
      });

      test('should update existing config when saving with same ID', () async {
        // Arrange
        final config1 = createTestConfig(
          id: 'config_1',
          petId: 'pet_1',
          eventType: 'vaccination',
          isEnabled: true,
        );
        await repository.save(config1);

        final config2 = config1.copyWith(isEnabled: false);

        // Act
        await repository.save(config2);

        // Assert
        expect(box.length, 1);
        expect(box.get('config_1')?.isEnabled, false);
      });

      test('should save multiple configs with different IDs', () async {
        // Arrange
        final config1 = createTestConfig(
          id: 'config_1',
          petId: 'pet_1',
          eventType: 'vaccination',
          isEnabled: true,
        );
        final config2 = createTestConfig(
          id: 'config_2',
          petId: 'pet_2',
          eventType: 'deworming',
          isEnabled: false,
        );

        // Act
        await repository.save(config1);
        await repository.save(config2);

        // Assert
        expect(box.length, 2);
        expect(box.get('config_1')?.eventType, 'vaccination');
        expect(box.get('config_2')?.eventType, 'deworming');
      });
    });

    group('getById', () {
      test('should retrieve reminder config by ID when it exists', () async {
        // Arrange
        final config = createTestConfig(
          id: 'config_1',
          petId: 'pet_1',
          eventType: 'vaccination',
          isEnabled: true,
        );
        await repository.save(config);

        // Act
        final result = await repository.getById('config_1');

        // Assert
        expect(result, isNotNull);
        expect(result?.id, 'config_1');
        expect(result?.petId, 'pet_1');
        expect(result?.eventType, 'vaccination');
      });

      test('should return null when config ID does not exist', () async {
        // Act
        final result = await repository.getById('non_existent_id');

        // Assert
        expect(result, isNull);
      });

      test('should return null when box is empty', () async {
        // Act
        final result = await repository.getById('any_id');

        // Assert
        expect(result, isNull);
      });
    });

    group('getAll', () {
      test('should return empty list when box is empty', () async {
        // Act
        final result = await repository.getAll();

        // Assert
        expect(result, isEmpty);
      });

      test('should return all reminder configs', () async {
        // Arrange
        final config1 = createTestConfig(
          id: 'config_1',
          petId: 'pet_1',
          eventType: 'vaccination',
          isEnabled: true,
        );
        final config2 = createTestConfig(
          id: 'config_2',
          petId: 'pet_2',
          eventType: 'deworming',
          isEnabled: false,
        );
        final config3 = createTestConfig(
          id: 'config_3',
          petId: 'pet_1',
          eventType: 'appointment',
          isEnabled: true,
        );

        await repository.save(config1);
        await repository.save(config2);
        await repository.save(config3);

        // Act
        final result = await repository.getAll();

        // Assert
        expect(result.length, 3);
        expect(result.any((c) => c.id == 'config_1'), isTrue);
        expect(result.any((c) => c.id == 'config_2'), isTrue);
        expect(result.any((c) => c.id == 'config_3'), isTrue);
      });

      test('should return configs sorted by createdAt descending (newest first)', () async {
        // Arrange
        final now = DateTime.now();
        final oldest = createTestConfig(
          id: 'config_oldest',
          petId: 'pet_1',
          eventType: 'vaccination',
          isEnabled: true,
          createdAt: now.subtract(const Duration(days: 10)),
        );
        final newest = createTestConfig(
          id: 'config_newest',
          petId: 'pet_1',
          eventType: 'vaccination',
          isEnabled: true,
          createdAt: now,
        );
        final middle = createTestConfig(
          id: 'config_middle',
          petId: 'pet_1',
          eventType: 'vaccination',
          isEnabled: true,
          createdAt: now.subtract(const Duration(days: 5)),
        );

        await repository.save(oldest);
        await repository.save(newest);
        await repository.save(middle);

        // Act
        final result = await repository.getAll();

        // Assert
        expect(result.length, 3);
        expect(result[0].id, 'config_newest');
        expect(result[1].id, 'config_middle');
        expect(result[2].id, 'config_oldest');
      });
    });

    group('getByPetId', () {
      test('should return empty list when no configs match petId', () async {
        // Arrange
        final config = createTestConfig(
          id: 'config_1',
          petId: 'pet_1',
          eventType: 'vaccination',
          isEnabled: true,
        );
        await repository.save(config);

        // Act
        final result = await repository.getByPetId('pet_2');

        // Assert
        expect(result, isEmpty);
      });

      test('should return only configs matching specified petId', () async {
        // Arrange
        final config1 = createTestConfig(
          id: 'config_1',
          petId: 'pet_1',
          eventType: 'vaccination',
          isEnabled: true,
        );
        final config2 = createTestConfig(
          id: 'config_2',
          petId: 'pet_2',
          eventType: 'deworming',
          isEnabled: true,
        );
        final config3 = createTestConfig(
          id: 'config_3',
          petId: 'pet_1',
          eventType: 'appointment',
          isEnabled: false,
        );

        await repository.save(config1);
        await repository.save(config2);
        await repository.save(config3);

        // Act
        final result = await repository.getByPetId('pet_1');

        // Assert
        expect(result.length, 2);
        expect(result.every((c) => c.petId == 'pet_1'), isTrue);
        expect(result.any((c) => c.id == 'config_1'), isTrue);
        expect(result.any((c) => c.id == 'config_3'), isTrue);
      });

      test('should return pet configs sorted by eventType alphabetically', () async {
        // Arrange
        final vaccinationConfig = createTestConfig(
          id: 'config_vacc',
          petId: 'pet_1',
          eventType: 'vaccination',
          isEnabled: true,
        );
        final appointmentConfig = createTestConfig(
          id: 'config_appt',
          petId: 'pet_1',
          eventType: 'appointment',
          isEnabled: true,
        );
        final dewormingConfig = createTestConfig(
          id: 'config_deworm',
          petId: 'pet_1',
          eventType: 'deworming',
          isEnabled: true,
        );

        await repository.save(vaccinationConfig);
        await repository.save(appointmentConfig);
        await repository.save(dewormingConfig);

        // Act
        final result = await repository.getByPetId('pet_1');

        // Assert
        expect(result.length, 3);
        expect(result[0].eventType, 'appointment'); // alphabetically first
        expect(result[1].eventType, 'deworming');
        expect(result[2].eventType, 'vaccination');
      });
    });

    group('getEnabledByPetId', () {
      test('should return empty list when no enabled configs exist for pet', () async {
        // Arrange
        final disabledConfig = createTestConfig(
          id: 'config_1',
          petId: 'pet_1',
          eventType: 'vaccination',
          isEnabled: false,
        );
        await repository.save(disabledConfig);

        // Act
        final result = await repository.getEnabledByPetId('pet_1');

        // Assert
        expect(result, isEmpty);
      });

      test('should return only enabled configs for specified petId', () async {
        // Arrange
        final enabled1 = createTestConfig(
          id: 'config_1',
          petId: 'pet_1',
          eventType: 'vaccination',
          isEnabled: true,
        );
        final disabled = createTestConfig(
          id: 'config_2',
          petId: 'pet_1',
          eventType: 'deworming',
          isEnabled: false,
        );
        final enabled2 = createTestConfig(
          id: 'config_3',
          petId: 'pet_1',
          eventType: 'appointment',
          isEnabled: true,
        );
        final otherPetEnabled = createTestConfig(
          id: 'config_4',
          petId: 'pet_2',
          eventType: 'vaccination',
          isEnabled: true,
        );

        await repository.save(enabled1);
        await repository.save(disabled);
        await repository.save(enabled2);
        await repository.save(otherPetEnabled);

        // Act
        final result = await repository.getEnabledByPetId('pet_1');

        // Assert
        expect(result.length, 2);
        expect(result.every((c) => c.petId == 'pet_1' && c.isEnabled), isTrue);
        expect(result.any((c) => c.id == 'config_1'), isTrue);
        expect(result.any((c) => c.id == 'config_3'), isTrue);
      });

      test('should return enabled configs sorted by eventType alphabetically', () async {
        // Arrange
        final vaccinationConfig = createTestConfig(
          id: 'config_vacc',
          petId: 'pet_1',
          eventType: 'vaccination',
          isEnabled: true,
        );
        final appointmentConfig = createTestConfig(
          id: 'config_appt',
          petId: 'pet_1',
          eventType: 'appointment',
          isEnabled: true,
        );

        await repository.save(vaccinationConfig);
        await repository.save(appointmentConfig);

        // Act
        final result = await repository.getEnabledByPetId('pet_1');

        // Assert
        expect(result.length, 2);
        expect(result[0].eventType, 'appointment');
        expect(result[1].eventType, 'vaccination');
      });
    });

    group('getDisabledByPetId', () {
      test('should return empty list when no disabled configs exist for pet', () async {
        // Arrange
        final enabledConfig = createTestConfig(
          id: 'config_1',
          petId: 'pet_1',
          eventType: 'vaccination',
          isEnabled: true,
        );
        await repository.save(enabledConfig);

        // Act
        final result = await repository.getDisabledByPetId('pet_1');

        // Assert
        expect(result, isEmpty);
      });

      test('should return only disabled configs for specified petId', () async {
        // Arrange
        final enabled = createTestConfig(
          id: 'config_1',
          petId: 'pet_1',
          eventType: 'vaccination',
          isEnabled: true,
        );
        final disabled1 = createTestConfig(
          id: 'config_2',
          petId: 'pet_1',
          eventType: 'deworming',
          isEnabled: false,
        );
        final disabled2 = createTestConfig(
          id: 'config_3',
          petId: 'pet_1',
          eventType: 'appointment',
          isEnabled: false,
        );
        final otherPetDisabled = createTestConfig(
          id: 'config_4',
          petId: 'pet_2',
          eventType: 'vaccination',
          isEnabled: false,
        );

        await repository.save(enabled);
        await repository.save(disabled1);
        await repository.save(disabled2);
        await repository.save(otherPetDisabled);

        // Act
        final result = await repository.getDisabledByPetId('pet_1');

        // Assert
        expect(result.length, 2);
        expect(result.every((c) => c.petId == 'pet_1' && !c.isEnabled), isTrue);
        expect(result.any((c) => c.id == 'config_2'), isTrue);
        expect(result.any((c) => c.id == 'config_3'), isTrue);
      });
    });

    group('getByEventType', () {
      test('should return empty list when no configs match eventType', () async {
        // Arrange
        final config = createTestConfig(
          id: 'config_1',
          petId: 'pet_1',
          eventType: 'vaccination',
          isEnabled: true,
        );
        await repository.save(config);

        // Act
        final result = await repository.getByEventType('deworming');

        // Assert
        expect(result, isEmpty);
      });

      test('should return only configs matching specified eventType', () async {
        // Arrange
        final vacc1 = createTestConfig(
          id: 'config_1',
          petId: 'pet_1',
          eventType: 'vaccination',
          isEnabled: true,
        );
        final deworm = createTestConfig(
          id: 'config_2',
          petId: 'pet_2',
          eventType: 'deworming',
          isEnabled: true,
        );
        final vacc2 = createTestConfig(
          id: 'config_3',
          petId: 'pet_3',
          eventType: 'vaccination',
          isEnabled: false,
        );

        await repository.save(vacc1);
        await repository.save(deworm);
        await repository.save(vacc2);

        // Act
        final result = await repository.getByEventType('vaccination');

        // Assert
        expect(result.length, 2);
        expect(result.every((c) => c.eventType == 'vaccination'), isTrue);
        expect(result.any((c) => c.id == 'config_1'), isTrue);
        expect(result.any((c) => c.id == 'config_3'), isTrue);
      });

      test('should return eventType configs sorted by createdAt descending', () async {
        // Arrange
        final now = DateTime.now();
        final oldest = createTestConfig(
          id: 'config_oldest',
          petId: 'pet_1',
          eventType: 'vaccination',
          isEnabled: true,
          createdAt: now.subtract(const Duration(days: 10)),
        );
        final newest = createTestConfig(
          id: 'config_newest',
          petId: 'pet_2',
          eventType: 'vaccination',
          isEnabled: true,
          createdAt: now,
        );

        await repository.save(oldest);
        await repository.save(newest);

        // Act
        final result = await repository.getByEventType('vaccination');

        // Assert
        expect(result.length, 2);
        expect(result[0].id, 'config_newest');
        expect(result[1].id, 'config_oldest');
      });
    });

    group('getByPetIdAndEventType', () {
      test('should return empty list when no configs match both petId and eventType', () async {
        // Arrange
        final config = createTestConfig(
          id: 'config_1',
          petId: 'pet_1',
          eventType: 'vaccination',
          isEnabled: true,
        );
        await repository.save(config);

        // Act
        final result = await repository.getByPetIdAndEventType('pet_2', 'vaccination');

        // Assert
        expect(result, isEmpty);
      });

      test('should return only configs matching both petId and eventType', () async {
        // Arrange
        final match1 = createTestConfig(
          id: 'config_1',
          petId: 'pet_1',
          eventType: 'vaccination',
          isEnabled: true,
        );
        final wrongPet = createTestConfig(
          id: 'config_2',
          petId: 'pet_2',
          eventType: 'vaccination',
          isEnabled: true,
        );
        final wrongEvent = createTestConfig(
          id: 'config_3',
          petId: 'pet_1',
          eventType: 'deworming',
          isEnabled: true,
        );
        final match2 = createTestConfig(
          id: 'config_4',
          petId: 'pet_1',
          eventType: 'vaccination',
          isEnabled: false,
        );

        await repository.save(match1);
        await repository.save(wrongPet);
        await repository.save(wrongEvent);
        await repository.save(match2);

        // Act
        final result = await repository.getByPetIdAndEventType('pet_1', 'vaccination');

        // Assert
        expect(result.length, 2);
        expect(result.every((c) => c.petId == 'pet_1' && c.eventType == 'vaccination'), isTrue);
        expect(result.any((c) => c.id == 'config_1'), isTrue);
        expect(result.any((c) => c.id == 'config_4'), isTrue);
      });

      test('should return combined filter results sorted by createdAt descending', () async {
        // Arrange
        final now = DateTime.now();
        final oldest = createTestConfig(
          id: 'config_oldest',
          petId: 'pet_1',
          eventType: 'vaccination',
          isEnabled: true,
          createdAt: now.subtract(const Duration(days: 10)),
        );
        final newest = createTestConfig(
          id: 'config_newest',
          petId: 'pet_1',
          eventType: 'vaccination',
          isEnabled: true,
          createdAt: now,
        );

        await repository.save(oldest);
        await repository.save(newest);

        // Act
        final result = await repository.getByPetIdAndEventType('pet_1', 'vaccination');

        // Assert
        expect(result.length, 2);
        expect(result[0].id, 'config_newest');
        expect(result[1].id, 'config_oldest');
      });
    });

    group('delete', () {
      test('should delete reminder config by ID when it exists', () async {
        // Arrange
        final config = createTestConfig(
          id: 'config_1',
          petId: 'pet_1',
          eventType: 'vaccination',
          isEnabled: true,
        );
        await repository.save(config);
        expect(box.length, 1);

        // Act
        await repository.delete('config_1');

        // Assert
        expect(box.length, 0);
        expect(box.get('config_1'), isNull);
      });

      test('should not throw error when deleting non-existent config', () async {
        // Act & Assert - should not throw
        await repository.delete('non_existent_id');
        expect(box.length, 0);
      });

      test('should delete only the specified config and leave others', () async {
        // Arrange
        final config1 = createTestConfig(
          id: 'config_1',
          petId: 'pet_1',
          eventType: 'vaccination',
          isEnabled: true,
        );
        final config2 = createTestConfig(
          id: 'config_2',
          petId: 'pet_2',
          eventType: 'deworming',
          isEnabled: false,
        );
        await repository.save(config1);
        await repository.save(config2);

        // Act
        await repository.delete('config_1');

        // Assert
        expect(box.length, 1);
        expect(box.get('config_1'), isNull);
        expect(box.get('config_2'), isNotNull);
      });
    });

    group('deleteAll', () {
      test('should delete all reminder configs from box', () async {
        // Arrange
        final config1 = createTestConfig(
          id: 'config_1',
          petId: 'pet_1',
          eventType: 'vaccination',
          isEnabled: true,
        );
        final config2 = createTestConfig(
          id: 'config_2',
          petId: 'pet_2',
          eventType: 'deworming',
          isEnabled: false,
        );
        final config3 = createTestConfig(
          id: 'config_3',
          petId: 'pet_1',
          eventType: 'appointment',
          isEnabled: true,
        );

        await repository.save(config1);
        await repository.save(config2);
        await repository.save(config3);
        expect(box.length, 3);

        // Act
        await repository.deleteAll();

        // Assert
        expect(box.length, 0);
        expect(box.isEmpty, isTrue);
      });

      test('should handle deleteAll on empty box without error', () async {
        // Arrange
        expect(box.length, 0);

        // Act & Assert - should not throw
        await repository.deleteAll();
        expect(box.length, 0);
      });
    });

    group('Edge Cases', () {
      test('should handle multiple pets with multiple event types', () async {
        // Arrange
        final pet1Vacc = createTestConfig(
          id: 'p1_vacc',
          petId: 'pet_1',
          eventType: 'vaccination',
          isEnabled: true,
        );
        final pet1Deworm = createTestConfig(
          id: 'p1_deworm',
          petId: 'pet_1',
          eventType: 'deworming',
          isEnabled: false,
        );
        final pet2Vacc = createTestConfig(
          id: 'p2_vacc',
          petId: 'pet_2',
          eventType: 'vaccination',
          isEnabled: true,
        );

        await repository.save(pet1Vacc);
        await repository.save(pet1Deworm);
        await repository.save(pet2Vacc);

        // Act
        final pet1Configs = await repository.getByPetId('pet_1');
        final vaccConfigs = await repository.getByEventType('vaccination');
        final pet1VaccConfigs = await repository.getByPetIdAndEventType('pet_1', 'vaccination');

        // Assert
        expect(pet1Configs.length, 2);
        expect(vaccConfigs.length, 2);
        expect(pet1VaccConfigs.length, 1);
        expect(pet1VaccConfigs[0].id, 'p1_vacc');
      });

      test('should handle all valid eventType values', () async {
        // Arrange
        final eventTypes = ['vaccination', 'deworming', 'appointment', 'medication', 'custom'];

        for (var i = 0; i < eventTypes.length; i++) {
          final config = eventTypes[i] == 'custom'
              ? ReminderConfig(
                  id: 'config_$i',
                  petId: 'pet_1',
                  eventType: 'custom',
                  reminderDays: [1, 7],
                  isEnabled: true,
                  customTitle: 'Custom Event',
                )
              : createTestConfig(
                  id: 'config_$i',
                  petId: 'pet_1',
                  eventType: eventTypes[i],
                  isEnabled: true,
                );
          await repository.save(config);
        }

        // Act
        final allConfigs = await repository.getAll();

        // Assert
        expect(allConfigs.length, 5);
        for (var eventType in eventTypes) {
          expect(allConfigs.any((c) => c.eventType == eventType), isTrue);
        }
      });

      test('should handle same petId and eventType with different enabled states', () async {
        // Arrange
        final enabled = createTestConfig(
          id: 'config_enabled',
          petId: 'pet_1',
          eventType: 'vaccination',
          isEnabled: true,
        );
        final disabled = createTestConfig(
          id: 'config_disabled',
          petId: 'pet_1',
          eventType: 'vaccination',
          isEnabled: false,
        );

        await repository.save(enabled);
        await repository.save(disabled);

        // Act
        final allMatching = await repository.getByPetIdAndEventType('pet_1', 'vaccination');
        final enabledOnly = await repository.getEnabledByPetId('pet_1');
        final disabledOnly = await repository.getDisabledByPetId('pet_1');

        // Assert
        expect(allMatching.length, 2);
        expect(enabledOnly.length, 1);
        expect(enabledOnly[0].id, 'config_enabled');
        expect(disabledOnly.length, 1);
        expect(disabledOnly[0].id, 'config_disabled');
      });
    });
  });
}
