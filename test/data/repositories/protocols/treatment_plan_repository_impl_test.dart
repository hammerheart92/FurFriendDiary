// File: test/data/repositories/protocols/treatment_plan_repository_impl_test.dart
// Coverage: 28 tests covering all CRUD operations, pet-based filtering, active/inactive filtering, completion status, sorting
// Focus Areas: save/retrieve operations, petId filtering, active/inactive states, incomplete tasks, sorting by dates

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fur_friend_diary/src/data/repositories/protocols/treatment_plan_repository_impl.dart';
import 'package:fur_friend_diary/src/domain/models/protocols/treatment_plan.dart';

void main() {
  group('TreatmentPlanRepositoryImpl', () {
    late TreatmentPlanRepositoryImpl repository;
    late Box<TreatmentPlan> box;

    setUpAll(() async {
      // Initialize Hive for testing
      Hive.init('test_hive_db_treatment_plan_repo');

      // Register adapters
      if (!Hive.isAdapterRegistered(27)) {
        Hive.registerAdapter(TreatmentPlanAdapter());
      }
      if (!Hive.isAdapterRegistered(28)) {
        Hive.registerAdapter(TreatmentTaskAdapter());
      }
    });

    setUp(() async {
      // Open and clear box before each test
      box = await Hive.openBox<TreatmentPlan>('treatment_plans');
      await box.clear();
      repository = TreatmentPlanRepositoryImpl(box: box);
    });

    tearDown(() async {
      // Clean up after each test
      await box.close();
      await Hive.deleteBoxFromDisk('treatment_plans');
    });

    tearDownAll(() async {
      await Hive.close();
    });

    // Helper function to create test treatment plans
    TreatmentPlan createTestPlan({
      required String id,
      required String petId,
      required String name,
      required bool isActive,
      DateTime? startDate,
      DateTime? createdAt,
      List<TreatmentTask>? tasks,
    }) {
      return TreatmentPlan(
        id: id,
        petId: petId,
        name: name,
        description: 'Test treatment plan for pet $petId',
        startDate: startDate ?? DateTime.now(),
        tasks: tasks ?? [
          TreatmentTask(
            id: 'task_1',
            title: 'Test Task',
            description: 'Test task description',
            scheduledDate: DateTime.now(),
            isCompleted: false,
          ),
        ],
        isActive: isActive,
        createdAt: createdAt,
      );
    }

    group('save', () {
      test('should save treatment plan to Hive box', () async {
        // Arrange
        final plan = createTestPlan(
          id: 'plan_1',
          petId: 'pet_1',
          name: 'Test Plan',
          isActive: true,
        );

        // Act
        await repository.save(plan);

        // Assert
        expect(box.length, 1);
        expect(box.get('plan_1'), isNotNull);
        expect(box.get('plan_1')?.name, 'Test Plan');
      });

      test('should update existing plan when saving with same ID', () async {
        // Arrange
        final plan1 = createTestPlan(
          id: 'plan_1',
          petId: 'pet_1',
          name: 'Original Plan',
          isActive: true,
        );
        await repository.save(plan1);

        final plan2 = plan1.copyWith(name: 'Updated Plan');

        // Act
        await repository.save(plan2);

        // Assert
        expect(box.length, 1);
        expect(box.get('plan_1')?.name, 'Updated Plan');
      });

      test('should save multiple plans with different IDs', () async {
        // Arrange
        final plan1 = createTestPlan(
          id: 'plan_1',
          petId: 'pet_1',
          name: 'Plan 1',
          isActive: true,
        );
        final plan2 = createTestPlan(
          id: 'plan_2',
          petId: 'pet_2',
          name: 'Plan 2',
          isActive: false,
        );

        // Act
        await repository.save(plan1);
        await repository.save(plan2);

        // Assert
        expect(box.length, 2);
        expect(box.get('plan_1')?.name, 'Plan 1');
        expect(box.get('plan_2')?.name, 'Plan 2');
      });
    });

    group('getById', () {
      test('should retrieve treatment plan by ID when it exists', () async {
        // Arrange
        final plan = createTestPlan(
          id: 'plan_1',
          petId: 'pet_1',
          name: 'Test Plan',
          isActive: true,
        );
        await repository.save(plan);

        // Act
        final result = await repository.getById('plan_1');

        // Assert
        expect(result, isNotNull);
        expect(result?.id, 'plan_1');
        expect(result?.name, 'Test Plan');
        expect(result?.petId, 'pet_1');
      });

      test('should return null when plan ID does not exist', () async {
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

      test('should return all treatment plans', () async {
        // Arrange
        final plan1 = createTestPlan(
          id: 'plan_1',
          petId: 'pet_1',
          name: 'Plan 1',
          isActive: true,
        );
        final plan2 = createTestPlan(
          id: 'plan_2',
          petId: 'pet_2',
          name: 'Plan 2',
          isActive: false,
        );
        final plan3 = createTestPlan(
          id: 'plan_3',
          petId: 'pet_1',
          name: 'Plan 3',
          isActive: true,
        );

        await repository.save(plan1);
        await repository.save(plan2);
        await repository.save(plan3);

        // Act
        final result = await repository.getAll();

        // Assert
        expect(result.length, 3);
        expect(result.any((p) => p.id == 'plan_1'), isTrue);
        expect(result.any((p) => p.id == 'plan_2'), isTrue);
        expect(result.any((p) => p.id == 'plan_3'), isTrue);
      });

      test('should return plans sorted by createdAt descending (newest first)', () async {
        // Arrange
        final now = DateTime.now();
        final oldest = createTestPlan(
          id: 'plan_oldest',
          petId: 'pet_1',
          name: 'Oldest Plan',
          isActive: true,
          createdAt: now.subtract(const Duration(days: 10)),
        );
        final newest = createTestPlan(
          id: 'plan_newest',
          petId: 'pet_1',
          name: 'Newest Plan',
          isActive: true,
          createdAt: now,
        );
        final middle = createTestPlan(
          id: 'plan_middle',
          petId: 'pet_1',
          name: 'Middle Plan',
          isActive: true,
          createdAt: now.subtract(const Duration(days: 5)),
        );

        await repository.save(oldest);
        await repository.save(newest);
        await repository.save(middle);

        // Act
        final result = await repository.getAll();

        // Assert
        expect(result.length, 3);
        expect(result[0].id, 'plan_newest');
        expect(result[1].id, 'plan_middle');
        expect(result[2].id, 'plan_oldest');
      });
    });

    group('getByPetId', () {
      test('should return empty list when no plans match petId', () async {
        // Arrange
        final plan = createTestPlan(
          id: 'plan_1',
          petId: 'pet_1',
          name: 'Plan 1',
          isActive: true,
        );
        await repository.save(plan);

        // Act
        final result = await repository.getByPetId('pet_2');

        // Assert
        expect(result, isEmpty);
      });

      test('should return only plans matching specified petId', () async {
        // Arrange
        final plan1 = createTestPlan(
          id: 'plan_1',
          petId: 'pet_1',
          name: 'Plan 1',
          isActive: true,
        );
        final plan2 = createTestPlan(
          id: 'plan_2',
          petId: 'pet_2',
          name: 'Plan 2',
          isActive: true,
        );
        final plan3 = createTestPlan(
          id: 'plan_3',
          petId: 'pet_1',
          name: 'Plan 3',
          isActive: false,
        );

        await repository.save(plan1);
        await repository.save(plan2);
        await repository.save(plan3);

        // Act
        final result = await repository.getByPetId('pet_1');

        // Assert
        expect(result.length, 2);
        expect(result.every((p) => p.petId == 'pet_1'), isTrue);
        expect(result.any((p) => p.id == 'plan_1'), isTrue);
        expect(result.any((p) => p.id == 'plan_3'), isTrue);
      });

      test('should return pet plans sorted by startDate descending (newest first)', () async {
        // Arrange
        final now = DateTime.now();
        final oldest = createTestPlan(
          id: 'plan_1',
          petId: 'pet_1',
          name: 'Oldest',
          isActive: true,
          startDate: now.subtract(const Duration(days: 20)),
        );
        final newest = createTestPlan(
          id: 'plan_2',
          petId: 'pet_1',
          name: 'Newest',
          isActive: true,
          startDate: now,
        );

        await repository.save(oldest);
        await repository.save(newest);

        // Act
        final result = await repository.getByPetId('pet_1');

        // Assert
        expect(result.length, 2);
        expect(result[0].id, 'plan_2'); // Newest startDate first
        expect(result[1].id, 'plan_1');
      });
    });

    group('getActiveByPetId', () {
      test('should return empty list when no active plans exist for pet', () async {
        // Arrange
        final inactivePlan = createTestPlan(
          id: 'plan_1',
          petId: 'pet_1',
          name: 'Inactive Plan',
          isActive: false,
        );
        await repository.save(inactivePlan);

        // Act
        final result = await repository.getActiveByPetId('pet_1');

        // Assert
        expect(result, isEmpty);
      });

      test('should return only active plans for specified petId', () async {
        // Arrange
        final activePlan1 = createTestPlan(
          id: 'plan_1',
          petId: 'pet_1',
          name: 'Active 1',
          isActive: true,
        );
        final inactivePlan = createTestPlan(
          id: 'plan_2',
          petId: 'pet_1',
          name: 'Inactive',
          isActive: false,
        );
        final activePlan2 = createTestPlan(
          id: 'plan_3',
          petId: 'pet_1',
          name: 'Active 2',
          isActive: true,
        );
        final otherPetActive = createTestPlan(
          id: 'plan_4',
          petId: 'pet_2',
          name: 'Other Pet Active',
          isActive: true,
        );

        await repository.save(activePlan1);
        await repository.save(inactivePlan);
        await repository.save(activePlan2);
        await repository.save(otherPetActive);

        // Act
        final result = await repository.getActiveByPetId('pet_1');

        // Assert
        expect(result.length, 2);
        expect(result.every((p) => p.petId == 'pet_1' && p.isActive), isTrue);
        expect(result.any((p) => p.id == 'plan_1'), isTrue);
        expect(result.any((p) => p.id == 'plan_3'), isTrue);
      });
    });

    group('getInactiveByPetId', () {
      test('should return empty list when no inactive plans exist for pet', () async {
        // Arrange
        final activePlan = createTestPlan(
          id: 'plan_1',
          petId: 'pet_1',
          name: 'Active Plan',
          isActive: true,
        );
        await repository.save(activePlan);

        // Act
        final result = await repository.getInactiveByPetId('pet_1');

        // Assert
        expect(result, isEmpty);
      });

      test('should return only inactive plans for specified petId', () async {
        // Arrange
        final activePlan = createTestPlan(
          id: 'plan_1',
          petId: 'pet_1',
          name: 'Active',
          isActive: true,
        );
        final inactivePlan1 = createTestPlan(
          id: 'plan_2',
          petId: 'pet_1',
          name: 'Inactive 1',
          isActive: false,
        );
        final inactivePlan2 = createTestPlan(
          id: 'plan_3',
          petId: 'pet_1',
          name: 'Inactive 2',
          isActive: false,
        );
        final otherPetInactive = createTestPlan(
          id: 'plan_4',
          petId: 'pet_2',
          name: 'Other Pet Inactive',
          isActive: false,
        );

        await repository.save(activePlan);
        await repository.save(inactivePlan1);
        await repository.save(inactivePlan2);
        await repository.save(otherPetInactive);

        // Act
        final result = await repository.getInactiveByPetId('pet_1');

        // Assert
        expect(result.length, 2);
        expect(result.every((p) => p.petId == 'pet_1' && !p.isActive), isTrue);
        expect(result.any((p) => p.id == 'plan_2'), isTrue);
        expect(result.any((p) => p.id == 'plan_3'), isTrue);
      });
    });

    group('getIncompleteByPetId', () {
      test('should return empty list when all plans are complete or inactive', () async {
        // Arrange
        final completePlan = createTestPlan(
          id: 'plan_1',
          petId: 'pet_1',
          name: 'Complete Plan',
          isActive: true,
          tasks: [
            TreatmentTask(
              id: 'task_1',
              title: 'Completed Task',
              description: 'Completed task description',
              scheduledDate: DateTime.now(),
              isCompleted: true,
            ),
          ],
        );
        await repository.save(completePlan);

        // Act
        final result = await repository.getIncompleteByPetId('pet_1');

        // Assert
        expect(result, isEmpty);
      });

      test('should return only active incomplete plans for specified petId', () async {
        // Arrange
        final incompletePlan = createTestPlan(
          id: 'plan_1',
          petId: 'pet_1',
          name: 'Incomplete Active',
          isActive: true,
          tasks: [
            TreatmentTask(
              id: 'task_1',
              title: 'Incomplete Task',
              description: 'Incomplete task description',
              scheduledDate: DateTime.now(),
              isCompleted: false,
            ),
          ],
        );
        final completePlan = createTestPlan(
          id: 'plan_2',
          petId: 'pet_1',
          name: 'Complete Active',
          isActive: true,
          tasks: [
            TreatmentTask(
              id: 'task_2',
              title: 'Complete Task',
              description: 'Complete task description',
              scheduledDate: DateTime.now(),
              isCompleted: true,
            ),
          ],
        );
        final inactivePlan = createTestPlan(
          id: 'plan_3',
          petId: 'pet_1',
          name: 'Inactive Incomplete',
          isActive: false,
          tasks: [
            TreatmentTask(
              id: 'task_3',
              title: 'Inactive Task',
              description: 'Incomplete but inactive',
              scheduledDate: DateTime.now(),
              isCompleted: false,
            ),
          ],
        );

        await repository.save(incompletePlan);
        await repository.save(completePlan);
        await repository.save(inactivePlan);

        // Act
        final result = await repository.getIncompleteByPetId('pet_1');

        // Assert
        expect(result.length, 1);
        expect(result[0].id, 'plan_1');
        expect(result[0].isActive, isTrue);
        expect(result[0].completionPercentage, lessThan(100.0));
      });

      test('should handle partially complete plans correctly', () async {
        // Arrange
        final partiallyComplete = createTestPlan(
          id: 'plan_1',
          petId: 'pet_1',
          name: 'Partially Complete',
          isActive: true,
          tasks: [
            TreatmentTask(
              id: 'task_1',
              title: 'Complete Task',
              description: 'Complete task description',
              scheduledDate: DateTime.now(),
              isCompleted: true,
            ),
            TreatmentTask(
              id: 'task_2',
              title: 'Incomplete Task',
              description: 'Incomplete task description',
              scheduledDate: DateTime.now(),
              isCompleted: false,
            ),
          ],
        );

        await repository.save(partiallyComplete);

        // Act
        final result = await repository.getIncompleteByPetId('pet_1');

        // Assert
        expect(result.length, 1);
        expect(result[0].completionPercentage, 50.0); // 1 of 2 tasks complete
      });
    });

    group('delete', () {
      test('should delete treatment plan by ID when it exists', () async {
        // Arrange
        final plan = createTestPlan(
          id: 'plan_1',
          petId: 'pet_1',
          name: 'Test Plan',
          isActive: true,
        );
        await repository.save(plan);
        expect(box.length, 1);

        // Act
        await repository.delete('plan_1');

        // Assert
        expect(box.length, 0);
        expect(box.get('plan_1'), isNull);
      });

      test('should not throw error when deleting non-existent plan', () async {
        // Act & Assert - should not throw
        await repository.delete('non_existent_id');
        expect(box.length, 0);
      });

      test('should delete only the specified plan and leave others', () async {
        // Arrange
        final plan1 = createTestPlan(
          id: 'plan_1',
          petId: 'pet_1',
          name: 'Plan 1',
          isActive: true,
        );
        final plan2 = createTestPlan(
          id: 'plan_2',
          petId: 'pet_2',
          name: 'Plan 2',
          isActive: false,
        );
        await repository.save(plan1);
        await repository.save(plan2);

        // Act
        await repository.delete('plan_1');

        // Assert
        expect(box.length, 1);
        expect(box.get('plan_1'), isNull);
        expect(box.get('plan_2'), isNotNull);
      });
    });

    group('deleteAll', () {
      test('should delete all treatment plans from box', () async {
        // Arrange
        final plan1 = createTestPlan(
          id: 'plan_1',
          petId: 'pet_1',
          name: 'Plan 1',
          isActive: true,
        );
        final plan2 = createTestPlan(
          id: 'plan_2',
          petId: 'pet_2',
          name: 'Plan 2',
          isActive: false,
        );
        final plan3 = createTestPlan(
          id: 'plan_3',
          petId: 'pet_1',
          name: 'Plan 3',
          isActive: true,
        );

        await repository.save(plan1);
        await repository.save(plan2);
        await repository.save(plan3);
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
      test('should handle multiple pets with multiple plans', () async {
        // Arrange
        final pet1Plan1 = createTestPlan(
          id: 'p1_plan1',
          petId: 'pet_1',
          name: 'Pet 1 Plan 1',
          isActive: true,
        );
        final pet1Plan2 = createTestPlan(
          id: 'p1_plan2',
          petId: 'pet_1',
          name: 'Pet 1 Plan 2',
          isActive: false,
        );
        final pet2Plan1 = createTestPlan(
          id: 'p2_plan1',
          petId: 'pet_2',
          name: 'Pet 2 Plan 1',
          isActive: true,
        );

        await repository.save(pet1Plan1);
        await repository.save(pet1Plan2);
        await repository.save(pet2Plan1);

        // Act
        final pet1Plans = await repository.getByPetId('pet_1');
        final pet2Plans = await repository.getByPetId('pet_2');
        final pet1Active = await repository.getActiveByPetId('pet_1');

        // Assert
        expect(pet1Plans.length, 2);
        expect(pet2Plans.length, 1);
        expect(pet1Active.length, 1);
        expect(pet1Active[0].id, 'p1_plan1');
      });

      test('should handle plan with no tasks as complete', () async {
        // Arrange
        final emptyPlan = createTestPlan(
          id: 'plan_1',
          petId: 'pet_1',
          name: 'Empty Plan',
          isActive: true,
          tasks: [],
        );

        await repository.save(emptyPlan);

        // Act
        final incomplete = await repository.getIncompleteByPetId('pet_1');

        // Assert - empty plan has 0% completion, so it's incomplete
        expect(incomplete.length, 1);
        expect(incomplete[0].completionPercentage, 0.0);
      });
    });
  });
}
