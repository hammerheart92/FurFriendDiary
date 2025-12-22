import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens/colors.dart';
import '../../../theme/tokens/spacing.dart';
import '../../../theme/tokens/shadows.dart';
import '../../presentation/providers/settings_provider.dart';

/// Full-screen Theme Selection page
///
/// Displays available themes in a card-based list with checkmark
/// indicator for the currently selected theme.
class ThemeSelectionScreen extends ConsumerWidget {
  const ThemeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentTheme = ref.watch(themeModeProvider);
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
          l10n.theme,
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
              l10n.chooseTheme,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: secondaryText,
              ),
            ),
          ),

          SizedBox(height: DesignSpacing.md),

          // Theme Card Container
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
                  // Light
                  _buildThemeItem(
                    context: context,
                    ref: ref,
                    label: l10n.light,
                    mode: ThemeMode.light,
                    isSelected: currentTheme == ThemeMode.light,
                    primaryText: primaryText,
                    showDivider: true,
                    dividerColor: dividerColor,
                  ),

                  // Dark
                  _buildThemeItem(
                    context: context,
                    ref: ref,
                    label: l10n.dark,
                    mode: ThemeMode.dark,
                    isSelected: currentTheme == ThemeMode.dark,
                    primaryText: primaryText,
                    showDivider: true,
                    dividerColor: dividerColor,
                  ),

                  // System
                  _buildThemeItem(
                    context: context,
                    ref: ref,
                    label: l10n.system,
                    mode: ThemeMode.system,
                    isSelected: currentTheme == ThemeMode.system,
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

  Widget _buildThemeItem({
    required BuildContext context,
    required WidgetRef ref,
    required String label,
    required ThemeMode mode,
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
            ref.read(themeModeProvider.notifier).setThemeMode(mode);
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
