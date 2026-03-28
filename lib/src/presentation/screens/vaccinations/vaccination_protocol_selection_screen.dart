// File: lib/src/presentation/screens/vaccinations/vaccination_protocol_selection_screen.dart
// Purpose: Protocol selection screen that generates vaccination events after selection
//
// This screen extends the standard protocol selection flow by:
// 1. Showing available vaccination protocols for the pet's species
// 2. After user confirms selection, calling VaccinationService.generateVaccinationsFromProtocol()
// 3. Creating actual VaccinationEvent records in the database

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
import '../../../../theme/tokens/colors.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../../../theme/tokens/shadows.dart';
import '../../../domain/models/pet_profile.dart';
import '../../../domain/models/protocols/vaccination_protocol.dart';
import '../../../data/services/vaccination_service.dart';
import '../../providers/protocols/vaccination_protocol_provider.dart';
import '../../providers/pet_profile_provider.dart';
import '../../providers/vaccinations_provider.dart';
import '../../../utils/snackbar_helper.dart';

/// Vaccination Protocol Selection Screen
///
/// This screen allows users to select a vaccination protocol for their pet
/// and generates actual vaccination event records based on the protocol schedule.
///
/// **Flow:**
/// 1. Display available protocols filtered by pet species
/// 2. User taps on a protocol
/// 3. Confirmation bottom sheet shows protocol details
/// 4. On confirm:
///    a. Update pet profile with selected protocol ID
///    b. Call VaccinationService.generateVaccinationsFromProtocol()
///    c. Show success message and return to timeline
class VaccinationProtocolSelectionScreen extends ConsumerWidget {
  final PetProfile pet;
  final Logger _logger = Logger();

