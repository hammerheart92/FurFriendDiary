// File: lib/src/presentation/screens/protocols/deworming_schedule_screen.dart
// Purpose: Displays the complete deworming treatment timeline for a pet
//
// Navigation: Expects a PetProfile object via route parameter
// Shows: Treatment dates, type (internal/external), product, status badges

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
import '../../../domain/models/pet_profile.dart';
import '../../providers/protocols/protocol_schedule_provider.dart';
import '../../providers/protocols/deworming_protocol_provider.dart';
import '../../../data/services/protocols/schedule_models.dart';

/// Deworming Schedule Screen - Displays complete treatment timeline
///
/// This screen shows all scheduled deworming treatments for a pet, including:
/// - Treatment dates with status indicators (completed/upcoming/overdue)
/// - Treatment type (internal worms vs external parasites)
/// - Product recommendations
/// - Notes and instructions
///
/// **Edge Cases Handled:**
/// - No birthday set: Shows error message prompting to add birthday
/// - No protocol assigned: Shows message with button to select protocol
/// - All treatments completed: Shows congratulations message
/// - Empty schedule: Shows appropriate message
///
/// **Missing Localization Strings (TODO: Add these):**
/// - treatment, treatmentHistory
/// - noBirthdaySet, addBirthdayToViewSchedule
/// - noScheduleAvailable, protocolMayNotApplyYet
/// - allTreatmentsCompleted, completedAllScheduledTreatments
class DewormingScheduleScreen extends ConsumerWidget {
  final PetProfile pet;
  final Logger _logger = Logger();

  DewormingScheduleScreen({
    super.key,
    required this.pet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheduleAsync = ref.watch(dewormingScheduleProvider(pet.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dewormingStatus),
        centerTitle: true,
      ),
      body: scheduleAsync.when(
        data: (schedule) {
          // Edge case: No protocol assigned
          if (pet.dewormingProtocolId == null) {
            return _buildNoProtocolMessage(context, l10n, theme);
          }

          // Edge case: No birthday set
          if (pet.birthday == null) {
            return _buildNoBirthdayMessage(context, l10n, theme);
          }

          // Edge case: Empty schedule
          if (schedule.isEmpty) {
            return _buildEmptyScheduleMessage(context, l10n, theme);
          }

          // Edge case: All treatments completed
          final now = DateTime.now();
          final allCompleted =
              schedule.every((entry) => entry.scheduledDate.isBefore(now));
          if (allCompleted) {
            return _buildAllCompletedMessage(context, l10n, theme, schedule);
          }

          // Normal case: Display timeline
          return _buildScheduleTimeline(context, ref, l10n, theme, schedule);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          _logger.e('Error loading deworming schedule',
              error: error, stackTrace: stackTrace);
          return _buildErrorMessage(context, l10n, theme, error);
        },
      ),
    );
  }

  // ========================================================================
  // TIMELINE BUILDER
  // ========================================================================

