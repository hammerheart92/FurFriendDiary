// File: lib/src/presentation/screens/protocols/deworming_schedule_screen.dart
// Purpose: Displays the complete deworming treatment timeline for a pet
//
// Navigation: Expects a PetProfile object via route parameter
// Shows: Treatment dates, type (internal/external), product, status badges

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
import '../../../../theme/tokens/colors.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../../../theme/tokens/shadows.dart';
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

    // Theme detection
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor =
        isDark ? DesignColors.dBackground : DesignColors.lBackground;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.dewormingStatus,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
        centerTitle: true,
        backgroundColor: backgroundColor,
        foregroundColor: primaryText,
        elevation: 0,
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
    // Theme detection
    final isDark = theme.brightness == Brightness.dark;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

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
      padding: EdgeInsets.all(DesignSpacing.lg),
      decoration: BoxDecoration(
        color: DesignColors.highlightYellow.withOpacity(0.15),
        border: Border(
          left: BorderSide(color: DesignColors.highlightYellow, width: 4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.pest_control,
            color: DesignColors.highlightYellow,
            size: 32,
          ),
          SizedBox(width: DesignSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: DesignColors.highlightYellow,
                  ),
                ),
                SizedBox(height: DesignSpacing.sm),
                Text(
                  displayDescription,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: secondaryText,
                  ),
                ),
                if (protocol.region != null) ...[
                  SizedBox(height: DesignSpacing.xs),
                  Text(
                    l10n.regionLabel(protocol.region!),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: secondaryText,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetInfoCard(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    // Theme detection
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: DesignSpacing.md),
      padding: EdgeInsets.all(DesignSpacing.lg),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: DesignColors.highlightTeal.withOpacity(0.2),
            child: Icon(
              Icons.pets,
              color: DesignColors.highlightTeal,
              size: 32,
            ),
          ),
          SizedBox(width: DesignSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${pet.species}${pet.breed != null ? ' • ${pet.breed}' : ''}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: secondaryText,
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
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: secondaryText,
                    ),
                  ),
                ],
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
    required DewormingScheduleEntry entry,
    required int treatmentNumber,
    required TreatmentStatus status,
    required bool isLast,
  }) {
    // Theme detection
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final dangerColor = isDark ? DesignColors.dDanger : DesignColors.lDanger;
    final successColor = isDark ? DesignColors.dSuccess : DesignColors.lSuccess;

    // Determine colors based on status
    final isUpcoming = status == TreatmentStatus.next;
    final isOverdue = status == TreatmentStatus.overdue;
    final isCompleted = status == TreatmentStatus.completed;

    Color titleColor = DesignColors.highlightYellow;
    Color? borderColor;
    if (isOverdue) {
      titleColor = dangerColor;
      borderColor = dangerColor;
    } else if (isUpcoming) {
      titleColor = DesignColors.highlightYellow;
      borderColor = DesignColors.highlightYellow;
    }

    return Semantics(
      label:
          '${l10n.treatmentNumber(treatmentNumber)}: ${_getTreatmentTypeLabel(l10n, entry.dewormingType)}, '
          '${_getStatusLabel(l10n, status, entry, context)}',
      child: Padding(
        padding: EdgeInsets.only(
          left: DesignSpacing.md,
          right: DesignSpacing.md,
          bottom: DesignSpacing.md,
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Timeline indicator column
              Column(
                children: [
                  // Circular indicator
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? successColor
                          : isUpcoming
                              ? DesignColors.highlightYellow
                              : isOverdue
                                  ? dangerColor
                                  : surfaceColor,
                      border: !isCompleted && !isUpcoming && !isOverdue
                          ? Border.all(
                              color: isDark
                                  ? const Color(0xFF3A3A3A)
                                  : const Color(0xFFE0E0E0),
                              width: 2,
                            )
                          : null,
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check, color: Colors.white, size: 28)
                          : Icon(
                              _getTreatmentIcon(entry.dewormingType),
                              color: isUpcoming || isOverdue
                                  ? Colors.white
                                  : secondaryText,
                              size: 24,
                            ),
                    ),
                  ),

                  // Vertical connecting line (if not last)
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: isDark
                            ? const Color(0xFF3A3A3A)
                            : const Color(0xFFE0E0E0),
                      ),
                    ),
                ],
              ),

              SizedBox(width: DesignSpacing.md),

              // Right: Treatment information card
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: borderColor != null
                        ? Border.all(color: borderColor, width: 2)
                        : null,
                    boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(DesignSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Treatment number and type badge
                        Row(
                          children: [
                            Text(
                              l10n.treatmentNumber(treatmentNumber),
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: titleColor,
                              ),
                            ),
                            SizedBox(width: DesignSpacing.sm),
                            _buildTypeChip(l10n, theme, entry.dewormingType),
                          ],
                        ),
                        SizedBox(height: DesignSpacing.md),

                        // Date with status
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: secondaryText,
                            ),
                            SizedBox(width: DesignSpacing.sm),
                            Expanded(
                              child: Text(
                                _formatDateDisplay(l10n, entry, status, context),
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: primaryText,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Product name
                        if (entry.productName != null) ...[
                          SizedBox(height: DesignSpacing.sm),
                          Row(
                            children: [
                              Icon(
                                Icons.medication,
                                size: 16,
                                color: DesignColors.highlightTeal,
                              ),
                              SizedBox(width: DesignSpacing.sm),
                              Expanded(
                                child: Text(
                                  entry.productName!,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: DesignColors.highlightTeal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        // Notes (use Romanian if available and locale matches)
                        if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                          SizedBox(height: DesignSpacing.sm),
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
                                padding: EdgeInsets.all(DesignSpacing.md),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF2A2A2A)
                                      : const Color(0xFFF5F3E8),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 16,
                                      color: secondaryText,
                                    ),
                                    SizedBox(width: DesignSpacing.sm),
                                    Expanded(
                                      child: Text(
                                        displayNotes,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: secondaryText,
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
    // Theme detection
    final isDark = theme.brightness == Brightness.dark;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pest_control,
              size: 80,
              color: DesignColors.highlightYellow.withOpacity(0.5),
            ),
            SizedBox(height: DesignSpacing.lg),
            Text(
              l10n.noDewormingProtocol,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: DesignSpacing.sm),
            Text(
              l10n.chooseDewormingProtocol,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: DesignSpacing.xl),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: Text(
                l10n.goBack,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignColors.highlightTeal,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: DesignSpacing.lg,
                  vertical: DesignSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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
    // Theme detection
    final isDark = theme.brightness == Brightness.dark;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final dangerColor = isDark ? DesignColors.dDanger : DesignColors.lDanger;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cake,
              size: 80,
              color: dangerColor.withOpacity(0.7),
            ),
            SizedBox(height: DesignSpacing.lg),
            Text(
              l10n.noBirthdaySet,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: DesignSpacing.sm),
            Text(
              l10n.addBirthdayToViewSchedule,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: DesignSpacing.xl),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.edit),
              label: Text(
                l10n.editProfile,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignColors.highlightTeal,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: DesignSpacing.lg,
                  vertical: DesignSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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
    // Theme detection
    final isDark = theme.brightness == Brightness.dark;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 80,
              color: DesignColors.highlightYellow.withOpacity(0.5),
            ),
            SizedBox(height: DesignSpacing.lg),
            Text(
              l10n.noScheduleAvailable,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: DesignSpacing.sm),
            Text(
              l10n.protocolMayNotApplyYet,
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

  Widget _buildAllCompletedMessage(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    List<DewormingScheduleEntry> schedule,
  ) {
    // Theme detection
    final isDark = theme.brightness == Brightness.dark;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final successColor = isDark ? DesignColors.dSuccess : DesignColors.lSuccess;

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: DesignSpacing.xxl),
          Icon(
            Icons.celebration,
            size: 80,
            color: successColor,
          ),
          SizedBox(height: DesignSpacing.lg),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: DesignSpacing.lg),
            child: Text(
              l10n.allTreatmentsCompleted,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: successColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: DesignSpacing.sm),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: DesignSpacing.lg),
            child: Text(
              l10n.completedAllScheduledTreatments,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: DesignSpacing.xl),

          // Show completed treatments
          Padding(
            padding: EdgeInsets.symmetric(horizontal: DesignSpacing.md),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.treatmentHistory,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
              ),
            ),
          ),
          SizedBox(height: DesignSpacing.md),

          ...List.generate(schedule.length, (index) {
            final entry = schedule[index];
            return _buildCompletedTreatmentCard(
                context, l10n, theme, entry, index + 1);
          }),

          SizedBox(height: DesignSpacing.lg),
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
    // Theme detection
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final successColor = isDark ? DesignColors.dSuccess : DesignColors.lSuccess;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: DesignSpacing.md,
        vertical: DesignSpacing.xs,
      ),
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.sm,
      ),
      child: Row(
        children: [
          // Green check circle
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: successColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              color: successColor,
              size: 20,
            ),
          ),
          SizedBox(width: DesignSpacing.md),
          // Treatment info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      l10n.treatmentNumber(number),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: primaryText,
                      ),
                    ),
                    SizedBox(width: DesignSpacing.sm),
                    _buildTypeChip(l10n, theme, entry.dewormingType),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  DateFormat.yMMMd(Localizations.localeOf(context).languageCode)
                      .format(entry.scheduledDate),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: secondaryText,
                  ),
                ),
              ],
            ),
          ),
          // Treatment type icon
          Icon(
            _getTreatmentIcon(entry.dewormingType),
            color: DesignColors.highlightYellow.withOpacity(0.6),
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    Object error,
  ) {
    // Theme detection
    final isDark = theme.brightness == Brightness.dark;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final dangerColor = isDark ? DesignColors.dDanger : DesignColors.lDanger;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: dangerColor,
            ),
            SizedBox(height: DesignSpacing.lg),
            Text(
              l10n.errorLoadingSchedule,
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
            ),
            SizedBox(height: DesignSpacing.xl),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: Text(
                l10n.goBack,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignColors.highlightTeal,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: DesignSpacing.lg,
                  vertical: DesignSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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
    // Use yellow for internal (pills/oral), coral for external (parasites)
    final chipColor = isInternal
        ? DesignColors.highlightYellow
        : DesignColors.highlightCoral;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getTreatmentIcon(type),
            size: 14,
            color: chipColor,
          ),
          const SizedBox(width: 4),
          Text(
            _getTreatmentTypeLabel(l10n, type),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: chipColor,
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
