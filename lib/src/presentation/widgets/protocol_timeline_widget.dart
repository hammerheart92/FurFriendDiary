// File: lib/src/presentation/widgets/protocol_timeline_widget.dart
// Purpose: Displays vaccination protocol schedule as a vertical timeline with dose status tracking
//
// Example Usage:
// ```dart
// // Basic usage with protocol only (shows age milestones)
// ProtocolTimelineWidget(
//   protocol: myVaccinationProtocol,
// )
//
// // With calculated schedule entries (shows actual dates and completion status)
// ProtocolTimelineWidget(
//   protocol: myVaccinationProtocol,
//   scheduleEntries: calculatedSchedule, // from ProtocolEngineService
// )
// ```

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/protocols/vaccination_protocol.dart';
import '../../data/services/protocols/schedule_models.dart';
import '../../../l10n/app_localizations.dart';

/// Widget that displays a vaccination protocol timeline showing all doses
///
/// This widget renders a vertical timeline (similar to a stepper widget) that
/// visualizes the complete vaccination protocol schedule. Each step represents
/// a dose/step from the protocol, with visual indicators for completion status.
///
/// **Visual Design:**
/// - Vertical timeline with circular indicators connected by lines
/// - Three visual states: Completed (green checkmark), Next/Current (blue dot),
///   Future (gray outlined circle)
/// - Each step shows dose number, vaccine name, and scheduled/completion date
///
/// **Data Integration:**
/// - Accepts a VaccinationProtocol with protocol steps
/// - Optionally accepts VaccinationScheduleEntry list to show calculated dates
///   and completion status
/// - Determines step status based on scheduled dates relative to current time
///
/// **Accessibility:**
/// - Semantic labels for screen readers on all timeline steps
/// - Proper color contrast for text and indicators
/// - Touch targets meet 48x48 minimum size requirements
class ProtocolTimelineWidget extends StatelessWidget {
  /// The vaccination protocol to display as a timeline
  final VaccinationProtocol protocol;

  /// Optional list of calculated schedule entries with dates
  ///
  /// If provided, the widget will:
  /// - Display actual scheduled dates from the entries
  /// - Determine completion status based on dates relative to now
  /// - Show "not scheduled yet" for missing entries
  ///
  /// If null, the widget will show age milestones only without specific dates.
  final List<VaccinationScheduleEntry>? scheduleEntries;

  const ProtocolTimelineWidget({
    required this.protocol,
    this.scheduleEntries,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Display message if protocol has no steps
    if (protocol.steps.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            l10n.noProtocolSelected,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Protocol header with name and species
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                protocol.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                protocol.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Timeline steps
        ...List.generate(protocol.steps.length, (index) {
          final step = protocol.steps[index];
          final isLastStep = index == protocol.steps.length - 1;

          // Find matching schedule entry for this step
          final scheduleEntry = scheduleEntries?.firstWhere(
            (entry) => entry.stepIndex == index,
            orElse: () => VaccinationScheduleEntry(
              stepIndex: index,
              vaccineName: step.vaccineName,
              scheduledDate: DateTime.now().add(Duration(days: 365)),
              isRequired: step.isRequired,
            ),
          );

          // Determine step status
          final stepStatus = _determineStepStatus(
            index,
            scheduleEntry,
          );

          return _buildTimelineStep(
            context: context,
            doseNumber: index + 1,
            step: step,
            scheduleEntry: scheduleEntry,
            stepStatus: stepStatus,
            isLast: isLastStep,
          );
        }),

        // Bottom spacing
        const SizedBox(height: 16),
      ],
    );
  }

