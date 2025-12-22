import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
import '../../../../theme/tokens/colors.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../../../theme/tokens/shadows.dart';
import '../../../domain/models/pet_profile.dart';
import '../../../domain/models/protocols/deworming_protocol.dart';
import '../../providers/protocols/deworming_protocol_provider.dart';
import '../../providers/pet_profile_provider.dart';

/// Deworming Protocol Selection Screen - Allows users to select a deworming protocol for their pet
///
/// This screen displays available deworming protocols filtered by the pet's species
/// and allows the user to select one to apply to their pet.
///
/// Navigation: Expects a `PetProfile` object via state.extra
/// Returns: bool (true if protocol was applied successfully)
class DewormingProtocolSelectionScreen extends ConsumerWidget {
  final PetProfile pet;
  final Logger _logger = Logger();

  DewormingProtocolSelectionScreen({
    super.key,
    required this.pet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final protocolsAsync = ref.watch(
      dewormingProtocolsBySpeciesProvider(pet.species),
    );

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
          l10n.selectDewormingProtocol,
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
      body: SafeArea(
        child: Semantics(
          label: l10n.selectProtocolForPet(pet.name),
          child: protocolsAsync.when(
            loading: () => _buildLoadingState(l10n),
            error: (error, stack) =>
                _buildErrorState(context, l10n, error, ref),
            data: (protocols) => protocols.isEmpty
                ? _buildEmptyState(context, l10n)
                : _buildProtocolList(context, l10n, protocols, ref),
          ),
        ),
      ),
    );
  }

  /// Loading state widget
  Widget _buildLoadingState(AppLocalizations l10n) {
    return Center(
      child: Semantics(
        label: l10n.loadingDewormingProtocols,
        child: CircularProgressIndicator(
          color: DesignColors.highlightYellow,
        ),
      ),
    );
  }

  /// Error state widget
  Widget _buildErrorState(
    BuildContext context,
    AppLocalizations l10n,
    Object error,
    WidgetRef ref,
  ) {
    final theme = Theme.of(context);
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
              Icons.error_outline,
              size: 80,
              color: dangerColor,
            ),
            SizedBox(height: DesignSpacing.lg),
            Text(
              l10n.failedToLoadDewormingProtocols,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: DesignSpacing.sm),
            Text(
              error.toString().length > 100
                  ? '${error.toString().substring(0, 100)}...'
                  : error.toString(),
              style: GoogleFonts.inter(
                fontSize: 12,
                color: secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: DesignSpacing.xl),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(
                    dewormingProtocolsBySpeciesProvider(pet.species));
              },
              icon: const Icon(Icons.refresh),
              label: Text(
                l10n.retry,
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

  /// Empty state widget
  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
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
              Icons.pest_control_outlined,
              size: 80,
              color: DesignColors.highlightYellow.withOpacity(0.5),
            ),
            SizedBox(height: DesignSpacing.lg),
            Text(
              l10n.noDewormingProtocolsAvailable,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: DesignSpacing.sm),
            Text(
              l10n.noDewormingProtocolsForSpecies(pet.species),
              style: GoogleFonts.inter(
                fontSize: 14,
                color: secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: DesignSpacing.xl),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                l10n.cancel,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: secondaryText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Main protocol list widget
  Widget _buildProtocolList(
    BuildContext context,
    AppLocalizations l10n,
    List<DewormingProtocol> protocols,
    WidgetRef ref,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Padding(
      padding: EdgeInsets.all(DesignSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pet info header
          _PetInfoHeader(pet: pet),
          SizedBox(height: DesignSpacing.lg),

          // Section title
          Text(
            l10n.selectDewormingProtocol,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: primaryText,
            ),
          ),
          SizedBox(height: DesignSpacing.sm),

          // Helper text
          Text(
            l10n.chooseDewormingProtocol,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: secondaryText,
            ),
          ),
          SizedBox(height: DesignSpacing.lg),

          // Protocol cards list
          Expanded(
            child: ListView.separated(
              itemCount: protocols.length,
              separatorBuilder: (context, index) =>
                  SizedBox(height: DesignSpacing.sm),
              itemBuilder: (context, index) {
                final protocol = protocols[index];
                return _ProtocolCard(
                  protocol: protocol,
                  onTap: () =>
                      _showConfirmationSheet(context, l10n, protocol, ref),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Show confirmation bottom sheet
  Future<void> _showConfirmationSheet(
    BuildContext context,
    AppLocalizations l10n,
    DewormingProtocol protocol,
    WidgetRef ref,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => _ConfirmationBottomSheet(
        protocol: protocol,
        pet: pet,
        onConfirm: () => _applyProtocol(context, l10n, protocol, ref),
      ),
    );
  }

  /// Apply protocol to pet
  Future<void> _applyProtocol(
    BuildContext context,
    AppLocalizations l10n,
    DewormingProtocol protocol,
    WidgetRef ref,
  ) async {
    try {
      _logger.d('Applying deworming protocol ${protocol.id} to pet ${pet.id}');

      // Update pet with new protocol ID
      final updatedPet = pet.copyWith(
        dewormingProtocolId: protocol.id,
      );

      await ref.read(petProfilesProvider.notifier).createOrUpdate(updatedPet);

      if (context.mounted) {
        // Close bottom sheet
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.dewormingProtocolApplied(pet.name)),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );

        // Return to previous screen with success result
        Navigator.of(context).pop(true);
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to apply deworming protocol',
          error: e, stackTrace: stackTrace);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.dewormingProtocolApplyFailed),
            backgroundColor: Theme.of(context).colorScheme.error,
            action: SnackBarAction(
              label: l10n.retry,
              onPressed: () => _applyProtocol(context, l10n, protocol, ref),
            ),
          ),
        );
      }
    }
  }
}