  VaccinationProtocolSelectionScreen({
    super.key,
    required this.pet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final protocolsAsync = ref.watch(
      vaccinationProtocolsBySpeciesProvider(pet.species),
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
          l10n.selectVaccinationProtocol,
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
        label: l10n.loadingProtocols,
        child: CircularProgressIndicator(
          color: DesignColors.highlightTeal,
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
              l10n.failedToLoadProtocols,
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
                    vaccinationProtocolsBySpeciesProvider(pet.species));
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
              Icons.vaccines_outlined,
              size: 80,
              color: DesignColors.highlightPurple.withOpacity(0.5),
            ),
            SizedBox(height: DesignSpacing.lg),
            Text(
              l10n.noProtocolsAvailable,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: DesignSpacing.sm),
            Text(
              l10n.noProtocolsForSpecies(pet.species),
              style: GoogleFonts.inter(
                fontSize: 14,
                color: secondaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: DesignSpacing.xl),
            TextButton(
              onPressed: () => context.pop(),
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
    List<VaccinationProtocol> protocols,
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
            l10n.selectVaccinationProtocol,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: primaryText,
            ),
          ),
          SizedBox(height: DesignSpacing.sm),

          // Helper text
          Text(
            l10n.chooseProtocolMatchingNeeds,
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

  Future<void> _showConfirmationSheet(
    BuildContext context,
    AppLocalizations l10n,
    VaccinationProtocol protocol,
    WidgetRef ref,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => _ConfirmationBottomSheet(
        protocol: protocol,
        pet: pet,
        onConfirm: () => _applyProtocolAndGenerateVaccinations(
          context,
          l10n,
          protocol,
          ref,
        ),
      ),
    );
  }

  /// Apply protocol AND generate vaccination events
  Future<void> _applyProtocolAndGenerateVaccinations(
    BuildContext context,
    AppLocalizations l10n,
    VaccinationProtocol protocol,
    WidgetRef ref,
  ) async {
    try {
      _logger.d(
          'Applying protocol ${protocol.id} to pet ${pet.id} and generating vaccinations');

      // Step 1: Update pet profile with protocol ID
      final updatedPet = pet.copyWith(
        vaccinationProtocolId: protocol.id,
      );
      await ref.read(petProfilesProvider.notifier).createOrUpdate(updatedPet);

      // Step 2: Generate vaccination events from protocol
      final vaccinationService = ref.read(vaccinationServiceProvider);
      final generatedEvents =
          await vaccinationService.generateVaccinationsFromProtocol(
        pet: updatedPet,
        protocolId: protocol.id,
        lookAheadMonths: 24, // Generate 2 years of vaccinations
      );

      _logger.i(
          'Generated ${generatedEvents.length} vaccination events for pet ${pet.id}');

      // Step 3: Invalidate vaccinations provider to refresh the list
      ref.invalidate(vaccinationsByPetIdProvider(pet.id));
      ref.invalidate(vaccinationProviderProvider);

      if (context.mounted) {
        // Close bottom sheet
        Navigator.of(context).pop();

        // Show success message
        SnackBarHelper.showSuccess(context, l10n.protocolAppliedSuccess(pet.name));

        // Return to vaccination timeline
        Navigator.of(context).pop(true);
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to apply protocol and generate vaccinations',
          error: e, stackTrace: stackTrace);

      if (context.mounted) {
        SnackBarHelper.showError(context, l10n.protocolApplyFailed);
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

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
                        _getLocalizedSpecies(context, pet.species),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: DesignColors.highlightTeal,
                        ),
                      ),
                    ),
                    SizedBox(width: DesignSpacing.sm),
                    Text(
                      _formatAge(context, pet.birthday),
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

  String _getLocalizedSpecies(BuildContext context, String species) {
    final l10n = AppLocalizations.of(context);
    switch (species.toLowerCase()) {
      case 'dog':
      case 'câine':
        return l10n.speciesDog;
      case 'cat':
      case 'pisică':
        return l10n.speciesCat;
      default:
        return species;
    }
  }

  String _formatAge(BuildContext context, DateTime? birthday) {
    final l10n = AppLocalizations.of(context);
    if (birthday == null) return l10n.pdfUnknown;
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
  final VaccinationProtocol protocol;
  final VoidCallback onTap;

  const _ProtocolCard({
    required this.protocol,
    required this.onTap,
  });

  bool get _isCore => protocol.name.toLowerCase().contains('core');

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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

    final displayName =
        (isRomanian && protocol.nameRo != null && protocol.nameRo!.isNotEmpty)
            ? protocol.nameRo!
            : protocol.name;
    final displayDescription = (isRomanian &&
            protocol.descriptionRo != null &&
            protocol.descriptionRo!.isNotEmpty)
        ? protocol.descriptionRo!
        : protocol.description;

    return Semantics(
      label: '$displayName, '
          '${_isCore ? l10n.coreProtocol : l10n.extendedProtocol}, '
          '${l10n.vaccinationsCount(protocol.steps.length)}',
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
                        // Protocol name and badge row
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                displayName,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: primaryText,
                                ),
                              ),
                            ),
                            SizedBox(width: DesignSpacing.sm),
                            // Core/Extended badge
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: DesignSpacing.sm,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _isCore
                                    ? DesignColors.highlightTeal.withOpacity(0.15)
                                    : DesignColors.highlightPurple.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _isCore ? l10n.coreProtocol : l10n.extendedProtocol,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _isCore
                                      ? DesignColors.highlightTeal
                                      : DesignColors.highlightPurple,
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

                        // Vaccination count
                        Row(
                          children: [
                            Icon(
                              Icons.vaccines,
                              size: 16,
                              color: DesignColors.highlightPurple,
                            ),
                            SizedBox(width: 4),
                            Text(
                              l10n.vaccinationsCount(protocol.steps.length),
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
  final VaccinationProtocol protocol;
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
    final l10n = AppLocalizations.of(context);
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

    final displayName = (isRomanian &&
            widget.protocol.nameRo != null &&
            widget.protocol.nameRo!.isNotEmpty)
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
                        color: DesignColors.highlightPurple,
                      ),
                    ),
                    Divider(
                      height: DesignSpacing.lg,
                      color: secondaryText.withOpacity(0.2),
                    ),

                    // Show first 5 vaccination steps
                    ...widget.protocol.steps.take(5).map((step) => Padding(
                          padding: EdgeInsets.only(bottom: DesignSpacing.sm),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                step.isRequired
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                size: 18,
                                color: step.isRequired
                                    ? DesignColors.highlightTeal
                                    : secondaryText.withOpacity(0.5),
                              ),
                              SizedBox(width: DesignSpacing.sm),
                              Expanded(
                                child: Text(
                                  '${step.vaccineName} ${l10n.atWeeksAge(step.ageInWeeks)}',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: primaryText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),

                    // Show "...and X more" if there are more steps
                    if (widget.protocol.steps.length > 5)
                      Padding(
                        padding: EdgeInsets.only(top: DesignSpacing.xs),
                        child: Text(
                          l10n.andXMore(widget.protocol.steps.length - 5),
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
