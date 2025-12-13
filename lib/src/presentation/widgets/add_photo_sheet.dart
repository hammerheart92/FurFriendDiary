import 'package:flutter/material.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fur_friend_diary/theme/tokens/colors.dart';
import 'package:fur_friend_diary/theme/tokens/spacing.dart';
import 'package:fur_friend_diary/theme/tokens/shadows.dart';

/// Bottom sheet for selecting photo source (camera or gallery)
class AddPhotoSheet extends StatelessWidget {
  const AddPhotoSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: DesignSpacing.md,
          horizontal: DesignSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: DesignSpacing.md),
              decoration: BoxDecoration(
                color: secondaryText.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: EdgeInsets.only(bottom: DesignSpacing.md),
              child: Text(
                'Add Photo',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
              ),
            ),

            // Camera option
            _buildOptionTile(
              context: context,
              icon: Icons.camera_alt,
              iconColor: DesignColors.highlightTeal,
              title: l10n.takePhoto,
              subtitle: 'Use camera to take a new photo',
              onTap: () => Navigator.of(context).pop('camera'),
              primaryText: primaryText,
              secondaryText: secondaryText,
              isDark: isDark,
            ),

            SizedBox(height: DesignSpacing.xs),

            // Single photo from gallery
            _buildOptionTile(
              context: context,
              icon: Icons.photo_library,
              iconColor: DesignColors.highlightPeach,
              title: l10n.chooseFromGallery,
              subtitle: 'Select one photo from gallery',
              onTap: () => Navigator.of(context).pop('gallery'),
              primaryText: primaryText,
              secondaryText: secondaryText,
              isDark: isDark,
            ),

            SizedBox(height: DesignSpacing.xs),

            // Multiple photos from gallery
            _buildOptionTile(
              context: context,
              icon: Icons.photo_library_outlined,
              iconColor: DesignColors.highlightPurple,
              title: l10n.chooseMultiplePhotos,
              subtitle: 'Select multiple photos at once',
              onTap: () => Navigator.of(context).pop('gallery_multiple'),
              primaryText: primaryText,
              secondaryText: secondaryText,
              isDark: isDark,
            ),

            Padding(
              padding: EdgeInsets.symmetric(vertical: DesignSpacing.sm),
              child: Divider(
                color: secondaryText.withOpacity(0.2),
              ),
            ),

            // Cancel option
            _buildCancelTile(
              context: context,
              title: l10n.cancel,
              secondaryText: secondaryText,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color primaryText,
    required Color secondaryText,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: DesignSpacing.md,
            vertical: DesignSpacing.sm,
          ),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              SizedBox(width: DesignSpacing.md),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: primaryText,
                      ),
                    ),
                    SizedBox(height: DesignSpacing.xs / 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              // Chevron
              Icon(
                Icons.chevron_right,
                color: secondaryText,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCancelTile({
    required BuildContext context,
    required String title,
    required Color secondaryText,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: DesignSpacing.md,
            vertical: DesignSpacing.sm,
          ),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: secondaryText.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.close,
                  color: secondaryText,
                  size: 24,
                ),
              ),
              SizedBox(width: DesignSpacing.md),
              // Text content
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show the add photo sheet and return the selected option
  static Future<String?> show(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;

    return await showModalBottomSheet<String>(
      context: context,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const AddPhotoSheet(),
    );
  }
}

/// Dialog for permission denied state
class PermissionDeniedDialog extends StatelessWidget {
  final String message;
  final bool isPermanentlyDenied;

  const PermissionDeniedDialog({
    super.key,
    required this.message,
    required this.isPermanentlyDenied,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

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
            // Warning icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: DesignColors.highlightCoral.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: DesignColors.highlightCoral,
                size: 32,
              ),
            ),
            SizedBox(height: DesignSpacing.md),
            Text(
              l10n.permissionDenied,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: primaryText,
              ),
            ),
            SizedBox(height: DesignSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: secondaryText,
              ),
            ),
            SizedBox(height: DesignSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    l10n.cancel,
                    style: GoogleFonts.inter(
                      color: secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (isPermanentlyDenied) ...[
                  SizedBox(width: DesignSpacing.sm),
                  ElevatedButton(
                    onPressed: () async {
                      await openAppSettings();
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
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
                    ),
                    child: Text(
                      l10n.openSettings,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Show permission denied dialog
  static Future<void> show(
    BuildContext context, {
    required String message,
    required bool isPermanentlyDenied,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => PermissionDeniedDialog(
        message: message,
        isPermanentlyDenied: isPermanentlyDenied,
      ),
    );
  }
}
