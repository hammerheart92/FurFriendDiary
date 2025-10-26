import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../presentation/providers/settings_provider.dart';
import '../../../l10n/app_localizations.dart';
import 'reminders_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          // Profile Section
          _buildProfileSection(context),
          const Divider(height: 32),

          // Premium (existing)
          ListTile(
            leading: const Icon(Icons.workspace_premium),
            title: Text(l10n.premium),
            subtitle: Text(l10n.upgradeToUnlock),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/premium'),
          ),
          const Divider(),

          // Pet Management Group
          _buildSectionHeader(context, l10n.petManagement),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: Text(l10n.reportsAndAnalytics),
            subtitle: Text(l10n.viewHealthScoresAndMetrics),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/analytics'),
          ),
          ListTile(
            leading: const Icon(Icons.local_hospital),
            title: Text(l10n.veterinarians),
            subtitle: Text(l10n.manageVeterinariansAndClinics),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/vet-list'),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: Text(l10n.photoGallery),
            subtitle: Text(l10n.viewAndManagePetPhotos),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/photo-gallery'),
          ),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: Text(l10n.medicationInventory),
            subtitle: Text(l10n.trackMedicationStockLevels),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/medication-inventory'),
          ),

          // Account Settings Group
          const Divider(height: 32),
          _buildSectionHeader(context, l10n.accountSettings),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            subtitle: Text(_getLanguageName(context, locale.languageCode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguageDialog(context, ref, locale),
          ),

          // App Preferences Group
          const Divider(height: 32),
          _buildSectionHeader(context, l10n.appPreferences),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: Text(l10n.reminders),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const RemindersScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: Text(l10n.theme),
            subtitle: Text(_getThemeName(context, themeMode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemeDialog(context, ref, themeMode),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: Text(l10n.notifications),
            subtitle: Text(l10n.enableNotifications),
            value: notificationsEnabled,
            onChanged: (value) {
              ref
                  .read(notificationsEnabledProvider.notifier)
                  .setNotificationsEnabled(value);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.analytics_outlined),
            title: Text(l10n.enableAnalytics),
            subtitle: Text(l10n.helpImproveApp),
            value: false,
            onChanged: (_) {},
          ),

          // Data Management Group
          const Divider(height: 32),
          _buildSectionHeader(context, l10n.dataManagement),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: Text(l10n.exportData),
            subtitle: Text(l10n.downloadYourData),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.featureComingSoon)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.cleaning_services),
            title: Text(l10n.clearCache),
            subtitle: Text(l10n.freeUpSpace),
            onTap: () => _showClearCacheDialog(context),
          ),
          ListTile(
            leading: Icon(Icons.delete_forever, color: theme.colorScheme.error),
            title: Text(l10n.deleteAccount,
                style: TextStyle(color: theme.colorScheme.error)),
            subtitle: Text(l10n.deleteAccountPermanently),
            onTap: () => _showDeleteAccountDialog(context),
          ),

          // Privacy & Legal
          const Divider(height: 32),
          _buildSectionHeader(context, l10n.privacyAndLegal),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.privacyPolicy),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              // Get current locale from app
              final locale = Localizations.localeOf(context);
              final isRomanian = locale.languageCode == 'ro';

              // Select URL based on language
              final urlString = isRomanian
                  ? 'https://hammerheart92.github.io/furfrienddiary-legal/privacy-policy-ro.html'
                  : 'https://hammerheart92.github.io/furfrienddiary-legal/privacy-policy.html';

              final url = Uri.parse(urlString);

              try {
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  if (context.mounted) {
                    final l10n = AppLocalizations.of(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.couldNotOpenLink)),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  final l10n = AppLocalizations.of(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.couldNotOpenLink)),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l10n.termsOfService),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              // Get current locale from app
              final locale = Localizations.localeOf(context);
              final isRomanian = locale.languageCode == 'ro';

              // Select URL based on language
              final urlString = isRomanian
                  ? 'https://hammerheart92.github.io/furfrienddiary-legal/terms-of-service-ro.html'
                  : 'https://hammerheart92.github.io/furfrienddiary-legal/terms-of-service.html';

              final url = Uri.parse(urlString);

              try {
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  if (context.mounted) {
                    final l10n = AppLocalizations.of(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.couldNotOpenLink)),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  final l10n = AppLocalizations.of(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.couldNotOpenLink)),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: Text(l10n.openSourceLicenses),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLicensePage(context),
          ),

          // About Section
          const Divider(height: 32),
          _buildSectionHeader(context, l10n.about),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.appVersion),
            subtitle: const Text('1.0.0'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              'PO',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.petOwner,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'user@example.com',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/profile-edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
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

  void _showLanguageDialog(
      BuildContext context, WidgetRef ref, Locale currentLocale) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text(l10n.english),
              value: 'en',
              groupValue: currentLocale.languageCode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(localeProvider.notifier).setLocale(Locale(value));
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: Text(l10n.romanian),
              value: 'ro',
              groupValue: currentLocale.languageCode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(localeProvider.notifier).setLocale(Locale(value));
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(
      BuildContext context, WidgetRef ref, ThemeMode currentMode) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectTheme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: Text(l10n.light),
              value: ThemeMode.light,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(l10n.dark),
              value: ThemeMode.dark,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(l10n.system),
              value: ThemeMode.system,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearCache),
        content: Text(l10n.clearCacheConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              // Simulate cache clearing
              await Future.delayed(const Duration(milliseconds: 500));
              if (context.mounted) {
                final l10n = AppLocalizations.of(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.cacheCleared)),
                );
              }
            },
            child: Text(l10n.clear),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAccount),
        content: Text(l10n.deleteAccountConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(context);
              final l10n = AppLocalizations.of(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.featureComingSoon)),
              );
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _showLicensePage(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: 'FurFriendDiary',
      applicationVersion: '1.0.0',
    );
  }
}
