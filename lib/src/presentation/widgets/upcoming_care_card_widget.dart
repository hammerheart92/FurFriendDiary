// File: lib/src/presentation/widgets/upcoming_care_card_widget.dart
// Purpose: Reusable card widget to display upcoming care events with color-coded
//          left border, icon, title, due date, and relative time display.
//
// Usage:
// ```dart
// UpcomingCareCardWidget(
//   event: upcomingCareEvent,
//   onTap: () => navigateToDetails(event),
// )
// ```

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
import '../../domain/constants/vaccine_type_translations.dart';
import '../../domain/models/medication_entry.dart';
import '../models/upcoming_care_event.dart';

/// Medication status states for display logic
enum _MedicationStatus {
  notStarted,       // startDate is in the future
  activeIndefinite, // started, no endDate
  activeEndingSoon, // started, endDate within 7 days
  active,           // started, endDate > 7 days away
  ended,            // endDate is in the past
}

/// A reusable card widget for displaying upcoming care events (vaccinations,
/// deworming, appointments, medications) in horizontal scrollable lists.
///
/// **Design Specifications:**
/// - Fixed size: 280px width × 130px height
/// - 4px colored left border based on event type
/// - Material InkWell wrapper for tap ripple effect
/// - Color coding follows CalendarViewScreen patterns:
///   - Red: Vaccination (Colors.red[600])
///   - Amber/Yellow: Deworming (Colors.orange[700])
///   - Blue: Appointment (Colors.blue[600])
///   - Green: Medication (Colors.green[600])
///
/// **Accessibility:**
/// - Semantic labels for screen readers
/// - Color-blind friendly with icons
/// - Minimum 48x48 tap target size
class UpcomingCareCardWidget extends StatelessWidget {
  /// The upcoming care event to display
  final UpcomingCareEvent event;

  /// Callback invoked when user taps the card
  final VoidCallback onTap;

