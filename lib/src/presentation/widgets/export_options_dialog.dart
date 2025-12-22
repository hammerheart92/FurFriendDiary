import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
import 'package:fur_friend_diary/theme/tokens/colors.dart';
import 'package:fur_friend_diary/theme/tokens/spacing.dart';

enum ExportOption {
  fullReport,
  vetSummary,
  textSummary,
}

/// Dialog for selecting export options
class ExportOptionsDialog extends StatelessWidget {
  const ExportOptionsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;

    return AlertDialog(
      backgroundColor: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        l10n.exportOptions,
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: primaryText,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildExportOption(
            context: context,
            icon: Icons.picture_as_pdf,
            iconColor: DesignColors.highlightCoral,
            title: l10n.fullReport,
            subtitle: l10n.fullReportDescription,
            primaryText: primaryText,
            secondaryText: secondaryText,
            onTap: () => Navigator.of(context).pop(ExportOption.fullReport),
          ),
          Divider(color: secondaryText.withOpacity(0.2)),
          _buildExportOption(
            context: context,
            icon: Icons.medical_information,
            iconColor: DesignColors.highlightTeal,
            title: l10n.vetSummary,
            subtitle: l10n.vetSummaryDescription,
            primaryText: primaryText,
            secondaryText: secondaryText,
            onTap: () => Navigator.of(context).pop(ExportOption.vetSummary),
          ),
          Divider(color: secondaryText.withOpacity(0.2)),
          _buildExportOption(
            context: context,
            icon: Icons.text_snippet,
            iconColor: DesignColors.highlightBlue,
            title: l10n.shareText,
            subtitle: l10n.shareTextDescription,
            primaryText: primaryText,
            secondaryText: secondaryText,
            onTap: () => Navigator.of(context).pop(ExportOption.textSummary),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
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
    );
  }

  Widget _buildExportOption({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color primaryText,
    required Color secondaryText,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.xs,
        vertical: DesignSpacing.xs,
      ),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: primaryText,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: secondaryText,
        ),
      ),
      onTap: onTap,
    );
  }
}

/// Show export options dialog and return selected option
Future<ExportOption?> showExportOptionsDialog(BuildContext context) async {
  return await showDialog<ExportOption>(
    context: context,
    builder: (context) => const ExportOptionsDialog(),
  );
}
