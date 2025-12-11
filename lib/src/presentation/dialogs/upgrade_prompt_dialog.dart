import 'package:flutter/material.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';

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
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            Icons.workspace_premium,
            color: theme.colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.upgradeToPremium,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pet illustration
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 128),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.pets,
              size: 48,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          // Main message
          Text(
            l10n.freeTierLimitReached,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          // Upgrade benefits
          Text(
            l10n.upgradeForUnlimitedPets,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          // Feature highlights
          _buildFeatureRow(context, Icons.pets, l10n.unlimitedPets),
          _buildFeatureRow(context, Icons.cloud_upload, l10n.cloudBackup),
          _buildFeatureRow(context, Icons.family_restroom, l10n.familySharing),
        ],
      ),
      actions: [
        // Maybe Later button
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.maybeLater),
        ),
        // Learn More button
        FilledButton.icon(
          onPressed: () => Navigator.pop(context, true),
          icon: const Icon(Icons.arrow_forward, size: 18),
          label: Text(l10n.learnMore),
        ),
      ],
    );
  }

  Widget _buildFeatureRow(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
