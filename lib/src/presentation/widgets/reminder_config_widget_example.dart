// File: lib/src/presentation/widgets/reminder_config_widget_example.dart
// Purpose: Example usage of ReminderConfigWidget for integration guidance
//
// This file demonstrates how to integrate the ReminderConfigWidget
// into screens like SmartReminderSettingsScreen or protocol application screens.

import 'package:flutter/material.dart';
import 'package:fur_friend_diary/src/domain/models/protocols/reminder_config.dart';
import 'package:fur_friend_diary/src/presentation/widgets/reminder_config_widget.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
import 'package:fur_friend_diary/src/utils/snackbar_helper.dart';

/// Example screen showing ReminderConfigWidget integration
///
/// This demonstrates:
/// - Managing ReminderConfig state
/// - Handling onChanged callbacks
/// - Saving changes to repository/provider
class ReminderConfigExample extends StatefulWidget {
  final String petId;
  final String eventType; // 'vaccination', 'medication', etc.

  const ReminderConfigExample({
    required this.petId,
    required this.eventType,
    super.key,
  });

  @override
  State<ReminderConfigExample> createState() => _ReminderConfigExampleState();
}

class _ReminderConfigExampleState extends State<ReminderConfigExample> {
  // Local state for the reminder configuration
  late ReminderConfig _config;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    // Initialize with default configuration
    // In real app, load from repository/provider
    _config = ReminderConfig(
      id: 'reminder_${widget.petId}_${widget.eventType}',
      petId: widget.petId,
      eventType: widget.eventType,
      reminderDays: [1, 7], // Default: 1 day and 1 week before
      isEnabled: true,
    );
  }

  /// Handle configuration changes
  void _handleConfigChange(ReminderConfig updatedConfig) {
    setState(() {
      _config = updatedConfig;
      _hasChanges = true;
    });
  }

  /// Save changes to repository
  Future<void> _saveChanges() async {
    // TODO: Call repository/provider to persist changes
    // Example:
    // await ref.read(reminderConfigRepositoryProvider).save(_config);

    if (mounted) {
      SnackBarHelper.showSuccess(
        context,
        AppLocalizations.of(context).reminderSettingsSaved,
      );
      setState(() {
        _hasChanges = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reminderSettingsFor(widget.eventType)),
        actions: [
          // Show save button only when there are changes
          if (_hasChanges)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveChanges,
              tooltip: l10n.save,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Instructional text
              Card(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.selectWhenToReceiveReminders(widget.eventType),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // The reminder configuration widget
              ReminderConfigWidget(
                config: _config,
                onChanged: _handleConfigChange,
                enabled: true, // Set to false to disable interaction
              ),

              const SizedBox(height: 32),

              // Save button (alternative to AppBar action)
              if (_hasChanges)
                FilledButton.icon(
                  onPressed: _saveChanges,
                  icon: const Icon(Icons.save),
                  label: Text(l10n.saveReminderSettings),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),

              // Debug info (remove in production)
              if (_hasChanges) ...[
                const SizedBox(height: 16),
                Card(
                  color: theme.colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Debug Info (remove in production):',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'isEnabled: ${_config.isEnabled}\n'
                          'reminderDays: ${_config.reminderDays}\n'
                          'description: ${_config.reminderDescription}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Alternative: Using with Riverpod StateProvider
///
/// ```dart
/// // Define a provider for reminder config state
/// final reminderConfigProvider = StateProvider.family<ReminderConfig, String>(
///   (ref, configId) {
///     // Load from repository or return default
///     return ReminderConfig(
///       id: configId,
///       petId: 'pet123',
///       eventType: 'vaccination',
///       reminderDays: [1, 7],
///       isEnabled: true,
///     );
///   },
/// );
///
/// // In your ConsumerWidget:
/// class ReminderSettingsScreen extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final configId = 'reminder_pet123_vaccination';
///     final config = ref.watch(reminderConfigProvider(configId));
///
///     return ReminderConfigWidget(
///       config: config,
///       onChanged: (updatedConfig) {
///         // Update provider state
///         ref.read(reminderConfigProvider(configId).notifier).state = updatedConfig;
///
///         // Optionally persist to repository
///         ref.read(reminderConfigRepositoryProvider).save(updatedConfig);
///       },
///     );
///   }
/// }
/// ```

/// Alternative: Using as a dialog/bottom sheet
void showReminderConfigDialog(
  BuildContext context,
  ReminderConfig initialConfig,
  ValueChanged<ReminderConfig> onSave,
) {
  ReminderConfig currentConfig = initialConfig;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(AppLocalizations.of(context).reminderSettings),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: ReminderConfigWidget(
            config: currentConfig,
            onChanged: (updated) {
              currentConfig = updated;
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context).cancel),
        ),
        FilledButton(
          onPressed: () {
            onSave(currentConfig);
            Navigator.pop(context);
          },
          child: Text(AppLocalizations.of(context).save),
        ),
      ],
    ),
  );
}
