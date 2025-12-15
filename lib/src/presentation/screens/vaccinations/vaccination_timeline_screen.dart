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
import 'package:google_fonts/google_fonts.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
import '../../../../theme/tokens/colors.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../../../theme/tokens/shadows.dart';
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
    final isDark = theme.brightness == Brightness.dark;
    final currentPet = ref.watch(currentPetProfileProvider);

    // Design tokens
    final backgroundColor =
        isDark ? DesignColors.dBackground : DesignColors.lBackground;
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;

    // Edge case: No pet selected
    if (currentPet == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: surfaceColor,
          title: Text(
            l10n.vaccinations,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: primaryText,
            ),
          ),
          centerTitle: true,
        ),
        body: _buildNoPetMessage(context, l10n, theme, isDark),
      );
    }

    final vaccinationsAsync =
        ref.watch(vaccinationsByPetIdProvider(currentPet.id));

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        title: Text(
          l10n.vaccinations,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
        centerTitle: true,
        actions: [
          // Add button in AppBar
          IconButton(
            icon: Icon(Icons.add, color: DesignColors.highlightPurple),
            onPressed: () => context.push('/vaccinations/add/${currentPet.id}'),
            tooltip: l10n.add,
          ),
        ],
      ),
      body: vaccinationsAsync.when(
        data: (vaccinations) {
          // Edge case: No vaccinations
          if (vaccinations.isEmpty) {
            return _buildEmptyState(context, ref, l10n, theme, isDark, currentPet);
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
            isDark: isDark,
            overdue: overdue,
            upcoming: upcoming,
            completed: completed,
            petName: currentPet.name,
            currentPet: currentPet,
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(
            color: DesignColors.highlightPurple,
          ),
        ),
        error: (error, stackTrace) {
          _logger.e('Error loading vaccinations',
              error: error, stackTrace: stackTrace);
          return _buildErrorMessage(
              context, ref, l10n, theme, isDark, error, currentPet.id);
        },
      ),
      // FAB for quick add action
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/vaccinations/add/${currentPet.id}'),
        tooltip: l10n.add,
        backgroundColor: DesignColors.highlightPurple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          l10n.add,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
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
    required bool isDark,
    required List<VaccinationEvent> overdue,
    required List<VaccinationEvent> upcoming,
    required List<VaccinationEvent> completed,
    required String petName,
    required PetProfile currentPet,
  }) {
    // Check if any protocol-based vaccinations exist
    final hasProtocolBasedVaccinations =
        [...overdue, ...upcoming, ...completed].any((v) => v.isFromProtocol);

    // Status colors
    final overdueColor = isDark ? DesignColors.dDanger : DesignColors.lDanger;
    final upcomingColor = DesignColors.highlightBlue;
    final completedColor = isDark ? DesignColors.dSuccess : DesignColors.lSuccess;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pet info header
          _buildPetInfoHeader(context, l10n, theme, isDark, petName),
          SizedBox(height: DesignSpacing.md),

          // Protocol selection card (show only if no protocol-based vaccinations exist)
          if (!hasProtocolBasedVaccinations)
            _buildProtocolSelectionCard(context, ref, l10n, theme, isDark, currentPet),

          // Overdue section
          if (overdue.isNotEmpty) ...[
            _buildSectionHeader(
              context: context,
              l10n: l10n,
              theme: theme,
              isDark: isDark,
              title: l10n.overdue,
              count: overdue.length,
              color: overdueColor,
              icon: Icons.warning,
            ),
            ...overdue.map((vax) => _buildTimelineItem(
                  context: context,
                  l10n: l10n,
                  theme: theme,
                  isDark: isDark,
                  vaccination: vax,
                  status: VaccinationStatus.overdue,
                )),
            SizedBox(height: DesignSpacing.sm),
          ],

          // Upcoming section
          if (upcoming.isNotEmpty) ...[
            _buildSectionHeader(
              context: context,
              l10n: l10n,
              theme: theme,
              isDark: isDark,
              title: l10n.upcoming,
              count: upcoming.length,
              color: upcomingColor,
              icon: Icons.schedule,
            ),
            ...upcoming.map((vax) => _buildTimelineItem(
                  context: context,
                  l10n: l10n,
                  theme: theme,
                  isDark: isDark,
                  vaccination: vax,
                  status: VaccinationStatus.upcoming,
                )),
            SizedBox(height: DesignSpacing.sm),
          ],

          // Completed section
          if (completed.isNotEmpty) ...[
            _buildSectionHeader(
              context: context,
              l10n: l10n,
              theme: theme,
              isDark: isDark,
              title: l10n.completed,
              count: completed.length,
              color: completedColor,
              icon: Icons.check_circle,
            ),
            ...completed.map((vax) => _buildTimelineItem(
                  context: context,
                  l10n: l10n,
                  theme: theme,
                  isDark: isDark,
                  vaccination: vax,
                  status: VaccinationStatus.completed,
                )),
            SizedBox(height: DesignSpacing.sm),
          ],

          SizedBox(height: DesignSpacing.xxxl), // Space for FAB
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
    bool isDark,
    String petName,
  ) {
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DesignColors.highlightPurple.withOpacity(0.15),
            surfaceColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: DesignColors.highlightPurple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.vaccines,
              color: DesignColors.highlightPurple,
              size: 28,
            ),
          ),
          SizedBox(width: DesignSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.vaccinations,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: primaryText,
                  ),
                ),
                SizedBox(height: DesignSpacing.xs),
                Text(
                  petName,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: secondaryText,
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
    bool isDark,
    PetProfile currentPet,
  ) {
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: DesignSpacing.md, vertical: DesignSpacing.sm),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
          border: Border.all(
            color: DesignColors.highlightPurple.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(DesignSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: DesignColors.highlightPurple.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.science,
                      color: DesignColors.highlightPurple,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: DesignSpacing.sm),
                  Expanded(
                    child: Text(
                      l10n.noProtocolSelected,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: primaryText,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: DesignSpacing.sm),
              Text(
                l10n.chooseProtocolMatchingNeeds,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: secondaryText,
                ),
              ),
              SizedBox(height: DesignSpacing.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _navigateToProtocolSelection(context, currentPet),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignColors.highlightPurple,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: DesignSpacing.sm),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.add),
                  label: Text(
                    l10n.selectProtocol,
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
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
    required bool isDark,
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: DesignSpacing.md, vertical: DesignSpacing.sm),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: DesignSpacing.sm, vertical: DesignSpacing.xs),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color, width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
                SizedBox(width: DesignSpacing.sm),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                SizedBox(width: DesignSpacing.sm),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: DesignSpacing.sm, vertical: 2),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    count.toString(),
                    style: GoogleFonts.inter(
                      fontSize: 12,
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
    required bool isDark,
    required VaccinationEvent vaccination,
    required VaccinationStatus status,
  }) {
    final statusConfig = _getStatusConfig(isDark, status);
    final locale = Localizations.localeOf(context).languageCode;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Semantics(
      label:
          '${VaccineTypeTranslations.getDisplayName(vaccination.vaccineType, locale)}, ${_getStatusLabel(l10n, status)}, '
          '${_formatDateForStatus(l10n, vaccination, status, locale)}',
      button: true,
      onTapHint: l10n.viewDetails,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: DesignSpacing.md, vertical: DesignSpacing.sm),
        child: Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: statusConfig.borderColor.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.push('/vaccinations/detail/${vaccination.id}'),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: EdgeInsets.all(DesignSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: Status indicator
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: statusConfig.fillColor.withOpacity(0.15),
                      ),
                      child: Center(
                        child: Icon(
                          _getStatusIcon(status),
                          color: statusConfig.fillColor,
                          size: 28,
                        ),
                      ),
                    ),

                    SizedBox(width: DesignSpacing.md),

                    // Right: Vaccination details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Vaccine type (primary info)
                          Text(
                            VaccineTypeTranslations.getDisplayName(
                              vaccination.vaccineType,
                              locale,
                            ),
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: primaryText,
                            ),
                          ),
                          SizedBox(height: DesignSpacing.sm),

                          // Date with icon
                          Row(
                            children: [
                              Icon(
                                Icons.event,
                                size: 16,
                                color: statusConfig.fillColor,
                              ),
                              SizedBox(width: DesignSpacing.xs),
                              Expanded(
                                child: Text(
                                  _formatDateForStatus(
                                      l10n, vaccination, status, locale),
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: statusConfig.fillColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Veterinarian/Clinic info (if available)
                          if (vaccination.veterinarianName != null ||
                              vaccination.clinicName != null) ...[
                            SizedBox(height: DesignSpacing.xs),
                            Row(
                              children: [
                                Icon(
                                  Icons.medical_services,
                                  size: 16,
                                  color: secondaryText,
                                ),
                                SizedBox(width: DesignSpacing.xs),
                                Expanded(
                                  child: Text(
                                    _buildVetClinicInfo(vaccination, l10n),
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: secondaryText,
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
                            SizedBox(height: DesignSpacing.xs),
                            Row(
                              children: [
                                Icon(
                                  Icons.qr_code_2,
                                  size: 16,
                                  color: secondaryText,
                                ),
                                SizedBox(width: DesignSpacing.xs),
                                Text(
                                  '${l10n.batchNumber}: ${vaccination.batchNumber}',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ],

                          // Protocol badge (if from protocol)
                          if (vaccination.isFromProtocol) ...[
                            SizedBox(height: DesignSpacing.sm),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: DesignSpacing.sm, vertical: DesignSpacing.xs),
                              decoration: BoxDecoration(
                                color: DesignColors.highlightBlue.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.auto_awesome,
                                    size: 12,
                                    color: DesignColors.highlightBlue,
                                  ),
                                  SizedBox(width: DesignSpacing.xs),
                                  Text(
                                    l10n.protocolBasedVaccination,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: DesignColors.highlightBlue,
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
                      color: secondaryText,
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
    bool isDark,
  ) {
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 80,
              color: DesignColors.highlightPurple.withOpacity(0.5),
            ),
            SizedBox(height: DesignSpacing.md),
            Text(
              l10n.noPetSelected,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: DesignSpacing.sm),
            Text(
              l10n.pleaseSetupPetFirst,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: secondaryText,
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
    bool isDark,
    PetProfile currentPet,
  ) {
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: DesignSpacing.lg),
          // Protocol selection card - prominently shown on empty state
          _buildProtocolSelectionCard(context, ref, l10n, theme, isDark, currentPet),
          SizedBox(height: DesignSpacing.lg),
          // Empty state message
          Padding(
            padding: EdgeInsets.all(DesignSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.vaccines_outlined,
                  size: 80,
                  color: DesignColors.highlightPurple.withOpacity(0.5),
                ),
                SizedBox(height: DesignSpacing.md),
                Text(
                  l10n.noVaccinations,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: primaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: DesignSpacing.sm),
                Text(
                  l10n.trackVaccinationRecords,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: secondaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: DesignSpacing.lg),
                ElevatedButton.icon(
                  onPressed: () =>
                      context.push('/vaccinations/add/${currentPet.id}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignColors.highlightPurple,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: DesignSpacing.lg,
                      vertical: DesignSpacing.sm,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.add),
                  label: Text(
                    l10n.add,
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
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
    bool isDark,
    Object error,
    String petId,
  ) {
    final dangerColor = isDark ? DesignColors.dDanger : DesignColors.lDanger;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: dangerColor,
            ),
            SizedBox(height: DesignSpacing.md),
            Text(
              l10n.errorLoadingVaccinations,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: dangerColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: DesignSpacing.sm),
            Text(
              error.toString(),
              style: GoogleFonts.inter(
                fontSize: 12,
                color: secondaryText,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: DesignSpacing.lg),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.invalidate(vaccinationsByPetIdProvider(petId)),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignColors.highlightPurple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: DesignSpacing.lg,
                  vertical: DesignSpacing.sm,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.refresh),
              label: Text(
                l10n.retry,
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
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

  _StatusConfig _getStatusConfig(bool isDark, VaccinationStatus status) {
    switch (status) {
      case VaccinationStatus.overdue:
        final overdueColor = isDark ? DesignColors.dDanger : DesignColors.lDanger;
        return _StatusConfig(
          fillColor: overdueColor,
          iconColor: Colors.white,
          borderColor: overdueColor,
        );
      case VaccinationStatus.upcoming:
        return _StatusConfig(
          fillColor: DesignColors.highlightBlue,
          iconColor: Colors.white,
          borderColor: DesignColors.highlightBlue,
        );
      case VaccinationStatus.completed:
        final completedColor = isDark ? DesignColors.dSuccess : DesignColors.lSuccess;
        return _StatusConfig(
          fillColor: completedColor,
          iconColor: Colors.white,
          borderColor: completedColor,
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
  final Color borderColor;

  _StatusConfig({
    required this.fillColor,
    required this.iconColor,
    required this.borderColor,
  });
}