// ============================================================================
// INLINE WIDGETS
// ============================================================================

/// Pet info header widget - displays pet details
class _PetInfoHeader extends StatelessWidget {
  final PetProfile pet;

  const _PetInfoHeader({required this.pet});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    // Localize species display
    String getLocalizedSpecies(String species) {
      final lowerSpecies = species.toLowerCase();
      if (lowerSpecies == 'dog' || lowerSpecies == 'câine') {
        return l10n.speciesDog;
      } else if (lowerSpecies == 'cat' || lowerSpecies == 'pisică') {
        return l10n.speciesCat;
      }
      return species; // Fallback to original if not recognized
    }

    return Container(
      padding: EdgeInsets.all(DesignSpacing.lg),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
      ),
      child: Row(
        children: [
          // Pet photo/avatar
          CircleAvatar(
            radius: 28,
            backgroundColor: DesignColors.highlightTeal.withOpacity(0.2),
            backgroundImage: pet.photoPath != null && pet.photoPath!.isNotEmpty
                ? AssetImage(pet.photoPath!)
                : null,
            child: pet.photoPath == null || pet.photoPath!.isEmpty
                ? Icon(
                    Icons.pets,
                    color: DesignColors.highlightTeal,
                    size: 28,
                  )
                : null,
          ),
          SizedBox(width: DesignSpacing.md),

          // Pet name and species/age
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: primaryText,
                  ),
                ),
                SizedBox(height: DesignSpacing.xs),
                Row(
                  children: [
                    // Species badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: DesignSpacing.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: DesignColors.highlightTeal.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        getLocalizedSpecies(pet.species),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: DesignColors.highlightTeal,
                        ),
                      ),
                    ),
                    SizedBox(width: DesignSpacing.sm),
                    Text(
                      _formatAge(pet.birthday, l10n),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: secondaryText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatAge(DateTime? birthday, AppLocalizations l10n) {
    if (birthday == null) return l10n.noBirthdaySet;
    final now = DateTime.now();
    final age = now.difference(birthday);
    final years = age.inDays ~/ 365;
    final months = (age.inDays % 365) ~/ 30;

    if (years > 0) {
      return l10n.ageYearsShort(years);
    } else if (months > 0) {
      return l10n.ageMonthsShort(months);
    } else {
      final weeks = age.inDays ~/ 7;
      return l10n.ageWeeksShort(weeks);
    }
  }
}

/// Protocol card widget - displays a single protocol
class _ProtocolCard extends StatelessWidget {
  final DewormingProtocol protocol;
  final VoidCallback onTap;

  const _ProtocolCard({
    required this.protocol,
    required this.onTap,
  });

  /// Determine if protocol is standard by checking if name contains "Standard"
  bool get _isStandard => protocol.name.toLowerCase().contains('standard');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final locale = Localizations.localeOf(context);
    final isRomanian = locale.languageCode == 'ro';

    // Use Romanian translations if available
    final displayName = isRomanian && protocol.nameRo != null
        ? protocol.nameRo!
        : protocol.name;
    final displayDescription = isRomanian && protocol.descriptionRo != null
        ? protocol.descriptionRo!
        : protocol.description;

    return Semantics(
      label: '$displayName, '
          '${_isStandard ? l10n.coreProtocol : l10n.extendedProtocol}, '
          '${l10n.treatmentsCount(protocol.schedules.length)}, '
          '${protocol.region ?? 'Unknown'}',
      button: true,
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: EdgeInsets.all(DesignSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Protocol name
                        Text(
                          displayName,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: primaryText,
                          ),
                        ),
                        SizedBox(height: DesignSpacing.sm),

                        // Badges row
                        Wrap(
                          spacing: DesignSpacing.xs,
                          runSpacing: DesignSpacing.xs,
                          children: [
                            // Standard/Intensive badge
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: DesignSpacing.sm,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _isStandard
                                    ? DesignColors.highlightTeal.withOpacity(0.15)
                                    : DesignColors.highlightPurple.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _isStandard
                                    ? l10n.coreProtocol
                                    : l10n.extendedProtocol,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _isStandard
                                      ? DesignColors.highlightTeal
                                      : DesignColors.highlightPurple,
                                ),
                              ),
                            ),

