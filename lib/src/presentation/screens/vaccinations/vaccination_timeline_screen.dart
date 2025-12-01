// File: lib/src/presentation/screens/vaccinations/vaccination_timeline_screen.dart
// Purpose: Displays the complete vaccination timeline for a pet
//
// Navigation: Uses currentPetProfileProvider to get active pet
// Shows: Vaccination dates, vaccine types, status badges, veterinarian/clinic info
// Actions: Navigate to add/detail screens

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
import '../../../domain/models/vaccination_event.dart';
import '../../../domain/models/pet_profile.dart';
import '../../../domain/constants/vaccine_type_translations.dart';
import '../../providers/vaccinations_provider.dart';
import '../../providers/pet_profile_provider.dart';

/// Vaccination Timeline Screen - Displays complete vaccination timeline
///
/// This screen shows all vaccination records for the current pet, organized by:
/// - Overdue vaccinations (past nextDueDate, red badge)
/// - Upcoming vaccinations (future nextDueDate, blue badge)
/// - Completed vaccinations (administeredDate in past, green badge)
///
/// **Edge Cases Handled:**
/// - No pet selected: Shows error message prompting to add pet
/// - No vaccinations: Shows empty state with add button
/// - Error loading: Shows error message with retry button
///
/// **UX Features:**
/// - Status-coded badges (overdue=red, upcoming=blue, completed=green)
/// - Timeline view with connecting lines
/// - Quick actions via FAB
/// - Tap to view details
class VaccinationTimelineScreen extends ConsumerWidget {
  final Logger _logger = Logger();

  VaccinationTimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final currentPet = ref.watch(currentPetProfileProvider);

