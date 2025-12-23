import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
import '../../../utils/snackbar_helper.dart';
import '../../../domain/models/pet_profile.dart';
import '../../../domain/models/protocols/reminder_config.dart';
import '../../providers/protocols/reminder_config_provider.dart';

/// Reminder Settings Screen - Configure notification timing for pet care events
///
/// This screen allows users to customize when they receive reminders for
/// upcoming care events (vaccinations, deworming, appointments, medications).
///
/// Features:
/// - Enable/disable reminders toggle
/// - Select reminder offset days (1 day, 3 days, 1 week, 2 weeks before event)
/// - Save configuration to Hive via ReminderConfig
/// - Automatic creation of default config if none exists
///
/// Usage:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(
///     builder: (context) => ReminderSettingsScreen(
///       pet: petProfile,
///       eventType: 'vaccination',
///     ),
///   ),
/// );
/// ```
class ReminderSettingsScreen extends ConsumerStatefulWidget {
  final PetProfile pet;
  final String
      eventType; // 'vaccination', 'deworming', 'appointment', 'medication'

  const ReminderSettingsScreen({
    super.key,
    required this.pet,
    required this.eventType,
  });

  @override
  ConsumerState<ReminderSettingsScreen> createState() =>
      _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState
    extends ConsumerState<ReminderSettingsScreen> {
  final Logger _logger = Logger();

  // Form state
  bool _isEnabled = true;
  bool _oneDayBefore = false;
  bool _threeDaysBefore = false;
  bool _oneWeekBefore = false;
  bool _twoWeeksBefore = false;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Watch reminder config for this pet and event type
    final configAsync = ref.watch(
      reminderConfigByPetIdAndEventTypeProvider(
        petId: widget.pet.id,
        eventType: widget.eventType,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_getEventTypeTitle(l10n)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Semantics(
          label: l10n.reminderSettingsFor(_getEventTypeTitle(l10n)),
          child: configAsync.when(
            loading: () => _buildLoadingState(l10n),
            error: (error, stack) => _buildErrorState(context, l10n, error),
            data: (config) {
              // Initialize form state from config
              if (config != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _initializeFormState(config);
                  }
                });
              }
              return _buildForm(context, l10n, config);
            },
          ),
        ),
      ),
    );
  }

  /// Get localized title for event type
  String _getEventTypeTitle(AppLocalizations l10n) {
    switch (widget.eventType.toLowerCase()) {
      case 'vaccination':
        return l10n.vaccinationReminders;
      case 'deworming':
        return l10n.dewormingReminders;
      case 'appointment':
        return l10n.appointmentReminders;
      case 'medication':
        return l10n.medicationReminders;
      default:
        return l10n.reminderSettings;
    }
  }

  /// Initialize form state from existing config
  void _initializeFormState(ReminderConfig config) {
    setState(() {
      _isEnabled = config.isEnabled;
      _oneDayBefore = config.reminderDays.contains(1);
      _threeDaysBefore = config.reminderDays.contains(3);
      _oneWeekBefore = config.reminderDays.contains(7);
      _twoWeeksBefore = config.reminderDays.contains(14);
    });
  }

  /// Build loading state
  Widget _buildLoadingState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            l10n.loadingReminderSettings,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState(
    BuildContext context,
    AppLocalizations l10n,
    Object error,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.failedToLoadReminderSettings,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => ref.invalidate(
                reminderConfigByPetIdAndEventTypeProvider(
                  petId: widget.pet.id,
                  eventType: widget.eventType,
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  /// Build main form
  Widget _buildForm(
    BuildContext context,
    AppLocalizations l10n,
    ReminderConfig? existingConfig,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pet info header
            _PetInfoHeader(pet: widget.pet),
            const SizedBox(height: 24),

            // Enable/Disable reminders switch
            Card(
              child: SwitchListTile(
                value: _isEnabled,
                onChanged: (value) {
                  setState(() => _isEnabled = value);
                },
                title: Text(
                  _isEnabled ? l10n.enableReminders : l10n.disableReminders,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  _isEnabled
                      ? l10n.selectWhenToReceiveReminders(widget.eventType)
                      : l10n.disableReminders,
                ),
                secondary: Icon(
                  _isEnabled
                      ? Icons.notifications_active
                      : Icons.notifications_off,
                  color: _isEnabled
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Reminder timing section header
            Text(
              l10n.reminderTiming,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.selectWhenToReceiveReminders(widget.eventType),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
            ),
            const SizedBox(height: 16),

            // Reminder offset switches
            Card(
              child: Column(
                children: [
                  // 1 day before
                  SwitchListTile(
                    value: _oneDayBefore,
                    onChanged: _isEnabled
                        ? (value) => setState(() => _oneDayBefore = value)
                        : null,
                    title: Text(l10n.oneDayBefore),
                    secondary: const Icon(Icons.calendar_today),
                  ),
                  const Divider(height: 1),

                  // 3 days before
                  SwitchListTile(
                    value: _threeDaysBefore,
                    onChanged: _isEnabled
                        ? (value) => setState(() => _threeDaysBefore = value)
                        : null,
                    title: Text(l10n.threeDaysBefore),
                    secondary: const Icon(Icons.date_range),
                  ),
                  const Divider(height: 1),

                  // 1 week before
                  SwitchListTile(
                    value: _oneWeekBefore,
                    onChanged: _isEnabled
                        ? (value) => setState(() => _oneWeekBefore = value)
                        : null,
                    title: Text(l10n.oneWeekBefore),
                    secondary: const Icon(Icons.event),
                  ),
                  const Divider(height: 1),

                  // 2 weeks before
                  SwitchListTile(
                    value: _twoWeeksBefore,
                    onChanged: _isEnabled
                        ? (value) => setState(() => _twoWeeksBefore = value)
                        : null,
                    title: Text(l10n.twoWeeksBefore),
                    secondary: const Icon(Icons.event_available),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isSaving
                    ? null
                    : () =>
                        _saveReminderSettings(context, l10n, existingConfig),
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(l10n.saveReminderSettings),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Save reminder settings
  Future<void> _saveReminderSettings(
    BuildContext context,
    AppLocalizations l10n,
    ReminderConfig? existingConfig,
  ) async {
    // Validate: At least one reminder must be selected if enabled
    if (_isEnabled &&
        !_oneDayBefore &&
        !_threeDaysBefore &&
        !_oneWeekBefore &&
        !_twoWeeksBefore) {
      SnackBarHelper.showError(context, l10n.selectAtLeastOneReminder);
      return;
    }

    setState(() => _isSaving = true);

    try {
      _logger.d(
        'Saving reminder settings for pet ${widget.pet.id}, '
        'eventType: ${widget.eventType}',
      );

      // Build reminder days list from form state
      final List<int> reminderDays = [];
      if (_oneDayBefore) reminderDays.add(1);
      if (_threeDaysBefore) reminderDays.add(3);
      if (_oneWeekBefore) reminderDays.add(7);
      if (_twoWeeksBefore) reminderDays.add(14);

      // If disabled, keep empty list
      final effectiveReminderDays =
          _isEnabled ? reminderDays : [1]; // Minimum required by model

      // Create or update config
      final config = existingConfig?.copyWith(
            isEnabled: _isEnabled,
            reminderDays: effectiveReminderDays,
            updatedAt: DateTime.now(),
          ) ??
          ReminderConfig(
            id: '', // Will be generated by repository
            petId: widget.pet.id,
            eventType: widget.eventType,
            reminderDays: effectiveReminderDays,
            isEnabled: _isEnabled,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

      await ref.read(reminderConfigsProvider.notifier).saveConfig(config);

      if (context.mounted) {
        SnackBarHelper.showSuccess(context, l10n.reminderSettingsSaved);
        Navigator.of(context).pop(true); // Return to previous screen
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to save reminder settings',
        error: e,
        stackTrace: stackTrace,
      );

      if (context.mounted) {
        SnackBarHelper.showError(context, l10n.reminderSettingsSaveFailed);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

// ============================================================================
// INLINE WIDGETS
// ============================================================================

/// Pet info header - displays pet context
class _PetInfoHeader extends StatelessWidget {
  final PetProfile pet;

  const _PetInfoHeader({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Pet avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            backgroundImage: pet.photoPath != null && pet.photoPath!.isNotEmpty
                ? AssetImage(pet.photoPath!)
                : null,
            child: pet.photoPath == null || pet.photoPath!.isEmpty
                ? Icon(
                    Icons.pets,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  )
                : null,
          ),
          const SizedBox(width: 12),

          // Pet info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Chip(
                  label: Text(pet.species),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                  labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
