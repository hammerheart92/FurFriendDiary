// File: test/integration/treatment_plan_workflow_test.dart
// Coverage: Complete treatment plan workflow integration test
// Focus Areas:
// - Create treatment plan with multiple tasks → verify tasks in dashboard
// - Test task completion → validate progress tracking
// - Full data flow through Hive storage
// - Data persistence across simulated app restart
// - Task urgency calculations (overdue, today, upcoming)

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:fur_friend_diary/src/data/local/hive_manager.dart';
import 'package:fur_friend_diary/src/domain/models/pet_profile.dart';
import 'package:fur_friend_diary/src/domain/models/time_of_day_model.dart';
import 'package:fur_friend_diary/src/domain/models/protocols/treatment_plan.dart';
import 'package:uuid/uuid.dart';

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

/// Integration test for complete treatment plan workflow
///
/// This test validates the entire user flow from creating a treatment plan
/// with multiple tasks to tracking completion and verifying dashboard integration.
///
/// Test Flow:
/// 1. Setup: Initialize Hive, create test pet
/// 2. Create treatment plan with 3 tasks (medication, appointment, care)
/// 3. Verify plan saved to Hive correctly
/// 4. Verify initial progress: 0 of 3 tasks (0%)
/// 5. Complete first task
/// 6. Verify progress: 1 of 3 tasks (33%)
/// 7. Complete all tasks
/// 8. Mark plan as complete
/// 9. Verify completed plan removed from active list
/// 10. Verify data persists across simulated app restart
/// 11. Cleanup: Close Hive, delete test directory
void main() {
  group('Treatment Plan Workflow Integration Test', () {
    late Directory testDirectory;
    late Box<TreatmentPlan> treatmentPlanBox;
    late Box<PetProfile> petBox;
    final uuid = Uuid();

    setUp(() async {
      // Step 1: Create temporary directory for test Hive storage
      testDirectory = await Directory.systemTemp.createTemp('treatment_plan_test_');
      print('📁 Test directory: ${testDirectory.path}');

      // Step 2: Mock PathProvider to use test directory
      PathProviderPlatform.instance = MockPathProviderPlatform(testDirectory.path);

      // Step 3: Initialize Hive with test directory
      Hive.init(testDirectory.path);

      // Step 4: Register all required Hive adapters
      // This follows the same pattern as HiveManager._registerAdapters()
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(PetProfileAdapter());
      }
      if (!Hive.isAdapterRegistered(13)) {
        Hive.registerAdapter(TimeOfDayModelAdapter());
      }
      if (!Hive.isAdapterRegistered(27)) {
        Hive.registerAdapter(TreatmentPlanAdapter());
      }
      if (!Hive.isAdapterRegistered(28)) {
        Hive.registerAdapter(TreatmentTaskAdapter());
      }

      // Step 5: Open boxes (without encryption for testing simplicity)
      petBox = await Hive.openBox<PetProfile>(HiveManager.petProfileBoxName);
      treatmentPlanBox = await Hive.openBox<TreatmentPlan>(
        HiveManager.treatmentPlanBoxName,
      );

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

    test('complete treatment plan workflow: create → tasks → completion', () async {
      // ========================================================================
      // PHASE 1: CREATE TEST PET
      // ========================================================================
      print('\n🐕 PHASE 1: Creating test pet...');

      final today = DateTime.now();
      final birthdateFor2YearOldDog = today.subtract(Duration(days: 365 * 2));

      final testPet = PetProfile(
        name: 'Test Dog Recovery',
        species: 'dog',
        breed: 'Labrador Retriever',
        birthday: birthdateFor2YearOldDog,
        isActive: true,
      );

      // Save pet to Hive
      await petBox.put(testPet.id, testPet);

      // Verify save
      final savedPet = petBox.get(testPet.id);
      expect(savedPet, isNotNull, reason: 'Pet should be saved to Hive');
      expect(savedPet!.name, equals('Test Dog Recovery'));
      expect(savedPet.species, equals('dog'));

      print('✅ Test pet created: ${savedPet.name}');
      print('   Pet ID: ${savedPet.id}');

      // ========================================================================
      // PHASE 2: CREATE TREATMENT PLAN WITH 3 TASKS
      // ========================================================================
      print('\n📋 PHASE 2: Creating treatment plan with 3 tasks...');

      // Create treatment tasks
      final task1Medication = TreatmentTask(
        id: uuid.v4(),
        title: 'Administer pain medication',
        description: 'Give 1 tablet of Rimadyl with food',
        scheduledDate: today,
        scheduledTime: TimeOfDayModel(hour: 8, minute: 0),
        taskType: 'medication',
        notes: 'Morning dose - with breakfast',
        isCompleted: false,
      );

      final task2Appointment = TreatmentTask(
        id: uuid.v4(),
        title: 'Follow-up checkup',
        description: 'Post-surgery examination and stitch removal',
        scheduledDate: today.add(Duration(days: 7)),
        scheduledTime: TimeOfDayModel(hour: 10, minute: 30),
        taskType: 'appointment',
        notes: 'Bring all post-op paperwork',
        isCompleted: false,
      );

      final task3Care = TreatmentTask(
        id: uuid.v4(),
        title: 'Apply wound dressing',
        description: 'Clean surgical site and apply new bandage',
        scheduledDate: today,
        scheduledTime: TimeOfDayModel(hour: 20, minute: 0),
        taskType: 'care',
        notes: 'Use sterile gauze and medical tape',
        isCompleted: false,
      );

      // Create treatment plan
      final treatmentPlan = TreatmentPlan(
        id: uuid.v4(),
        petId: testPet.id,
        name: 'Post-Surgery Recovery Plan',
        description: 'Complete recovery plan following spay surgery',
        veterinarianName: 'Dr. Elena Popescu',
        startDate: today,
        endDate: today.add(Duration(days: 14)),
        tasks: [task1Medication, task2Appointment, task3Care],
        isActive: true,
        createdAt: today,
      );

      // Verify treatment plan structure
      expect(treatmentPlan.tasks.length, equals(3),
        reason: 'Plan should have 3 tasks');
      expect(treatmentPlan.isActive, isTrue,
        reason: 'Plan should be active');
      expect(treatmentPlan.completionPercentage, equals(0.0),
        reason: 'Initial completion should be 0%');

      print('✅ Treatment plan created: ${treatmentPlan.name}');
      print('   Plan ID: ${treatmentPlan.id}');
      print('   Tasks: ${treatmentPlan.tasks.length}');
      print('   Task 1: ${task1Medication.title} (${task1Medication.taskType})');
      print('   Task 2: ${task2Appointment.title} (${task2Appointment.taskType})');
      print('   Task 3: ${task3Care.title} (${task3Care.taskType})');

      // ========================================================================
      // PHASE 3: SAVE TREATMENT PLAN TO HIVE
      // ========================================================================
      print('\n💾 PHASE 3: Saving treatment plan to Hive...');

      await treatmentPlanBox.put(treatmentPlan.id, treatmentPlan);

      // Verify save
      final savedPlan = treatmentPlanBox.get(treatmentPlan.id);
      expect(savedPlan, isNotNull, reason: 'Plan should be saved to Hive');
      expect(savedPlan!.id, equals(treatmentPlan.id));
      expect(savedPlan.name, equals('Post-Surgery Recovery Plan'));
      expect(savedPlan.petId, equals(testPet.id));
      expect(savedPlan.veterinarianName, equals('Dr. Elena Popescu'));
      expect(savedPlan.tasks.length, equals(3));

      // Verify tasks preserved correctly
      expect(savedPlan.tasks[0].title, equals('Administer pain medication'));
      expect(savedPlan.tasks[0].taskType, equals('medication'));
      expect(savedPlan.tasks[0].isCompleted, isFalse);

      expect(savedPlan.tasks[1].title, equals('Follow-up checkup'));
      expect(savedPlan.tasks[1].taskType, equals('appointment'));
      expect(savedPlan.tasks[1].isCompleted, isFalse);

      expect(savedPlan.tasks[2].title, equals('Apply wound dressing'));
      expect(savedPlan.tasks[2].taskType, equals('care'));
      expect(savedPlan.tasks[2].isCompleted, isFalse);

      print('✅ Treatment plan saved to Hive');
      print('   Verification: All 3 tasks preserved correctly');

      // ========================================================================
      // PHASE 4: VERIFY ACTIVE TREATMENT PLANS QUERY
      // ========================================================================
      print('\n🔍 PHASE 4: Verifying active treatment plans query...');

      // Query active plans for this pet
      final activePlansForPet = treatmentPlanBox.values
          .where((plan) => plan.petId == testPet.id && plan.isActive)
          .toList();

      expect(activePlansForPet.length, equals(1),
        reason: 'Should have 1 active plan for this pet');
      expect(activePlansForPet[0].id, equals(treatmentPlan.id));

      print('✅ Active plans query working: ${activePlansForPet.length} plan(s) found');

      // ========================================================================
      // PHASE 5: VERIFY INITIAL PROGRESS (0 of 3 tasks)
      // ========================================================================
      print('\n📊 PHASE 5: Verifying initial progress...');

      final initialProgress = savedPlan.completionPercentage;
      final incompleteTasks = savedPlan.incompleteTasks;
      final completedTasks = savedPlan.completedTasks;

      expect(initialProgress, equals(0.0),
        reason: 'Initial completion should be 0%');
      expect(incompleteTasks.length, equals(3),
        reason: 'All 3 tasks should be incomplete');
      expect(completedTasks.length, equals(0),
        reason: 'No tasks should be completed');

      print('✅ Initial progress verified:');
      print('   Completion: ${initialProgress.toStringAsFixed(1)}%');
      print('   Incomplete tasks: ${incompleteTasks.length}');
      print('   Completed tasks: ${completedTasks.length}');

      // ========================================================================
      // PHASE 6: COMPLETE FIRST TASK
      // ========================================================================
      print('\n✅ PHASE 6: Completing first task (medication)...');

      // Mark first task as completed
      final completedTask1 = task1Medication.markCompleted(
        notes: 'Administered successfully at 8:15 AM with breakfast',
      );

      // Verify task completion
      expect(completedTask1.isCompleted, isTrue);
      expect(completedTask1.completedAt, isNotNull);
      expect(completedTask1.notes, contains('Administered successfully'));

      // Update task in plan
      final updatedPlanAfterTask1 = savedPlan.copyWith(
        tasks: savedPlan.tasks.map((task) {
          return task.id == completedTask1.id ? completedTask1 : task;
        }).toList(),
        updatedAt: DateTime.now(),
      );

      // Save updated plan
      await treatmentPlanBox.put(updatedPlanAfterTask1.id, updatedPlanAfterTask1);

      // Verify update
      final planAfterTask1 = treatmentPlanBox.get(treatmentPlan.id);
      expect(planAfterTask1, isNotNull);
      expect(planAfterTask1!.tasks[0].isCompleted, isTrue,
        reason: 'First task should be completed');
      expect(planAfterTask1.completionPercentage, closeTo(33.33, 0.1),
        reason: 'Completion should be ~33% (1 of 3 tasks)');

      print('✅ First task completed:');
      print('   Task: ${completedTask1.title}');
      print('   Completed at: ${completedTask1.completedAt}');
      print('   Progress: ${planAfterTask1.completionPercentage.toStringAsFixed(1)}%');

      // ========================================================================
      // PHASE 7: VERIFY PROGRESS AFTER FIRST COMPLETION (1 of 3 tasks)
      // ========================================================================
      print('\n📊 PHASE 7: Verifying progress after first completion...');

      final progressAfterTask1 = planAfterTask1.completionPercentage;
      final incompleteAfterTask1 = planAfterTask1.incompleteTasks;
      final completedAfterTask1 = planAfterTask1.completedTasks;

      expect(progressAfterTask1, closeTo(33.33, 0.1),
        reason: 'Progress should be ~33%');
      expect(incompleteAfterTask1.length, equals(2),
        reason: '2 tasks should remain incomplete');
      expect(completedAfterTask1.length, equals(1),
        reason: '1 task should be completed');

      // Verify incomplete tasks are sorted by scheduled date
      expect(incompleteAfterTask1[0].scheduledDate.isBefore(incompleteAfterTask1[1].scheduledDate) ||
          incompleteAfterTask1[0].scheduledDate.isAtSameMomentAs(incompleteAfterTask1[1].scheduledDate),
        isTrue,
        reason: 'Incomplete tasks should be sorted by date');

      print('✅ Progress after first completion:');
      print('   Completion: ${progressAfterTask1.toStringAsFixed(1)}%');
      print('   Incomplete: ${incompleteAfterTask1.length} tasks');
      print('   Completed: ${completedAfterTask1.length} task');

      // ========================================================================
      // PHASE 8: COMPLETE SECOND TASK
      // ========================================================================
      print('\n✅ PHASE 8: Completing second task (care)...');

      // Complete third task (care task - scheduled for today)
      final completedTask3 = task3Care.markCompleted(
        notes: 'Wound looks clean, healing well',
      );

      // Update plan with second completion
      final updatedPlanAfterTask2 = planAfterTask1.copyWith(
        tasks: planAfterTask1.tasks.map((task) {
          return task.id == completedTask3.id ? completedTask3 : task;
        }).toList(),
        updatedAt: DateTime.now(),
      );

      await treatmentPlanBox.put(updatedPlanAfterTask2.id, updatedPlanAfterTask2);

      // Verify update
      final planAfterTask2 = treatmentPlanBox.get(treatmentPlan.id);
      expect(planAfterTask2, isNotNull);
      expect(planAfterTask2!.completionPercentage, closeTo(66.67, 0.1),
        reason: 'Completion should be ~67% (2 of 3 tasks)');

      print('✅ Second task completed:');
      print('   Task: ${completedTask3.title}');
      print('   Progress: ${planAfterTask2.completionPercentage.toStringAsFixed(1)}%');

      // ========================================================================
      // PHASE 9: COMPLETE ALL REMAINING TASKS
      // ========================================================================
      print('\n✅ PHASE 9: Completing all remaining tasks...');

      // Complete the appointment task
      final completedTask2 = task2Appointment.markCompleted(
        notes: 'Stitches removed, recovery excellent',
      );

      // Update plan with all tasks completed
      final fullyCompletedPlan = planAfterTask2.copyWith(
        tasks: planAfterTask2.tasks.map((task) {
          return task.id == completedTask2.id ? completedTask2 : task;
        }).toList(),
        updatedAt: DateTime.now(),
      );

      await treatmentPlanBox.put(fullyCompletedPlan.id, fullyCompletedPlan);

      // Verify all tasks completed
      final planAllTasksComplete = treatmentPlanBox.get(treatmentPlan.id);
      expect(planAllTasksComplete, isNotNull);
      expect(planAllTasksComplete!.completionPercentage, equals(100.0),
        reason: 'Completion should be 100% (3 of 3 tasks)');
      expect(planAllTasksComplete.incompleteTasks.length, equals(0),
        reason: 'No incomplete tasks should remain');
      expect(planAllTasksComplete.completedTasks.length, equals(3),
        reason: 'All 3 tasks should be completed');

      print('✅ All tasks completed:');
      print('   Progress: ${planAllTasksComplete.completionPercentage.toStringAsFixed(1)}%');
      print('   Completed tasks: ${planAllTasksComplete.completedTasks.length}');

      // ========================================================================
      // PHASE 10: MARK ENTIRE PLAN AS COMPLETE
      // ========================================================================
      print('\n🎉 PHASE 10: Marking entire plan as complete...');

      // Mark plan as inactive (completed)
      final completedPlan = planAllTasksComplete.copyWith(
        isActive: false,
        updatedAt: DateTime.now(),
      );

      await treatmentPlanBox.put(completedPlan.id, completedPlan);

      // Verify plan marked as complete
      final finalPlan = treatmentPlanBox.get(treatmentPlan.id);
      expect(finalPlan, isNotNull);
      expect(finalPlan!.isActive, isFalse,
        reason: 'Plan should be marked as inactive');

      print('✅ Treatment plan marked as complete');
      print('   Active status: ${finalPlan.isActive}');

      // ========================================================================
      // PHASE 11: VERIFY COMPLETED PLAN REMOVED FROM ACTIVE LIST
      // ========================================================================
      print('\n🔍 PHASE 11: Verifying completed plan removed from active list...');

      // Query active plans for this pet
      final activePlansAfterCompletion = treatmentPlanBox.values
          .where((plan) => plan.petId == testPet.id && plan.isActive)
          .toList();

      expect(activePlansAfterCompletion.length, equals(0),
        reason: 'Should have no active plans after completion');

      // Query all plans (including inactive)
      final allPlansForPet = treatmentPlanBox.values
          .where((plan) => plan.petId == testPet.id)
          .toList();

      expect(allPlansForPet.length, equals(1),
        reason: 'Should still have 1 total plan (now inactive)');
      expect(allPlansForPet[0].isActive, isFalse);

      print('✅ Active list verified:');
      print('   Active plans: ${activePlansAfterCompletion.length}');
      print('   Total plans (all statuses): ${allPlansForPet.length}');

      // ========================================================================
      // PHASE 12: SIMULATE APP RESTART - VERIFY DATA PERSISTENCE
      // ========================================================================
      print('\n🔄 PHASE 12: Simulating app restart...');

      // Close and reopen boxes to simulate app restart
      await Hive.close();

      // Reopen boxes
      final reopenedPetBox = await Hive.openBox<PetProfile>(HiveManager.petProfileBoxName);
      final reopenedTreatmentPlanBox = await Hive.openBox<TreatmentPlan>(
        HiveManager.treatmentPlanBoxName,
      );

      // Verify pet profile persisted
      final persistedPet = reopenedPetBox.get(testPet.id);
      expect(persistedPet, isNotNull, reason: 'Pet should persist across restart');
      expect(persistedPet!.name, equals('Test Dog Recovery'));

      // Verify treatment plan persisted
      final persistedPlan = reopenedTreatmentPlanBox.get(treatmentPlan.id);
      expect(persistedPlan, isNotNull,
        reason: 'Treatment plan should persist across restart');
      expect(persistedPlan!.name, equals('Post-Surgery Recovery Plan'));
      expect(persistedPlan.tasks.length, equals(3));
      expect(persistedPlan.isActive, isFalse);
      expect(persistedPlan.completionPercentage, equals(100.0));

      // Verify all tasks persisted with completion status
      expect(persistedPlan.tasks.where((t) => t.isCompleted).length, equals(3),
        reason: 'All 3 tasks should be marked as completed');

      print('✅ Data persisted across simulated app restart');
      print('   Pet profile: ✓');
      print('   Treatment plan: ✓');
      print('   Tasks: ✓ (${persistedPlan.tasks.length} tasks, all completed)');

      // ========================================================================
      // PHASE 13: VALIDATE COMPLETE WORKFLOW
      // ========================================================================
      print('\n✅ PHASE 13: Workflow validation complete!');
      print('');
      print('📊 WORKFLOW SUMMARY:');
      print('─────────────────────────────────────────────────────────');
      print('1. Created test pet: ${persistedPet.name}');
      print('2. Created treatment plan: ${persistedPlan.name}');
      print('3. Added 3 tasks: medication, appointment, care');
      print('4. Initial progress: 0% (0 of 3 tasks)');
      print('5. Completed task 1: Progress 33% (1 of 3 tasks)');
      print('6. Completed task 2: Progress 67% (2 of 3 tasks)');
      print('7. Completed task 3: Progress 100% (3 of 3 tasks)');
      print('8. Marked plan as complete (inactive)');
      print('9. Verified removal from active list');
      print('10. Verified data persists across app restart');
      print('─────────────────────────────────────────────────────────');
      print('');
      print('🎉 INTEGRATION TEST PASSED: Complete treatment plan workflow validated!');
    });

    // ========================================================================
    // EDGE CASE TEST: Plan with no tasks
    // ========================================================================
    test('should handle plan with no tasks', () async {
      print('\n⚠️  EDGE CASE TEST: Plan with no tasks');

      // Create pet
      final testPet = PetProfile(
        name: 'Test Pet Empty Plan',
        species: 'cat',
        isActive: true,
      );
      await petBox.put(testPet.id, testPet);

      // Create plan with no tasks
      final emptyPlan = TreatmentPlan(
        id: uuid.v4(),
        petId: testPet.id,
        name: 'Empty Plan',
        description: 'Plan with no tasks',
        startDate: DateTime.now(),
        tasks: [], // No tasks
        isActive: true,
      );

      await treatmentPlanBox.put(emptyPlan.id, emptyPlan);

      // Verify handling
      final savedEmptyPlan = treatmentPlanBox.get(emptyPlan.id);
      expect(savedEmptyPlan, isNotNull);
      expect(savedEmptyPlan!.tasks.length, equals(0));
      expect(savedEmptyPlan.completionPercentage, equals(0.0),
        reason: 'Empty plan should have 0% completion');
      expect(savedEmptyPlan.incompleteTasks.length, equals(0));
      expect(savedEmptyPlan.completedTasks.length, equals(0));

      print('✅ Edge case handled: Empty plan has 0% completion');
    });

    // ========================================================================
    // EDGE CASE TEST: Calculate progress with multiple tasks
    // ========================================================================
    test('should calculate progress correctly with multiple tasks', () async {
      print('\n📊 TEST: Progress calculation with 5 tasks');

      // Create pet
      final testPet = PetProfile(
        name: 'Test Pet Progress',
        species: 'dog',
        isActive: true,
      );
      await petBox.put(testPet.id, testPet);

      final today = DateTime.now();

      // Create plan with 5 tasks
      final tasks = List.generate(5, (index) {
        return TreatmentTask(
          id: uuid.v4(),
          title: 'Task ${index + 1}',
          scheduledDate: today.add(Duration(days: index)),
          taskType: 'care',
          isCompleted: false,
        );
      });

      final multiTaskPlan = TreatmentPlan(
        id: uuid.v4(),
        petId: testPet.id,
        name: 'Multi-Task Plan',
        description: 'Plan with 5 tasks',
        startDate: today,
        tasks: tasks,
        isActive: true,
      );

      await treatmentPlanBox.put(multiTaskPlan.id, multiTaskPlan);

      // Complete tasks one by one and verify progress
      var currentPlan = multiTaskPlan;

      for (int i = 0; i < 5; i++) {
        // Complete task at index i
        final completedTask = currentPlan.tasks[i].markCompleted();
        final updatedTasks = List<TreatmentTask>.from(currentPlan.tasks);
        updatedTasks[i] = completedTask;

        currentPlan = currentPlan.copyWith(
          tasks: updatedTasks,
          updatedAt: DateTime.now(),
        );

        await treatmentPlanBox.put(currentPlan.id, currentPlan);

        // Verify progress
        final savedPlan = treatmentPlanBox.get(multiTaskPlan.id);
        final expectedProgress = ((i + 1) / 5.0) * 100;
        expect(savedPlan!.completionPercentage, closeTo(expectedProgress, 0.1),
          reason: 'Progress should be ${expectedProgress.toStringAsFixed(0)}% after completing ${i + 1} tasks');

        print('   Task ${i + 1} completed: ${savedPlan.completionPercentage.toStringAsFixed(1)}%');
      }

      print('✅ Progress calculation verified: 0% → 20% → 40% → 60% → 80% → 100%');
    });

    // ========================================================================
    // EDGE CASE TEST: Mixed urgency levels
    // ========================================================================
    test('should handle mixed urgency levels correctly', () async {
      print('\n⏰ TEST: Mixed urgency levels (overdue, today, upcoming)');

      // Create pet
      final testPet = PetProfile(
        name: 'Test Pet Urgency',
        species: 'dog',
        isActive: true,
      );
      await petBox.put(testPet.id, testPet);

      final today = DateTime.now();
      final yesterday = today.subtract(Duration(days: 1));
      final tomorrow = today.add(Duration(days: 1));

      // Create tasks with different urgency levels
      final overdueTask = TreatmentTask(
        id: uuid.v4(),
        title: 'Overdue Task',
        scheduledDate: yesterday,
        taskType: 'medication',
        isCompleted: false,
      );

      final todayTask = TreatmentTask(
        id: uuid.v4(),
        title: 'Today Task',
        scheduledDate: today,
        taskType: 'care',
        isCompleted: false,
      );

      final upcomingTask = TreatmentTask(
        id: uuid.v4(),
        title: 'Upcoming Task',
        scheduledDate: tomorrow,
        taskType: 'appointment',
        isCompleted: false,
      );

      final urgencyPlan = TreatmentPlan(
        id: uuid.v4(),
        petId: testPet.id,
        name: 'Urgency Test Plan',
        description: 'Plan with mixed urgency tasks',
        startDate: yesterday,
        tasks: [overdueTask, todayTask, upcomingTask],
        isActive: true,
      );

      await treatmentPlanBox.put(urgencyPlan.id, urgencyPlan);

      // Verify urgency indicators
      final savedPlan = treatmentPlanBox.get(urgencyPlan.id);
      expect(savedPlan, isNotNull);

      final overdue = savedPlan!.tasks.firstWhere((t) => t.title == 'Overdue Task');
      final todayT = savedPlan.tasks.firstWhere((t) => t.title == 'Today Task');
      final upcoming = savedPlan.tasks.firstWhere((t) => t.title == 'Upcoming Task');

      expect(overdue.isOverdue, isTrue,
        reason: 'Task scheduled yesterday should be overdue');
      expect(todayT.isDueToday, isTrue,
        reason: 'Task scheduled today should be due today');
      expect(upcoming.isOverdue, isFalse,
        reason: 'Task scheduled tomorrow should not be overdue');
      expect(upcoming.isDueToday, isFalse,
        reason: 'Task scheduled tomorrow should not be due today');

      print('✅ Urgency indicators working correctly:');
      print('   Overdue: ${overdue.title} (scheduled ${overdue.scheduledDate})');
      print('   Due Today: ${todayT.title} (scheduled ${todayT.scheduledDate})');
      print('   Upcoming: ${upcoming.title} (scheduled ${upcoming.scheduledDate})');
    });

    // ========================================================================
    // EDGE CASE TEST: Multiple active plans for same pet
    // ========================================================================
    test('should support multiple active plans for same pet', () async {
      print('\n📋 TEST: Multiple active plans for same pet');

      // Create pet
      final testPet = PetProfile(
        name: 'Test Pet Multi Plans',
        species: 'dog',
        isActive: true,
      );
      await petBox.put(testPet.id, testPet);

      final today = DateTime.now();

      // Create first plan
      final plan1 = TreatmentPlan(
        id: uuid.v4(),
        petId: testPet.id,
        name: 'Medication Plan',
        description: 'Daily medication regimen',
        startDate: today,
        tasks: [
          TreatmentTask(
            id: uuid.v4(),
            title: 'Morning Medication',
            scheduledDate: today,
            taskType: 'medication',
            isCompleted: false,
          ),
        ],
        isActive: true,
      );

      // Create second plan
      final plan2 = TreatmentPlan(
        id: uuid.v4(),
        petId: testPet.id,
        name: 'Physical Therapy Plan',
        description: 'Post-injury rehabilitation exercises',
        startDate: today,
        tasks: [
          TreatmentTask(
            id: uuid.v4(),
            title: 'Leg Exercises',
            scheduledDate: today,
            taskType: 'care',
            isCompleted: false,
          ),
        ],
        isActive: true,
      );

      // Save both plans
      await treatmentPlanBox.put(plan1.id, plan1);
      await treatmentPlanBox.put(plan2.id, plan2);

      // Query active plans for pet
      final activePlans = treatmentPlanBox.values
          .where((plan) => plan.petId == testPet.id && plan.isActive)
          .toList();

      expect(activePlans.length, equals(2),
        reason: 'Pet should have 2 active plans');
      expect(activePlans.any((p) => p.name == 'Medication Plan'), isTrue);
      expect(activePlans.any((p) => p.name == 'Physical Therapy Plan'), isTrue);

      print('✅ Multiple active plans supported:');
      print('   Plan 1: ${plan1.name}');
      print('   Plan 2: ${plan2.name}');
      print('   Total active plans: ${activePlans.length}');
    });

    // ========================================================================
    // EDGE CASE TEST: Task completion toggle (mark complete → mark incomplete)
    // ========================================================================
    test('should support task completion toggle', () async {
      print('\n🔄 TEST: Task completion toggle');

      // Create pet
      final testPet = PetProfile(
        name: 'Test Pet Toggle',
        species: 'cat',
        isActive: true,
      );
      await petBox.put(testPet.id, testPet);

      final today = DateTime.now();

      // Create plan with one task
      final task = TreatmentTask(
        id: uuid.v4(),
        title: 'Toggle Task',
        scheduledDate: today,
        taskType: 'care',
        isCompleted: false,
      );

      final plan = TreatmentPlan(
        id: uuid.v4(),
        petId: testPet.id,
        name: 'Toggle Test Plan',
        description: 'Test task completion toggle',
        startDate: today,
        tasks: [task],
        isActive: true,
      );

      await treatmentPlanBox.put(plan.id, plan);

      // Initial state: incomplete
      var currentPlan = treatmentPlanBox.get(plan.id)!;
      expect(currentPlan.tasks[0].isCompleted, isFalse);
      expect(currentPlan.completionPercentage, equals(0.0));

      // Mark as complete
      final completedTask = currentPlan.tasks[0].markCompleted();
      currentPlan = currentPlan.copyWith(
        tasks: [completedTask],
        updatedAt: DateTime.now(),
      );
      await treatmentPlanBox.put(currentPlan.id, currentPlan);

      // Verify completed
      currentPlan = treatmentPlanBox.get(plan.id)!;
      expect(currentPlan.tasks[0].isCompleted, isTrue);
      expect(currentPlan.tasks[0].completedAt, isNotNull);
      expect(currentPlan.completionPercentage, equals(100.0));

      print('   ✓ Task marked as complete');

      // Mark as incomplete by creating a new task (workaround for copyWith limitation)
      // Note: TreatmentTask.copyWith cannot properly set nullable fields to null
      // due to using the null-coalescing operator (??)
      final incompleteTask = TreatmentTask(
        id: currentPlan.tasks[0].id,
        title: currentPlan.tasks[0].title,
        description: currentPlan.tasks[0].description,
        scheduledDate: currentPlan.tasks[0].scheduledDate,
        scheduledTime: currentPlan.tasks[0].scheduledTime,
        taskType: currentPlan.tasks[0].taskType,
        notes: currentPlan.tasks[0].notes,
        isCompleted: false,
        completedAt: null, // Explicitly null
      );

      currentPlan = currentPlan.copyWith(
        tasks: [incompleteTask],
        updatedAt: DateTime.now(),
      );
      await treatmentPlanBox.put(currentPlan.id, currentPlan);

      // Verify incomplete
      currentPlan = treatmentPlanBox.get(plan.id)!;
      expect(currentPlan.tasks[0].isCompleted, isFalse);
      expect(currentPlan.tasks[0].completedAt, isNull);
      expect(currentPlan.completionPercentage, equals(0.0));

      print('   ✓ Task marked as incomplete');
      print('✅ Task completion toggle working correctly (using manual task recreation)');
    });

    // ========================================================================
    // EDGE CASE TEST: Tasks with different types
    // ========================================================================
    test('should handle all task types correctly', () async {
      print('\n🏷️  TEST: All task types');

      // Create pet
      final testPet = PetProfile(
        name: 'Test Pet Task Types',
        species: 'dog',
        isActive: true,
      );
      await petBox.put(testPet.id, testPet);

      final today = DateTime.now();

      // Create tasks of all types
      final taskTypes = ['medication', 'appointment', 'care', 'other'];
      final tasks = taskTypes.map((type) {
        return TreatmentTask(
          id: uuid.v4(),
          title: '${type[0].toUpperCase()}${type.substring(1)} Task',
          scheduledDate: today,
          taskType: type,
          isCompleted: false,
        );
      }).toList();

      final plan = TreatmentPlan(
        id: uuid.v4(),
        petId: testPet.id,
        name: 'Task Types Test Plan',
        description: 'Plan with all task types',
        startDate: today,
        tasks: tasks,
        isActive: true,
      );

      await treatmentPlanBox.put(plan.id, plan);

      // Verify all types saved correctly
      final savedPlan = treatmentPlanBox.get(plan.id)!;
      expect(savedPlan.tasks.length, equals(4));

      for (final taskType in taskTypes) {
        final taskOfType = savedPlan.tasks.firstWhere((t) => t.taskType == taskType);
        expect(taskOfType.taskType, equals(taskType));
        print('   ✓ ${taskType[0].toUpperCase()}${taskType.substring(1)} task verified');
      }

      print('✅ All task types handled correctly');
    });

    // ========================================================================
    // EDGE CASE TEST: Tasks sorted by scheduled date
    // ========================================================================
    test('should sort incomplete tasks by scheduled date', () async {
      print('\n📅 TEST: Task sorting by date');

      // Create pet
      final testPet = PetProfile(
        name: 'Test Pet Sorting',
        species: 'dog',
        isActive: true,
      );
      await petBox.put(testPet.id, testPet);

      final today = DateTime.now();

      // Create tasks with different dates (out of order)
      final tasks = [
        TreatmentTask(
          id: uuid.v4(),
          title: 'Task 3 - Day 5',
          scheduledDate: today.add(Duration(days: 5)),
          taskType: 'care',
          isCompleted: false,
        ),
        TreatmentTask(
          id: uuid.v4(),
          title: 'Task 1 - Today',
          scheduledDate: today,
          taskType: 'medication',
          isCompleted: false,
        ),
        TreatmentTask(
          id: uuid.v4(),
          title: 'Task 2 - Day 2',
          scheduledDate: today.add(Duration(days: 2)),
          taskType: 'appointment',
          isCompleted: false,
        ),
      ];

      final plan = TreatmentPlan(
        id: uuid.v4(),
        petId: testPet.id,
        name: 'Sorting Test Plan',
        description: 'Test task sorting',
        startDate: today,
        tasks: tasks,
        isActive: true,
      );

      await treatmentPlanBox.put(plan.id, plan);

      // Get incomplete tasks (should be sorted)
      final savedPlan = treatmentPlanBox.get(plan.id)!;
      final incompleteTasks = savedPlan.incompleteTasks;

      expect(incompleteTasks.length, equals(3));

      // Verify sorted by date
      expect(incompleteTasks[0].title, contains('Today'),
        reason: 'First task should be scheduled for today');
      expect(incompleteTasks[1].title, contains('Day 2'),
        reason: 'Second task should be scheduled for day 2');
      expect(incompleteTasks[2].title, contains('Day 5'),
        reason: 'Third task should be scheduled for day 5');

      print('✅ Tasks sorted correctly by scheduled date:');
      print('   1. ${incompleteTasks[0].title}');
      print('   2. ${incompleteTasks[1].title}');
      print('   3. ${incompleteTasks[2].title}');
    });
  });
}
