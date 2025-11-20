// File: lib/src/presentation/widgets/treatment_task_list_widget_example.dart
// Purpose: Example usage of TreatmentTaskListWidget in a treatment plan viewer

import 'package:flutter/material.dart';
import 'package:fur_friend_diary/src/domain/models/protocols/treatment_plan.dart';
import 'package:fur_friend_diary/src/presentation/widgets/treatment_task_list_widget.dart';

/// Example usage of TreatmentTaskListWidget
///
/// This example shows how to integrate the widget into a treatment plan viewer screen
/// with proper state management for task completion.
class TreatmentPlanViewerExample extends StatefulWidget {
  final TreatmentPlan treatmentPlan;

  const TreatmentPlanViewerExample({
    required this.treatmentPlan,
    super.key,
  });

  @override
  State<TreatmentPlanViewerExample> createState() =>
      _TreatmentPlanViewerExampleState();
}

class _TreatmentPlanViewerExampleState
    extends State<TreatmentPlanViewerExample> {
  late TreatmentPlan _currentPlan;

  @override
  void initState() {
    super.initState();
    _currentPlan = widget.treatmentPlan;
  }

  /// Handle task completion toggle
  void _handleTaskToggle(int taskIndex, bool completed) {
    if (taskIndex < 0 || taskIndex >= _currentPlan.tasks.length) return;

    final task = _currentPlan.tasks[taskIndex];
    final updatedTask = completed
        ? task.markCompleted() // Marks task as completed with current timestamp
        : task.copyWith(
            isCompleted: false,
            completedAt: null,
          ); // Marks task as incomplete

    // Create updated task list
    final updatedTasks = List<TreatmentTask>.from(_currentPlan.tasks);
    updatedTasks[taskIndex] = updatedTask;

    // Update plan with new tasks
    setState(() {
      _currentPlan = _currentPlan.copyWith(tasks: updatedTasks);
    });

    // In real implementation, you would also persist this change to the repository:
    // ref.read(treatmentPlanRepositoryProvider).updatePlan(_currentPlan);
    // ref.invalidate(treatmentPlanProvider);

    // Show feedback to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          completed
              ? 'Task marked as complete: ${task.title}'
              : 'Task marked as incomplete: ${task.title}',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentPlan.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Treatment plan header
            Text(
              _currentPlan.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _currentPlan.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // Progress indicator
            LinearProgressIndicator(
              value: _currentPlan.completionPercentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_currentPlan.completedTasks.length} of ${_currentPlan.tasks.length} tasks complete',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),

            // Task list widget
            TreatmentTaskListWidget(
              tasks: _currentPlan.tasks,
              onTaskToggle: _handleTaskToggle,
              readOnly: false, // Set to true for completed plans
            ),
          ],
        ),
      ),
    );
  }
}

/// Example for read-only view of completed treatment plan
class CompletedTreatmentPlanViewerExample extends StatelessWidget {
  final TreatmentPlan completedPlan;

  const CompletedTreatmentPlanViewerExample({
    required this.completedPlan,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${completedPlan.name} (Completed)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Completed plan banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.green[50],
                border: Border.all(color: Colors.green[700] ?? Colors.green),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This treatment plan was completed',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.green[900],
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Read-only task list
            TreatmentTaskListWidget(
              tasks: completedPlan.tasks,
              onTaskToggle: (_, __) {}, // No-op callback for read-only view
              readOnly: true, // Disables checkboxes
            ),
          ],
        ),
      ),
    );
  }
}

/// Example with Riverpod integration (pseudo-code)
///
/// ```dart
/// class TreatmentPlanViewerScreen extends ConsumerWidget {
///   final String planId;
///
///   const TreatmentPlanViewerScreen({
///     required this.planId,
///     super.key,
///   });
///
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final planAsync = ref.watch(treatmentPlanProvider(planId));
///
///     return planAsync.when(
///       loading: () => Center(child: CircularProgressIndicator()),
///       error: (err, stack) => ErrorWidget(error: err),
///       data: (plan) => Scaffold(
///         appBar: AppBar(title: Text(plan.name)),
///         body: SingleChildScrollView(
///           padding: const EdgeInsets.all(16.0),
///           child: TreatmentTaskListWidget(
///             tasks: plan.tasks,
///             onTaskToggle: (index, completed) async {
///               // Update task in repository
///               final updatedTask = completed
///                   ? plan.tasks[index].markCompleted()
///                   : plan.tasks[index].copyWith(isCompleted: false, completedAt: null);
///
///               final updatedTasks = List<TreatmentTask>.from(plan.tasks);
///               updatedTasks[index] = updatedTask;
///
///               final updatedPlan = plan.copyWith(tasks: updatedTasks);
///
///               await ref
///                   .read(treatmentPlanRepositoryProvider)
///                   .updatePlan(updatedPlan);
///
///               // Refresh provider
///               ref.invalidate(treatmentPlanProvider(planId));
///             },
///             readOnly: !plan.isActive,
///           ),
///         ),
///       ),
///     );
///   }
/// }
/// ```
