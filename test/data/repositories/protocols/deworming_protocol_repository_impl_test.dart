// File: test/data/repositories/protocols/deworming_protocol_repository_impl_test.dart
// Coverage: 24 tests covering all CRUD operations, filtering, sorting, and edge cases
// Focus Areas: save/retrieve operations, species filtering, custom/predefined filtering, sorting validation

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fur_friend_diary/src/data/repositories/protocols/deworming_protocol_repository_impl.dart';
import 'package:fur_friend_diary/src/domain/models/protocols/deworming_protocol.dart';
import 'package:fur_friend_diary/src/domain/models/protocols/vaccination_protocol.dart';

void main() {
  group('DewormingProtocolRepositoryImpl', () {
    late DewormingProtocolRepositoryImpl repository;
    late Box<DewormingProtocol> box;

    setUpAll(() async {
      // Initialize Hive for testing
      Hive.init('test_hive_db_deworming_protocol_repo');

      // Register adapters
      if (!Hive.isAdapterRegistered(25)) {
        Hive.registerAdapter(DewormingProtocolAdapter());
      }
      if (!Hive.isAdapterRegistered(26)) {
        Hive.registerAdapter(DewormingScheduleAdapter());
      }
      if (!Hive.isAdapterRegistered(24)) {
        Hive.registerAdapter(RecurringScheduleAdapter());
      }
    });

    setUp(() async {
      // Open and clear box before each test
      box = await Hive.openBox<DewormingProtocol>('deworming_protocols');
      await box.clear();
      repository = DewormingProtocolRepositoryImpl(box: box);
    });

    tearDown(() async {
      // Clean up after each test
      await box.close();
      await Hive.deleteBoxFromDisk('deworming_protocols');
    });

    tearDownAll(() async {
      await Hive.close();
    });

    // Helper function to create test protocols
    DewormingProtocol createTestProtocol({
      required String id,
      required String name,
      required String species,
      required bool isCustom,
      DateTime? createdAt,
    }) {
      return DewormingProtocol(
        id: id,
        name: name,
        species: species,
        schedules: [
          DewormingSchedule(
            dewormingType: 'internal',
            productName: 'Test Dewormer',
            ageInWeeks: 4,
            notes: 'First dose',
          ),
        ],
        description: 'Test deworming protocol for $species',
        isCustom: isCustom,
        region: 'Romania/EU',
        createdAt: createdAt,
      );
    }

    group('save', () {
      test('should save deworming protocol to Hive box', () async {
        // Arrange
        final protocol = createTestProtocol(
          id: 'test_protocol_1',
          name: 'Test Protocol',
          species: 'dog',
          isCustom: false,
        );

        // Act
        await repository.save(protocol);

        // Assert
        expect(box.length, 1);
        expect(box.get('test_protocol_1'), isNotNull);
        expect(box.get('test_protocol_1')?.name, 'Test Protocol');
      });

      test('should update existing protocol when saving with same ID', () async {
        // Arrange
        final protocol1 = createTestProtocol(
          id: 'test_protocol_1',
          name: 'Original Name',
          species: 'dog',
          isCustom: false,
        );
        await repository.save(protocol1);

        final protocol2 = protocol1.copyWith(name: 'Updated Name');

        // Act
        await repository.save(protocol2);

        // Assert
        expect(box.length, 1); // Still only one item
        expect(box.get('test_protocol_1')?.name, 'Updated Name');
      });

      test('should save multiple protocols with different IDs', () async {
        // Arrange
        final protocol1 = createTestProtocol(
          id: 'protocol_1',
          name: 'Protocol 1',
          species: 'dog',
          isCustom: false,
        );
        final protocol2 = createTestProtocol(
          id: 'protocol_2',
          name: 'Protocol 2',
          species: 'cat',
          isCustom: true,
        );

        // Act
        await repository.save(protocol1);
        await repository.save(protocol2);

        // Assert
        expect(box.length, 2);
        expect(box.get('protocol_1')?.name, 'Protocol 1');
        expect(box.get('protocol_2')?.name, 'Protocol 2');
      });
    });

    group('getById', () {
      test('should retrieve deworming protocol by ID when it exists', () async {
        // Arrange
        final protocol = createTestProtocol(
          id: 'test_protocol_1',
          name: 'Test Protocol',
          species: 'dog',
          isCustom: false,
        );
        await repository.save(protocol);

        // Act
        final result = await repository.getById('test_protocol_1');

        // Assert
        expect(result, isNotNull);
        expect(result?.id, 'test_protocol_1');
        expect(result?.name, 'Test Protocol');
        expect(result?.species, 'dog');
      });

      test('should return null when protocol ID does not exist', () async {
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

      test('should return all deworming protocols', () async {
        // Arrange
        final protocol1 = createTestProtocol(
          id: 'protocol_1',
          name: 'Protocol 1',
          species: 'dog',
          isCustom: false,
        );
        final protocol2 = createTestProtocol(
          id: 'protocol_2',
          name: 'Protocol 2',
          species: 'cat',
          isCustom: true,
        );
        final protocol3 = createTestProtocol(
          id: 'protocol_3',
          name: 'Protocol 3',
          species: 'dog',
          isCustom: false,
        );

        await repository.save(protocol1);
        await repository.save(protocol2);
        await repository.save(protocol3);

        // Act
        final result = await repository.getAll();

        // Assert
        expect(result.length, 3);
        expect(result.any((p) => p.id == 'protocol_1'), isTrue);
        expect(result.any((p) => p.id == 'protocol_2'), isTrue);
        expect(result.any((p) => p.id == 'protocol_3'), isTrue);
      });

      test('should return protocols sorted alphabetically by name', () async {
        // Arrange
        final protocolZ = createTestProtocol(
          id: 'protocol_z',
          name: 'Zebra Protocol',
          species: 'dog',
          isCustom: false,
        );
        final protocolA = createTestProtocol(
          id: 'protocol_a',
          name: 'Alpha Protocol',
          species: 'cat',
          isCustom: false,
        );
        final protocolM = createTestProtocol(
          id: 'protocol_m',
          name: 'Middle Protocol',
          species: 'dog',
          isCustom: false,
        );

        // Save in random order
        await repository.save(protocolZ);
        await repository.save(protocolA);
        await repository.save(protocolM);

        // Act
        final result = await repository.getAll();

        // Assert
        expect(result.length, 3);
        expect(result[0].name, 'Alpha Protocol');
        expect(result[1].name, 'Middle Protocol');
        expect(result[2].name, 'Zebra Protocol');
      });
    });

    group('getBySpecies', () {
      test('should return empty list when no protocols match species', () async {
        // Arrange
        final protocol = createTestProtocol(
          id: 'protocol_1',
          name: 'Dog Protocol',
          species: 'dog',
          isCustom: false,
        );
        await repository.save(protocol);

        // Act
        final result = await repository.getBySpecies('cat');

        // Assert
        expect(result, isEmpty);
      });

      test('should return only protocols matching specified species', () async {
        // Arrange
        final dogProtocol1 = createTestProtocol(
          id: 'dog_1',
          name: 'Dog Protocol 1',
          species: 'dog',
          isCustom: false,
        );
        final catProtocol = createTestProtocol(
          id: 'cat_1',
          name: 'Cat Protocol',
          species: 'cat',
          isCustom: false,
        );
        final dogProtocol2 = createTestProtocol(
          id: 'dog_2',
          name: 'Dog Protocol 2',
          species: 'dog',
          isCustom: true,
        );

        await repository.save(dogProtocol1);
        await repository.save(catProtocol);
        await repository.save(dogProtocol2);

        // Act
        final result = await repository.getBySpecies('dog');

        // Assert
        expect(result.length, 2);
        expect(result.every((p) => p.species == 'dog'), isTrue);
        expect(result.any((p) => p.id == 'dog_1'), isTrue);
        expect(result.any((p) => p.id == 'dog_2'), isTrue);
      });

      test('should return species protocols sorted alphabetically by name', () async {
        // Arrange
        final protocolZ = createTestProtocol(
          id: 'dog_z',
          name: 'Zebra Dog Protocol',
          species: 'dog',
          isCustom: false,
        );
        final protocolA = createTestProtocol(
          id: 'dog_a',
          name: 'Alpha Dog Protocol',
          species: 'dog',
          isCustom: false,
        );

        await repository.save(protocolZ);
        await repository.save(protocolA);

        // Act
        final result = await repository.getBySpecies('dog');

        // Assert
        expect(result.length, 2);
        expect(result[0].name, 'Alpha Dog Protocol');
        expect(result[1].name, 'Zebra Dog Protocol');
      });
    });

    group('getPredefined', () {
      test('should return empty list when no predefined protocols exist', () async {
        // Arrange
        final customProtocol = createTestProtocol(
          id: 'custom_1',
          name: 'Custom Protocol',
          species: 'dog',
          isCustom: true,
        );
        await repository.save(customProtocol);

        // Act
        final result = await repository.getPredefined();

        // Assert
        expect(result, isEmpty);
      });

      test('should return only predefined protocols (isCustom=false)', () async {
        // Arrange
        final predefined1 = createTestProtocol(
          id: 'predefined_1',
          name: 'Predefined 1',
          species: 'dog',
          isCustom: false,
        );
        final custom = createTestProtocol(
          id: 'custom_1',
          name: 'Custom Protocol',
          species: 'cat',
          isCustom: true,
        );
        final predefined2 = createTestProtocol(
          id: 'predefined_2',
          name: 'Predefined 2',
          species: 'dog',
          isCustom: false,
        );

        await repository.save(predefined1);
        await repository.save(custom);
        await repository.save(predefined2);

        // Act
        final result = await repository.getPredefined();

        // Assert
        expect(result.length, 2);
        expect(result.every((p) => !p.isCustom), isTrue);
      });

      test('should return predefined protocols sorted by species then name', () async {
        // Arrange
        final dogB = createTestProtocol(
          id: 'dog_b',
          name: 'Dog B Protocol',
          species: 'dog',
          isCustom: false,
        );
        final catA = createTestProtocol(
          id: 'cat_a',
          name: 'Cat A Protocol',
          species: 'cat',
          isCustom: false,
        );
        final dogA = createTestProtocol(
          id: 'dog_a',
          name: 'Dog A Protocol',
          species: 'dog',
          isCustom: false,
        );

        await repository.save(dogB);
        await repository.save(catA);
        await repository.save(dogA);

        // Act
        final result = await repository.getPredefined();

        // Assert
        expect(result.length, 3);
        // First by species (cat < dog alphabetically)
        expect(result[0].species, 'cat');
        // Then within same species, by name
        expect(result[1].species, 'dog');
        expect(result[1].name, 'Dog A Protocol');
        expect(result[2].species, 'dog');
        expect(result[2].name, 'Dog B Protocol');
      });
    });

    group('getCustom', () {
      test('should return empty list when no custom protocols exist', () async {
        // Arrange
        final predefined = createTestProtocol(
          id: 'predefined_1',
          name: 'Predefined Protocol',
          species: 'dog',
          isCustom: false,
        );
        await repository.save(predefined);

        // Act
        final result = await repository.getCustom();

        // Assert
        expect(result, isEmpty);
      });

      test('should return only custom protocols (isCustom=true)', () async {
        // Arrange
        final custom1 = createTestProtocol(
          id: 'custom_1',
          name: 'Custom 1',
          species: 'dog',
          isCustom: true,
        );
        final predefined = createTestProtocol(
          id: 'predefined_1',
          name: 'Predefined',
          species: 'cat',
          isCustom: false,
        );
        final custom2 = createTestProtocol(
          id: 'custom_2',
          name: 'Custom 2',
          species: 'dog',
          isCustom: true,
        );

        await repository.save(custom1);
        await repository.save(predefined);
        await repository.save(custom2);

        // Act
        final result = await repository.getCustom();

        // Assert
        expect(result.length, 2);
        expect(result.every((p) => p.isCustom), isTrue);
      });

      test('should return custom protocols sorted by createdAt descending (newest first)', () async {
        // Arrange
        final now = DateTime.now();
        final oldest = createTestProtocol(
          id: 'custom_oldest',
          name: 'Oldest Custom',
          species: 'dog',
          isCustom: true,
          createdAt: now.subtract(const Duration(days: 10)),
        );
        final newest = createTestProtocol(
          id: 'custom_newest',
          name: 'Newest Custom',
          species: 'dog',
          isCustom: true,
          createdAt: now,
        );
        final middle = createTestProtocol(
          id: 'custom_middle',
          name: 'Middle Custom',
          species: 'dog',
          isCustom: true,
          createdAt: now.subtract(const Duration(days: 5)),
        );

        await repository.save(oldest);
        await repository.save(newest);
        await repository.save(middle);

        // Act
        final result = await repository.getCustom();

        // Assert
        expect(result.length, 3);
        expect(result[0].id, 'custom_newest'); // Newest first
        expect(result[1].id, 'custom_middle');
        expect(result[2].id, 'custom_oldest'); // Oldest last
      });
    });

    group('delete', () {
      test('should delete deworming protocol by ID when it exists', () async {
        // Arrange
        final protocol = createTestProtocol(
          id: 'test_protocol_1',
          name: 'Test Protocol',
          species: 'dog',
          isCustom: false,
        );
        await repository.save(protocol);
        expect(box.length, 1);

        // Act
        await repository.delete('test_protocol_1');

        // Assert
        expect(box.length, 0);
        expect(box.get('test_protocol_1'), isNull);
      });

      test('should not throw error when deleting non-existent protocol', () async {
        // Act & Assert - should not throw
        await repository.delete('non_existent_id');
        expect(box.length, 0);
      });

      test('should delete only the specified protocol and leave others', () async {
        // Arrange
        final protocol1 = createTestProtocol(
          id: 'protocol_1',
          name: 'Protocol 1',
          species: 'dog',
          isCustom: false,
        );
        final protocol2 = createTestProtocol(
          id: 'protocol_2',
          name: 'Protocol 2',
          species: 'cat',
          isCustom: true,
        );
        await repository.save(protocol1);
        await repository.save(protocol2);

        // Act
        await repository.delete('protocol_1');

        // Assert
        expect(box.length, 1);
        expect(box.get('protocol_1'), isNull);
        expect(box.get('protocol_2'), isNotNull);
      });
    });

    group('deleteAll', () {
      test('should delete all deworming protocols from box', () async {
        // Arrange
        final protocol1 = createTestProtocol(
          id: 'protocol_1',
          name: 'Protocol 1',
          species: 'dog',
          isCustom: false,
        );
        final protocol2 = createTestProtocol(
          id: 'protocol_2',
          name: 'Protocol 2',
          species: 'cat',
          isCustom: true,
        );
        final protocol3 = createTestProtocol(
          id: 'protocol_3',
          name: 'Protocol 3',
          species: 'dog',
          isCustom: false,
        );

        await repository.save(protocol1);
        await repository.save(protocol2);
        await repository.save(protocol3);
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
      test('should handle multiple saves and deletes correctly', () async {
        // Arrange & Act
        final protocol1 = createTestProtocol(
          id: 'protocol_1',
          name: 'Protocol 1',
          species: 'dog',
          isCustom: false,
        );
        await repository.save(protocol1);
        expect(box.length, 1);

        await repository.delete('protocol_1');
        expect(box.length, 0);

        await repository.save(protocol1);
        expect(box.length, 1);

        final protocol2 = createTestProtocol(
          id: 'protocol_2',
          name: 'Protocol 2',
          species: 'cat',
          isCustom: true,
        );
        await repository.save(protocol2);
        expect(box.length, 2);

        // Assert
        final all = await repository.getAll();
        expect(all.length, 2);
      });

      test('should handle protocols with same species but different custom flags', () async {
        // Arrange
        final predefinedDog = createTestProtocol(
          id: 'predefined_dog',
          name: 'Predefined Dog',
          species: 'dog',
          isCustom: false,
        );
        final customDog = createTestProtocol(
          id: 'custom_dog',
          name: 'Custom Dog',
          species: 'dog',
          isCustom: true,
        );

        await repository.save(predefinedDog);
        await repository.save(customDog);

        // Act
        final allDogs = await repository.getBySpecies('dog');
        final predefined = await repository.getPredefined();
        final custom = await repository.getCustom();

        // Assert
        expect(allDogs.length, 2);
        expect(predefined.length, 1);
        expect(predefined[0].id, 'predefined_dog');
        expect(custom.length, 1);
        expect(custom[0].id, 'custom_dog');
      });
    });
  });
}