  Widget _buildScheduleTimeline(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    ThemeData theme,
    List<DewormingScheduleEntry> schedule,
  ) {
    final protocolAsync =
        ref.watch(dewormingProtocolByIdProvider(pet.dewormingProtocolId!));

    return protocolAsync.when(
      data: (protocol) {
        if (protocol == null) {
          return _buildNoProtocolMessage(context, l10n, theme);
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Protocol header
              _buildProtocolHeader(context, l10n, theme, protocol),
              const SizedBox(height: 16),

              // Pet info card
              _buildPetInfoCard(context, l10n, theme),
              const SizedBox(height: 24),

              // Timeline
              ...List.generate(schedule.length, (index) {
                final entry = schedule[index];
                final isLast = index == schedule.length - 1;
                final status = _determineStatus(entry, schedule, index);

                return _buildTimelineItem(
                  context: context,
                  l10n: l10n,
                  theme: theme,
                  entry: entry,
                  treatmentNumber: index + 1,
                  status: status,
                  isLast: isLast,
                );
              }),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => _buildNoProtocolMessage(context, l10n, theme),
    );
  }

  // ========================================================================
  // HEADER & INFO CARDS
  // ========================================================================

  Widget _buildProtocolHeader(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    protocol,
  ) {
    // Use Romanian name/description if locale is Romanian and they exist
    final locale = Localizations.localeOf(context);
    final isRomanian = locale.languageCode == 'ro';
    final displayName = (isRomanian && protocol.nameRo != null)
        ? protocol.nameRo!
        : protocol.name;
    final displayDescription = (isRomanian && protocol.descriptionRo != null)
        ? protocol.descriptionRo!
        : protocol.description;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.orange.shade200, width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bug_report,
                color: Colors.orange.shade700,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  displayName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            displayDescription,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.orange.shade800,
            ),
          ),
          if (protocol.region != null) ...[
            const SizedBox(height: 4),
            Text(
              l10n.regionLabel(protocol.region!),
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.orange.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPetInfoCard(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.pets,
                color: theme.colorScheme.onPrimaryContainer,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${pet.species}${pet.breed != null ? ' • ${pet.breed}' : ''}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  if (pet.birthday != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      l10n.birthDateLabel(
                        DateFormat.yMMMd(
                                Localizations.localeOf(context).languageCode)
                            .format(pet.birthday!),
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================================================
  // TIMELINE ITEM BUILDER
  // ========================================================================

  Widget _buildTimelineItem({
    required BuildContext context,
    required AppLocalizations l10n,
    required ThemeData theme,
    required DewormingScheduleEntry entry,
    required int treatmentNumber,
    required TreatmentStatus status,
    required bool isLast,
  }) {
    final statusConfig = _getStatusConfig(theme, status);

    return Semantics(
      label:
          '${l10n.treatmentNumber(treatmentNumber)}: ${_getTreatmentTypeLabel(l10n, entry.dewormingType)}, '
          '${_getStatusLabel(l10n, status, entry, context)}',
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Timeline indicator column
              Column(
                children: [
                  // Circular indicator
                  Container(
                    width: 40,
                    height: 40,
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
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 24,
                            )
                          : Icon(
                              _getTreatmentIcon(entry.dewormingType),
                              color: statusConfig.iconColor,
                              size: 20,
                            ),
                    ),
                  ),

                  // Vertical connecting line (if not last)
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

              // Right: Treatment information card
              Expanded(
                child: Card(
                  margin: EdgeInsets.zero,
                  elevation: status == TreatmentStatus.next ? 2 : 1,
                  child: Container(
                    decoration: status == TreatmentStatus.next
                        ? BoxDecoration(
                            border: Border.all(
                              color: Colors.blue.shade600,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          )
                        : status == TreatmentStatus.overdue
                            ? BoxDecoration(
                                border: Border.all(
                                  color: Colors.red.shade400,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              )
                            : null,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Treatment number and type badge
                          Row(
                            children: [
                              Text(
                                l10n.treatmentNumber(treatmentNumber),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: status == TreatmentStatus.next
                                      ? Colors.blue.shade700
                                      : status == TreatmentStatus.overdue
                                          ? Colors.red.shade700
                                          : null,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildTypeChip(l10n, theme, entry.dewormingType),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Date with status
                          Row(
                            children: [
                              Icon(
                                Icons.event,
                                size: 16,
                                color: statusConfig.iconColor,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _formatDateDisplay(
                                      l10n, entry, status, context),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: statusConfig.iconColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Product name
                          if (entry.productName != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.medication,
                                  size: 16,
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.7),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    entry.productName!,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],

                          // Notes (use Romanian if available and locale matches)
                          if (entry.notes != null &&
                              entry.notes!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Builder(
                              builder: (context) {
                                final locale = Localizations.localeOf(context);
                                final isRomanian = locale.languageCode == 'ro';
                                final displayNotes = (isRomanian &&
                                        entry.notesRo != null &&
                                        entry.notesRo!.isNotEmpty)
                                    ? entry.notesRo!
                                    : entry.notes!;
                                return Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: theme
                                        .colorScheme.surfaceContainerHighest
                                        .withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          displayNotes,
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
                                );
                              },
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

  // ========================================================================
  // EDGE CASE MESSAGES
  // ========================================================================

  Widget _buildNoProtocolMessage(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bug_report,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noDewormingProtocol,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.chooseDewormingProtocol,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: Text(l10n.goBack),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoBirthdayMessage(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cake,
              size: 64,
              color: theme.colorScheme.error.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noBirthdaySet,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.addBirthdayToViewSchedule,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.edit),
              label: Text(l10n.editProfile),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyScheduleMessage(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noScheduleAvailable,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.protocolMayNotApplyYet,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllCompletedMessage(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    List<DewormingScheduleEntry> schedule,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 48),
          Icon(
            Icons.celebration,
            size: 80,
            color: Colors.green.shade600,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              l10n.allTreatmentsCompleted,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              l10n.completedAllScheduledTreatments,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),

          // Show completed treatments
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n.treatmentHistory,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),

          ...List.generate(schedule.length, (index) {
            final entry = schedule[index];
            return _buildCompletedTreatmentCard(
                context, l10n, theme, entry, index + 1);
          }),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCompletedTreatmentCard(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    DewormingScheduleEntry entry,
    int number,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Icon(
            Icons.check,
            color: Colors.green.shade700,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Text(l10n.treatmentNumber(number)),
            const SizedBox(width: 8),
            _buildTypeChip(l10n, theme, entry.dewormingType),
          ],
        ),
        subtitle: Text(
          DateFormat.yMMMd(Localizations.localeOf(context).languageCode)
              .format(entry.scheduledDate),
          style: theme.textTheme.bodySmall,
        ),
        trailing: Icon(
          _getTreatmentIcon(entry.dewormingType),
          color: theme.colorScheme.primary.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    Object error,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
              l10n.errorLoadingSchedule,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: Text(l10n.goBack),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================================================
  // HELPER WIDGETS & FORMATTERS
  // ========================================================================

  Widget _buildTypeChip(AppLocalizations l10n, ThemeData theme, String type) {
    final isInternal = type == 'internal';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isInternal ? Colors.amber.shade100 : Colors.orange.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isInternal ? Colors.amber.shade700 : Colors.orange.shade700,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getTreatmentIcon(type),
            size: 12,
            color: isInternal ? Colors.amber.shade900 : Colors.orange.shade900,
          ),
          const SizedBox(width: 4),
          Text(
            _getTreatmentTypeLabel(l10n, type),
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color:
                  isInternal ? Colors.amber.shade900 : Colors.orange.shade900,
            ),
          ),
        ],
      ),
    );
  }

  TreatmentStatus _determineStatus(
    DewormingScheduleEntry entry,
    List<DewormingScheduleEntry> allEntries,
    int currentIndex,
  ) {
    final now = DateTime.now();
    final scheduledDate = entry.scheduledDate;

    // Check if completed (past)
    if (scheduledDate.isBefore(now)) {
      return TreatmentStatus.completed;
    }

    // Check if overdue (should have been done but wasn't)
    if (scheduledDate.isBefore(now.subtract(const Duration(days: 7)))) {
      return TreatmentStatus.overdue;
    }

    // Find next upcoming treatment
    final futureEntries = allEntries
        .where((e) => e.scheduledDate.isAfter(now))
        .toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

    if (futureEntries.isNotEmpty && futureEntries.first == entry) {
      return TreatmentStatus.next;
    }

    return TreatmentStatus.future;
  }

  _StatusConfig _getStatusConfig(ThemeData theme, TreatmentStatus status) {
    switch (status) {
      case TreatmentStatus.completed:
        return _StatusConfig(
          fillColor: Colors.green.shade600,
          iconColor: Colors.white,
          showCheckmark: true,
        );

      case TreatmentStatus.next:
        return _StatusConfig(
          fillColor: Colors.blue.shade600,
          iconColor: Colors.white,
          showCheckmark: false,
        );

      case TreatmentStatus.overdue:
        return _StatusConfig(
          fillColor: Colors.red.shade600,
          iconColor: Colors.white,
          showCheckmark: false,
        );

      case TreatmentStatus.future:
        return _StatusConfig(
          fillColor: Colors.transparent,
          borderColor: theme.colorScheme.outline,
          iconColor: theme.colorScheme.onSurface.withOpacity(0.6),
          showCheckmark: false,
        );
    }
  }

  String _formatDateDisplay(
    AppLocalizations l10n,
    DewormingScheduleEntry entry,
    TreatmentStatus status,
    BuildContext context,
  ) {
    // Use the intl package's current locale
    final locale = Localizations.localeOf(context).languageCode;
    final formattedDate = DateFormat.yMMMd(locale).format(entry.scheduledDate);

    switch (status) {
      case TreatmentStatus.completed:
        return '${l10n.completed}: $formattedDate';
      case TreatmentStatus.next:
        return '${l10n.upcoming}: $formattedDate';
      case TreatmentStatus.overdue:
        return '${l10n.overdue}: $formattedDate';
      case TreatmentStatus.future:
        return '${l10n.scheduled}: $formattedDate';
    }
  }

  String _getStatusLabel(
    AppLocalizations l10n,
    TreatmentStatus status,
    DewormingScheduleEntry entry,
    BuildContext context,
  ) {
    final locale = Localizations.localeOf(context).languageCode;
    final formattedDate = DateFormat.yMMMMd(locale).format(entry.scheduledDate);

    switch (status) {
      case TreatmentStatus.completed:
        return '${l10n.completed} on $formattedDate';
      case TreatmentStatus.next:
        return 'Next treatment, scheduled for $formattedDate';
      case TreatmentStatus.overdue:
        return 'Overdue treatment, was scheduled for $formattedDate';
      case TreatmentStatus.future:
        return 'Future treatment, scheduled for $formattedDate';
    }
  }

  String _getTreatmentTypeLabel(AppLocalizations l10n, String type) {
    return type == 'internal' ? l10n.internalDeworming : l10n.externalDeworming;
  }

  IconData _getTreatmentIcon(String type) {
    return type == 'internal' ? Icons.medication : Icons.pest_control;
  }
}

// ============================================================================
// ENUMS & DATA CLASSES
// ============================================================================

/// Status of a treatment in the timeline
enum TreatmentStatus {
  /// Treatment has been completed (date is in the past)
  completed,

  /// This is the next upcoming treatment
  next,

  /// Treatment is overdue (past due date but not marked as completed)
  overdue,

  /// Treatment is scheduled in the future
  future,
}

/// Internal configuration for status-dependent styling
class _StatusConfig {
  final Color fillColor;
  final Color? borderColor;
  final Color iconColor;
  final bool showCheckmark;

  _StatusConfig({
    required this.fillColor,
    this.borderColor,
    required this.iconColor,
    required this.showCheckmark,
  });
}
