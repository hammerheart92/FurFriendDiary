import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../presentation/providers/settings_provider.dart';
import '../../presentation/providers/pet_owner_provider.dart';
import '../../presentation/widgets/tier_badge.dart';
import '../../../l10n/app_localizations.dart';
import '../../services/data_deletion_service.dart';
import 'reminders_screen.dart';
import 'language_selection_screen.dart';
import 'theme_selection_screen.dart';
import '../../presentation/providers/pdf_consent_provider.dart';
import '../../../theme/tokens/colors.dart';
import '../../../theme/tokens/spacing.dart';
import '../../../theme/tokens/shadows.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor =
        isDark ? DesignColors.dBackground : DesignColors.lBackground;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              // Profile Section
              _buildProfileSection(context),

              // Pet Management Group
              _buildSectionHeader(context, l10n.petManagement),
              _buildSettingsItem(
                context: context,
                icon: Icons.analytics,
                iconColor: DesignColors.highlightBlue,
                title: l10n.reportsAndAnalytics,
                subtitle: l10n.viewHealthScoresAndMetrics,
                onTap: () => context.push('/analytics'),
              ),
              _buildSettingsItem(
                context: context,
                icon: Icons.local_hospital,
                iconColor: DesignColors.highlightCoral,
                title: l10n.veterinarians,
                subtitle: l10n.manageVeterinariansAndClinics,
                onTap: () => context.push('/vet-list'),
              ),
              _buildSettingsItem(
                context: context,
                icon: Icons.photo_library,
                iconColor: DesignColors.highlightPink,
                title: l10n.photoGallery,
                subtitle: l10n.viewAndManagePetPhotos,
                onTap: () => context.push('/photo-gallery'),
              ),
              _buildSettingsItem(
                context: context,
                icon: Icons.inventory,
                iconColor: DesignColors.highlightPurple,
                title: l10n.medicationInventory,
                subtitle: l10n.trackMedicationStockLevels,
                onTap: () => context.push('/medication-inventory'),
              ),

              // Account Settings Group
              _buildSectionHeader(context, l10n.accountSettings),
              _buildSettingsItem(
                context: context,
                icon: Icons.language,
                iconColor: DesignColors.highlightTeal,
                title: l10n.language,
                subtitle: _getLanguageName(context, locale.languageCode),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LanguageSelectionScreen(),
                    ),
                  );
                },
              ),

              // App Preferences Group
              _buildSectionHeader(context, l10n.appPreferences),
              _buildSettingsItem(
                context: context,
                icon: Icons.notifications_outlined,
                iconColor: DesignColors.highlightYellow,
                title: l10n.reminders,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const RemindersScreen(),
                    ),
                  );
                },
              ),
              _buildSettingsItem(
                context: context,
                icon: Icons.palette_outlined,
                iconColor: DesignColors.highlightPurple,
                title: l10n.theme,
                subtitle: _getThemeName(context, themeMode),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ThemeSelectionScreen(),
                    ),
                  );
                },
              ),
              _buildSettingsItem(
                context: context,
                icon: Icons.notifications_active,
                iconColor: DesignColors.highlightBlue,
                title: l10n.notifications,
                subtitle: l10n.enableNotifications,
                trailing: Switch(
                  value: notificationsEnabled,
                  activeTrackColor: DesignColors.highlightTeal.withAlpha(128),
                  activeThumbColor: DesignColors.highlightTeal,
                  onChanged: (value) {
                    ref
                        .read(notificationsEnabledProvider.notifier)
                        .setNotificationsEnabled(value);
                  },
                ),
              ),
              _buildSettingsItem(
                context: context,
                icon: Icons.bar_chart,
                iconColor: DesignColors.highlightNavy,
                title: l10n.enableAnalytics,
                subtitle: l10n.helpImproveApp,
                trailing: Switch(
                  value: false,
                  activeTrackColor: DesignColors.highlightTeal.withAlpha(128),
                  activeThumbColor: DesignColors.highlightTeal,
                  onChanged: (_) {},
                ),
              ),

              // Data Management Group
              _buildSectionHeader(context, l10n.dataManagement),
              _buildSettingsItem(
                context: context,
                icon: Icons.file_download,
                iconColor: DesignColors.highlightTeal,
                title: l10n.exportData,
                subtitle: l10n.downloadYourData,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.featureComingSoon)),
                  );
                },
              ),
              // PDF Export Consent Management
              Consumer(
                builder: (context, ref, child) {
                  final consentAsync = ref.watch(pdfConsentServiceProvider);

                  return consentAsync.when(
                    data: (consent) {
                      final isGranted = consent?.consentGiven ?? false;
                      final hasDecision = consent != null;

                      return _buildSettingsItem(
                        context: context,
                        icon: Icons.picture_as_pdf,
                        iconColor: DesignColors.highlightCoral,
                        title: l10n.pdfExportConsent,
                        subtitle: hasDecision
                            ? (isGranted
                                ? l10n.consentStatusGranted
                                : l10n.consentStatusNotGranted)
                            : l10n.consentStatusNotSet,
                        trailing: Switch(
                          value: isGranted,
                          activeTrackColor:
                              DesignColors.highlightTeal.withAlpha(128),
                          activeThumbColor: DesignColors.highlightTeal,
                          onChanged: (value) async {
                            if (value) {
                              await ref
                                  .read(pdfConsentServiceProvider.notifier)
                                  .grantConsent();
                              if (context.mounted) {
                                final isDarkMode =
                                    Theme.of(context).brightness ==
                                        Brightness.dark;
                                final surfaceBg = isDarkMode
                                    ? DesignColors.dSurfaces
                                    : DesignColors.lSurfaces;
                                final textColor = isDarkMode
                                    ? DesignColors.dPrimaryText
                                    : DesignColors.lPrimaryText;
                                final successColor = isDarkMode
                                    ? DesignColors.dSuccess
                                    : DesignColors.lSuccess;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: successColor,
                                          size: 20,
                                        ),
                                        const SizedBox(width: DesignSpacing.sm),
                                        Expanded(
                                          child: Text(
                                            l10n.consentGrantedMessage,
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: textColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: surfaceBg,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    margin:
                                        const EdgeInsets.all(DesignSpacing.md),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            } else {
                              if (context.mounted) {
                                _showRevokeConsentDialog(context);
                              }
                            }
                          },
                        ),
                      );
                    },
                    loading: () => _buildSettingsItem(
                      context: context,
                      icon: Icons.picture_as_pdf,
                      iconColor: DesignColors.highlightCoral,
                      title: l10n.pdfExportConsent,
                      subtitle: '...',
                      trailing: const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    error: (error, stack) => _buildSettingsItem(
                      context: context,
                      icon: Icons.error_outline,
                      iconColor: DesignColors.lDanger,
                      title: l10n.pdfExportConsent,
                      subtitle: l10n.errorLoadingConsent,
                      trailing: const SizedBox.shrink(),
                    ),
                  );
                },
              ),
              _buildSettingsItem(
                context: context,
                icon: Icons.cleaning_services,
                iconColor: DesignColors.highlightYellow,
                title: l10n.clearCache,
                subtitle: l10n.freeUpSpace,
                onTap: () => _showClearCacheDialog(context),
              ),
              _buildSettingsItem(
                context: context,
                icon: Icons.delete_forever,
                iconColor: DesignColors.lDanger,
                title: l10n.deleteAccount,
                subtitle: l10n.deleteAccountPermanently,
                onTap: () => _showDeleteAccountDialog(context),
              ),

              // Privacy & Legal
              _buildSectionHeader(context, l10n.privacyAndLegal),
              _buildSettingsItem(
                context: context,
                icon: Icons.privacy_tip_outlined,
                iconColor: DesignColors.highlightBlue,
                title: l10n.privacyPolicy,
                onTap: () async {
                  final currentLocale = Localizations.localeOf(context);
                  final isRomanian = currentLocale.languageCode == 'ro';
                  final urlString = isRomanian
                      ? 'https://hammerheart92.github.io/furfrienddiary-legal/privacy-policy-ro.html'
                      : 'https://hammerheart92.github.io/furfrienddiary-legal/privacy-policy.html';
                  final url = Uri.parse(urlString);
                  try {
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url,
                          mode: LaunchMode.externalApplication);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.couldNotOpenLink)),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.couldNotOpenLink)),
                      );
                    }
                  }
                },
              ),
              _buildSettingsItem(
                context: context,
                icon: Icons.description_outlined,
                iconColor: DesignColors.highlightNavy,
                title: l10n.termsOfService,
                onTap: () async {
                  final currentLocale = Localizations.localeOf(context);
                  final isRomanian = currentLocale.languageCode == 'ro';
                  final urlString = isRomanian
                      ? 'https://hammerheart92.github.io/furfrienddiary-legal/terms-of-service-ro.html'
                      : 'https://hammerheart92.github.io/furfrienddiary-legal/terms-of-service.html';
                  final url = Uri.parse(urlString);
                  try {
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url,
                          mode: LaunchMode.externalApplication);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.couldNotOpenLink)),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.couldNotOpenLink)),
                      );
                    }
                  }
                },
              ),
              _buildSettingsItem(
                context: context,
                icon: Icons.code,
                iconColor: DesignColors.highlightTeal,
                title: l10n.openSourceLicenses,
                onTap: () => _showLicensePage(context),
              ),

              // About Section
              _buildSectionHeader(context, l10n.about),
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  final version = snapshot.data?.version ?? '...';
                  final buildNumber = snapshot.data?.buildNumber ?? '';
                  return _buildSettingsItem(
                    context: context,
                    icon: Icons.info_outline,
                    iconColor: DesignColors.highlightPurple,
                    title: l10n.appVersion,
                    subtitle: '$version+$buildNumber',
                    trailing: const SizedBox.shrink(),
                  );
                },
              ),
              SizedBox(height: DesignSpacing.xl),
            ],
          ),
          // Loading overlay
          if (_isDeleting)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final profileAsync = ref.watch(petOwnerProvider);
    final petCount = ref.watch(currentPetCountProvider);

    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryTextColor =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryTextColor =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return profileAsync.when(
      data: (profile) {
        final name = profile?.name ?? l10n.petOwner;
        final email = profile?.email;
        final tier = profile?.effectiveTier;
        final initials = name.isNotEmpty
            ? name
                .split(' ')
                .map((w) => w.isNotEmpty ? w[0] : '')
                .take(2)
                .join()
                .toUpperCase()
            : 'PO';

        return Container(
          margin: EdgeInsets.all(DesignSpacing.md),
          padding: EdgeInsets.all(DesignSpacing.md),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar with gradient border
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      DesignColors.highlightPurple,
                      DesignColors.highlightPink,
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(3),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: surfaceColor,
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: DesignColors.highlightPurple,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: DesignSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: primaryTextColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: DesignSpacing.xs),
                        const Text('🐾', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                    if (email != null && email.isNotEmpty) ...[
                      SizedBox(height: DesignSpacing.xs),
                      Text(
                        email,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: secondaryTextColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    SizedBox(height: DesignSpacing.sm),
                    Row(
                      children: [
                        if (tier != null) ...[
                          TierBadge(tier: tier, compact: true),
                          SizedBox(width: DesignSpacing.sm),
                        ],
                        Flexible(
                          child: Text(
                            l10n.managingPets(petCount),
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: secondaryTextColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  color: secondaryTextColor,
                ),
                onPressed: () => context.push('/profile-edit'),
                tooltip: l10n.editProfile,
              ),
            ],
          ),
        );
      },
      loading: () => Container(
        margin: EdgeInsets.all(DesignSpacing.md),
        padding: EdgeInsets.all(DesignSpacing.md),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: DesignColors.highlightPurple.withAlpha(51),
              ),
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            SizedBox(width: DesignSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120,
                    height: 20,
                    decoration: BoxDecoration(
                      color: secondaryTextColor.withAlpha(51),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: DesignSpacing.sm),
                  Container(
                    width: 80,
                    height: 16,
                    decoration: BoxDecoration(
                      color: secondaryTextColor.withAlpha(51),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      error: (_, __) => Container(
        margin: EdgeInsets.all(DesignSpacing.md),
        padding: EdgeInsets.all(DesignSpacing.md),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: DesignColors.lDanger.withAlpha(51),
              ),
              child: Icon(
                Icons.person_off,
                color: DesignColors.lDanger,
                size: 32,
              ),
            ),
            SizedBox(width: DesignSpacing.md),
            Expanded(
              child: Text(
                l10n.petOwner,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: primaryTextColor,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit_outlined, color: secondaryTextColor),
              onPressed: () => context.push('/profile-edit'),
            ),
          ],
        ),
      ),
    );
  }

  /// Theme-aware section header with teal accent color
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(
        left: DesignSpacing.md,
        top: DesignSpacing.lg,
        bottom: DesignSpacing.xs,
      ),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: DesignColors.highlightTeal,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Builds a colored circular icon background
  Widget _buildIconBackground({
    required IconData icon,
    required Color color,
    double size = 48,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withAlpha(51), // 20% opacity (255 * 0.2 ≈ 51)
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        icon,
        color: color,
        size: size * 0.5,
      ),
    );
  }

  /// Theme-aware settings list item with icon background
  Widget _buildSettingsItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryTextColor =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryTextColor =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: DesignSpacing.md,
        vertical: DesignSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.sm,
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: DesignSpacing.md,
          vertical: DesignSpacing.sm,
        ),
        leading: _buildIconBackground(icon: icon, color: iconColor),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: primaryTextColor,
          ),
        ),
        subtitle: subtitle != null
            ? Padding(
                padding: EdgeInsets.only(top: DesignSpacing.xs),
                child: Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: secondaryTextColor,
                  ),
                ),
              )
            : null,
        trailing: trailing ??
            Icon(
              Icons.chevron_right,
              color: secondaryTextColor,
            ),
        onTap: onTap,
      ),
    );
  }

  String _getLanguageName(BuildContext context, String code) {
    final l10n = AppLocalizations.of(context);
    switch (code) {
      case 'en':
        return l10n.english;
      case 'ro':
        return l10n.romanian;
      default:
        return l10n.english;
    }
  }

  String _getThemeName(BuildContext context, ThemeMode mode) {
    final l10n = AppLocalizations.of(context);
    switch (mode) {
      case ThemeMode.light:
        return l10n.light;
      case ThemeMode.dark:
        return l10n.dark;
      case ThemeMode.system:
        return l10n.system;
    }
  }


  void _showClearCacheDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          l10n.clearCache,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
        content: Text(
          l10n.clearCacheConfirm,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: secondaryText,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: secondaryText,
              padding: const EdgeInsets.symmetric(
                horizontal: DesignSpacing.lg,
                vertical: DesignSpacing.sm,
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignColors.highlightTeal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: DesignSpacing.lg,
                vertical: DesignSpacing.sm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);
              // Simulate cache clearing
              await Future.delayed(const Duration(milliseconds: 500));
              if (context.mounted) {
                final l10n = AppLocalizations.of(context);
                final isDarkMode =
                    Theme.of(context).brightness == Brightness.dark;
                final surfaceBg = isDarkMode
                    ? DesignColors.dSurfaces
                    : DesignColors.lSurfaces;
                final textColor = isDarkMode
                    ? DesignColors.dPrimaryText
                    : DesignColors.lPrimaryText;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: DesignColors.highlightTeal,
                          size: 20,
                        ),
                        const SizedBox(width: DesignSpacing.sm),
                        Expanded(
                          child: Text(
                            l10n.cacheCleared,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: surfaceBg,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.all(DesignSpacing.md),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Text(
              l10n.clear,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          l10n.deleteAccount,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
        content: Text(
          l10n.deleteAccountConfirm,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: secondaryText,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: secondaryText,
              padding: const EdgeInsets.symmetric(
                horizontal: DesignSpacing.lg,
                vertical: DesignSpacing.sm,
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignColors.highlightCoral,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: DesignSpacing.lg,
                vertical: DesignSpacing.sm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context); // Close confirmation dialog

              // Show loading overlay
              setState(() {
                _isDeleting = true;
              });

              // Execute GDPR Article 17 compliant data deletion
              final deletionService = DataDeletionService();
              final success = await deletionService.deleteAllUserData();

              if (!mounted) return;

              // Hide loading overlay
              setState(() {
                _isDeleting = false;
              });

              if (!mounted) return;

              if (success) {
                // Show success dialog that exits app on dismiss
                final isDarkMode =
                    Theme.of(context).brightness == Brightness.dark;
                final dialogPrimaryText = isDarkMode
                    ? DesignColors.dPrimaryText
                    : DesignColors.lPrimaryText;
                final dialogSecondaryText = isDarkMode
                    ? DesignColors.dSecondaryText
                    : DesignColors.lSecondaryText;
                final dialogSurfaceColor = isDarkMode
                    ? DesignColors.dSurfaces
                    : DesignColors.lSurfaces;

                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    final dialogL10n = AppLocalizations.of(context);
                    return AlertDialog(
                      backgroundColor: dialogSurfaceColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: Text(
                        dialogL10n.accountDeletedSuccessfully,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: dialogPrimaryText,
                        ),
                      ),
                      content: Text(
                        dialogL10n.dataDeletedAppCloseMessage,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: dialogSecondaryText,
                          height: 1.5,
                        ),
                      ),
                      actions: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DesignColors.highlightCoral,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: DesignSpacing.lg,
                              vertical: DesignSpacing.sm,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            // Exit the app
                            SystemNavigator.pop();
                          },
                          child: Text(
                            dialogL10n.ok,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              } else {
                // Show error message
                final isDarkMode =
                    Theme.of(context).brightness == Brightness.dark;
                final surfaceBg = isDarkMode
                    ? DesignColors.dSurfaces
                    : DesignColors.lSurfaces;
                final textColor = isDarkMode
                    ? DesignColors.dPrimaryText
                    : DesignColors.lPrimaryText;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(
                          Icons.error,
                          color: DesignColors.highlightCoral,
                          size: 20,
                        ),
                        const SizedBox(width: DesignSpacing.sm),
                        Expanded(
                          child: Text(
                            l10n.accountDeletionFailed,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: surfaceBg,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.all(DesignSpacing.md),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            child: Text(
              l10n.delete,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRevokeConsentDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          l10n.revokeConsentTitle,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
        content: Text(
          l10n.revokeConsentMessage,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: secondaryText,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: secondaryText,
              padding: const EdgeInsets.symmetric(
                horizontal: DesignSpacing.lg,
                vertical: DesignSpacing.sm,
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignColors.highlightCoral,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: DesignSpacing.lg,
                vertical: DesignSpacing.sm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              Navigator.pop(context);

              // Revoke consent
              await ref
                  .read(pdfConsentServiceProvider.notifier)
                  .revokeConsent();

              if (context.mounted) {
                final isDarkMode =
                    Theme.of(context).brightness == Brightness.dark;
                final surfaceBg = isDarkMode
                    ? DesignColors.dSurfaces
                    : DesignColors.lSurfaces;
                final textColor = isDarkMode
                    ? DesignColors.dPrimaryText
                    : DesignColors.lPrimaryText;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(
                          Icons.info,
                          color: DesignColors.highlightCoral,
                          size: 20,
                        ),
                        const SizedBox(width: DesignSpacing.sm),
                        Expanded(
                          child: Text(
                            l10n.consentRevokedMessage,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: surfaceBg,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.all(DesignSpacing.md),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Text(
              l10n.revoke,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLicensePage(BuildContext context) async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (context.mounted) {
      showLicensePage(
        context: context,
        applicationName: 'FurFriendDiary',
        applicationVersion: '${packageInfo.version}+${packageInfo.buildNumber}',
      );
    }
  }
}