  const UpcomingCareCardWidget({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);
    final eventColor = _getEventColor(event);
    final dateFormat = DateFormat.yMMMMd(locale.languageCode);
    final relativeTime = _getRelativeTime(context, event.scheduledDate);

    return SizedBox(
      width: 280,
      height: 130,
      child: Card(
        elevation: 2,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: eventColor,
                  width: 4,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event icon and title
                  Row(
                    children: [
                      // Icon container
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: eventColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _buildEventIcon(event, eventColor, theme),
                      ),
                      const SizedBox(width: 12),

                      // Title
                      Expanded(
                        child: Text(
                          _getLocalizedTitle(context, event),
                          style: theme.textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Due date - context-aware for medications
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _getContextAwareDate(context, event, dateFormat),
                          style: theme.textTheme.bodySmall!.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Relative time
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getRelativeTimeColor(
                        event,
                        theme,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      relativeTime,
                      style: theme.textTheme.labelSmall!.copyWith(
                        color: _getRelativeTimeColor(
                          event,
                          theme,
                        ),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Get localized title for event
  String _getLocalizedTitle(BuildContext context, UpcomingCareEvent event) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    // For deworming events, use localized string
    if (event is DewormingEvent) {
      return l10n.dewormingTreatment;
    }

    // ISSUE 3 FIX: For vaccination events, translate vaccine type
    if (event is VaccinationEvent || event is VaccinationRecordEvent) {
      final vaccineType = event.title; // This is the vaccine type (e.g., "Rabies")
      return VaccineTypeTranslations.getDisplayName(vaccineType, locale);
    }

    // For other events, use the title from the event
    // (AppointmentEvent uses reason, MedicationEvent uses medication name - user data)
    return event.title;
  }

  /// Build event icon - custom calendar for appointments, emoji for others
  Widget _buildEventIcon(
    UpcomingCareEvent event,
    Color eventColor,
    ThemeData theme,
  ) {
    // For appointments, use custom calendar icon with actual date
    if (event is AppointmentEvent) {
      final date = event.scheduledDate;
      final monthAbbr = DateFormat('MMM').format(date).toUpperCase();
      final day = DateFormat('d').format(date);

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Month abbreviation
          Text(
            monthAbbr,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: eventColor,
              height: 1.0,
            ),
          ),
          // Day number
          Text(
            day,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: eventColor,
              height: 1.1,
            ),
          ),
        ],
      );
    }

    // For other events, use emoji icon
    return Center(
      child: Text(
        event.icon,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }

  /// Get color for event type using pattern matching
  Color _getEventColor(UpcomingCareEvent event) {
    // Use pattern matching on sealed class
    return switch (event) {
      VaccinationEvent() => Colors.red.shade600,
      VaccinationRecordEvent() => Colors.red.shade600,
      DewormingEvent() => Colors.orange.shade700,
      AppointmentEvent() => Colors.blue.shade600,
      MedicationEvent() => Colors.green.shade600,
    };
  }

  /// Get relative time string (today, tomorrow, overdue, in X days)
  /// For medications, shows treatment status instead of relative date
  String _getRelativeTime(BuildContext context, DateTime scheduledDate) {
    final l10n = AppLocalizations.of(context);

    // Special handling for medications
    if (event is MedicationEvent) {
      return _getMedicationStatus(context, event as MedicationEvent);
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final scheduleDay = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
    );

    // Calculate difference in days
    final difference = scheduleDay.difference(today).inDays;

    if (scheduleDay.isBefore(today)) {
      // Overdue
      final daysOverdue = today.difference(scheduleDay).inDays;
      return l10n.overdueByDays(daysOverdue);
    } else if (scheduleDay == today) {
      // Today
      return l10n.today;
    } else if (scheduleDay == tomorrow) {
      // Tomorrow
      return l10n.tomorrow;
    } else {
      // In X days
      return l10n.inDays(difference);
    }
  }

  /// Get medication treatment status
  /// Returns appropriate status text based on treatment period
  String _getMedicationStatus(BuildContext context, MedicationEvent event) {
    final l10n = AppLocalizations.of(context);
    final status = _determineMedicationStatus(event.entry);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (status) {
      case _MedicationStatus.notStarted:
        // Calculate days until start
        final startDay = DateTime(
          event.entry.startDate.year,
          event.entry.startDate.month,
          event.entry.startDate.day,
        );
        final daysUntil = startDay.difference(today).inDays;

        if (daysUntil == 1) {
          return l10n.startsTomorrow;
        } else {
          return l10n.startsInDays(daysUntil);
        }

      case _MedicationStatus.activeIndefinite:
      case _MedicationStatus.active:
        // Active medication
        return l10n.medicationActive;

      case _MedicationStatus.activeEndingSoon:
        // Calculate days until end
        final endDay = DateTime(
          event.entry.endDate!.year,
          event.entry.endDate!.month,
          event.entry.endDate!.day,
        );
        final daysUntilEnd = endDay.difference(today).inDays;

        if (daysUntilEnd == 0) {
          return l10n.medicationEndsToday;
        } else if (daysUntilEnd == 1) {
          return l10n.medicationEndsTomorrow;
        } else {
          return l10n.medicationEndsInDays(daysUntilEnd);
        }

      case _MedicationStatus.ended:
        // Treatment completed
        return l10n.treatmentCompleted;
    }
  }

  /// Determine the current status of a medication
  _MedicationStatus _determineMedicationStatus(MedicationEntry entry) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Normalize dates to midnight for accurate comparison
    final startDay = DateTime(
      entry.startDate.year,
      entry.startDate.month,
      entry.startDate.day,
    );

    // Check if medication hasn't started yet
    if (startDay.isAfter(today)) {
      return _MedicationStatus.notStarted;
    }

    // Check if medication has an end date
    if (entry.endDate != null) {
      final endDay = DateTime(
        entry.endDate!.year,
        entry.endDate!.month,
        entry.endDate!.day,
      );

      // Has ended
      if (endDay.isBefore(today)) {
        return _MedicationStatus.ended;
      }

      // Calculate days until end
      final daysUntilEnd = endDay.difference(today).inDays;

      // Ending soon (within 7 days)
      if (daysUntilEnd <= 7) {
        return _MedicationStatus.activeEndingSoon;
      }

      // Active with end date more than 7 days away
      return _MedicationStatus.active;
    }

    // Active with no end date (indefinite)
    return _MedicationStatus.activeIndefinite;
  }

  /// Get context-aware date display for events
  /// For medications, shows relevant date based on status
  /// For other events, shows scheduled date
  String _getContextAwareDate(
    BuildContext context,
    UpcomingCareEvent event,
    DateFormat dateFormat,
  ) {
    final l10n = AppLocalizations.of(context);

    // For non-medication events, show scheduled date as before
    if (event is! MedicationEvent) {
      return dateFormat.format(event.scheduledDate);
    }

    // For medications, show context-appropriate date
    final status = _determineMedicationStatus(event.entry);

    switch (status) {
      case _MedicationStatus.notStarted:
      case _MedicationStatus.activeIndefinite:
        // Show start date
        return '${l10n.started}: ${dateFormat.format(event.entry.startDate)}';

      case _MedicationStatus.activeEndingSoon:
      case _MedicationStatus.active:
      case _MedicationStatus.ended:
        // Show end date
        return '${l10n.ends}: ${dateFormat.format(event.entry.endDate!)}';
    }
  }

  /// Get color for relative time badge
  /// For medications, uses status-based colors
  /// For other events, uses date-based colors
  Color _getRelativeTimeColor(UpcomingCareEvent event, ThemeData theme) {
    // Special handling for medications
    if (event is MedicationEvent) {
      return _getMedicationStatusColor(event, theme);
    }

    // For non-medication events, use existing date-based logic
    final scheduledDate = event.scheduledDate;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final scheduleDay = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
    );

    if (scheduleDay.isBefore(today)) {
      // Overdue - red
      return Colors.red.shade700;
    } else if (scheduleDay == today) {
      // Today - amber
      return Colors.amber.shade700;
    } else if (scheduleDay.difference(today).inDays <= 3) {
      // Due soon (within 3 days) - amber
      return Colors.amber.shade700;
    } else {
      // Future - green
      return Colors.green.shade700;
    }
  }

  /// Get status-based color for medication badges
  Color _getMedicationStatusColor(MedicationEvent event, ThemeData theme) {
    final status = _determineMedicationStatus(event.entry);

    switch (status) {
      case _MedicationStatus.notStarted:
        // Future medication - blue
        return Colors.blue.shade700;

      case _MedicationStatus.activeIndefinite:
      case _MedicationStatus.active:
        // Active - green
        return Colors.green.shade700;

      case _MedicationStatus.activeEndingSoon:
        // Ending soon - orange
        return Colors.orange.shade700;

      case _MedicationStatus.ended:
        // Ended - gray
        return Colors.grey.shade600;
    }
  }
}
