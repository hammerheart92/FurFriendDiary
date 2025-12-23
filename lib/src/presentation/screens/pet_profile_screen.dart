import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:fur_friend_diary/src/domain/models/pet_profile.dart';
import 'package:fur_friend_diary/src/presentation/providers/pet_profile_provider.dart';
import 'package:fur_friend_diary/src/presentation/providers/pet_owner_provider.dart';
import 'package:fur_friend_diary/src/presentation/dialogs/upgrade_prompt_dialog.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
import 'package:fur_friend_diary/src/ui/screens/weight_history_screen.dart';
import 'package:fur_friend_diary/src/presentation/providers/protocols/protocol_schedule_provider.dart';
import 'package:fur_friend_diary/src/presentation/providers/protocols/vaccination_protocol_provider.dart';
import 'package:fur_friend_diary/src/domain/constants/species_translations.dart';
import 'package:intl/intl.dart';
import '../widgets/pet_qr_code_sheet.dart';
import '../../../../theme/tokens/colors.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../../../theme/tokens/shadows.dart';
import '../../utils/snackbar_helper.dart';

final _logger = Logger();

/// Get gender-specific icon
IconData _getGenderIcon(PetGender gender) {
  switch (gender) {
    case PetGender.male:
      return Icons.male;
    case PetGender.female:
      return Icons.female;
    case PetGender.unknown:
      return Icons.help_outline;
  }
}

/// Get gender icon color
Color _getGenderIconColor(PetGender gender) {
  switch (gender) {
    case PetGender.male:
      return Colors.blue;
    case PetGender.female:
      return Colors.pink;
    case PetGender.unknown:
      return Colors.grey;
  }
}

/// Get localized gender name
String _getLocalizedGender(PetGender gender, AppLocalizations l10n) {
  switch (gender) {
    case PetGender.male:
      return l10n.genderMale;
    case PetGender.female:
      return l10n.genderFemale;
    case PetGender.unknown:
      return l10n.genderUnknown;
  }
}

class PetProfileScreen extends ConsumerWidget {
  const PetProfileScreen({super.key});

