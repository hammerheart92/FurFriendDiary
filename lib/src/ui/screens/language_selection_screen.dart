import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens/colors.dart';
import '../../../theme/tokens/spacing.dart';
import '../../../theme/tokens/shadows.dart';
import '../../presentation/providers/settings_provider.dart';

/// Full-screen Language Selection page
///
/// Displays available languages in a card-based list with checkmark
/// indicator for the currently selected language.
class LanguageSelectionScreen extends ConsumerWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor =
        isDark ? DesignColors.dBackground : DesignColors.lBackground;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final dividerColor = isDark
        ? DesignColors.dSecondaryText.withOpacity(0.2)
        : DesignColors.lSecondaryText.withOpacity(0.2);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: primaryText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.language,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subtitle
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: DesignSpacing.md,
              vertical: DesignSpacing.sm,
            ),
            child: Text(
              l10n.chooseLanguage,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: secondaryText,
              ),
            ),
          ),

          SizedBox(height: DesignSpacing.md),

          // Language Card Container
          Padding(
            padding: EdgeInsets.symmetric(horizontal: DesignSpacing.md),
            child: Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
              ),
              child: Column(
                children: [
                  // English
                  _buildLanguageItem(
                    context: context,
                    ref: ref,
                    label: l10n.english,
                    code: 'en',
                    isSelected: currentLocale.languageCode == 'en',
                    primaryText: primaryText,
                    showDivider: true,
                    dividerColor: dividerColor,
                  ),

                  // Romanian
                  _buildLanguageItem(
                    context: context,
                    ref: ref,
                    label: l10n.romanian,
                    code: 'ro',
                    isSelected: currentLocale.languageCode == 'ro',
                    primaryText: primaryText,
                    showDivider: false,
                    dividerColor: dividerColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageItem({
    required BuildContext context,
    required WidgetRef ref,
    required String label,
    required String code,
    required bool isSelected,
    required Color primaryText,
    required bool showDivider,
    required Color dividerColor,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.symmetric(
            horizontal: DesignSpacing.lg,
            vertical: DesignSpacing.sm,
          ),
          title: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: primaryText,
            ),
          ),
          trailing: isSelected
              ? Icon(
                  Icons.check,
                  color: DesignColors.highlightTeal,
                  size: 24,
                )
              : null,
          onTap: () {
            ref.read(localeProvider.notifier).setLocale(Locale(code));
            Navigator.pop(context);
          },
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            indent: DesignSpacing.lg,
            endIndent: DesignSpacing.lg,
            color: dividerColor,
          ),
      ],
    );
  }
}
