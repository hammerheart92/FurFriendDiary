import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens/colors.dart';
import '../../../theme/tokens/spacing.dart';
import '../../../theme/tokens/shadows.dart';
import '../../domain/models/pet_profile.dart';
import '../../data/services/qr_code_service.dart';
import 'pet_qr_code_widget.dart';
import '../../utils/snackbar_helper.dart';

/// Bottom sheet for displaying and sharing pet QR code.
class PetQrCodeSheet extends StatefulWidget {
  final PetProfile pet;

  const PetQrCodeSheet({super.key, required this.pet});

  @override
  State<PetQrCodeSheet> createState() => _PetQrCodeSheetState();
}

class _PetQrCodeSheetState extends State<PetQrCodeSheet> {
  final GlobalKey _qrKey = GlobalKey();
  final QrCodeService _service = QrCodeService();
  bool _isSaving = false;
  bool _isSharing = false;

  Future<void> _saveQrCode() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isSaving = true);

    try {
      await _service.saveQrCodeImage(_qrKey, widget.pet.name);
      if (mounted) {
        SnackBarHelper.showSuccess(context, l10n.qrCodeSaved);
      }
    } catch (_) {
      if (mounted) {
        SnackBarHelper.showError(context, l10n.qrCodeSaveFailed);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _shareQrCode() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isSharing = true);

    try {
      // First save to temp location, then share
      final path = await _service.saveQrCodeImage(_qrKey, widget.pet.name);
      await _service.shareQrCode(
        path,
        petName: widget.pet.name,
        text: l10n.qrCodeShareText(widget.pet.name),
      );
    } catch (_) {
      if (mounted) {
        SnackBarHelper.showError(context, l10n.qrCodeShareFailed);
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  /// Get localized species name.
  String _getLocalizedSpecies(AppLocalizations l10n, String species) {
    switch (species.toLowerCase()) {
      case 'dog':
        return l10n.speciesDog;
      case 'cat':
        return l10n.speciesCat;
      case 'bird':
        return l10n.speciesBird;
      case 'rabbit':
        return l10n.speciesRabbit;
      case 'hamster':
        return l10n.speciesHamster;
      case 'guinea pig':
        return l10n.speciesGuineaPig;
      case 'fish':
        return l10n.speciesFish;
      case 'turtle':
        return l10n.speciesTurtle;
      case 'lizard':
        return l10n.speciesLizard;
      case 'snake':
        return l10n.speciesSnake;
      case 'ferret':
        return l10n.speciesFerret;
      case 'chinchilla':
        return l10n.speciesChinchilla;
      case 'rat':
        return l10n.speciesRat;
      case 'mouse':
        return l10n.speciesMouse;
      case 'gerbil':
        return l10n.speciesGerbil;
      case 'hedgehog':
        return l10n.speciesHedgehog;
      case 'parrot':
        return l10n.speciesParrot;
      case 'horse':
        return l10n.speciesHorse;
      case 'chicken':
        return l10n.speciesChicken;
      default:
        return species;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final qrData = _service.generateQrDataString(pet: widget.pet, l10n: l10n);
    final localizedSpecies = _getLocalizedSpecies(l10n, widget.pet.species);

    // Design tokens
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: DesignShadows.lg,
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(DesignSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: secondaryText.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: DesignSpacing.lg),

          // Title
          Text(
            l10n.qrCodeTitle,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: primaryText,
            ),
          ),
          SizedBox(height: DesignSpacing.xs),

          // Description
          Text(
            l10n.qrCodeDescription,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: secondaryText,
            ),
          ),
          SizedBox(height: DesignSpacing.lg),

          // QR Code Card
          Center(
            child: PetQrCodeWidget(
              qrData: qrData,
              petName: widget.pet.name,
              petSpecies: localizedSpecies,
              size: 260,
              repaintKey: _qrKey,
              showBorder: true,
              isDark: isDark,
            ),
          ),
          SizedBox(height: DesignSpacing.lg),

          // Privacy notice (Info Message)
          Container(
            padding: EdgeInsets.all(DesignSpacing.md),
            decoration: BoxDecoration(
              color: DesignColors.highlightBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: DesignColors.highlightBlue.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 24,
                  color: DesignColors.highlightBlue,
                ),
                SizedBox(width: DesignSpacing.sm),
                Expanded(
                  child: Text(
                    l10n.qrCodePrivacyNote,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: primaryText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: DesignSpacing.lg),

          // Action buttons
          Row(
            children: [
              // Save Button (Outlined)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isSaving ? null : _saveQrCode,
                  icon: _isSaving
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: DesignColors.highlightBlue,
                          ),
                        )
                      : Icon(Icons.download_outlined, size: 20),
                  label: Text(
                    l10n.saveToDevice,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DesignColors.highlightBlue,
                    side: BorderSide(
                      color: DesignColors.highlightBlue,
                      width: 2,
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: DesignSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: DesignSpacing.md),

              // Share Button (Filled)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isSharing ? null : _shareQrCode,
                  icon: _isSharing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(Icons.share_outlined, size: 20),
                  label: Text(
                    l10n.share,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignColors.highlightTeal,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: DesignSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.md),
        ],
        ),
      ),
    );
  }
}

/// Show QR code bottom sheet for a pet profile.
Future<void> showPetQrCodeSheet(
  BuildContext context, {
  required PetProfile pet,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => PetQrCodeSheet(pet: pet),
  );
}
