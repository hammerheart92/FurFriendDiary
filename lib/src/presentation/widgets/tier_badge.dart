import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../domain/models/pet_owner_tier.dart';

/// A badge widget that displays the user's subscription tier.
///
/// Color coding:
/// - FREE: Gray
/// - PREMIUM: Gold/Amber
/// - LIFETIME: Purple
class TierBadge extends StatelessWidget {
  final PetOwnerTier tier;
  final bool compact;

  const TierBadge({
    super.key,
    required this.tier,
    this.compact = false,
  });

  /// Returns the localized display name for a tier.
  String _getLocalizedTierName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (tier) {
      case PetOwnerTier.free:
        return l10n.tierFree;
      case PetOwnerTier.premium:
        return l10n.tierPremium;
      case PetOwnerTier.lifetime:
        return l10n.tierLifetime;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getTierColors(context);
    final icon = _getTierIcon();
    final tierName = _getLocalizedTierName(context);

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: colors.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.borderColor, width: 1),
        ),
        child: Text(
          tierName.toUpperCase(),
          style: TextStyle(
            color: colors.textColor,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.borderColor, width: 1.5),
        boxShadow: tier != PetOwnerTier.free
            ? [
                BoxShadow(
                  color: colors.borderColor.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: colors.iconColor,
          ),
          const SizedBox(width: 6),
          Text(
            tierName.toUpperCase(),
            style: TextStyle(
              color: colors.textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTierIcon() {
    switch (tier) {
      case PetOwnerTier.free:
        return Icons.person_outline;
      case PetOwnerTier.premium:
        return Icons.star;
      case PetOwnerTier.lifetime:
        return Icons.diamond;
    }
  }

  _TierColors _getTierColors(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (tier) {
      case PetOwnerTier.free:
        return _TierColors(
          backgroundColor: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          borderColor: isDark ? Colors.grey[600]! : Colors.grey[400]!,
          textColor: isDark ? Colors.grey[300]! : Colors.grey[700]!,
          iconColor: isDark ? Colors.grey[400]! : Colors.grey[600]!,
        );
      case PetOwnerTier.premium:
        return _TierColors(
          backgroundColor: isDark
              ? Colors.amber[900]!.withOpacity(0.3)
              : Colors.amber[50]!,
          borderColor: isDark ? Colors.amber[600]! : Colors.amber[700]!,
          textColor: isDark ? Colors.amber[300]! : Colors.amber[800]!,
          iconColor: isDark ? Colors.amber[400]! : Colors.amber[600]!,
        );
      case PetOwnerTier.lifetime:
        return _TierColors(
          backgroundColor: isDark
              ? Colors.purple[900]!.withOpacity(0.3)
              : Colors.purple[50]!,
          borderColor: isDark ? Colors.purple[400]! : Colors.purple[600]!,
          textColor: isDark ? Colors.purple[200]! : Colors.purple[800]!,
          iconColor: isDark ? Colors.purple[300]! : Colors.purple[500]!,
        );
    }
  }
}

class _TierColors {
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Color iconColor;

  _TierColors({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.iconColor,
  });
}