  /// Build a styled section header with teal accent
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(
        left: DesignSpacing.md,
        top: DesignSpacing.lg,
        bottom: DesignSpacing.xs,
      ),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: DesignColors.highlightTeal,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Build a colorful action button with PetiCare-style design
  Widget _buildColorfulActionButton(
    BuildContext context, {
    required Color color,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Navy color needs higher opacity in dark mode for visibility
    final isNavyColor = color == DesignColors.highlightNavy;
    // Alpha values (0-255): 0.4→102, 0.2→51, 0.1→26, 0.5→128, 0.3→77, 0.25→64, 0.15→38
    final bgAlpha = isDark
        ? (isNavyColor ? 102 : 51)
        : (isNavyColor ? 51 : 26);
    final borderAlpha = isNavyColor ? 128 : 77;
    final iconBgAlpha = isNavyColor ? 64 : 38;

    // Use lighter text/icon color for Navy in dark mode
    final displayColor = (isDark && isNavyColor)
        ? const Color(0xFF7B8BA8) // Lighter navy for better visibility
        : color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: DesignSpacing.sm,
            vertical: DesignSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(bgAlpha / 255),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: displayColor.withOpacity(borderAlpha / 255)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(iconBgAlpha / 255),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: displayColor),
              ),
              SizedBox(width: DesignSpacing.xs),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: displayColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesAsync = ref.watch(petProfilesProvider);
    final currentProfile = ref.watch(currentPetProfileProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.petProfiles),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _handleAddPet(context, ref, l10n),
            icon: const Icon(Icons.add),
            tooltip: l10n.addPet,
          ),
        ],
      ),
      body: profilesAsync.when(
        data: (profiles) =>
            _buildProfileList(context, ref, profiles, currentProfile),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text('${l10n.errorLoadingProfiles}: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(petProfilesProvider),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handle add pet button press.
  /// Checks tier limit and shows upgrade dialog if limit reached.
  Future<void> _handleAddPet(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    // Check if user can add more pets
    final canAdd = ref.read(canAddMorePetsProvider);

    if (canAdd) {
      // Navigate to add pet screen
      context.push('/add-pet');
    } else {
      // Show upgrade prompt dialog
      final result = await UpgradePromptDialog.show(context);

      if (result == true) {
        // User wants to learn more about Premium
        // For now, show a snackbar (placeholder for future premium flow)
        if (context.mounted) {
          SnackBarHelper.showInfo(context, l10n.premiumComingSoon);
        }
      }
      // If result is false or null, dialog was dismissed - do nothing
    }
  }

  Widget _buildProfileList(
    BuildContext context,
    WidgetRef ref,
    List<PetProfile> profiles,
    PetProfile? currentProfile,
  ) {
    if (profiles.isEmpty) {
      return _buildEmptyState(context);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark ? DesignColors.dDisabled : DesignColors.lDisabled;

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(petProfilesProvider),
      child: ListView(
        padding: EdgeInsets.all(DesignSpacing.md),
        children: [
          if (currentProfile != null) ...[
            _buildActiveProfileCard(context, ref, currentProfile),
            SizedBox(height: DesignSpacing.md),
            _buildVaccinationStatusCard(context, ref, currentProfile),
            SizedBox(height: DesignSpacing.md),
            _buildDewormingStatusCard(context, ref, currentProfile),
            SizedBox(height: DesignSpacing.lg),
            Divider(color: dividerColor),
            SizedBox(height: DesignSpacing.sm),
          ],
          // Section header using helper
          _buildSectionHeader(context, AppLocalizations.of(context).allProfiles),
          SizedBox(height: DesignSpacing.sm),
          ...profiles.map((profile) => Padding(
                padding: EdgeInsets.only(bottom: DesignSpacing.sm),
                child: _buildProfileCard(
                    context, ref, profile, profile == currentProfile),
              )),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets,
            size: 96,
            color: DesignColors.highlightPurple.withOpacity(0.5),
          ),
          SizedBox(height: DesignSpacing.lg),
          Text(
            l10n.noPetsYet,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: primaryText,
            ),
          ),
          SizedBox(height: DesignSpacing.sm),
          Text(
            l10n.addYourFirstPet,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: secondaryText,
            ),
          ),
          SizedBox(height: DesignSpacing.xl),
          ElevatedButton.icon(
            onPressed: () => context.push('/profile-setup'),
            icon: const Icon(Icons.add),
            label: Text(l10n.addPet),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignColors.highlightBlue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: DesignSpacing.lg,
                vertical: DesignSpacing.sm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveProfileCard(
      BuildContext context, WidgetRef ref, PetProfile profile) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/edit-pet/${profile.id}'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(DesignSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Avatar with coral accent border and edit badge overlay
                    GestureDetector(
                      onTap: () => context.push('/edit-pet/${profile.id}'),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: DesignColors.highlightCoral,
                                width: 3,
                              ),
                              boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
                            ),
                            child: _buildProfileAvatar(context, profile, 120),
                          ),
                          // Edit badge overlay
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: DesignColors.highlightCoral,
                                shape: BoxShape.circle,
                                boxShadow: DesignShadows.sm,
                              ),
                              child: const Icon(
                                Icons.edit,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: DesignSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Pet name with Poppins font
                          Text(
                            profile.name,
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: primaryText,
                            ),
                          ),
                          SizedBox(height: DesignSpacing.xs),
                          Builder(
                            builder: (context) {
                              final locale = Localizations.localeOf(context);
                              return Row(
                                children: [
                                  Icon(Icons.pets, size: 16, color: secondaryText),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      '${SpeciesTranslations.getDisplayName(profile.species, locale.languageCode)}${profile.breed != null ? ' • ${profile.breed}' : ''}',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: secondaryText,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          if (profile.gender != PetGender.unknown) ...[
                            SizedBox(height: DesignSpacing.xs),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getGenderIcon(profile.gender),
                                  size: 16,
                                  color: _getGenderIconColor(profile.gender),
                                ),
                                SizedBox(width: DesignSpacing.xs),
                                Text(
                                  _getLocalizedGender(profile.gender, l10n),
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (profile.age > 0)
                            Row(
                              children: [
                                Icon(Icons.cake, size: 16, color: secondaryText),
                                const SizedBox(width: 4),
                                Text(
                                  l10n.yearsOld(profile.age, profile.age != 1 ? 's' : ''),
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: secondaryText,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    // Active badge with teal styling
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: DesignSpacing.sm,
                        vertical: DesignSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: DesignColors.highlightTeal.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: DesignColors.highlightTeal),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: DesignColors.highlightTeal,
                          ),
                          SizedBox(width: DesignSpacing.xs),
                          Text(
                            l10n.activeProfile,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: DesignColors.highlightTeal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (profile.notes != null) ...[
                  SizedBox(height: DesignSpacing.sm),
                  Text(
                    profile.notes!,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: secondaryText,
                    ),
                  ),
                ],
                SizedBox(height: DesignSpacing.md),
                Divider(
                  height: 1,
                  color: isDark ? DesignColors.dDisabled : DesignColors.lDisabled,
                ),
                SizedBox(height: DesignSpacing.sm),
                // Quick Actions Section Header
                Text(
                  'QUICK ACTIONS',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: secondaryText,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: DesignSpacing.sm),
                // Colorful Action Buttons
                Wrap(
                  spacing: DesignSpacing.sm,
                  runSpacing: DesignSpacing.sm,
                  children: [
                    _buildColorfulActionButton(
                      context,
                      color: DesignColors.highlightBlue,
                      icon: Icons.monitor_weight_outlined,
                      label: l10n.weightTracking,
                      onTap: () => _navigateToWeightTracking(context),
                    ),
                    _buildColorfulActionButton(
                      context,
                      color: DesignColors.highlightPink,
                      icon: Icons.photo_library,
                      label: l10n.photoGallery,
                      onTap: () => context.push('/photo-gallery'),
                    ),
                    _buildColorfulActionButton(
                      context,
                      color: DesignColors.highlightCoral,
                      icon: Icons.lunch_dining,
                      label: l10n.feedings,
                      onTap: () => context.push('/feedings'),
                    ),
                    _buildColorfulActionButton(
                      context,
                      color: DesignColors.highlightTeal,
                      icon: Icons.medical_services,
                      label: l10n.medications,
                      onTap: () => context.go('/meds'),
                    ),
                    _buildColorfulActionButton(
                      context,
                      color: DesignColors.highlightPurple,
                      icon: Icons.vaccines,
                      label: l10n.vaccinations,
                      onTap: () => context.push('/vaccinations'),
                    ),
                    _buildColorfulActionButton(
                      context,
                      color: DesignColors.highlightYellow,
                      icon: Icons.event,
                      label: l10n.appointments,
                      onTap: () => context.go('/appointments'),
                    ),
                    _buildColorfulActionButton(
                      context,
                      color: DesignColors.highlightNavy,
                      icon: Icons.qr_code,
                      label: l10n.qrCode,
                      onTap: () => showPetQrCodeSheet(context, pet: profile),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVaccinationStatusCard(
    BuildContext context,
    WidgetRef ref,
    PetProfile profile,
  ) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final vaccinationScheduleAsync =
        ref.watch(vaccinationScheduleProvider(profile.id));

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.sm,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go('/calendar'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(DesignSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icon with teal background
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: DesignColors.highlightTeal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.vaccines,
                        color: DesignColors.highlightTeal,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: DesignSpacing.sm),
                    Expanded(
                      child: Text(
                        l10n.vaccinationStatus,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: primaryText,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: secondaryText,
                    ),
                  ],
                ),
                SizedBox(height: DesignSpacing.md),

                // Show loading/error/data states
                vaccinationScheduleAsync.when(
                  data: (schedule) {
                    // Check if pet has protocol assigned
                    if (profile.vaccinationProtocolId == null) {
                      return _buildNoProtocolState(context, l10n, theme);
                    }

                    // Check if schedule is empty
                    if (schedule.isEmpty) {
                      return _buildNoProtocolState(context, l10n, theme);
                    }

                    // Show protocol info and next due
                    return _buildProtocolInfo(
                        context, ref, profile, schedule, l10n, theme);
                  },
                  loading: () => const Column(
                    children: [
                      SizedBox(
                        height: 60,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  ),
                  error: (error, stack) => Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: theme.colorScheme.error,
                        size: 32,
                      ),
                      SizedBox(height: DesignSpacing.sm),
                      Text(
                        '${l10n.errorLoadingSchedule}: $error',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDewormingStatusCard(
    BuildContext context,
    WidgetRef ref,
    PetProfile profile,
  ) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.sm,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go('/calendar'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(DesignSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icon with coral background
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: DesignColors.highlightCoral.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.bug_report,
                        color: DesignColors.highlightCoral,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: DesignSpacing.sm),
                    Expanded(
                      child: Text(
                        l10n.dewormingStatus,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: primaryText,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: secondaryText,
                    ),
                  ],
                ),
                SizedBox(height: DesignSpacing.md),
                _buildNoDewormingProtocolState(context, l10n, theme, profile),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoDewormingProtocolState(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    PetProfile profile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.noDewormingProtocol,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.tonalIcon(
          onPressed: () =>
              context.push('/deworming/select/${profile.id}', extra: profile),
          icon: const Icon(Icons.add, size: 18),
          label: Text(l10n.selectDewormingProtocol),
        ),
      ],
    );
  }

  Widget _buildNoProtocolState(
      BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.noProtocolSelected,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.tonalIcon(
          onPressed: () => context.go('/calendar'),
          icon: const Icon(Icons.add, size: 18),
          label: Text(l10n.selectProtocol),
        ),
      ],
    );
  }

  Widget _buildProtocolInfo(
    BuildContext context,
    WidgetRef ref,
    PetProfile profile,
    List<dynamic> schedule,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    // Get protocol name
    final protocolAsync = ref
        .watch(vaccinationProtocolByIdProvider(profile.vaccinationProtocolId!));

    // Find next upcoming vaccination
    final now = DateTime.now();
    final upcomingVaccinations =
        schedule.where((entry) => entry.scheduledDate.isAfter(now)).toList();

    // Count completed vaccinations (past dates)
    final completedCount =
        schedule.where((entry) => entry.scheduledDate.isBefore(now)).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Protocol name
        protocolAsync.when(
          data: (protocol) {
            if (protocol != null) {
              // Use protocol.nameRo when locale is Romanian
              final locale = Localizations.localeOf(context);
              final protocolName =
                  locale.languageCode == 'ro' && protocol.nameRo != null
                      ? protocol.nameRo!
                      : protocol.name;

              return Row(
                children: [
                  Text(
                    '${l10n.currentProtocol}:',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      protocolName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),

        const SizedBox(height: 12),

        // Progress indicator
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: schedule.isEmpty ? 0 : completedCount / schedule.length,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$completedCount/${schedule.length}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Next due date
        if (upcomingVaccinations.isNotEmpty) ...[
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.event,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '${l10n.nextDue}:',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('MMM dd, yyyy')
                    .format(upcomingVaccinations.first.scheduledDate),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text(
              upcomingVaccinations.first.vaccineName,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ],

        const SizedBox(height: 12),

        // View full schedule link
        TextButton.icon(
          onPressed: () => context.go('/calendar'),
          icon: const Icon(Icons.calendar_month, size: 16),
          label: Text(l10n.viewFullSchedule),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 32),
          ),
        ),
      ],
    );
  }

  void _navigateToWeightTracking(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const WeightHistoryScreen(),
      ),
    );
  }

  Widget _buildProfileCard(
      BuildContext context, WidgetRef ref, PetProfile profile, bool isActive) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.sm,
        // Teal left border for active pet
        border: isActive
            ? const Border(
                left: BorderSide(
                  color: DesignColors.highlightTeal,
                  width: 4,
                ),
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isActive ? null : () => _activateProfile(context, ref, profile),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(DesignSpacing.sm),
            child: Row(
              children: [
                _buildProfileAvatar(context, profile, 48),
                SizedBox(width: DesignSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: GoogleFonts.quicksand(
                          fontSize: 16,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                          color: primaryText,
                        ),
                      ),
                      SizedBox(height: DesignSpacing.xs),
                      Builder(
                        builder: (context) {
                          final locale = Localizations.localeOf(context);
                          return Row(
                            children: [
                              if (profile.gender != PetGender.unknown) ...[
                                Icon(
                                  _getGenderIcon(profile.gender),
                                  size: 14,
                                  color: _getGenderIconColor(profile.gender),
                                ),
                                SizedBox(width: DesignSpacing.xs),
                              ],
                              Expanded(
                                child: Text(
                                  '${SpeciesTranslations.getDisplayName(profile.species, locale.languageCode)}${profile.breed != null ? ' • ${profile.breed}' : ''}',
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: secondaryText,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      if (profile.age > 0)
                        Text(
                          l10n.yearsOld(profile.age, profile.age != 1 ? 's' : ''),
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: secondaryText,
                          ),
                        ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isActive)
                      const Icon(
                        Icons.check_circle,
                        color: DesignColors.highlightTeal,
                        size: 24,
                      ),
                    PopupMenuButton<String>(
                      onSelected: (value) =>
                          _handleMenuAction(context, ref, profile, value),
                      icon: Icon(Icons.more_vert, color: secondaryText),
                      itemBuilder: (context) => [
                        if (!isActive)
                          PopupMenuItem(
                            value: 'activate',
                            child: ListTile(
                              leading: const Icon(Icons.check_circle_outline),
                              title: Text(l10n.makeActive),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: const Icon(Icons.edit),
                            title: Text(l10n.edit),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: const Icon(Icons.delete, color: Colors.red),
                            title: Text(l10n.delete,
                                style: const TextStyle(color: Colors.red)),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(
      BuildContext context, PetProfile profile, double radius) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;

    _logger.d('[PROFILE_PIC] Building avatar for pet: ${profile.name}');
    _logger.d('[PROFILE_PIC] photoPath from profile: ${profile.photoPath}');

    Widget avatarContent;

    if (profile.photoPath != null && profile.photoPath!.isNotEmpty) {
      final imageFile = File(profile.photoPath!);
      final exists = imageFile.existsSync();

      _logger.d('[PROFILE_PIC] Checking file existence...');
      _logger.d('[PROFILE_PIC] - Path: ${profile.photoPath}');
      _logger.d('[PROFILE_PIC] - Absolute path: ${imageFile.absolute.path}');
      _logger.d('[PROFILE_PIC] - File exists: $exists');

      if (exists) {
        try {
          final fileSize = imageFile.lengthSync();
          _logger
              .d('[PROFILE_PIC] SUCCESS: File verified! Size: $fileSize bytes');
          _logger.d('[PROFILE_PIC] Creating CircleAvatar with FileImage');

          avatarContent = CircleAvatar(
            radius: radius / 2 - 2,
            backgroundImage: FileImage(imageFile),
          );
        } catch (e) {
          _logger.e('[PROFILE_PIC] ERROR: Failed to read file: $e');
          avatarContent = _buildDefaultAvatar(radius, surfaceColor);
        }
      } else {
        _logger.e(
            '[PROFILE_PIC] ERROR: photoPath is set but file does NOT exist!');
        _logger
            .e('[PROFILE_PIC] ERROR: Expected at: ${imageFile.absolute.path}');
        avatarContent = _buildDefaultAvatar(radius, surfaceColor);
      }
    } else {
      _logger
          .d('[PROFILE_PIC] photoPath is null or empty, showing default icon');
      avatarContent = _buildDefaultAvatar(radius, surfaceColor);
    }

    // Wrap with coral accent border
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: DesignColors.highlightCoral.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: avatarContent,
    );
  }

  Widget _buildDefaultAvatar(double radius, Color surfaceColor) {
    return CircleAvatar(
      radius: radius / 2 - 2,
      backgroundColor: surfaceColor,
      child: Icon(
        Icons.pets,
        size: radius * 0.5,
        color: DesignColors.highlightCoral,
      ),
    );
  }

  Future<void> _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    PetProfile profile,
    String action,
  ) async {
    switch (action) {
      case 'activate':
        await _activateProfile(context, ref, profile);
        break;
      case 'edit':
        context.push('/edit-pet/${profile.id}');
        break;
      case 'delete':
        await _deleteProfile(context, ref, profile);
        break;
    }
  }

  Future<void> _activateProfile(
      BuildContext context, WidgetRef ref, PetProfile profile) async {
    try {
      await ref.read(petProfilesProvider.notifier).setActive(profile.id);
      if (context.mounted) {
        final l10n = AppLocalizations.of(context);
        SnackBarHelper.showSuccess(context, l10n.nowActive(profile.name));
      }
    } catch (e) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context);
        SnackBarHelper.showError(context, l10n.failedToActivateProfile(e.toString()));
      }
    }
  }

  Future<void> _deleteProfile(
      BuildContext context, WidgetRef ref, PetProfile profile) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteProfile),
        content: Text(l10n.deleteProfileConfirm(profile.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(petProfilesProvider.notifier).remove(profile.id);
        if (context.mounted) {
          final l10n = AppLocalizations.of(context);
          SnackBarHelper.showSuccess(context, l10n.profileDeleted(profile.name));
        }
      } catch (e) {
        if (context.mounted) {
          final l10n = AppLocalizations.of(context);
          SnackBarHelper.showError(context, '${l10n.failedToDeleteProfile}: $e');
        }
      }
    }
  }
}
