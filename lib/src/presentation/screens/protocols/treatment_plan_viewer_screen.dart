import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
import '../../../domain/models/pet_profile.dart';
import '../../../domain/models/protocols/treatment_plan.dart';
import '../../providers/protocols/treatment_plan_provider.dart';

/// Treatment Plan Viewer Screen - View and manage active treatment plans
///
/// This screen displays all active treatment plans for a specific pet, allowing
/// users to view task checklists, update task completion status, and mark entire
/// plans as complete when all tasks are finished.
///
/// Features:
/// - List of active treatment plans with progress indicators
/// - Task checklist with visual status indicators (overdue, due today, completed)
/// - Toggle task completion by tapping checkboxes
/// - Mark entire plan as complete when all tasks are done
/// - Visual feedback for task types (medication, appointment, care, other)
///
/// Usage:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => TreatmentPlanViewerScreen(pet: petProfile),
///   ),
/// );
/// ```
class TreatmentPlanViewerScreen extends ConsumerStatefulWidget {
  final PetProfile pet;

  const TreatmentPlanViewerScreen({
    super.key,
    required this.pet,
  });

  @override
  ConsumerState<TreatmentPlanViewerScreen> createState() =>
      _TreatmentPlanViewerScreenState();
}

class _TreatmentPlanViewerScreenState
    extends ConsumerState<TreatmentPlanViewerScreen> {
  final Logger _logger = Logger();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Watch active treatment plans for this pet
    final plansAsync = ref.watch(
      activeTreatmentPlansByPetIdProvider(widget.pet.id),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.treatmentPlanViewer),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Semantics(
          label: l10n.activeTreatmentPlans,
          child: plansAsync.when(
            loading: () => _buildLoadingState(l10n),
            error: (error, stack) => _buildErrorState(context, l10n, error),
            data: (plans) {
              if (plans.isEmpty) {
                return _buildEmptyState(context, l10n);
              }
              return _buildPlansList(context, l10n, plans);
            },
          ),
        ),
      ),
    );
  }

  /// Build loading state
  Widget _buildLoadingState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            l10n.loadingTreatmentPlans,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState(
    BuildContext context,
    AppLocalizations l10n,
    Object error,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.failedToLoadTreatmentPlans,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => ref.invalidate(
                activeTreatmentPlansByPetIdProvider(widget.pet.id),
              ),
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noActiveTreatmentPlans,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noActiveTreatmentPlansMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build plans list
  Widget _buildPlansList(
    BuildContext context,
    AppLocalizations l10n,
    List<TreatmentPlan> plans,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: plans.length + 1, // +1 for pet info header
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            children: [
              _PetInfoHeader(pet: widget.pet),
              const SizedBox(height: 24),
            ],
          );
        }

        final plan = plans[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _TreatmentPlanCard(
            plan: plan,
            onTaskToggle: (planId, taskIndex, completed) =>
                _handleTaskToggle(planId, taskIndex, completed),
            onMarkComplete: (planId, planName) =>
                _markPlanComplete(planId, planName),
          ),
        );
      },
    );
  }

  /// Handle task completion toggle
  Future<void> _handleTaskToggle(
    String planId,
    int taskIndex,
    bool completed,
  ) async {
    try {
      _logger.d(
        'Toggling task completion: planId=$planId, taskIndex=$taskIndex, completed=$completed',
      );

      await ref.read(treatmentPlansProvider.notifier).updateTaskCompletion(
            planId,
            taskIndex,
            completed,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).taskUpdated),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to update task completion',
        error: e,
        stackTrace: stackTrace,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).taskCompletionFailed),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  /// Mark plan as complete
  Future<void> _markPlanComplete(String planId, String planName) async {
    final l10n = AppLocalizations.of(context);

    // Show confirmation bottom sheet
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => _MarkCompleteConfirmationSheet(
        planName: planName,
      ),
    );

    if (confirmed == true) {
      try {
        _logger.d('Marking plan as complete: planId=$planId');

        await ref.read(treatmentPlansProvider.notifier).markPlanComplete(planId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.planMarkedComplete),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }
      } catch (e, stackTrace) {
        _logger.e(
          'Failed to mark plan as complete',
          error: e,
          stackTrace: stackTrace,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.failedToMarkPlanComplete),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }
}

// ============================================================================
// INLINE WIDGETS
// ============================================================================

/// Pet info header - displays pet context
class _PetInfoHeader extends StatelessWidget {
  final PetProfile pet;