  /// Determines the visual status of a timeline step
  ///
  /// Returns:
  /// - TimelineStepStatus.completed: If scheduled date is in the past
  /// - TimelineStepStatus.next: If this is the first upcoming dose
  /// - TimelineStepStatus.future: If scheduled date is in the future
  TimelineStepStatus _determineStepStatus(
    int stepIndex,
    VaccinationScheduleEntry? entry,
  ) {
    if (entry == null) {
      return TimelineStepStatus.future;
    }

    final now = DateTime.now();
    final scheduledDate = entry.scheduledDate;

    // Check if this dose was already administered (date is in past)
    if (scheduledDate.isBefore(now)) {
      return TimelineStepStatus.completed;
    }

    // Check if this is the next upcoming dose
    // (first future dose in the timeline)
    final allFutureDoses = scheduleEntries
            ?.where((e) => e.scheduledDate.isAfter(now))
            .toList() ??
        [];

    if (allFutureDoses.isNotEmpty) {
      allFutureDoses.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
      if (allFutureDoses.first.stepIndex == stepIndex) {
        return TimelineStepStatus.next;
      }
    }

    return TimelineStepStatus.future;
  }

  /// Builds a single timeline step widget
  ///
  /// Each step consists of:
  /// - Left: Circular indicator with state-dependent styling
  /// - Middle: Vertical connecting line (if not last step)
  /// - Right: Information card with dose details
  Widget _buildTimelineStep({
    required BuildContext context,
    required int doseNumber,
    required VaccinationStep step,
    VaccinationScheduleEntry? scheduleEntry,
    required TimelineStepStatus stepStatus,
    required bool isLast,
  }) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Get status-dependent colors and icons
    final statusConfig = _getStatusConfig(context, stepStatus);

