import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
import '../../../../theme/tokens/colors.dart';
import '../../../../theme/tokens/spacing.dart';
import '../../../../theme/tokens/shadows.dart';

/// Dialog shown when FREE tier user tries to add more pets than allowed.
///
/// Returns:
/// - `true` if user taps "Learn More" (wants to upgrade)
/// - `false` if user taps "Maybe Later" (dismisses)
/// - `null` if dialog is dismissed by tapping outside
class UpgradePromptDialog extends StatelessWidget {
  const UpgradePromptDialog({super.key});

  /// Shows the upgrade prompt dialog.
  ///
  /// Returns `true` if user wants to learn more about Premium,
  /// `false` if they dismiss, or `null` if dialog is closed otherwise.
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => const UpgradePromptDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: DesignShadows.lg,
        ),
        padding: EdgeInsets.all(DesignSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Star icon with teal tinted background
            Container(
              padding: EdgeInsets.all(DesignSpacing.md),
              decoration: BoxDecoration(
                color: DesignColors.highlightTeal.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.star,
                size: 48,
                color: DesignColors.highlightTeal,
              ),
            ),

            SizedBox(height: DesignSpacing.md),

            // Title
            Text(
              l10n.upgradeToPremium,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: primaryText,
              ),
            ),

            SizedBox(height: DesignSpacing.sm),

            // Subtitle
            Text(
              l10n.freeTierLimitReached,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: secondaryText,
              ),
            ),

            SizedBox(height: DesignSpacing.xs),

            Text(
              l10n.upgradeForUnlimitedPets,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: secondaryText,
              ),
            ),

            SizedBox(height: DesignSpacing.lg),

            // Features List
            _buildFeatureRow(Icons.pets, l10n.unlimitedPets, primaryText),
            _buildFeatureRow(Icons.cloud_upload, l10n.cloudBackup, primaryText),
            _buildFeatureRow(Icons.family_restroom, l10n.familySharing, primaryText),

            SizedBox(height: DesignSpacing.lg),

            // Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    l10n.maybeLater,
                    style: GoogleFonts.inter(
                      color: secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                SizedBox(width: DesignSpacing.sm),

                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignColors.highlightTeal,
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
                  child: Text(
                    l10n.learnMore,
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text, Color textColor) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: DesignSpacing.xs),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            size: 20,
            color: DesignColors.highlightTeal,
          ),
          SizedBox(width: DesignSpacing.sm),
          Icon(icon, size: 20, color: DesignColors.highlightTeal),
          SizedBox(width: DesignSpacing.sm),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