  const _PetInfoHeader({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Pet avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            backgroundImage:
                pet.photoPath != null && pet.photoPath!.isNotEmpty
                    ? AssetImage(pet.photoPath!)
                    : null,
            child: pet.photoPath == null || pet.photoPath!.isEmpty
                ? Icon(
                    Icons.pets,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  )
                : null,
          ),
          const SizedBox(width: 12),

          // Pet info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Chip(
                  label: Text(pet.species),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                  labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSecondaryContainer,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Treatment plan card - displays plan details and tasks
class _TreatmentPlanCard extends StatelessWidget {
  final TreatmentPlan plan;
  final Function(String planId, int taskIndex, bool completed) onTaskToggle;
  final Function(String planId, String planName) onMarkComplete;

  const _TreatmentPlanCard({
    required this.plan,
    required this.onTaskToggle,
    required this.onMarkComplete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final completedCount = plan.completedTasks.length;
    final totalCount = plan.tasks.length;
    final isFullyCompleted = plan.completionPercentage >= 100;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan header
            Text(
              plan.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),

            // Veterinarian info (if available)
            if (plan.veterinarianName != null &&
                plan.veterinarianName!.isNotEmpty) ...[
              Text(
                l10n.prescribedBy(plan.veterinarianName!),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
              ),
              const SizedBox(height: 4),
            ],

            // Start date
            Text(
              l10n.startedOn(DateFormat.yMMMd().format(plan.startDate)),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
            ),
            const SizedBox(height: 16),

            // Progress bar
            LinearProgressIndicator(
              value: plan.completionPercentage / 100,
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),

            // Progress text
            Text(
              l10n.tasksComplete(completedCount, totalCount),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
            ),
            const SizedBox(height: 16),

            // Task checklist
            ...plan.tasks.asMap().entries.map((entry) {
              final taskIndex = entry.key;
              final task = entry.value;

              return _TaskChecklistItem(
                task: task,
                taskIndex: taskIndex,
                planId: plan.id,
                onToggle: onTaskToggle,
              );
            }),

            const SizedBox(height: 16),

            // Mark complete button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isFullyCompleted
                    ? () => onMarkComplete(plan.id, plan.name)
                    : null,
                icon: const Icon(Icons.check_circle),
                label: Text(l10n.markPlanComplete),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Task checklist item - individual task with checkbox
class _TaskChecklistItem extends StatelessWidget {
  final TreatmentTask task;
  final int taskIndex;
  final String planId;
  final Function(String planId, int taskIndex, bool completed) onToggle;

  const _TaskChecklistItem({
    required this.task,
    required this.taskIndex,
    required this.planId,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final backgroundColor = _getTaskBackgroundColor(
      task,
      Theme.of(context).colorScheme,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: CheckboxListTile(
        value: task.isCompleted,
        onChanged: (value) {
          if (value != null) {
            onToggle(planId, taskIndex, value);
          }
        },
        title: Text(
          task.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                decoration:
                    task.isCompleted ? TextDecoration.lineThrough : null,
                color: task.isCompleted
                    ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                    : null,
              ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  _getTaskTypeIcon(task.taskType),
                  size: 16,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormat.yMMMd().format(task.scheduledDate),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                ),
                if (task.isOverdue) ...[
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(l10n.overdue),
                    visualDensity: VisualDensity.compact,
                    backgroundColor: Theme.of(context).colorScheme.error,
                    labelStyle:
                        Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onError,
                            ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                ] else if (task.isDueToday) ...[
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(l10n.dueToday),
                    visualDensity: VisualDensity.compact,
                    backgroundColor:
                        Theme.of(context).colorScheme.tertiaryContainer,
                    labelStyle:
                        Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onTertiaryContainer,
                            ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                ],
              ],
            ),
            if (task.isCompleted && task.completedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Completed ${DateFormat.yMMMd().format(task.completedAt!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
          ],
        ),
        secondary: Icon(
          _getTaskTypeIcon(task.taskType),
          color: task.isCompleted
              ? Theme.of(context).colorScheme.onSurface.withOpacity(0.4)
              : Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  /// Get background color based on task status
  Color _getTaskBackgroundColor(TreatmentTask task, ColorScheme colorScheme) {
    if (task.isCompleted) {
      return colorScheme.surfaceContainerHighest.withOpacity(0.5);
    } else if (task.isOverdue) {
      return colorScheme.errorContainer.withOpacity(0.3);
    } else if (task.isDueToday) {
      return colorScheme.tertiaryContainer.withOpacity(0.3);
    }
    return colorScheme.surface;
  }

  /// Get icon based on task type
  IconData _getTaskTypeIcon(String taskType) {
    switch (taskType) {
      case 'medication':
        return Icons.medication;
      case 'appointment':
        return Icons.event;
      case 'care':
        return Icons.favorite;
      default:
        return Icons.task_alt;
    }
  }
}

/// Mark complete confirmation bottom sheet
class _MarkCompleteConfirmationSheet extends StatelessWidget {
  final String planName;

  const _MarkCompleteConfirmationSheet({
    required this.planName,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.confirmMarkComplete,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.confirmMarkCompleteMessage(planName),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.confirmMarkComplete),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
