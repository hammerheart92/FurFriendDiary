// File: lib/src/presentation/widgets/treatment_task_list_widget.dart
// Purpose: Display treatment plan tasks with checkboxes, color-coded urgency, and completion tracking

import 'package:flutter/material.dart';
import 'package:fur_friend_diary/src/domain/models/protocols/treatment_plan.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

/// A widget that displays a list of treatment tasks with checkboxes for completion tracking.
///
/// Features:
/// - Color-coded urgency (red for overdue, orange for due today)
/// - Strike-through styling for completed tasks
/// - Task type icons (medication, appointment, care, other)
/// - Interactive checkboxes with toggle callback
/// - Read-only mode for viewing completed plans
/// - Empty state for plans with no tasks
///
/// Usage:
/// ```dart
/// TreatmentTaskListWidget(
///   tasks: treatmentPlan.tasks,
///   onTaskToggle: (index, completed) {
///     // Handle task completion state change
///   },
///   readOnly: false,
/// )
/// ```
class TreatmentTaskListWidget extends StatelessWidget {
  /// List of treatment tasks to display
  final List<TreatmentTask> tasks;

  /// Callback triggered when a task's checkbox is toggled
  /// Parameters: taskIndex (position in list), completed (new completion state)
  final Function(int taskIndex, bool completed) onTaskToggle;

  /// Whether the list is read-only (disables checkboxes)
  /// Useful for viewing completed treatment plans
  final bool readOnly;

  const TreatmentTaskListWidget({
    required this.tasks,
    required this.onTaskToggle,
    this.readOnly = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Show empty state if no tasks
    if (tasks.isEmpty) {
      return _buildEmptyState(context);
    }

    // Build list of task tiles with dividers
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskTile(context, task, index);
      },
    );
  }

  /// Builds a single task tile with checkbox, icon, title, and subtitle
  Widget _buildTaskTile(BuildContext context, TreatmentTask task, int index) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    // Determine task urgency status
    final isOverdue = task.isOverdue;
    final isDueToday = task.isDueToday;
    final isCompleted = task.isCompleted;

    // Apply color coding based on urgency status
    Color iconColor;
    Color? tileColor;
    TextStyle? titleStyle;

    if (isCompleted) {
      // Completed tasks: muted colors with strike-through
      iconColor = theme.colorScheme.outline;
      tileColor = null;
      titleStyle = theme.textTheme.bodyLarge?.copyWith(
        decoration: TextDecoration.lineThrough,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
      );
    } else if (isOverdue) {
      // Overdue tasks: red theme with emphasis
      iconColor = Colors.red[700]!;
      tileColor = Colors.red[50];
      titleStyle = theme.textTheme.bodyLarge?.copyWith(
        color: Colors.red[900],
        fontWeight: FontWeight.w600,
      );
    } else if (isDueToday) {
      // Due today tasks: orange theme with medium emphasis
      iconColor = Colors.orange[700]!;
      tileColor = Colors.orange[50];
      titleStyle = theme.textTheme.bodyLarge?.copyWith(
        color: Colors.orange[900],
        fontWeight: FontWeight.w500,
      );
    } else {
      // Future tasks: normal theme colors
      iconColor = theme.colorScheme.primary;
      tileColor = null;
      titleStyle = theme.textTheme.bodyLarge;
    }

    return Container(
      color: tileColor,
      child: CheckboxListTile(
        value: task.isCompleted,
        onChanged: readOnly
            ? null
            : (value) {
                if (value != null) {
                  onTaskToggle(index, value);
                }
              },
        enabled: !readOnly,
        secondary: Icon(
          _getTaskTypeIcon(task.taskType),
          color: iconColor,
          size: 28,
          semanticLabel: _getTaskTypeLabel(task.taskType, l10n),
        ),
        title: Text(
          task.title,
          style: titleStyle,
        ),
        subtitle: _buildTaskSubtitle(context, task, l10n),
        // Accessibility: Provide semantic label for screen readers
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
      ),
    );
  }

  /// Builds the subtitle showing due date/completion date and status
  Widget _buildTaskSubtitle(
    BuildContext context,
    TreatmentTask task,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);

    // For completed tasks, show completion date
    if (task.isCompleted && task.completedAt != null) {
      final formattedDate =
          DateFormat('MMM dd, yyyy').format(task.completedAt!);
      return Row(
        children: [
          Icon(Icons.check_circle, size: 14, color: Colors.green[700]),
          const SizedBox(width: 4),
          Text(
            '${l10n.taskCompleted}: $formattedDate',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.green[700],
            ),
          ),
        ],
      );
    }

    // For incomplete tasks, show due date and status
    final formattedDate = DateFormat('MMM dd, yyyy').format(task.scheduledDate);
    final timeString = task.scheduledTime != null
        ? ' at ${task.scheduledTime!.hour}:${task.scheduledTime!.minute.toString().padLeft(2, '0')}'
        : '';

    String statusText;
    Color statusColor;

    if (task.isOverdue) {
      statusText = l10n.overdue;
      statusColor = Colors.red[700]!;
    } else if (task.isDueToday) {
      statusText = l10n.dueToday;
      statusColor = Colors.orange[700]!;
    } else {
      // No special status for future tasks
      statusText = '';
      statusColor = theme.colorScheme.onSurface;
    }

    return Wrap(
      spacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event, size: 14, color: statusColor),
            const SizedBox(width: 4),
            Text(
              '${l10n.dueDate}: $formattedDate$timeString',
              style: theme.textTheme.bodySmall?.copyWith(color: statusColor),
            ),
          ],
        ),
        if (statusText.isNotEmpty)
          Text(
            '• $statusText',
            style: theme.textTheme.bodySmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  /// Returns the appropriate icon for the task type
  IconData _getTaskTypeIcon(String taskType) {
    switch (taskType) {
      case 'medication':
        return Icons.medication;
      case 'appointment':
        return Icons.event;
      case 'care':
        return Icons.healing;
      case 'other':
      default:
        return Icons.task_alt;
    }
  }

  /// Returns semantic label for task type icon (accessibility)
  String _getTaskTypeLabel(String taskType, AppLocalizations l10n) {
    switch (taskType) {
      case 'medication':
        return 'Medication task';
      case 'appointment':
        return 'Appointment task';
      case 'care':
        return 'Care task';
      case 'other':
      default:
        return 'Task';
    }
  }

  /// Builds empty state when no tasks are present
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.task_alt,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noTasksInPlan,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
