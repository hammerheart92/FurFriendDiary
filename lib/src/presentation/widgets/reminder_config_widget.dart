// File: lib/src/presentation/widgets/reminder_config_widget.dart
// Purpose: Configurable reminder widget for pet care events (vaccinations, medications, etc.)
//
// This widget provides an intuitive interface for users to:
// - Enable/disable reminders for specific care events
// - Select multiple reminder offsets (day of, 1 day, 1 week, 2 weeks before)
// - See a human-readable summary of configured reminders

import 'package:flutter/material.dart';
import 'package:fur_friend_diary/src/domain/models/protocols/reminder_config.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';

/// A reusable widget for configuring pet care event reminders
///
/// Displays:
/// - Master on/off toggle for reminders
/// - Multi-select filter chips for common reminder offsets (0, 1, 7, 14 days before)
/// - Visual summary of selected reminders
///
/// All state changes are communicated upward via [onChanged] callback.
/// Parent component manages the [ReminderConfig] state.
class ReminderConfigWidget extends StatelessWidget {
  /// Current reminder configuration
  final ReminderConfig config;

  /// Callback fired when reminder settings change
  final ValueChanged<ReminderConfig> onChanged;

  /// Whether the widget is interactive (default: true)
  /// When false, all controls are disabled
  final bool enabled;

  const ReminderConfigWidget({
    required this.config,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Master enable/disable toggle
        _buildMasterToggle(context, theme, l10n),

        // Reminder offset selection (only shown when enabled)
        if (config.isEnabled) ...[
          const SizedBox(height: 24),
          _buildReminderSelection(context, theme, l10n),
        ],
      ],
    );
  }

  /// Builds the master enable/disable switch
  Widget _buildMasterToggle(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Card(
      child: SwitchListTile(
        title: Text(
          l10n.enableReminders,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          config.isEnabled
              ? l10n.notificationsActive
              : l10n.notificationsDisabled,
          style: theme.textTheme.bodySmall?.copyWith(
            color: config.isEnabled
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
          ),
        ),
        value: config.isEnabled,
        onChanged: enabled
            ? (value) {
                onChanged(config.copyWith(
                  isEnabled: value,
                  updatedAt: DateTime.now(),
                ));
              }
            : null,
        secondary: Icon(
          config.isEnabled
              ? Icons.notifications_active
              : Icons.notifications_off,
          color: config.isEnabled
              ? theme.colorScheme.primary
              : theme.colorScheme.outline,
          semanticLabel: config.isEnabled
              ? l10n.notificationsActive
              : l10n.notificationsDisabled,
        ),
      ),
    );
  }

  /// Builds the reminder timing selection section
  Widget _buildReminderSelection(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            l10n.remindMe,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Filter chips for reminder offsets
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildReminderChip(
                context,
                l10n.dayOf,
                0,
                config,
                onChanged,
                enabled,
              ),
              _buildReminderChip(
                context,
                l10n.dayBefore,
                1,
                config,
                onChanged,
                enabled,
              ),
              _buildReminderChip(
                context,
                l10n.oneWeekBefore,
                7,
                config,
                onChanged,
                enabled,
              ),
              _buildReminderChip(
                context,
                l10n.twoWeeksBefore,
                14,
                config,
                onChanged,
                enabled,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Summary card showing human-readable reminder description
        if (config.reminderDays.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildReminderSummary(context, theme, l10n),
          ),
      ],
    );
  }

  /// Builds a single filter chip for a reminder offset
  ///
  /// [label] - Display text (e.g., "1 day before")
  /// [days] - Number of days before event (0 = day of)
  Widget _buildReminderChip(
    BuildContext context,
    String label,
    int days,
    ReminderConfig config,
    ValueChanged<ReminderConfig> onChanged,
    bool enabled,
  ) {
    final theme = Theme.of(context);
    final isSelected = config.reminderDays.contains(days);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: enabled && config.isEnabled
          ? (selected) {
              _handleChipSelection(selected, days, config, onChanged);
            }
          : null,
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.onPrimaryContainer,
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      // Ensure accessibility: minimum 48x48 touch target
      materialTapTargetSize: MaterialTapTargetSize.padded,
      // Semantic label for screen readers
      tooltip: isSelected
          ? 'Reminder active: $label'
          : 'Tap to activate reminder: $label',
    );
  }

  /// Handles chip selection/deselection with duplicate prevention
  void _handleChipSelection(
    bool selected,
    int days,
    ReminderConfig config,
    ValueChanged<ReminderConfig> onChanged,
  ) {
    final updatedDays = List<int>.from(config.reminderDays);

    if (selected) {
      // Add only if not already present (prevent duplicates)
      if (!updatedDays.contains(days)) {
        updatedDays.add(days);
      }
    } else {
      // Remove the offset
      updatedDays.remove(days);
    }

    // Update configuration
    onChanged(config.copyWith(
      reminderDays: updatedDays,
      updatedAt: DateTime.now(),
    ));
  }

  /// Builds the reminder summary card
  ///
  /// Shows a human-readable description of selected reminder offsets
  /// Example: "Reminders: 1 day before, 1 week before"
  Widget _buildReminderSummary(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.remindersActive,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    config.reminderDescription,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
