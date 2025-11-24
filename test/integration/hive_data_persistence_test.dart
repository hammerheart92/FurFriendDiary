import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:fur_friend_diary/src/domain/models/protocols/treatment_plan.dart';
import 'package:fur_friend_diary/src/domain/models/protocols/reminder_config.dart';
import 'package:fur_friend_diary/src/domain/models/protocols/vaccination_protocol.dart';
import 'package:fur_friend_diary/src/domain/models/protocols/deworming_protocol.dart';
import 'package:fur_friend_diary/src/domain/models/time_of_day_model.dart';

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

/// Integration test for Hive data persistence of Week 3 protocol models
///
/// This test suite verifies that all new domain models introduced in Week 3
/// for the smart scheduling feature properly persist to Hive storage across
/// simulated app restarts. Critical for ensuring users don't lose their
/// treatment plans, reminder configurations, and protocol schedules.
///
/// Models tested:
/// - TreatmentPlan (TypeId: 27) with nested TreatmentTask (TypeId: 28)
/// - ReminderConfig (TypeId: 29)
/// - VaccinationProtocol (TypeId: 22) with nested VaccinationStep (TypeId: 23)
/// - DewormingProtocol (TypeId: 25) with nested DewormingSchedule (TypeId: 26)
///
/// Test coverage: 10 comprehensive tests covering:
/// - Basic persistence for each model
/// - Nested object persistence (TreatmentTask, VaccinationStep, etc.)
/// - Null/optional field handling
/// - Large dataset performance (100+ records)
/// - Concurrent read/write operations
/// - Update operations after restart
/// - Delete operations and verification
/// - Special characters and edge case strings
void main() {
  late Directory testDirectory;
  late Box<TreatmentPlan> treatmentPlanBox;
  late Box<ReminderConfig> reminderConfigBox;
  late Box<VaccinationProtocol> vaccinationProtocolBox;
  late Box<DewormingProtocol> dewormingProtocolBox;

  setUp(() async {
    // Create temporary directory for isolated test
    testDirectory = await Directory.systemTemp.createTemp('hive_persistence_test_');

    // Set up mock path provider
    PathProviderPlatform.instance = MockPathProviderPlatform(testDirectory.path);

    // Initialize Hive with test directory
    Hive.init(testDirectory.path);

    // Register all required adapters (check if not already registered)
    if (!Hive.isAdapterRegistered(13)) {
      Hive.registerAdapter(TimeOfDayModelAdapter());
    }
    if (!Hive.isAdapterRegistered(22)) {
      Hive.registerAdapter(VaccinationProtocolAdapter());
    }
    if (!Hive.isAdapterRegistered(23)) {
      Hive.registerAdapter(VaccinationStepAdapter());
    }
    if (!Hive.isAdapterRegistered(24)) {
      Hive.registerAdapter(RecurringScheduleAdapter());
    }
    if (!Hive.isAdapterRegistered(25)) {
      Hive.registerAdapter(DewormingProtocolAdapter());
    }
    if (!Hive.isAdapterRegistered(26)) {
      Hive.registerAdapter(DewormingScheduleAdapter());
    }
    if (!Hive.isAdapterRegistered(27)) {
      Hive.registerAdapter(TreatmentPlanAdapter());
    }
    if (!Hive.isAdapterRegistered(28)) {
      Hive.registerAdapter(TreatmentTaskAdapter());
    }
    if (!Hive.isAdapterRegistered(29)) {
      Hive.registerAdapter(ReminderConfigAdapter());
    }

    // Open boxes without encryption (for testing)
    treatmentPlanBox = await Hive.openBox<TreatmentPlan>('treatment_plans');
    reminderConfigBox = await Hive.openBox<ReminderConfig>('reminder_configs');
    vaccinationProtocolBox = await Hive.openBox<VaccinationProtocol>('vaccination_protocols');
    dewormingProtocolBox = await Hive.openBox<DewormingProtocol>('deworming_protocols');
  });

  tearDown(() async {
    // Close all boxes
    await Hive.close();

    // Delete test directory
    if (await testDirectory.exists()) {
      await testDirectory.delete(recursive: true);
    }
  });

  group('Hive Data Persistence Integration Test', () {
    test('TreatmentPlan with nested TreatmentTasks persistence across restart', () async {
      print('\n💾 PHASE 1: Creating and saving TreatmentPlan with 3 tasks...');

      // Create treatment plan with 3 tasks
      final treatmentPlan = TreatmentPlan(
        id: 'plan-${DateTime.now().millisecondsSinceEpoch}',
        petId: 'pet-123',
        name: 'Post-Surgery Recovery Protocol',
        description: 'Recovery protocol after neutering surgery with antibiotics and pain management',
        veterinarianName: 'Dr. Elena Popescu',
        startDate: DateTime(2025, 11, 20),
        endDate: DateTime(2025, 12, 10),
        tasks: [
          TreatmentTask(
            id: 'task-1',
            title: 'Administer Amoxicillin 250mg',
            description: 'Give antibiotic with food',
            scheduledDate: DateTime(2025, 11, 20),
            scheduledTime: TimeOfDayModel(hour: 8, minute: 0),
            isCompleted: false,
            taskType: 'medication',
          ),
          TreatmentTask(
            id: 'task-2',
            title: 'Clean wound with saline solution',
            description: 'Gently clean surgical site',
            scheduledDate: DateTime(2025, 11, 21),
            scheduledTime: TimeOfDayModel(hour: 18, minute: 30),
            isCompleted: false,
            taskType: 'care',
          ),
          TreatmentTask(
            id: 'task-3',
            title: 'Follow-up appointment',
            description: 'Post-surgery checkup',
            scheduledDate: DateTime(2025, 11, 25),
            scheduledTime: TimeOfDayModel(hour: 10, minute: 15),
            isCompleted: false,
            taskType: 'appointment',
          ),
        ],
        isActive: true,
      );

      // Save to Hive
      await treatmentPlanBox.put(treatmentPlan.id, treatmentPlan);
      await treatmentPlanBox.flush();

      // Verify saved
      expect(treatmentPlanBox.length, equals(1), reason: 'Should have 1 treatment plan');
      expect(treatmentPlanBox.get(treatmentPlan.id)?.tasks.length, equals(3),
          reason: 'Plan should have 3 tasks');

      print('✅ Treatment plan saved with ${treatmentPlan.tasks.length} tasks');

      print('\n🔄 PHASE 2: Simulating app restart...');

      // Simulate app restart
      await treatmentPlanBox.close();
      treatmentPlanBox = await Hive.openBox<TreatmentPlan>('treatment_plans');

      print('✅ App restarted - boxes reopened');

      print('\n✅ PHASE 3: Verifying data persistence...');

      // Retrieve and verify
      final retrieved = treatmentPlanBox.get(treatmentPlan.id);

      expect(retrieved, isNotNull, reason: 'Treatment plan should persist');
      expect(retrieved!.id, equals(treatmentPlan.id), reason: 'ID should match');
      expect(retrieved.petId, equals('pet-123'), reason: 'PetId should match');
      expect(retrieved.name, equals('Post-Surgery Recovery Protocol'),
          reason: 'Name should match');
      expect(retrieved.description, contains('neutering surgery'),
          reason: 'Description should match');
      expect(retrieved.veterinarianName, equals('Dr. Elena Popescu'),
          reason: 'Veterinarian name should match');
      expect(retrieved.startDate, equals(DateTime(2025, 11, 20)),
          reason: 'Start date should match');
      expect(retrieved.endDate, equals(DateTime(2025, 12, 10)),
          reason: 'End date should match');
      expect(retrieved.isActive, isTrue, reason: 'Active status should match');

      // Verify nested tasks
      expect(retrieved.tasks.length, equals(3),
          reason: 'Should have 3 tasks after restart');

      final task1 = retrieved.tasks[0];
      expect(task1.id, equals('task-1'), reason: 'Task 1 ID should match');
      expect(task1.title, equals('Administer Amoxicillin 250mg'),
          reason: 'Task 1 title should match');
      expect(task1.description, equals('Give antibiotic with food'),
          reason: 'Task 1 description should match');
      expect(task1.scheduledDate, equals(DateTime(2025, 11, 20)),
          reason: 'Task 1 date should match');
      expect(task1.scheduledTime?.hour, equals(8),
          reason: 'Task 1 time hour should match');
      expect(task1.scheduledTime?.minute, equals(0),
          reason: 'Task 1 time minute should match');
      expect(task1.taskType, equals('medication'),
          reason: 'Task 1 type should match');
      expect(task1.isCompleted, isFalse,
          reason: 'Task 1 completion status should match');

      final task3 = retrieved.tasks[2];
      expect(task3.taskType, equals('appointment'),
          reason: 'Task 3 type should match');

      // Verify computed properties work after deserialization
      expect(retrieved.completionPercentage, equals(0.0),
          reason: 'Completion percentage should be 0%');
      expect(retrieved.incompleteTasks.length, equals(3),
          reason: 'All tasks should be incomplete');

      print('✅ All TreatmentPlan fields verified successfully');
      print('✅ All 3 nested TreatmentTask objects verified successfully');
    });

    test('ReminderConfig persistence with multiple reminder days', () async {
      print('\n💾 PHASE 1: Creating and saving ReminderConfig...');

      // Create reminder config with multiple reminder days
      final reminderConfig = ReminderConfig(
        id: 'reminder-${DateTime.now().millisecondsSinceEpoch}',
        petId: 'pet-456',
        eventType: 'vaccination',
        reminderDays: [1, 7, 14, 30], // 1 day, 1 week, 2 weeks, 1 month before
        isEnabled: true,
        customTitle: null,
        customMessage: null,
      );

      // Save to Hive
      await reminderConfigBox.put(reminderConfig.id, reminderConfig);
      await reminderConfigBox.flush();

      expect(reminderConfigBox.length, equals(1),
          reason: 'Should have 1 reminder config');

      print('✅ ReminderConfig saved with ${reminderConfig.reminderDays.length} reminder days');

      print('\n🔄 PHASE 2: Simulating app restart...');

      // Simulate app restart
      await reminderConfigBox.close();
      reminderConfigBox = await Hive.openBox<ReminderConfig>('reminder_configs');

      print('✅ App restarted - boxes reopened');

      print('\n✅ PHASE 3: Verifying data persistence...');

      // Retrieve and verify
      final retrieved = reminderConfigBox.get(reminderConfig.id);

      expect(retrieved, isNotNull, reason: 'ReminderConfig should persist');
      expect(retrieved!.id, equals(reminderConfig.id), reason: 'ID should match');
      expect(retrieved.petId, equals('pet-456'), reason: 'PetId should match');
      expect(retrieved.eventType, equals('vaccination'),
          reason: 'EventType should match');
      expect(retrieved.isEnabled, isTrue, reason: 'Enabled status should match');
      expect(retrieved.customTitle, isNull,
          reason: 'CustomTitle should be null for non-custom events');
      expect(retrieved.customMessage, isNull,
          reason: 'CustomMessage should be null');

      // Verify List<int> reminderDays preserved
      expect(retrieved.reminderDays.length, equals(4),
          reason: 'Should have 4 reminder days');
      expect(retrieved.reminderDays, equals([1, 7, 14, 30]),
          reason: 'ReminderDays should match in exact order');
      expect(retrieved.reminderDays[0], equals(1),
          reason: 'First reminder day should be 1');
      expect(retrieved.reminderDays[3], equals(30),
          reason: 'Last reminder day should be 30');

      // Verify computed properties
      expect(retrieved.earliestReminderDays, equals(30),
          reason: 'Earliest reminder should be 30 days');
      expect(retrieved.isCustom, isFalse,
          reason: 'Should not be custom event');

      print('✅ All ReminderConfig fields verified successfully');
      print('✅ List<int> reminderDays preserved correctly');
    });

    test('ReminderConfig with custom event type and messages', () async {
      print('\n💾 PHASE 1: Creating custom ReminderConfig...');

      final customReminder = ReminderConfig(
        id: 'custom-reminder-${DateTime.now().millisecondsSinceEpoch}',
        petId: 'pet-789',
        eventType: 'custom',
        reminderDays: [0, 1], // Day of event and 1 day before
        isEnabled: true,
        customTitle: 'Birthday Celebration',
        customMessage: 'Don\'t forget Max\'s birthday party! 🎉',
      );

      // Save to Hive
      await reminderConfigBox.put(customReminder.id, customReminder);
      await reminderConfigBox.flush();

      print('✅ Custom ReminderConfig saved');

      print('\n🔄 PHASE 2: Simulating app restart...');

      // Simulate app restart
      await reminderConfigBox.close();
      reminderConfigBox = await Hive.openBox<ReminderConfig>('reminder_configs');

      print('\n✅ PHASE 3: Verifying custom event persistence...');

      // Retrieve and verify
      final retrieved = reminderConfigBox.get(customReminder.id);

      expect(retrieved, isNotNull, reason: 'Custom reminder should persist');
      expect(retrieved!.eventType, equals('custom'),
          reason: 'EventType should be custom');
      expect(retrieved.customTitle, equals('Birthday Celebration'),
          reason: 'CustomTitle should persist');
      expect(retrieved.customMessage, equals('Don\'t forget Max\'s birthday party! 🎉'),
          reason: 'CustomMessage with emoji should persist');
      expect(retrieved.isCustom, isTrue,
          reason: 'Should be recognized as custom event');

      print('✅ Custom ReminderConfig with emoji verified successfully');
    });

    test('Null and optional fields handling across all models', () async {
      print('\n💾 PHASE 1: Creating entries with null optional fields...');

      // TreatmentTask with null optional fields
      final taskWithNulls = TreatmentTask(
        id: 'task-null-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Minimal task',
        description: null, // Optional - null
        scheduledDate: DateTime(2025, 12, 1),
        scheduledTime: null, // Optional - null
        isCompleted: false,
        completedAt: null, // Should be null when not completed
        notes: null, // Optional - null
        taskType: 'other',
      );

      final planWithNullFields = TreatmentPlan(
        id: 'plan-nulls-${DateTime.now().millisecondsSinceEpoch}',
        petId: 'pet-nulltest',
        name: 'Minimal Plan',
        description: 'Test plan',
        veterinarianName: null, // Optional - null
        startDate: DateTime(2025, 12, 1),
        endDate: null, // Optional - null (ongoing plan)
        tasks: [taskWithNulls],
        isActive: true,
      );

      // ReminderConfig with null custom fields
      final reminderWithNulls = ReminderConfig(
        id: 'reminder-nulls-${DateTime.now().millisecondsSinceEpoch}',
        petId: 'pet-nulltest',
        eventType: 'medication',
        reminderDays: [1],
        isEnabled: true,
        customTitle: null, // Should be null for non-custom events
        customMessage: null, // Should be null
      );

      // Save all to Hive
      await treatmentPlanBox.put(planWithNullFields.id, planWithNullFields);
      await reminderConfigBox.put(reminderWithNulls.id, reminderWithNulls);
      await treatmentPlanBox.flush();
      await reminderConfigBox.flush();

      print('✅ Entries with null fields saved');

      print('\n🔄 PHASE 2: Simulating app restart...');

      // Simulate app restart
      await treatmentPlanBox.close();
      await reminderConfigBox.close();
      treatmentPlanBox = await Hive.openBox<TreatmentPlan>('treatment_plans');
      reminderConfigBox = await Hive.openBox<ReminderConfig>('reminder_configs');

      print('\n✅ PHASE 3: Verifying null fields remain null...');

      // Retrieve and verify TreatmentPlan
      final retrievedPlan = treatmentPlanBox.get(planWithNullFields.id);
      expect(retrievedPlan, isNotNull);
      expect(retrievedPlan!.veterinarianName, isNull,
          reason: 'Null veterinarianName should remain null');
      expect(retrievedPlan.endDate, isNull,
          reason: 'Null endDate should remain null');

      // Verify nested task null fields
      final retrievedTask = retrievedPlan.tasks[0];
      expect(retrievedTask.description, isNull,
          reason: 'Null description should remain null');
      expect(retrievedTask.scheduledTime, isNull,
          reason: 'Null scheduledTime should remain null');
      expect(retrievedTask.completedAt, isNull,
          reason: 'Null completedAt should remain null');
      expect(retrievedTask.notes, isNull,
          reason: 'Null notes should remain null');

      // Retrieve and verify ReminderConfig
      final retrievedReminder = reminderConfigBox.get(reminderWithNulls.id);
      expect(retrievedReminder, isNotNull);
      expect(retrievedReminder!.customTitle, isNull,
          reason: 'Null customTitle should remain null');
      expect(retrievedReminder.customMessage, isNull,
          reason: 'Null customMessage should remain null');

      print('✅ All null optional fields verified - no conversion to empty strings or defaults');
    });

    test('Large dataset performance - 100+ records', () async {
      print('\n💾 PHASE 1: Creating 150 records (50 plans with 150 tasks, 100 reminders)...');

      final startTime = DateTime.now();

      // Create 50 TreatmentPlans with 3 tasks each (150 total tasks)
      for (int i = 0; i < 50; i++) {
        final plan = TreatmentPlan(
          id: 'plan-$i',
          petId: 'pet-${i % 10}', // 10 different pets
          name: 'Treatment Plan $i',
          description: 'Description for plan $i',
          startDate: DateTime(2025, 11, 20).add(Duration(days: i)),
          tasks: [
            TreatmentTask(
              id: 'plan-$i-task-1',
              title: 'Task 1 for plan $i',
              scheduledDate: DateTime(2025, 11, 21).add(Duration(days: i)),
              taskType: 'medication',
            ),
            TreatmentTask(
              id: 'plan-$i-task-2',
              title: 'Task 2 for plan $i',
              scheduledDate: DateTime(2025, 11, 22).add(Duration(days: i)),
              taskType: 'care',
            ),
            TreatmentTask(
              id: 'plan-$i-task-3',
              title: 'Task 3 for plan $i',
              scheduledDate: DateTime(2025, 11, 23).add(Duration(days: i)),
              taskType: 'appointment',
            ),
          ],
          isActive: true,
        );
        await treatmentPlanBox.put(plan.id, plan);
      }

      // Create 100 ReminderConfigs
      for (int i = 0; i < 100; i++) {
        final reminder = ReminderConfig(
          id: 'reminder-$i',
          petId: 'pet-${i % 10}',
          eventType: ['vaccination', 'deworming', 'appointment', 'medication'][i % 4],
          reminderDays: [1, 7, 14],
          isEnabled: i % 3 != 0, // ~67% enabled
        );
        await reminderConfigBox.put(reminder.id, reminder);
      }

      await treatmentPlanBox.flush();
      await reminderConfigBox.flush();

      final saveTime = DateTime.now().difference(startTime);
      print('✅ Created 50 plans (150 tasks) and 100 reminders in ${saveTime.inMilliseconds}ms');

      print('\n🔄 PHASE 2: Simulating app restart...');

      // Simulate app restart
      await treatmentPlanBox.close();
      await reminderConfigBox.close();

      final reopenStart = DateTime.now();
      treatmentPlanBox = await Hive.openBox<TreatmentPlan>('treatment_plans');
      reminderConfigBox = await Hive.openBox<ReminderConfig>('reminder_configs');
      final reopenTime = DateTime.now().difference(reopenStart);

      print('✅ Boxes reopened in ${reopenTime.inMilliseconds}ms');

      print('\n✅ PHASE 3: Verifying large dataset integrity...');

      // Verify counts
      expect(treatmentPlanBox.length, equals(50),
          reason: 'Should have 50 treatment plans');
      expect(reminderConfigBox.length, equals(100),
          reason: 'Should have 100 reminder configs');

      // Verify specific records
      final plan25 = treatmentPlanBox.get('plan-25');
      expect(plan25, isNotNull, reason: 'Plan 25 should exist');
      expect(plan25!.tasks.length, equals(3),
          reason: 'Plan 25 should have 3 tasks');
      expect(plan25.name, equals('Treatment Plan 25'),
          reason: 'Plan 25 name should match');

      final reminder75 = reminderConfigBox.get('reminder-75');
      expect(reminder75, isNotNull, reason: 'Reminder 75 should exist');
      expect(reminder75!.eventType, equals(['vaccination', 'deworming', 'appointment', 'medication'][75 % 4]),
          reason: 'Reminder 75 event type should match');

      // Count total tasks across all plans
      int totalTasks = 0;
      for (final plan in treatmentPlanBox.values) {
        totalTasks += plan.tasks.length;
      }
      expect(totalTasks, equals(150),
          reason: 'Should have 150 total tasks across all plans');

      final totalTime = DateTime.now().difference(startTime);
      print('✅ Large dataset verified successfully in ${totalTime.inSeconds}s');
      expect(totalTime.inSeconds, lessThan(10),
          reason: 'Full operation should complete in <10 seconds');
    });

    test('Data modification after restart - mark task as completed', () async {
      print('\n💾 PHASE 1: Creating TreatmentPlan with incomplete task...');

      final plan = TreatmentPlan(
        id: 'plan-modify-${DateTime.now().millisecondsSinceEpoch}',
        petId: 'pet-modify',
        name: 'Plan to Modify',
        description: 'Test modification persistence',
        startDate: DateTime(2025, 11, 20),
        tasks: [
          TreatmentTask(
            id: 'task-modify',
            title: 'Task to be completed',
            scheduledDate: DateTime(2025, 11, 21),
            isCompleted: false,
            completedAt: null,
            taskType: 'medication',
          ),
        ],
        isActive: true,
      );

      await treatmentPlanBox.put(plan.id, plan);
      await treatmentPlanBox.flush();

      expect(plan.tasks[0].isCompleted, isFalse,
          reason: 'Task should initially be incomplete');

      print('✅ Plan created with incomplete task');

      print('\n🔄 PHASE 2: Simulating app restart...');

      // Simulate app restart
      await treatmentPlanBox.close();
      treatmentPlanBox = await Hive.openBox<TreatmentPlan>('treatment_plans');

      print('✅ App restarted');

      print('\n🔧 PHASE 3: Modifying task to mark as completed...');

      // Retrieve, modify, and save
      final retrievedPlan = treatmentPlanBox.get(plan.id);
      expect(retrievedPlan, isNotNull);

      final completionTime = DateTime.now();
      final modifiedTask = retrievedPlan!.tasks[0].copyWith(
        isCompleted: true,
        completedAt: completionTime,
        notes: 'Completed successfully',
      );

      final modifiedPlan = retrievedPlan.copyWith(
        tasks: [modifiedTask],
      );

      await treatmentPlanBox.put(modifiedPlan.id, modifiedPlan);
      await treatmentPlanBox.flush();

      print('✅ Task marked as completed and saved');

      print('\n🔄 PHASE 4: Simulating another app restart...');

      // Simulate another restart
      await treatmentPlanBox.close();
      treatmentPlanBox = await Hive.openBox<TreatmentPlan>('treatment_plans');

      print('\n✅ PHASE 5: Verifying modification persisted...');

      // Verify modification persisted
      final finalPlan = treatmentPlanBox.get(modifiedPlan.id);
      expect(finalPlan, isNotNull);
      expect(finalPlan!.tasks[0].isCompleted, isTrue,
          reason: 'Task completion status should persist');
      // Compare DateTime at millisecond precision (Hive only stores milliseconds)
      expect(
          finalPlan.tasks[0].completedAt?.millisecondsSinceEpoch,
          equals(completionTime.millisecondsSinceEpoch),
          reason: 'Completion time should persist');
      expect(finalPlan.tasks[0].notes, equals('Completed successfully'),
          reason: 'Notes should persist');

      // Verify other fields unchanged
      expect(finalPlan.name, equals('Plan to Modify'),
          reason: 'Plan name should be unchanged');
      expect(finalPlan.tasks[0].title, equals('Task to be completed'),
          reason: 'Task title should be unchanged');

      print('✅ Modification verified - updated fields persisted, other fields unchanged');
    });

    test('Delete operations and verification', () async {
      print('\n💾 PHASE 1: Creating 5 ReminderConfigs...');

      // Create 5 reminder configs
      for (int i = 1; i <= 5; i++) {
        final reminder = ReminderConfig(
          id: 'config-$i',
          petId: 'pet-delete-test',
          eventType: 'vaccination',
          reminderDays: [i],
          isEnabled: true,
        );
        await reminderConfigBox.put(reminder.id, reminder);
      }
      await reminderConfigBox.flush();

      expect(reminderConfigBox.length, equals(5),
          reason: 'Should have 5 reminder configs');

      print('✅ 5 ReminderConfigs created');

      print('\n🔧 PHASE 2: Deleting config-3...');

      // Delete config-3
      await reminderConfigBox.delete('config-3');
      await reminderConfigBox.flush();

      expect(reminderConfigBox.length, equals(4),
          reason: 'Should have 4 configs after deletion');
      expect(reminderConfigBox.get('config-3'), isNull,
          reason: 'config-3 should be deleted');

      print('✅ config-3 deleted');

      print('\n🔄 PHASE 3: Simulating app restart...');

      // Simulate app restart
      await reminderConfigBox.close();
      reminderConfigBox = await Hive.openBox<ReminderConfig>('reminder_configs');

      print('\n✅ PHASE 4: Verifying deletion persisted...');

      // Verify deletion persisted
      expect(reminderConfigBox.length, equals(4),
          reason: 'Should still have 4 configs after restart');
      expect(reminderConfigBox.get('config-3'), isNull,
          reason: 'config-3 should still be deleted after restart');

      // Verify other configs still exist
      expect(reminderConfigBox.get('config-1'), isNotNull,
          reason: 'config-1 should still exist');
      expect(reminderConfigBox.get('config-2'), isNotNull,
          reason: 'config-2 should still exist');
      expect(reminderConfigBox.get('config-4'), isNotNull,
          reason: 'config-4 should still exist');
      expect(reminderConfigBox.get('config-5'), isNotNull,
          reason: 'config-5 should still exist');

      print('✅ Deletion persisted - correct entry deleted, other entries unaffected');
    });

    test('Special characters and edge case strings', () async {
      print('\n💾 PHASE 1: Creating entries with special characters...');

      // TreatmentTask with special characters and emojis
      final taskWithSpecialChars = TreatmentTask(
        id: 'task-special-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Administer medication "Amoxicillin" (250mg) - Morning & Evening',
        description: 'Give with food\nDosage: 1/2 tablet\n@ 8:00 AM & 8:00 PM',
        scheduledDate: DateTime(2025, 12, 25),
        notes: 'Important: Don\'t skip doses! Contact vet if vomiting occurs.\n\n'
            'Side effects to watch for:\n'
            '• Diarrhea\n'
            '• Loss of appetite\n'
            '• Allergic reaction (rare)',
        taskType: 'medication',
      );

      final planWithSpecialChars = TreatmentPlan(
        id: 'plan-special-${DateTime.now().millisecondsSinceEpoch}',
        petId: 'pet-special',
        name: 'Post-Op Recovery: "Major Surgery" Protocol',
        description: 'Treatment for pet after surgery @ "VetClinic+" facility\n\n'
            'Protocol includes:\n'
            '1. Pain management (Rimadyl™)\n'
            '2. Antibiotics (Amoxicillin/Clavulanate 250mg)\n'
            '3. Wound care\n\n'
            'Follow-up: 2025-12-30',
        veterinarianName: 'Dr. Maria Ionescu-Popescu',
        startDate: DateTime(2025, 11, 20),
        tasks: [taskWithSpecialChars],
        isActive: true,
      );

      // ReminderConfig with emojis and special characters
      final reminderWithEmojis = ReminderConfig(
        id: 'reminder-emoji-${DateTime.now().millisecondsSinceEpoch}',
        petId: 'pet-emoji',
        eventType: 'custom',
        reminderDays: [0, 1, 7],
        isEnabled: true,
        customTitle: 'Vaccination Reminder 💉',
        customMessage: 'Don\'t forget! 🔔\n\n'
            'Next appointment: 2025-12-25 @ 10:00 AM\n'
            'Location: Veterinary Clinic "PetCare+"\n'
            'Bring: Vaccine card 📋\n\n'
            'Important: Fast pet 12h before visit! 🚫🍖',
      );

      // Save all to Hive
      await treatmentPlanBox.put(planWithSpecialChars.id, planWithSpecialChars);
      await reminderConfigBox.put(reminderWithEmojis.id, reminderWithEmojis);
      await treatmentPlanBox.flush();
      await reminderConfigBox.flush();

      print('✅ Entries with special characters and emojis saved');

      print('\n🔄 PHASE 2: Simulating app restart...');

      // Simulate app restart
      await treatmentPlanBox.close();
      await reminderConfigBox.close();
      treatmentPlanBox = await Hive.openBox<TreatmentPlan>('treatment_plans');
      reminderConfigBox = await Hive.openBox<ReminderConfig>('reminder_configs');

      print('\n✅ PHASE 3: Verifying special characters preserved exactly...');

      // Retrieve and verify TreatmentPlan
      final retrievedPlan = treatmentPlanBox.get(planWithSpecialChars.id);
      expect(retrievedPlan, isNotNull);
      expect(retrievedPlan!.name, equals('Post-Op Recovery: "Major Surgery" Protocol'),
          reason: 'Quotes in name should be preserved');
      expect(retrievedPlan.description, contains('@ "VetClinic+"'),
          reason: '@ symbol and quotes should be preserved');
      expect(retrievedPlan.description, contains('Rimadyl™'),
          reason: 'Trademark symbol should be preserved');
      expect(retrievedPlan.description, contains('\n'),
          reason: 'Newlines should be preserved');
      expect(retrievedPlan.veterinarianName, equals('Dr. Maria Ionescu-Popescu'),
          reason: 'Hyphen in name should be preserved');

      // Verify task special characters
      final retrievedTask = retrievedPlan.tasks[0];
      expect(retrievedTask.title, equals('Administer medication "Amoxicillin" (250mg) - Morning & Evening'),
          reason: 'Quotes, parentheses, hyphen, & should be preserved');
      expect(retrievedTask.description, contains('@ 8:00 AM & 8:00 PM'),
          reason: '@ and & symbols should be preserved');
      expect(retrievedTask.notes, contains('Don\'t skip'),
          reason: 'Apostrophe should be preserved');
      expect(retrievedTask.notes, contains('•'),
          reason: 'Bullet point character should be preserved');

      // Retrieve and verify ReminderConfig with emojis
      final retrievedReminder = reminderConfigBox.get(reminderWithEmojis.id);
      expect(retrievedReminder, isNotNull);
      expect(retrievedReminder!.customTitle, equals('Vaccination Reminder 💉'),
          reason: 'Emoji in title should be preserved');
      expect(retrievedReminder.customMessage, contains('🔔'),
          reason: 'Bell emoji should be preserved');
      expect(retrievedReminder.customMessage, contains('📋'),
          reason: 'Clipboard emoji should be preserved');
      expect(retrievedReminder.customMessage, contains('🚫🍖'),
          reason: 'Multiple emojis should be preserved');
      expect(retrievedReminder.customMessage, contains('@ 10:00 AM'),
          reason: '@ symbol should be preserved');
      expect(retrievedReminder.customMessage, contains('"PetCare+"'),
          reason: 'Quotes should be preserved');
      expect(retrievedReminder.customMessage, contains('\n\n'),
          reason: 'Multiple newlines should be preserved');

      print('✅ All special characters verified:');
      print('  ✓ Unicode characters (emojis)');
      print('  ✓ Special punctuation (quotes, parentheses, hyphens, @, &)');
      print('  ✓ Multi-line strings');
      print('  ✓ Bullet points');
      print('  ✓ Trademark symbols');
      print('  ✓ No encoding/decoding issues');
    });

    test('Concurrent read/write operations', () async {
      print('\n💾 PHASE 1: Creating initial TreatmentPlan with 5 tasks...');

      final plan = TreatmentPlan(
        id: 'plan-concurrent',
        petId: 'pet-concurrent',
        name: 'Concurrent Test Plan',
        description: 'Testing concurrent operations',
        startDate: DateTime(2025, 11, 20),
        tasks: [
          for (int i = 1; i <= 5; i++)
            TreatmentTask(
              id: 'task-$i',
              title: 'Task $i',
              scheduledDate: DateTime(2025, 11, 20 + i),
              isCompleted: false,
              taskType: 'medication',
            ),
        ],
        isActive: true,
      );

      await treatmentPlanBox.put(plan.id, plan);
      await treatmentPlanBox.flush();

      print('✅ Initial plan created with 5 tasks');

      print('\n🔧 PHASE 2: Performing concurrent operations...');

      // Perform concurrent operations
      final futures = <Future>[];

      // Future 1: Read the plan
      futures.add(Future(() async {
        final readPlan = treatmentPlanBox.get('plan-concurrent');
        expect(readPlan, isNotNull, reason: 'Should be able to read during concurrent ops');
        return readPlan;
      }));

      // Future 2: Update task 1 to completed
      futures.add(Future(() async {
        final planToUpdate = treatmentPlanBox.get('plan-concurrent');
        if (planToUpdate != null) {
          final updatedTask1 = planToUpdate.tasks[0].copyWith(
            isCompleted: true,
            completedAt: DateTime.now(),
          );
          final updatedTasks = [...planToUpdate.tasks];
          updatedTasks[0] = updatedTask1;
          final updatedPlan = planToUpdate.copyWith(tasks: updatedTasks);
          await treatmentPlanBox.put('plan-concurrent', updatedPlan);
        }
      }));

      // Future 3: Add new task 6
      futures.add(Future(() async {
        await Future.delayed(Duration(milliseconds: 10));
        final planToUpdate = treatmentPlanBox.get('plan-concurrent');
        if (planToUpdate != null) {
          final newTask = TreatmentTask(
            id: 'task-6',
            title: 'Task 6 (added concurrently)',
            scheduledDate: DateTime(2025, 11, 26),
            isCompleted: false,
            taskType: 'care',
          );
          final updatedPlan = planToUpdate.copyWith(
            tasks: [...planToUpdate.tasks, newTask],
          );
          await treatmentPlanBox.put('plan-concurrent', updatedPlan);
        }
      }));

      // Future 4: Mark task 2 as completed
      futures.add(Future(() async {
        await Future.delayed(Duration(milliseconds: 20));
        final planToUpdate = treatmentPlanBox.get('plan-concurrent');
        if (planToUpdate != null) {
          final taskIndex = planToUpdate.tasks.indexWhere((t) => t.id == 'task-2');
          if (taskIndex != -1) {
            final updatedTask2 = planToUpdate.tasks[taskIndex].copyWith(
              isCompleted: true,
              completedAt: DateTime.now(),
            );
            final updatedTasks = [...planToUpdate.tasks];
            updatedTasks[taskIndex] = updatedTask2;
            final updatedPlan = planToUpdate.copyWith(tasks: updatedTasks);
            await treatmentPlanBox.put('plan-concurrent', updatedPlan);
          }
        }
      }));

      // Wait for all futures
      await Future.wait(futures);
      await treatmentPlanBox.flush();

      print('✅ All concurrent operations completed');

      print('\n🔄 PHASE 3: Simulating app restart...');

      // Simulate app restart
      await treatmentPlanBox.close();
      treatmentPlanBox = await Hive.openBox<TreatmentPlan>('treatment_plans');

      print('\n✅ PHASE 4: Verifying final state after concurrent operations...');

      // Retrieve final plan
      final finalPlan = treatmentPlanBox.get('plan-concurrent');
      expect(finalPlan, isNotNull, reason: 'Plan should still exist');

      // Note: Due to race conditions, we can only verify that:
      // 1. No data corruption occurred
      // 2. The plan still exists and is valid
      // 3. Some updates were applied
      // We cannot guarantee which update "won" in the concurrent scenario

      expect(finalPlan!.id, equals('plan-concurrent'),
          reason: 'Plan ID should be intact');
      expect(finalPlan.petId, equals('pet-concurrent'),
          reason: 'PetId should be intact');
      expect(finalPlan.tasks.isNotEmpty, isTrue,
          reason: 'Should have at least some tasks');

      // Check for no duplicate task IDs (data corruption check)
      final taskIds = finalPlan.tasks.map((t) => t.id).toSet();
      expect(taskIds.length, equals(finalPlan.tasks.length),
          reason: 'No duplicate task IDs - no data corruption');

      print('✅ Concurrent operations verified:');
      print('  ✓ No data corruption from concurrent writes');
      print('  ✓ Plan integrity maintained');
      print('  ✓ Final state: ${finalPlan.tasks.length} tasks');
      print('  Note: Concurrent updates may have overwritten each other (expected behavior)');
    });

    test('VaccinationProtocol persistence with nested steps', () async {
      print('\n💾 PHASE 1: Creating VaccinationProtocol with vaccination steps...');

      final protocol = VaccinationProtocol(
        id: 'protocol-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Canine Core Vaccination Protocol (Romania)',
        species: 'dog',
        description: 'Standard vaccination protocol for dogs in Romania following EU guidelines',
        isCustom: false,
        region: 'RO',
        steps: [
          VaccinationStep(
            vaccineName: 'DHPPiL',
            ageInWeeks: 6, // 6 weeks
            notes: 'First dose - Core vaccines for Distemper, Hepatitis, Parvo, Parainfluenza, Lepto',
            isRequired: true,
            recurring: RecurringSchedule(
              intervalMonths: 12,
              indefinitely: true,
            ),
          ),
          VaccinationStep(
            vaccineName: 'DHPPiL',
            ageInWeeks: 10, // 10 weeks
            intervalDays: 28, // 4 weeks after first dose
            notes: 'Second dose - booster',
            isRequired: true,
          ),
          VaccinationStep(
            vaccineName: 'Rabies',
            ageInWeeks: 12, // 12 weeks
            notes: 'Rabies vaccination - legally required in Romania',
            isRequired: true,
            recurring: RecurringSchedule(
              intervalMonths: 36, // Every 3 years
              indefinitely: true,
            ),
          ),
        ],
      );

      await vaccinationProtocolBox.put(protocol.id, protocol);
      await vaccinationProtocolBox.flush();

      print('✅ VaccinationProtocol saved with ${protocol.steps.length} steps');

      print('\n🔄 PHASE 2: Simulating app restart...');

      await vaccinationProtocolBox.close();
      vaccinationProtocolBox = await Hive.openBox<VaccinationProtocol>('vaccination_protocols');

      print('\n✅ PHASE 3: Verifying VaccinationProtocol persistence...');

      final retrieved = vaccinationProtocolBox.get(protocol.id);
      expect(retrieved, isNotNull, reason: 'VaccinationProtocol should persist');
      expect(retrieved!.name, equals('Canine Core Vaccination Protocol (Romania)'));
      expect(retrieved.species, equals('dog'));
      expect(retrieved.region, equals('RO'));
      expect(retrieved.isCustom, isFalse);
      expect(retrieved.steps.length, equals(3), reason: 'Should have 3 vaccination steps');

      // Verify first step
      final step1 = retrieved.steps[0];
      expect(step1.vaccineName, equals('DHPPiL'));
      expect(step1.ageInWeeks, equals(6));
      expect(step1.isRequired, isTrue);
      expect(step1.recurring, isNotNull);
      expect(step1.recurring!.intervalMonths, equals(12));

      // Verify second step
      final step2 = retrieved.steps[1];
      expect(step2.intervalDays, equals(28));

      // Verify third step (Rabies)
      final step3 = retrieved.steps[2];
      expect(step3.vaccineName, equals('Rabies'));
      expect(step3.notes, contains('legally required'));
      expect(step3.recurring, isNotNull);
      expect(step3.recurring!.intervalMonths, equals(36));

      print('✅ VaccinationProtocol with nested steps verified successfully');
    });

    test('DewormingProtocol persistence with recurring schedules', () async {
      print('\n💾 PHASE 1: Creating DewormingProtocol...');

      final protocol = DewormingProtocol(
        id: 'deworming-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Canine Standard Deworming Protocol',
        species: 'dog',
        description: 'Standard deworming protocol for dogs - internal and external parasites',
        isCustom: false,
        region: 'RO',
        schedules: [
          DewormingSchedule(
            dewormingType: 'internal',
            ageInWeeks: 2, // 2 weeks
            productName: 'Milbemax',
            notes: 'First internal deworming',
            recurring: RecurringSchedule(
              intervalMonths: 3, // Every 3 months
              indefinitely: true,
            ),
          ),
          DewormingSchedule(
            dewormingType: 'internal',
            ageInWeeks: 4, // 4 weeks
            intervalDays: 14, // 2 weeks after first dose
            productName: 'Milbemax',
            notes: 'Second internal deworming',
          ),
          DewormingSchedule(
            dewormingType: 'external',
            ageInWeeks: 8, // 8 weeks
            productName: 'Bravecto',
            notes: 'External parasites (fleas/ticks) - start at 8 weeks',
            recurring: RecurringSchedule(
              intervalMonths: 1, // Monthly
              indefinitely: true,
            ),
          ),
        ],
      );

      await dewormingProtocolBox.put(protocol.id, protocol);
      await dewormingProtocolBox.flush();

      print('✅ DewormingProtocol saved with ${protocol.schedules.length} schedules');

      print('\n🔄 PHASE 2: Simulating app restart...');

      await dewormingProtocolBox.close();
      dewormingProtocolBox = await Hive.openBox<DewormingProtocol>('deworming_protocols');

      print('\n✅ PHASE 3: Verifying DewormingProtocol persistence...');

      final retrieved = dewormingProtocolBox.get(protocol.id);
      expect(retrieved, isNotNull, reason: 'DewormingProtocol should persist');
      expect(retrieved!.name, equals('Canine Standard Deworming Protocol'));
      expect(retrieved.species, equals('dog'));
      expect(retrieved.schedules.length, equals(3), reason: 'Should have 3 deworming schedules');

      // Verify first internal schedule
      final schedule1 = retrieved.schedules[0];
      expect(schedule1.dewormingType, equals('internal'));
      expect(schedule1.ageInWeeks, equals(2));
      expect(schedule1.productName, equals('Milbemax'));
      expect(schedule1.recurring, isNotNull);
      expect(schedule1.recurring!.intervalMonths, equals(3));

      // Verify second internal schedule
      final schedule2 = retrieved.schedules[1];
      expect(schedule2.dewormingType, equals('internal'));
      expect(schedule2.intervalDays, equals(14));

      // Verify external schedule
      final schedule3 = retrieved.schedules[2];
      expect(schedule3.dewormingType, equals('external'));
      expect(schedule3.ageInWeeks, equals(8));
      expect(schedule3.productName, equals('Bravecto'));
      expect(schedule3.recurring, isNotNull);
      expect(schedule3.recurring!.intervalMonths, equals(1));

      print('✅ DewormingProtocol with recurring schedules verified successfully');
    });
  });
}
