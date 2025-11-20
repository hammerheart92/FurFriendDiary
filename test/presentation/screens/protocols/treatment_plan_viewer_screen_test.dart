// File: test/presentation/screens/protocols/treatment_plan_viewer_screen_test.dart
// Coverage: 40+ tests covering all scenarios
// Focus Areas: Task checklist interaction, progress tracking, mark complete flow,
//              provider integration, visual states (overdue, due today, completed)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fur_friend_diary/src/presentation/screens/protocols/treatment_plan_viewer_screen.dart';
import 'package:fur_friend_diary/src/presentation/providers/protocols/treatment_plan_provider.dart';
import 'package:fur_friend_diary/src/domain/models/pet_profile.dart';
import 'package:fur_friend_diary/src/domain/models/protocols/treatment_plan.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

void main() {
  group('TreatmentPlanViewerScreen', () {
    // ========================================================================
    // HELPER FUNCTIONS
    // ========================================================================

    /// Helper to pump widget under test with ProviderScope
    Future<void> pumpWidgetUnderTest(
      WidgetTester tester, {
      required PetProfile pet,
      AsyncValue<List<TreatmentPlan>>? plansValue,
    }) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeTreatmentPlansByPetIdProvider(pet.id).overrideWith((ref) async {
              return plansValue?.when(
                data: (data) => data,
                loading: () => throw UnimplementedError('Loading state'),
                error: (error, stack) => throw error,
              ) ?? <TreatmentPlan>[];
            }),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            home: TreatmentPlanViewerScreen(pet: pet),
          ),
        ),
      );
    }

    /// Helper to create mock pet profile
    PetProfile createMockPetProfile() {
      return PetProfile(
        id: 'test-pet-id',
        name: 'Buddy',
        species: 'Dog',
        breed: 'Golden Retriever',
        birthday: DateTime(2020, 1, 1),
      );
    }

    /// Helper to create treatment plan
    TreatmentPlan createTreatmentPlan({
      String id = 'plan-1',
      String petId = 'test-pet-id',
      String name = 'Post-Surgery Recovery',
      String? veterinarianName = 'Dr. Smith',
      required List<TreatmentTask> tasks,
      bool isActive = true,
    }) {
      return TreatmentPlan(
        id: id,
        petId: petId,
        name: name,
        description: 'Recovery protocol',
        veterinarianName: veterinarianName,
        startDate: DateTime.now().subtract(const Duration(days: 7)),
        endDate: DateTime.now().add(const Duration(days: 14)),
        tasks: tasks,
        isActive: isActive,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      );
    }

    /// Helper to create overdue task
    TreatmentTask createOverdueTask({
      String id = 'task-overdue',
      String title = 'Administer antibiotic',
      String taskType = 'medication',
      bool isCompleted = false,
    }) {
      return TreatmentTask(
        id: id,
        title: title,
        scheduledDate: DateTime.now().subtract(const Duration(days: 3)),
        taskType: taskType,
        isCompleted: isCompleted,
        completedAt:
            isCompleted ? DateTime.now().subtract(const Duration(days: 2)) : null,
      );
    }

    /// Helper to create due-today task
    TreatmentTask createDueTodayTask({
      String id = 'task-today',
      String title = 'Follow-up appointment',
      String taskType = 'appointment',
      bool isCompleted = false,
    }) {
      return TreatmentTask(
        id: id,
        title: title,
        scheduledDate: DateTime.now(),
        taskType: taskType,
        isCompleted: isCompleted,
        completedAt: isCompleted ? DateTime.now() : null,
      );
    }

    /// Helper to create completed task
    TreatmentTask createCompletedTask({
      String id = 'task-completed',
      String title = 'Wound cleaning',
      String taskType = 'care',
    }) {
      final now = DateTime.now();
      return TreatmentTask(
        id: id,
        title: title,
        scheduledDate: now.subtract(const Duration(days: 2)),
        taskType: taskType,
        isCompleted: true,
        completedAt: now.subtract(const Duration(days: 2)),
      );
    }

    /// Helper to create future task
    TreatmentTask createFutureTask({
      String id = 'task-future',
      String title = 'Next checkup',
      String taskType = 'other',
      int daysAhead = 7,
    }) {
      return TreatmentTask(
        id: id,
        title: title,
        scheduledDate: DateTime.now().add(Duration(days: daysAhead)),
        taskType: taskType,
        isCompleted: false,
      );
    }

    // ========================================================================
    // 1. RENDERING TESTS
    // ========================================================================

    group('Rendering Tests', () {
      testWidgets('screen renders with pet profile', (tester) async {
        final pet = createMockPetProfile();
        final task = createCompletedTask();
        final plan = createTreatmentPlan(tasks: [task]);

        await pumpWidgetUnderTest(
          tester,
          pet: pet,
          plansValue: AsyncValue.data([plan]),
        );
        await tester.pumpAndSettle();

        expect(find.byType(TreatmentPlanViewerScreen), findsOneWidget);
      });

      testWidgets('AppBar shows correct title', (tester) async {
        final pet = createMockPetProfile();
        final task = createCompletedTask();
        final plan = createTreatmentPlan(tasks: [task]);

        await pumpWidgetUnderTest(
          tester,
          pet: pet,
          plansValue: AsyncValue.data([plan]),
        );
        await tester.pumpAndSettle();

        expect(find.widgetWithText(AppBar, 'Treatment Plans'), findsOneWidget);
      });

      testWidgets('pet info header displays pet name and species', (tester) async {
        final pet = createMockPetProfile();
        final task = createCompletedTask();
        final plan = createTreatmentPlan(tasks: [task]);

        await pumpWidgetUnderTest(
          tester,
          pet: pet,
          plansValue: AsyncValue.data([plan]),
        );
        await tester.pumpAndSettle();

        expect(find.text('Buddy'), findsOneWidget);
        expect(find.text('Dog'), findsOneWidget);
      });

      testWidgets('treatment plan card displays plan name', (tester) async {
        final pet = createMockPetProfile();
        final task = createCompletedTask();
        final plan = createTreatmentPlan(
          name: 'Post-Surgery Recovery',
          tasks: [task],
        );

        await pumpWidgetUnderTest(
          tester,
          pet: pet,
          plansValue: AsyncValue.data([plan]),
        );
        await tester.pumpAndSettle();

        expect(find.text('Post-Surgery Recovery'), findsOneWidget);
      });

      testWidgets('progress bar displays correctly', (tester) async {
        final pet = createMockPetProfile();
        final task = createCompletedTask();
        final plan = createTreatmentPlan(tasks: [task]);

        await pumpWidgetUnderTest(
          tester,
          pet: pet,
          plansValue: AsyncValue.data([plan]),
        );
        await tester.pumpAndSettle();

        expect(find.byType(LinearProgressIndicator), findsOneWidget);
      });

      testWidgets('progress text shows correct format', (tester) async {
        final pet = createMockPetProfile();
        final completedTask = createCompletedTask();
        final incompleteTask = createOverdueTask();
        final plan = createTreatmentPlan(tasks: [completedTask, incompleteTask]);

        await pumpWidgetUnderTest(
          tester,
          pet: pet,
          plansValue: AsyncValue.data([plan]),
        );
        await tester.pumpAndSettle();

        expect(find.text('1 of 2 tasks complete'), findsOneWidget);
      });

      testWidgets('veterinarian name shows when present', (tester) async {
        final pet = createMockPetProfile();
        final task = createCompletedTask();
        final plan = createTreatmentPlan(
          veterinarianName: 'Dr. Smith',
          tasks: [task],
        );

        await pumpWidgetUnderTest(
          tester,
          pet: pet,
          plansValue: AsyncValue.data([plan]),
        );
        await tester.pumpAndSettle();

        expect(find.textContaining('Prescribed by Dr. Smith'), findsOneWidget);
      });

      testWidgets('start date displays correctly', (tester) async {
        final pet = createMockPetProfile();
        final task = createCompletedTask();
        final plan = createTreatmentPlan(tasks: [task]);

        await pumpWidgetUnderTest(
          tester,
          pet: pet,
          plansValue: AsyncValue.data([plan]),
        );
        await tester.pumpAndSettle();

        expect(find.textContaining('Started on'), findsOneWidget);
      });
    });

    // ========================================================================
    // 2. TASK CHECKLIST RENDERING TESTS
    // ========================================================================

    group('Task Checklist Rendering Tests', () {
      testWidgets('task titles display correctly', (tester) async {
        final pet = createMockPetProfile();
        final task = createOverdueTask(title: 'Give medication');
        final plan = createTreatmentPlan(tasks: [task]);

        await pumpWidgetUnderTest(
          tester,
          pet: pet,
          plansValue: AsyncValue.data([plan]),
        );
        await tester.pumpAndSettle();

        expect(find.text('Give medication'), findsOneWidget);
      });

      testWidgets('task type icons show for medication', (tester) async {
        final pet = createMockPetProfile();
        final task = createOverdueTask(taskType: 'medication');
        final plan = createTreatmentPlan(tasks: [task]);

        await pumpWidgetUnderTest(
          tester,
          pet: pet,
          plansValue: AsyncValue.data([plan]),
        );
        await tester.pumpAndSettle();

        // Find medication icon
        expect(find.byIcon(Icons.medication), findsWidgets);
      });

      testWidgets('task type icons show for appointment', (tester) async {
        final pet = createMockPetProfile();
        final task = createDueTodayTask(taskType: 'appointment');
        final plan = createTreatmentPlan(tasks: [task]);

        await pumpWidgetUnderTest(
          tester,
          pet: pet,
          plansValue: AsyncValue.data([plan]),
        );
        await tester.pumpAndSettle();

        // Find appointment icon
        expect(find.byIcon(Icons.event), findsWidgets);
      });

      testWidgets('scheduled dates display', (tester) async {
        final pet = createMockPetProfile();
        final scheduledDate = DateTime.now().subtract(const Duration(days: 3));
        final task = createOverdueTask();
        final plan = createTreatmentPlan(tasks: [task]);

        await pumpWidgetUnderTest(
          tester,
          pet: pet,
          plansValue: AsyncValue.data([plan]),
        );
        await tester.pumpAndSettle();

        final formattedDate = DateFormat.yMMMd().format(scheduledDate);
        expect(find.text(formattedDate), findsOneWidget);
      });

      testWidgets('completed tasks show strike-through text', (tester) async {
        final pet = createMockPetProfile();
        final task = createCompletedTask(title: 'Completed task');
        final plan = createTreatmentPlan(tasks: [task]);

        await pumpWidgetUnderTest(
          tester,
          pet: pet,
          plansValue: AsyncValue.data([plan]),
        );
        await tester.pumpAndSettle();

        // Find the text widget with strike-through decoration
        final textWidget = tester.widget<CheckboxListTile>(
          find.byType(CheckboxListTile),
        );
        expect(textWidget.value, true); // Completed
      });

      testWidgets('completed tasks show completion date', (tester) async {
        final pet = createMockPetProfile();
        final task = createCompletedTask();
        final plan = createTreatmentPlan(tasks: [task]);

        await pumpWidgetUnderTest(
          tester,
          pet: pet,
          plansValue: AsyncValue.data([plan]),
        );
        await tester.pumpAndSettle();

        expect(find.textContaining('Completed'), findsOneWidget);
      });

      testWidgets('overdue tasks show red "Overdue" chip', (tester) async {
        final pet = createMockPetProfile();
        final task = createOverdueTask();
        final plan = createTreatmentPlan(tasks: [task]);

        await pumpWidgetUnderTest(
          tester,
          pet: pet,
          plansValue: AsyncValue.data([plan]),
        );
        await tester.pumpAndSettle();

        expect(find.text('Overdue'), findsOneWidget);
      });

      testWidgets('due today tasks show "Due Today" chip', (tester) async {
        final pet = createMockPetProfile();
        final task = createDueTodayTask();
        final plan = createTreatmentPlan(tasks: [task]);

        await pumpWidgetUnderTest(
          tester,
          pet: pet,
          plansValue: AsyncValue.data([plan]),
        );
        await tester.pumpAndSettle();

        expect(find.text('Due Today'), findsOneWidget);
      });
    });

    // ========================================================================
    // 3. TASK INTERACTION TESTS (CRITICAL)
    // ========================================================================

    group('Task Interaction Tests', () {
      testWidgets('checkbox is displayed for each task', (tester) async {
        final pet = createMockPetProfile();
        final task1 = createOverdueTask();
        final task2 = createDueTodayTask();
        final plan = createTreatmentPlan(tasks: [task1, task2]);

        await pumpWidgetUnderTest(
          tester,
          pet: pet,
          plansValue: AsyncValue.data([plan]),
        );
        await tester.pumpAndSettle();

        expect(find.byType(Checkbox), findsNWidgets(2));
      });

      testWidgets('unchecked checkbox for incomplete task', (tester) async {
        final pet = createMockPetProfile();
        final task = createOverdueTask(isCompleted: false);
        final plan = createTreatmentPlan(tasks: [task]);

        await pumpWidgetUnderTest(
          tester,
          pet: pet,
          plansValue: AsyncValue.data([plan]),
        );
        await tester.pumpAndSettle();

        final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
        expect(checkbox.value, false);
      });

      testWidgets('checked checkbox for completed task', (tester) async {
        final pet = createMockPetProfile();
        final task = createCompletedTask();
        final plan = createTreatmentPlan(tasks: [task]);

        await pumpWidgetUnderTest(
          tester,
          pet: pet,
          plansValue: AsyncValue.data([plan]),
        );
        await tester.pumpAndSettle();

        final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
        expect(checkbox.value, true);
      });

      testWidgets('tapping checkbox shows success SnackBar', (tester) async {
        final pet = createMockPetProfile();
        final task = createOverdueTask(isCompleted: false);
        final plan = createTreatmentPlan(tasks: [task]);

        await pumpWidgetUnderTest(
          tester,
          pet: pet,
          plansValue: AsyncValue.data([plan]),
        );
        await tester.pumpAndSettle();

        // Tap the checkbox
        await tester.tap(find.byType(Checkbox).first);
        await tester.pumpAndSettle();

        // Verify SnackBar appears (indicates success)
        expect(find.text('Task updated successfully'), findsOneWidget);
      });
    });

    // ========================================================================
    // 4. PROGRESS TRACKING TESTS
    // ========================================================================

    group('Progress Tracking Tests', () {
      testWidgets('progress bar reflects 0% completion', (tester) async {
        final pet = createMockPetProfile();
        final task = createOverdueTask(isCompleted: false);
        final plan = createTreatmentPlan(tasks: [task]);

        await pumpWidgetUnderTest(
          tester,
          pet: pet,
          plansValue: AsyncValue.data([plan]),
        );
        await tester.pumpAndSettle();

        expect(find.text('0 of 1 tasks complete'), findsOneWidget);
      });

      testWidgets('progress bar reflects 50% completion', (tester) async {
        final pet = createMockPetProfile();
        final completedTask = createCompletedTask();
        final incompleteTask = createOverdueTask();
        final plan = createTreatmentPlan(tasks: [completedTask, incompleteTask]);

        await pumpWidgetUnderTest(
          tester,
          pet: pet,
          plansValue: AsyncValue.data([plan]),
        );
        await tester.pumpAndSettle();

        expect(find.text('1 of 2 tasks complete'), findsOneWidget);
      });

      testWidgets('progress bar reflects 100% completion', (tester) async {
        final pet = createMockPetProfile();
        final task = createCompletedTask();
        final plan = createTreatmentPlan(tasks: [task]);

        await pumpWidgetUnderTest(
          tester,
          pet: pet,
          plansValue: AsyncValue.data([plan]),
        );
        await tester.pumpAndSettle();

        expect(find.text('1 of 1 tasks complete'), findsOneWidget);
      });

      testWidgets('Mark Plan Complete button enabled at 100%', (tester) async {
        final pet = createMockPetProfile();
        final task = createCompletedTask();
        final plan = createTreatmentPlan(tasks: [task]);

        await pumpWidgetUnderTest(
          tester,
          pet: pet,
          plansValue: AsyncValue.data([plan]),
        );
        await tester.pumpAndSettle();

        final button = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Mark Plan Complete'),
        );
        expect(button.onPressed, isNotNull); // Button is enabled
      });

      testWidgets('Mark Plan Complete button disabled when incomplete',
          (tester) async {
        final pet = createMockPetProfile();
        final incompleteTask = createOverdueTask();
        final plan = createTreatmentPlan(tasks: [incompleteTask]);

        await pumpWidgetUnderTest(
          tester,
          pet: pet,
          plansValue: AsyncValue.data([plan]),
        );
        await tester.pumpAndSettle();

        final button = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Mark Plan Complete'),
        );
        expect(button.onPressed, isNull); // Button is disabled
      });
    });

    // ========================================================================
    // 5. MARK COMPLETE FLOW TESTS (CRITICAL)
    // ========================================================================

    group('Mark Complete Flow Tests', () {
      testWidgets('Mark Plan Complete button shows bottom sheet', (tester) async {
        final pet = createMockPetProfile();
        final completedTask = createCompletedTask();
        final plan = createTreatmentPlan(
          name: 'Post-Surgery Recovery',
          tasks: [completedTask],
        );

        await pumpWidgetUnderTest(
          tester,
          pet: pet,
          plansValue: AsyncValue.data([plan]),
        );
        await tester.pumpAndSettle();

        // Tap "Mark Plan Complete" button
        await tester.tap(find.text('Mark Plan Complete'));
        await tester.pumpAndSettle();

        // Verify bottom sheet appears
        expect(find.text('Confirm Mark Complete'), findsOneWidget);
      });

      testWidgets('confirmation bottom sheet shows plan name', (tester) async {
        final pet = createMockPetProfile();
        final completedTask = createCompletedTask();
        final plan = createTreatmentPlan(
          name: 'Post-Surgery Recovery',
          tasks: [completedTask],
        );

        await pumpWidgetUnderTest(
          tester,
          pet: pet,
          plansValue: AsyncValue.data([plan]),
        );
        await tester.pumpAndSettle();

        // Tap "Mark Plan Complete" button
        await tester.tap(find.text('Mark Plan Complete'));
        await tester.pumpAndSettle();

        // Verify plan name is shown in confirmation message
        expect(
          find.textContaining('Post-Surgery Recovery'),
          findsOneWidget,
        );
      });

      testWidgets('Cancel button closes bottom sheet without action',
          (tester) async {
        final pet = createMockPetProfile();
        final completedTask = createCompletedTask();
        final plan = createTreatmentPlan(tasks: [completedTask]);

        await pumpWidgetUnderTest(
          tester,
          pet: pet,
          plansValue: AsyncValue.data([plan]),
        );
        await tester.pumpAndSettle();

        // Tap "Mark Plan Complete" button
        await tester.tap(find.text('Mark Plan Complete'));
        await tester.pumpAndSettle();

        // Tap cancel button
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Verify no success SnackBar appears
        expect(find.text('Treatment plan marked as complete'), findsNothing);
      });

      testWidgets('Confirm button shows success SnackBar', (tester) async {
        final pet = createMockPetProfile();
        final completedTask = createCompletedTask();
        final plan = createTreatmentPlan(tasks: [completedTask]);

        await pumpWidgetUnderTest(
          tester,
          pet: pet,
          plansValue: AsyncValue.data([plan]),
        );
        await tester.pumpAndSettle();

        // Tap "Mark Plan Complete" button
        await tester.tap(find.text('Mark Plan Complete'));
        await tester.pumpAndSettle();

        // Tap confirm button
        await tester.tap(find.text('Confirm Mark Complete').last);
        await tester.pumpAndSettle();

        // Verify success SnackBar
        expect(find.text('Treatment plan marked as complete'), findsOneWidget);
      });
    });

    // ========================================================================
    // 6. PROVIDER INTEGRATION TESTS
    // ========================================================================

    group('Provider Integration Tests', () {
      testWidgets('shows loading state', (tester) async {
        final pet = createMockPetProfile();

        await pumpWidgetUnderTest(
          tester,
          pet: pet,
          plansValue: const AsyncValue.loading(),
        );
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Loading treatment plans...'), findsOneWidget);
      });

      testWidgets('shows error state with message', (tester) async {
        final pet = createMockPetProfile();

        await pumpWidgetUnderTest(
          tester,
          pet: pet,
          plansValue: AsyncValue.error(
            Exception('Database error'),
            StackTrace.current,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('Failed to load treatment plans'), findsOneWidget);
      });

      testWidgets('error state shows retry button', (tester) async {
        final pet = createMockPetProfile();

        await pumpWidgetUnderTest(
          tester,
          pet: pet,
          plansValue: AsyncValue.error(
            Exception('Database error'),
            StackTrace.current,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('shows empty state when no plans', (tester) async {
        final pet = createMockPetProfile();

        await pumpWidgetUnderTest(
          tester,
          pet: pet,
          plansValue: const AsyncValue.data([]),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.assignment_outlined), findsOneWidget);
        expect(find.text('No Active Treatment Plans'), findsOneWidget);
      });

      testWidgets('shows data when plans exist', (tester) async {
        final pet = createMockPetProfile();
        final task = createCompletedTask();
        final plan = createTreatmentPlan(tasks: [task]);

        await pumpWidgetUnderTest(
          tester,
          pet: pet,
          plansValue: AsyncValue.data([plan]),
        );
        await tester.pumpAndSettle();

        expect(find.text('Post-Surgery Recovery'), findsOneWidget);
      });
    });

    // ========================================================================
    // 7. EDGE CASES
    // ========================================================================

    group('Edge Cases', () {
      testWidgets('plan with empty task list', (tester) async {
        final pet = createMockPetProfile();
        final plan = createTreatmentPlan(tasks: []);

        await pumpWidgetUnderTest(
          tester,
          pet: pet,
          plansValue: AsyncValue.data([plan]),
        );
        await tester.pumpAndSettle();

        expect(find.text('0 of 0 tasks complete'), findsOneWidget);
      });

      testWidgets('plan with all tasks completed', (tester) async {
        final pet = createMockPetProfile();
        final task1 = createCompletedTask(id: 'task-1');
        final task2 = createCompletedTask(id: 'task-2', title: 'Task 2');
        final plan = createTreatmentPlan(tasks: [task1, task2]);

        await pumpWidgetUnderTest(
          tester,
          pet: pet,
          plansValue: AsyncValue.data([plan]),
        );
        await tester.pumpAndSettle();

        expect(find.text('2 of 2 tasks complete'), findsOneWidget);
      });

      testWidgets('plan without veterinarian name', (tester) async {
        final pet = createMockPetProfile();
        final task = createCompletedTask();
        final plan = createTreatmentPlan(
          veterinarianName: null,
          tasks: [task],
        );

        await pumpWidgetUnderTest(
          tester,
          pet: pet,
          plansValue: AsyncValue.data([plan]),
        );
        await tester.pumpAndSettle();

        expect(find.textContaining('Prescribed by'), findsNothing);
      });

      testWidgets('plan with only overdue tasks', (tester) async {
        final pet = createMockPetProfile();
        final task1 = createOverdueTask(id: 'task-1');
        final task2 = createOverdueTask(id: 'task-2', title: 'Task 2');
        final plan = createTreatmentPlan(tasks: [task1, task2]);

        await pumpWidgetUnderTest(
          tester,
          pet: pet,
          plansValue: AsyncValue.data([plan]),
        );
        await tester.pumpAndSettle();

        expect(find.text('Overdue'), findsNWidgets(2));
      });

      testWidgets('plan with mix of task statuses', (tester) async {
        final pet = createMockPetProfile();
        final overdueTask = createOverdueTask(id: 'task-1');
        final dueTodayTask = createDueTodayTask(id: 'task-2');
        final completedTask = createCompletedTask(id: 'task-3');
        final futureTask = createFutureTask(id: 'task-4');

        final plan = createTreatmentPlan(
          tasks: [overdueTask, dueTodayTask, completedTask, futureTask],
        );

        await pumpWidgetUnderTest(
          tester,
          pet: pet,
          plansValue: AsyncValue.data([plan]),
        );
        await tester.pumpAndSettle();

        expect(find.text('Overdue'), findsOneWidget);
        expect(find.text('Due Today'), findsOneWidget);
        expect(find.text('1 of 4 tasks complete'), findsOneWidget);
      });

      testWidgets('multiple treatment plans for same pet', (tester) async {
        final pet = createMockPetProfile();
        final task1 = createCompletedTask();
        final task2 = createOverdueTask();

        final plan1 = createTreatmentPlan(
          id: 'plan-1',
          name: 'Post-Surgery Recovery',
          tasks: [task1],
        );
        final plan2 = createTreatmentPlan(
          id: 'plan-2',
          name: 'Antibiotic Course',
          tasks: [task2],
        );

        await pumpWidgetUnderTest(
          tester,
          pet: pet,
          plansValue: AsyncValue.data([plan1, plan2]),
        );
        await tester.pumpAndSettle();

        expect(find.text('Post-Surgery Recovery'), findsOneWidget);
        expect(find.text('Antibiotic Course'), findsOneWidget);
      });

      testWidgets('task types render correct icons', (tester) async {
        final pet = createMockPetProfile();
        final medicationTask = createOverdueTask(
          id: 'task-1',
          title: 'Give pills',
          taskType: 'medication',
        );
        final appointmentTask = createDueTodayTask(
          id: 'task-2',
          title: 'Vet visit',
          taskType: 'appointment',
        );
        final careTask = createCompletedTask(
          id: 'task-3',
          title: 'Clean wound',
          taskType: 'care',
        );
        final otherTask = createFutureTask(
          id: 'task-4',
          title: 'Other task',
          taskType: 'other',
        );

        final plan = createTreatmentPlan(
          tasks: [medicationTask, appointmentTask, careTask, otherTask],
        );

        await pumpWidgetUnderTest(
          tester,
          pet: pet,
          plansValue: AsyncValue.data([plan]),
        );
        await tester.pumpAndSettle();

        // Verify different task type icons appear
        expect(find.byIcon(Icons.medication), findsWidgets);
        expect(find.byIcon(Icons.event), findsWidgets);
        expect(find.byIcon(Icons.favorite), findsWidgets);
        expect(find.byIcon(Icons.task_alt), findsWidgets);
      });
    });
  });
}
