import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
import '../../models/upcoming_care_event.dart';
import '../../providers/protocols/protocol_schedule_provider.dart';
import '../../providers/pet_profile_provider.dart';

/// Calendar View Screen - Visual centerpiece of smart scheduling feature
///
/// Displays upcoming care events in a monthly calendar view with color-coded
/// event markers and detailed day view. Allows filtering by event type.
///
/// Features:
/// - Monthly calendar with table_calendar package
/// - Color-coded event markers (vaccination/deworming/appointment/medication)
/// - Filter chips for event type filtering
/// - Selected day details with event list
/// - Navigation to event detail screens
/// - Empty states for no pet, no events, and no events on selected day
///
/// Usage:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => const CalendarViewScreen(),
///   ),
/// );
/// ```
class CalendarViewScreen extends ConsumerStatefulWidget {
  const CalendarViewScreen({super.key});

  @override
  ConsumerState<CalendarViewScreen> createState() =>
      _CalendarViewScreenState();
}

class _CalendarViewScreenState extends ConsumerState<CalendarViewScreen> {
  final Logger _logger = Logger();

  // Calendar state
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  String? _selectedFilter; // null = 'All', or event type string

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _selectedFilter = null; // Show all by default
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    // Get current pet
    final currentPet = ref.watch(currentPetProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.calendarView),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Semantics(
          label: l10n.calendarView,
          child: currentPet == null
              ? _buildNoPetState(context, l10n, theme)
              : _buildCalendarContent(context, l10n, theme, currentPet.id),
        ),
      ),
    );
  }

  /// Build calendar content with events
  Widget _buildCalendarContent(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    String petId,
  ) {
    // Watch upcoming care events
    final upcomingCareAsync = ref.watch(
      upcomingCareProvider(
        petId: petId,
        daysAhead: 365, // 12 months ahead for annual protocols
      ),
    );

    return upcomingCareAsync.when(
      loading: () => _buildLoadingState(l10n),
      error: (error, stack) => _buildErrorState(context, l10n, theme, error),
      data: (allEvents) {
        if (allEvents.isEmpty) {
          return _buildEmptyStateNoEvents(context, l10n, theme);
        }

        // Apply filter
        final filteredEvents = _selectedFilter == null
            ? allEvents
            : allEvents.where((e) => e.eventType == _selectedFilter).toList();

        final eventMap = _groupEventsByDate(filteredEvents);
        final selectedDayEvents = _getEventsForDay(_selectedDay, eventMap);

        return Column(
          children: [
            // Filter chips
            _buildFilterChips(l10n, theme, allEvents),

            // Calendar
            TableCalendar<UpcomingCareEvent>(
              locale: Localizations.localeOf(context).languageCode,
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
              // Styling
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 3, // Show up to 3 dots
              ),
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: theme.textTheme.titleLarge!,
              ),
              // Event markers
              eventLoader: (day) => _getEventsForDay(day, eventMap),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  if (events.isEmpty) return const SizedBox.shrink();

                  return _buildEventMarkers(
                    events.cast<UpcomingCareEvent>(),
                    theme,
                  );
                },
              ),
            ),

            const Divider(height: 1),

            // Selected day details
            Expanded(
              child: _buildSelectedDayDetails(
                context,
                selectedDayEvents,
                l10n,
                theme,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Group events by date for efficient lookup
  Map<DateTime, List<UpcomingCareEvent>> _groupEventsByDate(
    List<UpcomingCareEvent> events,
  ) {
    final grouped = <DateTime, List<UpcomingCareEvent>>{};

    for (final event in events) {
      final dateKey = DateTime(
        event.scheduledDate.year,
        event.scheduledDate.month,
        event.scheduledDate.day,
      );

      grouped.putIfAbsent(dateKey, () => []).add(event);
    }

    return grouped;
  }

  /// Get events for a specific day
  List<UpcomingCareEvent> _getEventsForDay(
    DateTime day,
    Map<DateTime, List<UpcomingCareEvent>> eventMap,
  ) {
    final dateKey = DateTime(day.year, day.month, day.day);
    return eventMap[dateKey] ?? [];
  }

  /// Build filter chips
  Widget _buildFilterChips(
    AppLocalizations l10n,
    ThemeData theme,
    List<UpcomingCareEvent> allEvents,
  ) {
    // Count events by type for badge display
    final eventCounts = <String, int>{};
    for (final event in allEvents) {
      eventCounts[event.eventType] = (eventCounts[event.eventType] ?? 0) + 1;
    }

    final filters = [
      _FilterOption(null, l10n.all, Icons.calendar_today, null),
      _FilterOption(
        'vaccination',
        l10n.vaccinations,
        Icons.vaccines,
        Colors.red.shade600,
      ),
      _FilterOption(
        'deworming',
        l10n.deworming,
        Icons.pest_control,
        Colors.amber.shade700,
      ),
      _FilterOption(
        'appointment',
        l10n.appointments,
        Icons.event,
        Colors.blue.shade600,
      ),
      _FilterOption(
        'medication',
        l10n.medications,
        Icons.medication,
        Colors.green.shade600,
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = _selectedFilter == filter.value;
            final count = filter.value == null
                ? allEvents.length
                : (eventCounts[filter.value] ?? 0);

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      filter.icon,
                      size: 16,
                      color: isSelected
                          ? theme.colorScheme.onSecondaryContainer
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(filter.label),
                    if (count > 0) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.onSecondaryContainer
                                  .withOpacity(0.2)
                              : theme.colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$count',
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                    ],
                  ],
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = selected ? filter.value : null;
                  });
                },
                backgroundColor: theme.colorScheme.surface,
                selectedColor: theme.colorScheme.secondaryContainer,
                checkmarkColor: theme.colorScheme.onSecondaryContainer,
                side: BorderSide(
                  color: isSelected
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.outline.withOpacity(0.3),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Build event markers (multiple colored dots)
  Widget _buildEventMarkers(
    List<UpcomingCareEvent> events,
    ThemeData theme,
  ) {
    // Get unique event types for this day
    final eventTypes = <String>{};
    for (final event in events) {
      eventTypes.add(event.eventType);
    }

    // Limit to 3 markers max to avoid clutter
    final displayTypes = eventTypes.take(3).toList();

    return Positioned(
      bottom: 2,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: displayTypes.map((type) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 1),
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: _getEventTypeColor(type, theme),
              shape: BoxShape.circle,
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Get color for event type
  Color _getEventTypeColor(String eventType, ThemeData theme) {
    switch (eventType) {
      case 'vaccination':
      case 'vaccination_record':
        return Colors.red.shade600; // Red
      case 'deworming':
        return Colors.amber.shade700; // Yellow/Amber
      case 'appointment':
        return Colors.blue.shade600; // Blue
      case 'medication':
        return Colors.green.shade600; // Green
      default:
        return theme.colorScheme.secondary;
    }
  }

  /// Build selected day details
  Widget _buildSelectedDayDetails(
    BuildContext context,
    List<UpcomingCareEvent> events,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    if (events.isEmpty) {
      return _buildEmptyDayState(l10n, theme);
    }

    final locale = Localizations.localeOf(context).languageCode;
    final dateFormat = DateFormat.yMMMMd(locale);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.event,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                dateFormat.format(_selectedDay),
                style: theme.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                '${events.length} ${events.length == 1 ? l10n.eventSingular : l10n.eventPlural}',
                style: theme.textTheme.labelMedium!.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        // Event list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return _EventListTile(
                event: event,
                theme: theme,
                l10n: l10n,
                onTap: () => _navigateToEventDetails(context, event, l10n),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Navigate to event details based on event type
  void _navigateToEventDetails(
    BuildContext context,
    UpcomingCareEvent event,
    AppLocalizations l10n,
  ) {
    _logger.d('Navigating to event details: ${event.eventType}');

    switch (event) {
      case MedicationEvent(:final entry):
        // Navigate to medication detail screen
        context.push('/meds/detail/${entry.id}');
        break;

      case AppointmentEvent():
        // Navigate to Appointments tab
        context.go('/appointments');
        break;

      case VaccinationEvent():
        // Navigate to vaccination timeline screen
        context.push('/vaccinations');
        break;

      case VaccinationRecordEvent():
        // Navigate to specific vaccination detail
        context.push('/vaccinations/detail/${event.id}');
        break;

      case DewormingEvent():
        // Navigate to deworming schedule screen
        final pet = ref.read(currentPetProfileProvider);
        if (pet != null) {
          context.push('/deworming/schedule/${pet.id}', extra: pet);
        }
        break;
    }
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
            l10n.loadingCalendar,
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
    ThemeData theme,
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
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.failedToLoadCalendar,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => ref.invalidate(upcomingCareProvider),
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state when no pet is selected
  Widget _buildNoPetState(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.2),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noPetSelected,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.pleaseSetupPetFirst,
              style: theme.textTheme.bodyMedium!.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state when no events exist at all
  Widget _buildEmptyStateNoEvents(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.2),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noUpcomingCareEvents,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.setupProtocolsToSeeEvents,
              style: theme.textTheme.bodyMedium!.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                // Navigate to protocol selection (will be implemented)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.setUpProtocols)),
                );
              },
              icon: const Icon(Icons.vaccines),
              label: Text(l10n.setUpProtocols),
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state when no events on selected day
  Widget _buildEmptyDayState(
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noEventsOnThisDay,
              style: theme.textTheme.titleMedium!.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.selectAnotherDay,
              style: theme.textTheme.bodySmall!.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// INLINE WIDGETS
// ============================================================================

/// Filter option data class
class _FilterOption {
  final String? value; // null = 'All'
  final String label;
  final IconData icon;
  final Color? color;

  const _FilterOption(this.value, this.label, this.icon, this.color);
}

/// Event list tile - individual event card
class _EventListTile extends StatelessWidget {
  final UpcomingCareEvent event;
  final ThemeData theme;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _EventListTile({
    required this.event,
    required this.theme,
    required this.l10n,
    required this.onTap,
  });

  /// Get localized title for the event
  String _getLocalizedTitle() {
    if (event is DewormingEvent) {
      return l10n.dewormingTreatment;
    } else if (event is VaccinationEvent) {
      return l10n.vaccination;
    } else if (event is MedicationEvent) {
      return l10n.medication;
    } else if (event is AppointmentEvent) {
      return l10n.veterinaryAppointment;
    }
    return event.title;
  }

  /// Get localized description for events (vaccination, deworming, etc.)
  String _getLocalizedDescription(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isRomanian = locale.languageCode == 'ro';

    print('📅 [CALENDAR] Event type: ${event.runtimeType}');
    print('📅 [CALENDAR] Locale: ${locale.languageCode}');

    // Handle VaccinationEvent with Romanian localization (protocol-generated scheduled events)
    if (event is VaccinationEvent) {
      final vaccinationEvent = event as VaccinationEvent;
      print('📅 [VACCINATION] notes: ${vaccinationEvent.entry.notes}');
      print('📅 [VACCINATION] notesRo: ${vaccinationEvent.entry.notesRo}');
      return vaccinationEvent.getLocalizedDescription(locale.languageCode);
    }

    // Handle VaccinationRecordEvent with Romanian localization (stored records)
    if (event is VaccinationRecordEvent) {
      final recordEvent = event as VaccinationRecordEvent;
      print('📅 [VACCINATION_RECORD] notes: ${recordEvent.record.notes}');
      print('📅 [VACCINATION_RECORD] notesRo: ${recordEvent.record.notesRo}');
      return recordEvent.getLocalizedDescription(locale.languageCode);
    }

    // Handle DewormingEvent with Romanian localization
    if (event is DewormingEvent) {
      final dewormingEvent = event as DewormingEvent;
      final parts = <String>[];

      // Translate deworming type
      final typeLabel = dewormingEvent.entry.dewormingType == 'internal'
          ? l10n.internalDeworming
          : l10n.externalDeworming;
      parts.add(typeLabel);

      // Add product name if available
      if (dewormingEvent.entry.productName != null &&
          dewormingEvent.entry.productName!.isNotEmpty) {
        parts.add(dewormingEvent.entry.productName!);
      }

      // Add notes if available (use Romanian if locale matches)
      final notes = (isRomanian && dewormingEvent.entry.notesRo != null && dewormingEvent.entry.notesRo!.isNotEmpty)
          ? dewormingEvent.entry.notesRo!
          : dewormingEvent.entry.notes;
      if (notes != null && notes.isNotEmpty) {
        parts.add(notes);
      }

      return parts.join(' - ');
    }
    return event.description;
  }

  @override
  Widget build(BuildContext context) {
    final eventColor = _getEventTypeColor(event.eventType);
    final statusInfo = _getEventStatus(event);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: eventColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Color indicator
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  color: eventColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),

              // Event icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: eventColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _buildEventIcon(context, event, eventColor),
              ),
              const SizedBox(width: 12),

              // Event details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _getLocalizedTitle(),
                            style: theme.textTheme.titleSmall!.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (statusInfo.badgeText != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: statusInfo.badgeColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              statusInfo.badgeText!.toUpperCase(),
                              style: theme.textTheme.labelSmall!.copyWith(
                                color: statusInfo.badgeTextColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getLocalizedDescription(context),
                      style: theme.textTheme.bodySmall!.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Navigation arrow
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build event icon - custom calendar for appointments, emoji for others
  Widget _buildEventIcon(BuildContext context, UpcomingCareEvent event, Color eventColor) {
    // For appointments, use custom calendar icon with actual date
    if (event is AppointmentEvent) {
      final date = event.scheduledDate;
      final locale = Localizations.localeOf(context).languageCode;
      final monthAbbr = DateFormat('MMM', locale).format(date).toUpperCase();
      final day = DateFormat('d', locale).format(date);

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

  Color _getEventTypeColor(String eventType) {
    switch (eventType) {
      case 'vaccination':
        return Colors.red.shade600;
      case 'deworming':
        return Colors.amber.shade700;
      case 'appointment':
        return Colors.blue.shade600;
      case 'medication':
        return Colors.green.shade600;
      default:
        return theme.colorScheme.secondary;
    }
  }

  /// Get event status info (badge text, colors)
  /// Returns appropriate status for different event types
  _EventStatusInfo _getEventStatus(UpcomingCareEvent event) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Special handling for medications
    if (event is MedicationEvent) {
      final startDay = DateTime(
        event.entry.startDate.year,
        event.entry.startDate.month,
        event.entry.startDate.day,
      );

      // Future medication - hasn't started yet
      if (startDay.isAfter(today)) {
        return _EventStatusInfo(
          badgeText: null, // No badge for future medications
          badgeColor: Colors.transparent,
          badgeTextColor: Colors.transparent,
        );
      }

      // Check if medication has ended
      if (event.entry.endDate != null) {
        final endDay = DateTime(
          event.entry.endDate!.year,
          event.entry.endDate!.month,
          event.entry.endDate!.day,
        );

        if (endDay.isBefore(today)) {
          // Treatment ended - show completed badge
          return _EventStatusInfo(
            badgeText: l10n.treatmentCompleted,
            badgeColor: Colors.green.shade100,
            badgeTextColor: Colors.green.shade900,
          );
        }
      }

      // Active or ongoing medication - no badge (just show in list)
      return _EventStatusInfo(
        badgeText: null,
        badgeColor: Colors.transparent,
        badgeTextColor: Colors.transparent,
      );
    }

    // For other event types (vaccination, deworming, appointment)
    // Show overdue badge if scheduled date has passed
    final scheduleDay = DateTime(
      event.scheduledDate.year,
      event.scheduledDate.month,
      event.scheduledDate.day,
    );

    if (scheduleDay.isBefore(today)) {
      return _EventStatusInfo(
        badgeText: l10n.overdue,
        badgeColor: Colors.red.shade100,
        badgeTextColor: Colors.red.shade900,
      );
    }

    // No badge for future events
    return _EventStatusInfo(
      badgeText: null,
      badgeColor: Colors.transparent,
      badgeTextColor: Colors.transparent,
    );
  }
}

/// Event status information data class
class _EventStatusInfo {
  final String? badgeText;
  final Color badgeColor;
  final Color badgeTextColor;

  const _EventStatusInfo({
    required this.badgeText,
    required this.badgeColor,
    required this.badgeTextColor,
  });
}