    // Edge case: No pet selected
    if (currentPet == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.vaccinations),
          centerTitle: true,
        ),
        body: _buildNoPetMessage(context, l10n, theme),
      );
    }

    final vaccinationsAsync =
        ref.watch(vaccinationsByPetIdProvider(currentPet.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.vaccinations),
        centerTitle: true,
        actions: [
          // Add button in AppBar
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/vaccinations/add/${currentPet.id}'),
            tooltip: l10n.add,
            // Accessibility: Minimum 48x48 tap target
          ),
        ],
      ),
      body: vaccinationsAsync.when(
        data: (vaccinations) {
          // Edge case: No vaccinations
          if (vaccinations.isEmpty) {
            return _buildEmptyState(context, ref, l10n, theme, currentPet);
          }

          // Organize vaccinations by status
          final now = DateTime.now();
          final overdue = <VaccinationEvent>[];
          final upcoming = <VaccinationEvent>[];
          final completed = <VaccinationEvent>[];

          for (final vax in vaccinations) {
            final status = _determineStatus(vax, now);
            switch (status) {
              case VaccinationStatus.overdue:
                overdue.add(vax);
                break;
              case VaccinationStatus.upcoming:
                upcoming.add(vax);
                break;
              case VaccinationStatus.completed:
                completed.add(vax);
                break;
            }
          }

          // Sort: overdue by oldest first, upcoming by soonest first, completed by newest first
          overdue.sort((a, b) => (a.nextDueDate ?? a.administeredDate)
              .compareTo(b.nextDueDate ?? b.administeredDate));
          upcoming.sort((a, b) => (a.nextDueDate ?? a.administeredDate)
              .compareTo(b.nextDueDate ?? b.administeredDate));
          completed
              .sort((a, b) => b.administeredDate.compareTo(a.administeredDate));

          // Build timeline
          return _buildTimeline(
            context: context,
            ref: ref,
            l10n: l10n,
            theme: theme,
            overdue: overdue,
            upcoming: upcoming,
            completed: completed,
            petName: currentPet.name,
            currentPet: currentPet,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          _logger.e('Error loading vaccinations',
              error: error, stackTrace: stackTrace);
          return _buildErrorMessage(
              context, ref, l10n, theme, error, currentPet.id);
        },
      ),
      // FAB for quick add action
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/vaccinations/add/${currentPet.id}'),
        tooltip: l10n.add,
        child: const Icon(Icons.add),
      ),
    );
  }

  // ========================================================================
  // TIMELINE BUILDER
  // ========================================================================

  Widget _buildTimeline({
    required BuildContext context,
    required WidgetRef ref,
    required AppLocalizations l10n,
    required ThemeData theme,
    required List<VaccinationEvent> overdue,
    required List<VaccinationEvent> upcoming,
    required List<VaccinationEvent> completed,
    required String petName,
    required PetProfile currentPet,
  }) {
    // Check if any protocol-based vaccinations exist
    final hasProtocolBasedVaccinations = [...overdue, ...upcoming, ...completed]
        .any((v) => v.isFromProtocol);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pet info header
          _buildPetInfoHeader(context, l10n, theme, petName),
          const SizedBox(height: 16),

          // Protocol selection card (show only if no protocol-based vaccinations exist)
          if (!hasProtocolBasedVaccinations)
            _buildProtocolSelectionCard(context, ref, l10n, theme, currentPet),

          // Overdue section
          if (overdue.isNotEmpty) ...[
            _buildSectionHeader(
              context: context,
              l10n: l10n,
              theme: theme,
              title: l10n.overdue,
              count: overdue.length,
              color: Colors.red,
            ),
            ...overdue.map((vax) => _buildTimelineItem(
                  context: context,
                  l10n: l10n,
                  theme: theme,
                  vaccination: vax,
                  status: VaccinationStatus.overdue,
                )),
            const SizedBox(height: 8),
          ],

          // Upcoming section
          if (upcoming.isNotEmpty) ...[
            _buildSectionHeader(
              context: context,
              l10n: l10n,
              theme: theme,
              title: l10n.upcoming,
              count: upcoming.length,
              color: Colors.blue,
            ),
            ...upcoming.map((vax) => _buildTimelineItem(
                  context: context,
                  l10n: l10n,
                  theme: theme,
                  vaccination: vax,
                  status: VaccinationStatus.upcoming,
                )),
            const SizedBox(height: 8),
          ],

          // Completed section
          if (completed.isNotEmpty) ...[
            _buildSectionHeader(
              context: context,
              l10n: l10n,
              theme: theme,
              title: l10n.completed,
              count: completed.length,
              color: Colors.green,
            ),
            ...completed.map((vax) => _buildTimelineItem(
                  context: context,
                  l10n: l10n,
                  theme: theme,
                  vaccination: vax,
                  status: VaccinationStatus.completed,
                )),
            const SizedBox(height: 8),
          ],

          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  // ========================================================================
  // HEADER & SECTION BUILDERS
  // ========================================================================

  Widget _buildPetInfoHeader(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    String petName,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.vaccines,
            color: theme.colorScheme.onPrimaryContainer,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.vaccinations,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  petName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer
                        .withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProtocolSelectionCard(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    ThemeData theme,
    PetProfile currentPet,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.science,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.noProtocolSelected,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n.chooseProtocolMatchingNeeds,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: () => _navigateToProtocolSelection(context, currentPet),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.selectProtocol),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToProtocolSelection(
    BuildContext context,
    PetProfile pet,
  ) {
    context.push(
      '/vaccinations/protocol-selection',
      extra: pet,
    );
    // The vaccinations provider will automatically refresh when we return
  }

  Widget _buildSectionHeader({
    required BuildContext context,
    required AppLocalizations l10n,
    required ThemeData theme,
    required String title,
    required int count,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color, width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getStatusIcon(title == l10n.overdue
                      ? VaccinationStatus.overdue
                      : title == l10n.upcoming
                          ? VaccinationStatus.upcoming
                          : VaccinationStatus.completed),
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    count.toString(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
    required VaccinationEvent vaccination,
    required VaccinationStatus status,
  }) {
    final statusConfig = _getStatusConfig(theme, status);
    final locale = Localizations.localeOf(context).languageCode;

    return Semantics(
      label: '${VaccineTypeTranslations.getDisplayName(vaccination.vaccineType, locale)}, ${_getStatusLabel(l10n, status)}, '
          '${_formatDateForStatus(l10n, vaccination, status, locale)}',
      button: true,
      onTapHint: l10n.viewDetails,
      child: InkWell(
        onTap: () => context.push('/vaccinations/detail/${vaccination.id}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Card(
            elevation: status == VaccinationStatus.upcoming ? 2 : 1,
            child: Container(
              decoration: status == VaccinationStatus.overdue
                  ? BoxDecoration(
                      border: Border.all(
                        color: Colors.red.shade400,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    )
                  : status == VaccinationStatus.upcoming
                      ? BoxDecoration(
                          border: Border.all(
                            color: Colors.blue.shade400,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        )
                      : null,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: Status indicator
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: statusConfig.fillColor,
                      ),
                      child: Center(
                        child: Icon(
                          _getStatusIcon(status),
                          color: statusConfig.iconColor,
                          size: 24,
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Right: Vaccination details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Vaccine type (primary info)
                          // ISSUE 3 FIX: Display translated vaccine type name
                          Text(
                            VaccineTypeTranslations.getDisplayName(
                              vaccination.vaccineType,
                              locale,
                            ),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: status == VaccinationStatus.overdue
                                  ? Colors.red.shade700
                                  : status == VaccinationStatus.upcoming
                                      ? Colors.blue.shade700
                                      : null,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Date with icon
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
                                  _formatDateForStatus(
                                      l10n, vaccination, status, locale),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: statusConfig.iconColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Veterinarian/Clinic info (if available)
                          if (vaccination.veterinarianName != null ||
                              vaccination.clinicName != null) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.medical_services,
                                  size: 16,
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.7),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _buildVetClinicInfo(vaccination, l10n),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.7),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],

                          // Batch number (if available)
                          if (vaccination.batchNumber != null) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.qr_code,
                                  size: 16,
                                  color: theme.colorScheme.secondary
                                      .withValues(alpha: 0.7),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${l10n.batchNumber}: ${vaccination.batchNumber}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ],

                          // Protocol badge (if from protocol)
                          if (vaccination.isFromProtocol) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.tertiaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.auto_awesome,
                                    size: 12,
                                    color:
                                        theme.colorScheme.onTertiaryContainer,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    l10n.protocolBasedVaccination,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color:
                                          theme.colorScheme.onTertiaryContainer,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Right arrow indicator
                    Icon(
                      Icons.chevron_right,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ========================================================================
  // EDGE CASE MESSAGES
  // ========================================================================

  Widget _buildNoPetMessage(
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
              Icons.pets,
              size: 80,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noPetSelected,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.pleaseSetupPetFirst,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    ThemeData theme,
    PetProfile currentPet,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Protocol selection card - prominently shown on empty state
          _buildProtocolSelectionCard(context, ref, l10n, theme, currentPet),
          const SizedBox(height: 24),
          // Empty state message
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.vaccines_outlined,
                  size: 80,
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.noVaccinations,
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.trackVaccinationRecords,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => context.push('/vaccinations/add/${currentPet.id}'),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.add),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    ThemeData theme,
    Object error,
    String petId,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.errorLoadingVaccinations,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () =>
                  ref.invalidate(vaccinationsByPetIdProvider(petId)),
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================================================
  // HELPER METHODS
  // ========================================================================

  VaccinationStatus _determineStatus(
      VaccinationEvent vaccination, DateTime now) {
    // Overdue: nextDueDate is in the past
    if (vaccination.nextDueDate != null &&
        vaccination.nextDueDate!
            .isBefore(now.subtract(const Duration(hours: 1)))) {
      return VaccinationStatus.overdue;
    }

    // Upcoming: nextDueDate is in the future
    if (vaccination.nextDueDate != null &&
        vaccination.nextDueDate!.isAfter(now)) {
      return VaccinationStatus.upcoming;
    }

    // Completed: administeredDate is in the past, no upcoming nextDueDate
    return VaccinationStatus.completed;
  }

  _StatusConfig _getStatusConfig(ThemeData theme, VaccinationStatus status) {
    switch (status) {
      case VaccinationStatus.overdue:
        return _StatusConfig(
          fillColor: Colors.red.shade600,
          iconColor: Colors.white,
        );
      case VaccinationStatus.upcoming:
        return _StatusConfig(
          fillColor: Colors.blue.shade600,
          iconColor: Colors.white,
        );
      case VaccinationStatus.completed:
        return _StatusConfig(
          fillColor: Colors.green.shade600,
          iconColor: Colors.white,
        );
    }
  }

  IconData _getStatusIcon(VaccinationStatus status) {
    switch (status) {
      case VaccinationStatus.overdue:
        return Icons.warning;
      case VaccinationStatus.upcoming:
        return Icons.schedule;
      case VaccinationStatus.completed:
        return Icons.check_circle;
    }
  }

  String _getStatusLabel(AppLocalizations l10n, VaccinationStatus status) {
    switch (status) {
      case VaccinationStatus.overdue:
        return l10n.overdue;
      case VaccinationStatus.upcoming:
        return l10n.upcoming;
      case VaccinationStatus.completed:
        return l10n.completed;
    }
  }

  String _formatDateForStatus(
    AppLocalizations l10n,
    VaccinationEvent vaccination,
    VaccinationStatus status,
    String locale,
  ) {
    final formatter = DateFormat.yMMMd(locale);

    switch (status) {
      case VaccinationStatus.overdue:
        final dueDate = vaccination.nextDueDate ?? vaccination.administeredDate;
        return '${l10n.overdue}: ${formatter.format(dueDate)}';
      case VaccinationStatus.upcoming:
        final dueDate = vaccination.nextDueDate ?? vaccination.administeredDate;
        return '${l10n.dueDate}: ${formatter.format(dueDate)}';
      case VaccinationStatus.completed:
        return '${l10n.administeredDate}: ${formatter.format(vaccination.administeredDate)}';
    }
  }

  String _buildVetClinicInfo(
      VaccinationEvent vaccination, AppLocalizations l10n) {
    final parts = <String>[];
    if (vaccination.veterinarianName != null) {
      parts.add(vaccination.veterinarianName!);
    }
    if (vaccination.clinicName != null) {
      parts.add(vaccination.clinicName!);
    }
    return parts.join(' • ');
  }
}

// ============================================================================
// ENUMS & DATA CLASSES
// ============================================================================

/// Status of a vaccination in the timeline
enum VaccinationStatus {
  /// Vaccination is overdue (past nextDueDate)
  overdue,

  /// Vaccination is upcoming (future nextDueDate)
  upcoming,

  /// Vaccination has been completed (administeredDate in past, no upcoming due date)
  completed,
}

/// Internal configuration for status-dependent styling
class _StatusConfig {
  final Color fillColor;
  final Color iconColor;

  _StatusConfig({
    required this.fillColor,
    required this.iconColor,
  });
}
