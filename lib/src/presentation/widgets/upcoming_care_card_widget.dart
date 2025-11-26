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
import '../models/upcoming_care_event.dart';

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
    final eventColor = _getEventColor(event);
    final dateFormat = DateFormat.yMMMMd();
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
                          event.title,
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

                  // Due date
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateFormat.format(event.scheduledDate),
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
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
                        event.scheduledDate,
                        theme,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      relativeTime,
                      style: theme.textTheme.labelSmall!.copyWith(
                        color: _getRelativeTimeColor(
                          event.scheduledDate,
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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDay = DateTime(
      event.entry.startDate.year,
      event.entry.startDate.month,
      event.entry.startDate.day,
    );

    // Future medication - hasn't started yet
    if (startDay.isAfter(today)) {
      final daysUntil = startDay.difference(today).inDays;
      if (daysUntil == 1) {
        return l10n.startsTomorrow;
      } else {
        return l10n.startsInDays(daysUntil);
      }
    }

    // Check if medication has ended
    if (event.entry.endDate != null) {
      final endDay = DateTime(
        event.entry.endDate!.year,
        event.entry.endDate!.month,
        event.entry.endDate!.day,
      );

      if (endDay.isBefore(today)) {
        // Treatment ended in the past
        return l10n.treatmentCompleted;
      } else {
        // Active treatment (started and not ended yet)
        return l10n.dueToday;
      }
    }

    // Ongoing medication (no end date, has started)
    return l10n.dueToday;
  }

  /// Get color for relative time badge
  Color _getRelativeTimeColor(DateTime scheduledDate, ThemeData theme) {
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
}