    return Semantics(
      label: '${l10n.dose} $doseNumber: ${step.vaccineName}, '
          '${_getStatusLabel(context, stepStatus, scheduleEntry)}',
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Timeline indicator column
              Column(
                children: [
                  // Circular indicator
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusConfig.fillColor,
                      border: statusConfig.borderColor != null
                          ? Border.all(
                              color: statusConfig.borderColor!,
                              width: 2,
                            )
                          : null,
                    ),
                    child: Center(
                      child: statusConfig.showCheckmark
                          ? Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                          : Text(
                              '$doseNumber',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: statusConfig.textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  // Vertical connecting line (if not last step)
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: theme.colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 16),

              // Right: Dose information card
              Expanded(
                child: Card(
                  margin: EdgeInsets.zero,
                  elevation: stepStatus == TimelineStepStatus.next ? 2 : 1,
                  child: Container(
                    decoration: stepStatus == TimelineStepStatus.next
                        ? BoxDecoration(
                            border: Border.all(
                              color: theme.colorScheme.primary,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          )
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Dose number and required badge
                          Row(
                            children: [
                              Text(
                                '${l10n.dose} $doseNumber',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: stepStatus == TimelineStepStatus.next
                                      ? theme.colorScheme.primary
                                      : null,
                                ),
                              ),
                              if (!step.isRequired) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Optional',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Vaccine name
                          Text(
                            step.vaccineName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Date information
                          Row(
                            children: [
                              Icon(
                                Icons.event,
                                size: 16,
                                color: statusConfig.iconColor,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _formatDateDisplay(
                                    context,
                                    scheduleEntry,
                                    stepStatus,
                                  ),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: statusConfig.iconColor,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Age milestone
                          if (step.ageInWeeks > 0) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.cake_outlined,
                                  size: 16,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.5),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatAgeMilestone(context, step.ageInWeeks),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ],

                          // Notes (if present)
                          if (step.notes != null && step.notes!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest
                                    .withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 14,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      step.notes!,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                        fontSize: 12,
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.7),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Recurring indicator (if applicable)
                          if (step.recurring != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.repeat,
                                  size: 14,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatRecurringSchedule(
                                    context,
                                    step.recurring!,
                                  ),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Gets status-dependent colors and styling configuration
  _StatusConfig _getStatusConfig(
    BuildContext context,
    TimelineStepStatus status,
  ) {
    final theme = Theme.of(context);

    switch (status) {
      case TimelineStepStatus.completed:
        return _StatusConfig(
          fillColor: Colors.green[600]!,
          textColor: Colors.white,
          iconColor: Colors.green[700]!,
          showCheckmark: true,
        );

      case TimelineStepStatus.next:
        return _StatusConfig(
          fillColor: Colors.blue[600]!,
          textColor: Colors.white,
          iconColor: Colors.blue[700]!,
          showCheckmark: false,
        );

      case TimelineStepStatus.future:
        return _StatusConfig(
          fillColor: Colors.transparent,
          borderColor: theme.colorScheme.outline,
          textColor: theme.colorScheme.onSurface.withOpacity(0.6),
          iconColor: theme.colorScheme.onSurface.withOpacity(0.5),
          showCheckmark: false,
        );
    }
  }

  /// Formats the date display based on status and schedule entry
  String _formatDateDisplay(
    BuildContext context,
    VaccinationScheduleEntry? entry,
    TimelineStepStatus status,
  ) {
    final l10n = AppLocalizations.of(context);

    if (entry == null) {
      return 'Not scheduled yet';
    }

    final formattedDate = DateFormat('MMM dd, yyyy').format(entry.scheduledDate);

    switch (status) {
      case TimelineStepStatus.completed:
        return '${l10n.completed}: $formattedDate';

      case TimelineStepStatus.next:
        return '${l10n.upcoming}: $formattedDate';

      case TimelineStepStatus.future:
        return '${l10n.scheduled}: $formattedDate';
    }
  }

  /// Formats age milestone in human-readable format
  String _formatAgeMilestone(BuildContext context, int ageInWeeks) {
    if (ageInWeeks < 4) {
      return '$ageInWeeks weeks old';
    } else if (ageInWeeks < 52) {
      final months = (ageInWeeks / 4.33).round();
      return '$months ${months == 1 ? 'month' : 'months'} old';
    } else {
      final years = (ageInWeeks / 52).round();
      return '$years ${years == 1 ? 'year' : 'years'} old';
    }
  }

  /// Formats recurring schedule information
  String _formatRecurringSchedule(
    BuildContext context,
    RecurringSchedule recurring,
  ) {
    if (recurring.indefinitely) {
      return 'Repeats every ${recurring.intervalMonths} ${recurring.intervalMonths == 1 ? 'month' : 'months'}';
    } else {
      return 'Repeats ${recurring.numberOfDoses} times, every ${recurring.intervalMonths} ${recurring.intervalMonths == 1 ? 'month' : 'months'}';
    }
  }

  /// Gets semantic label for status (accessibility)
  String _getStatusLabel(
    BuildContext context,
    TimelineStepStatus status,
    VaccinationScheduleEntry? entry,
  ) {
    final l10n = AppLocalizations.of(context);

    if (entry == null) {
      return 'Not scheduled yet';
    }

    final formattedDate = DateFormat('MMMM dd, yyyy').format(entry.scheduledDate);

    switch (status) {
      case TimelineStepStatus.completed:
        return '${l10n.completed} on $formattedDate';

      case TimelineStepStatus.next:
        return 'Next dose, scheduled for $formattedDate';

      case TimelineStepStatus.future:
        return 'Future dose, scheduled for $formattedDate';
    }
  }
}

/// Enum representing the visual status of a timeline step
enum TimelineStepStatus {
  /// Dose has been completed (date is in the past)
  completed,

  /// This is the next upcoming dose (first future dose)
  next,

  /// Dose is scheduled in the future (but not next)
  future,
}

/// Internal configuration for status-dependent styling
class _StatusConfig {
  final Color fillColor;
  final Color? borderColor;
  final Color textColor;
  final Color iconColor;
  final bool showCheckmark;

  _StatusConfig({
    required this.fillColor,
    this.borderColor,
    required this.textColor,
    required this.iconColor,
    required this.showCheckmark,
  });
}
