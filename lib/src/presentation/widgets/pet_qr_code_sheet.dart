import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../domain/models/pet_profile.dart';
import '../../data/services/qr_code_service.dart';
import 'pet_qr_code_widget.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.qrCodeSaved)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.qrCodeSaveFailed)),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.qrCodeShareFailed)),
        );
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

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            l10n.qrCodeTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            l10n.qrCodeDescription,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),

          // QR Code
          Center(
            child: PetQrCodeWidget(
              qrData: qrData,
              petName: widget.pet.name,
              petSpecies: localizedSpecies,
              size: 220,
              repaintKey: _qrKey,
            ),
          ),
          const SizedBox(height: 16),

          // Privacy notice
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.privacy_tip_outlined,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.qrCodePrivacyNote,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isSaving ? null : _saveQrCode,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_alt),
                  label: Text(l10n.saveToDevice),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton.icon(
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
                      : const Icon(Icons.share),
                  label: Text(l10n.share),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
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
