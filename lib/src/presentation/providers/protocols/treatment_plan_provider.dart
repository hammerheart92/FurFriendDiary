import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/models/protocols/treatment_plan.dart';
import '../../../data/repositories/protocols/treatment_plan_repository_impl.dart';

part 'treatment_plan_provider.g.dart';

// ============================================================================
// TREATMENT PLAN DATA PROVIDER
// ============================================================================

/// Main treatment plan provider - manages all treatment plans
///
/// Treatment plans are digital representations of veterinarian-prescribed
/// treatment protocols with task checklists for pet owners to follow.
///
/// Usage:
/// ```dart
/// final plans = await ref.read(treatmentPlansProvider.future);
/// ```
@riverpod
class TreatmentPlans extends _$TreatmentPlans {
  @override
  Future<List<TreatmentPlan>> build() async {
    final repository = ref.watch(treatmentPlanRepositoryProvider);
    return await repository.getAll();
  }

  /// Save a treatment plan (create or update)
  Future<void> savePlan(TreatmentPlan plan) async {
    final repository = ref.read(treatmentPlanRepositoryProvider);
    await repository.save(plan);
    ref.invalidateSelf();
  }

  /// Delete a treatment plan
  Future<void> deletePlan(String id) async {
    final repository = ref.read(treatmentPlanRepositoryProvider);
    await repository.delete(id);
    ref.invalidateSelf();
  }

  /// Update task completion status
  ///
  /// Marks a specific task within a treatment plan as completed or incomplete.
  /// Automatically updates timestamps and triggers a rebuild.
  Future<void> updateTaskCompletion(
    String planId,
    int taskIndex,
    bool completed,
  ) async {
    final repository = ref.read(treatmentPlanRepositoryProvider);
    final plan = await repository.getById(planId);
    if (plan == null) {
      throw ArgumentError('Treatment plan with ID $planId not found');
    }

    if (taskIndex < 0 || taskIndex >= plan.tasks.length) {
      throw ArgumentError(
          'Task index $taskIndex is out of bounds (plan has ${plan.tasks.length} tasks)');
    }

    // Create updated task list with the modified task
    final updatedTasks = List<TreatmentTask>.from(plan.tasks);
    updatedTasks[taskIndex] = updatedTasks[taskIndex].copyWith(
      isCompleted: completed,
      completedAt: completed ? DateTime.now() : null,
    );

    // Save updated plan
    final updatedPlan = plan.copyWith(
      tasks: updatedTasks,
      updatedAt: DateTime.now(),
    );
    await repository.save(updatedPlan);
    ref.invalidateSelf();
  }

  /// Mark entire treatment plan as complete
  ///
  /// Sets the plan's isCompleted flag to true if all tasks are completed.
  /// Throws an error if not all tasks are completed.
  Future<void> markPlanComplete(String planId) async {
    final repository = ref.read(treatmentPlanRepositoryProvider);
    final plan = await repository.getById(planId);
    if (plan == null) {
      throw ArgumentError('Treatment plan with ID $planId not found');
    }

    // Verify all tasks are completed
    final allTasksComplete = plan.tasks.every((task) => task.isCompleted);
    if (!allTasksComplete) {
      final incompleteTasks = plan.tasks.where((task) => !task.isCompleted).length;
      throw StateError(
          'Cannot mark plan as complete: $incompleteTasks task(s) are still incomplete');
    }

    final updatedPlan = plan.copyWith(
      isActive: false,
      updatedAt: DateTime.now(),
    );
    await repository.save(updatedPlan);
    ref.invalidateSelf();
  }

  /// Reopen a completed treatment plan
  ///
  /// Sets the plan's isActive flag back to true.
  Future<void> reopenPlan(String planId) async {
    final repository = ref.read(treatmentPlanRepositoryProvider);
    final plan = await repository.getById(planId);
    if (plan == null) {
      throw ArgumentError('Treatment plan with ID $planId not found');
    }

    final updatedPlan = plan.copyWith(
      isActive: true,
      updatedAt: DateTime.now(),
    );
    await repository.save(updatedPlan);
    ref.invalidateSelf();
  }
}

// ============================================================================
// FILTERED TREATMENT PLAN PROVIDERS
// ============================================================================

/// Get treatment plans for a specific pet
///
/// Returns all treatment plans (active and completed) for the given pet ID.
///
/// Usage:
/// ```dart
/// final petPlans = await ref.read(treatmentPlansByPetIdProvider('pet-id').future);
/// ```
@riverpod
Future<List<TreatmentPlan>> treatmentPlansByPetId(
  TreatmentPlansByPetIdRef ref,
  String petId,
) async {
  final repository = ref.watch(treatmentPlanRepositoryProvider);
  return await repository.getByPetId(petId);
}

/// Get active (non-completed) treatment plans for a specific pet
///
/// Usage:
/// ```dart
/// final activePlans = await ref.read(activeTreatmentPlansByPetIdProvider('pet-id').future);
/// ```
@riverpod
Future<List<TreatmentPlan>> activeTreatmentPlansByPetId(
  ActiveTreatmentPlansByPetIdRef ref,
  String petId,
) async {
  final repository = ref.watch(treatmentPlanRepositoryProvider);
  return await repository.getActiveByPetId(petId);
}

/// Get completed treatment plans for a specific pet
///
/// Usage:
/// ```dart
/// final completedPlans = await ref.read(completedTreatmentPlansByPetIdProvider('pet-id').future);
/// ```
@riverpod
Future<List<TreatmentPlan>> completedTreatmentPlansByPetId(
  CompletedTreatmentPlansByPetIdRef ref,
  String petId,
) async {
  final plans = await ref.watch(treatmentPlansByPetIdProvider(petId).future);
  return plans.where((plan) => plan.tasks.every((task) => task.isCompleted)).toList();
}

/// Get a specific treatment plan by ID
///
/// Returns null if plan not found.
///
/// Usage:
/// ```dart
/// final plan = await ref.read(treatmentPlanByIdProvider('plan-id').future);
/// ```
@riverpod
Future<TreatmentPlan?> treatmentPlanById(
  TreatmentPlanByIdRef ref,
  String id,
) async {
  final repository = ref.watch(treatmentPlanRepositoryProvider);
  return await repository.getById(id);
}

/// Get treatment plan completion statistics for a pet
///
/// Returns a map with completion stats:
/// - 'total': Total number of treatment plans
/// - 'completed': Number of completed plans
/// - 'active': Number of active plans
/// - 'completionRate': Percentage of completed plans (0-100)
///
/// Usage:
/// ```dart
/// final stats = await ref.read(treatmentPlanStatsProvider('pet-id').future);
/// print('Completion rate: ${stats['completionRate']}%');
/// ```
@riverpod
Future<Map<String, dynamic>> treatmentPlanStats(
  TreatmentPlanStatsRef ref,
  String petId,
) async {
  final plans = await ref.watch(treatmentPlansByPetIdProvider(petId).future);

  final total = plans.length;
  final completed = plans.where((plan) => plan.tasks.every((task) => task.isCompleted)).length;
  final active = plans.where((plan) => !plan.tasks.every((task) => task.isCompleted)).length;
  final completionRate = total > 0 ? (completed / total * 100).round() : 0;

  return {
    'total': total,
    'completed': completed,
    'active': active,
    'completionRate': completionRate,
  };
}