                            // Predefined/Custom badge
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: DesignSpacing.sm,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: protocol.isCustom
                                    ? secondaryText.withOpacity(0.1)
                                    : DesignColors.highlightBlue.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                protocol.isCustom
                                    ? l10n.customProtocol
                                    : l10n.predefinedProtocol,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: protocol.isCustom
                                      ? secondaryText
                                      : DesignColors.highlightBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: DesignSpacing.sm),

                        // Description
                        Text(
                          displayDescription,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: secondaryText,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: DesignSpacing.md),

                        // Metadata (treatment count and region)
                        Row(
                          children: [
                            Icon(
                              Icons.pest_control,
                              size: 16,
                              color: DesignColors.highlightYellow,
                            ),
                            SizedBox(width: 4),
                            Text(
                              l10n.treatmentsCount(protocol.schedules.length),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: secondaryText,
                              ),
                            ),
                            SizedBox(width: DesignSpacing.md),
                            Icon(
                              Icons.public,
                              size: 16,
                              color: DesignColors.highlightYellow,
                            ),
                            SizedBox(width: 4),
                            Text(
                              protocol.region ?? 'Unknown',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Chevron icon
                  Icon(
                    Icons.chevron_right,
                    color: secondaryText,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Confirmation bottom sheet - shows protocol summary and confirmation buttons
class _ConfirmationBottomSheet extends StatefulWidget {
  final DewormingProtocol protocol;
  final PetProfile pet;
  final VoidCallback onConfirm;

  const _ConfirmationBottomSheet({
    required this.protocol,
    required this.pet,
    required this.onConfirm,
  });

  @override
  State<_ConfirmationBottomSheet> createState() =>
      _ConfirmationBottomSheetState();
}

class _ConfirmationBottomSheetState extends State<_ConfirmationBottomSheet> {
  bool _isApplying = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final locale = Localizations.localeOf(context);
    final isRomanian = locale.languageCode == 'ro';

    // Use Romanian translations if available
    final displayName = isRomanian && widget.protocol.nameRo != null
        ? widget.protocol.nameRo!
        : widget.protocol.name;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Padding(
          padding: EdgeInsets.all(DesignSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                l10n.confirmProtocolSelection,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
              ),
              SizedBox(height: DesignSpacing.lg),

              // Protocol summary card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(DesignSpacing.lg),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2A2A2A)
                      : const Color(0xFFF5F3E8),
                  borderRadius: BorderRadius.circular(16),
                ),
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
                    Divider(
                      height: DesignSpacing.lg,
                      color: secondaryText.withOpacity(0.2),
                    ),

                    // Show first 5 deworming schedules
                    ...widget.protocol.schedules
                        .take(5)
                        .map((schedule) => Padding(
                              padding: EdgeInsets.only(bottom: DesignSpacing.sm),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    schedule.dewormingType == 'internal'
                                        ? Icons.medication
                                        : Icons.pest_control,
                                    size: 18,
                                    color: schedule.dewormingType == 'internal'
                                        ? DesignColors.highlightBlue
                                        : DesignColors.highlightYellow,
                                  ),
                                  SizedBox(width: DesignSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      '${schedule.dewormingType == 'internal' ? l10n.internalDeworming : l10n.externalDeworming} ${l10n.atWeeksAge(schedule.ageInWeeks)}${schedule.productName != null ? ' - ${schedule.productName}' : ''}',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: primaryText,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),

                    // Show "...and X more" if there are more schedules
                    if (widget.protocol.schedules.length > 5)
                      Padding(
                        padding: EdgeInsets.only(top: DesignSpacing.xs),
                        child: Text(
                          l10n.andXMore(widget.protocol.schedules.length - 5),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: secondaryText,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: DesignSpacing.xl),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isApplying ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: secondaryText),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: DesignSpacing.md),
                      ),
                      child: Text(
                        l10n.cancel,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: primaryText,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: DesignSpacing.md),
                  Expanded(
                    flex: 2,
                    child: Semantics(
                      label: l10n.applyProtocolToPet(
                        displayName,
                        widget.pet.name,
                      ),
                      button: true,
                      child: ElevatedButton(
                        onPressed: _isApplying
                            ? null
                            : () {
                                setState(() => _isApplying = true);
                                widget.onConfirm();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: DesignColors.highlightTeal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: DesignSpacing.md),
                        ),
                        child: _isApplying
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                l10n.applyProtocol,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
