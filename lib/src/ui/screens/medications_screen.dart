import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/medication_entry.dart';
import '../../domain/models/reminder.dart';
import '../../domain/models/time_of_day_model.dart';
import '../../providers/medications_provider.dart';
import '../../presentation/providers/pet_profile_provider.dart';
import '../../presentation/providers/reminder_provider.dart';
import '../widgets/medication_card.dart';
import '../../presentation/widgets/add_refill_dialog.dart';
import '../../../l10n/app_localizations.dart';

class MedicationsScreen extends ConsumerStatefulWidget {
  const MedicationsScreen({super.key});

  @override
  ConsumerState<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends ConsumerState<MedicationsScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final activePet = ref.watch(currentPetProfileProvider);

    if (activePet == null) {
      return _buildNoPetView(theme);
    }
    return _buildMedicationsView(theme, activePet.id);
  }

  Widget _buildNoPetView(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.medications),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noPetSelected,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.pleaseSetupPetFirst,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationsView(ThemeData theme, String petId) {
    final medicationsAsync = ref.watch(medicationsProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.medications),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory_2),
            onPressed: () => context.push('/medication-inventory'),
            tooltip: l10n.medicationInventory,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.colorScheme.onPrimary,
          labelColor: theme.colorScheme.onPrimary,
          unselectedLabelColor: theme.colorScheme.onPrimary.withOpacity(0.7),
          tabs: [
            Tab(text: l10n.active),
            Tab(text: l10n.all),
            Tab(text: l10n.inactive),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: l10n.searchMedications,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.background,
              ),
            ),
          ),

          // Tabs content
          Expanded(
            child: medicationsAsync.when(
              data: (medications) {
                final petMedications =
                    medications.where((med) => med.petId == petId).toList();

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMedicationsList(
                      petMedications.where((med) => med.isActive).toList(),
                      l10n.noActiveMedications,
                      theme,
                    ),
                    _buildMedicationsList(
                      petMedications,
                      l10n.noMedicationsFound,
                      theme,
                    ),
                    _buildMedicationsList(
                      petMedications.where((med) => !med.isActive).toList(),
                      l10n.noInactiveMedications,
                      theme,
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('${l10n.errorLoadingMedications}: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(medicationsProvider),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/meds/add'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: Text(l10n.addMedication),
      ),
    );
  }

  Widget _buildMedicationsList(
    List<MedicationEntry> medications,
    String emptyMessage,
    ThemeData theme,
  ) {
    final l10n = AppLocalizations.of(context);
    // Filter medications based on search query
    final filteredMedications = medications.where((medication) {
      if (_searchQuery.isEmpty) return true;
      return medication.medicationName.toLowerCase().contains(_searchQuery) ||
          medication.dosage.toLowerCase().contains(_searchQuery) ||
          medication.frequency.toLowerCase().contains(_searchQuery) ||
          medication.administrationMethod.toLowerCase().contains(_searchQuery);
    }).toList();

    // Sort by start date (newest first)
    filteredMedications.sort((a, b) => b.startDate.compareTo(a.startDate));

    if (filteredMedications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medication,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? l10n.noMedicationsMatchSearch
                  : emptyMessage,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                l10n.tryAdjustingSearchTerms,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(medicationsProvider.notifier).refresh();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredMedications.length,
        itemBuilder: (context, index) {
          final medication = filteredMedications[index];
          return MedicationCard(
            medication: medication,
            onTap: () => context.push('/meds/detail/${medication.id}'),
            onToggleStatus: () => _toggleMedicationStatus(medication),
            onDelete: () => _deleteMedication(medication),
            onSetReminder: () => _showReminderDialog(medication),
            onMarkAsGiven: medication.stockQuantity != null
                ? () => _markAsGiven(medication)
                : null,
            onAddRefill: medication.stockQuantity != null
                ? () => _showAddRefillDialog(medication)
                : null,
          );
        },
      ),
    );
  }

  Future<void> _toggleMedicationStatus(MedicationEntry medication) async {
    final l10n = AppLocalizations.of(context);
    try {
      await ref
          .read(medicationsProvider.notifier)
          .toggleMedicationStatus(medication.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(medication.isActive
                ? l10n.medicationMarkedInactive
                : l10n.medicationMarkedActive),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.failedToUpdateMedication}: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteMedication(MedicationEntry medication) async {
    final l10n = AppLocalizations.of(context);
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteMedication),
        content: Text(
          l10n.deleteMedicationConfirm(medication.medicationName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await ref
            .read(medicationsProvider.notifier)
            .deleteMedication(medication.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.medicationDeletedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.failedToDeleteMedication}: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _markAsGiven(MedicationEntry medication) async {
    final l10n = AppLocalizations.of(context);

    try {
      // Determine dosage units to decrement (default to 1)
      final dosageUnits =
          1; // Could be made configurable based on medication.dosage

      await ref.read(medicationsRepositoryProvider).recordDosageGiven(
            medication.id,
            dosageUnits,
          );

      await ref.read(medicationsProvider.notifier).refresh();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.stockUpdated),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showAddRefillDialog(MedicationEntry medication) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddRefillDialog(medication: medication),
    );

    if (result == true && mounted) {
      // Dialog already shows success message, just refresh the list
      await ref.read(medicationsProvider.notifier).refresh();
    }
  }

  /// Shows a bottom sheet to create medication reminders.
  ///
  /// Known Issue (Non-Critical - Deferred to v1.2.0):
  /// - "Remind Daily" and "Remind Once" options do not auto-dismiss the bottom sheet
  /// - Workaround: Users can tap "View" button or swipe down to manually dismiss
  /// - "Remind All Doses" works correctly (auto-dismisses as expected)
  ///
  /// Fix Attempts (Week 4 Manual Testing):
  /// 1. Attempt 1: Context renaming (builder context → bottomSheetContext)
  ///    Result: No change
  ///
  /// 2. Attempt 2: Explicit Navigator.of() with rootNavigator flag
  ///    Result: No change
  ///
  /// 3. Attempt 3: Added 100ms delay before Navigator.pop() to resolve gesture conflicts
  ///    Result: No change
  ///
  /// 4. Attempt 4: Captured Navigator reference before delay to prevent context disposal
  ///    Code: `final navigator = Navigator.of(bottomSheetContext);`
  ///          `await Future.delayed(const Duration(milliseconds: 100));`
  ///          `navigator.pop();`
  ///    Result: Partial improvement - "Remind All Doses" works, others still require manual dismiss
  ///
  /// Root Cause Analysis:
  /// - DraggableScrollableSheet + ListTile tap gesture conflict
  /// - Manual swipe-down dismissal works correctly (proves modal config is correct)
  /// - Context lifecycle + async operations create race condition
  /// - Different code paths have different timing characteristics
  ///
  /// Current Status:
  /// - All reminder functionality works correctly (save, fire, frequency labels)
  /// - Only auto-dismiss UX is affected
  /// - Acceptable workaround available (tap "View" or swipe down)
  /// - Deferred to v1.2.0 for proper investigation (may require different bottom sheet approach)
  ///
  /// See also: MANUAL_TESTING_CHECKLIST.md - Scenario 5 notes
  void _showReminderDialog(MedicationEntry medication) {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (bottomSheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                l10n.setReminder,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.schedule),
                      title: Text(l10n.remindDaily),
                      subtitle: medication.administrationTimes.isNotEmpty
                          ? Text(
                              '${l10n.firstDose}: ${medication.administrationTimes.first.format24Hour()}')
                          : null,
                      onTap: () async {
                        // KNOWN ISSUE: Bottom sheet requires manual dismiss (swipe or tap "View")
                        // Fix attempted: Navigator reference capture before delay
                        final navigator = Navigator.of(bottomSheetContext);
                        await Future.delayed(const Duration(milliseconds: 100));
                        navigator.pop();
                        await _createReminder(
                          medication,
                          ReminderFrequency.daily,
                          medication.administrationTimes.isNotEmpty
                              ? TimeOfDay(
                                  hour:
                                      medication.administrationTimes.first.hour,
                                  minute: medication
                                      .administrationTimes.first.minute,
                                )
                              : null,
                        );
                      },
                    ),
                    if (medication.administrationTimes.length > 1)
                      ListTile(
                        leading: const Icon(Icons.repeat),
                        title: Text(l10n.remindAllDoses),
                        subtitle: Text(
                            '${medication.administrationTimes.length} ${l10n.timesDaily}'),
                        onTap: () async {
                          // This option works correctly - auto-dismisses as expected
                          final navigator = Navigator.of(bottomSheetContext);
                          await Future.delayed(
                              const Duration(milliseconds: 100));
                          navigator.pop();
                          await _createMultipleReminders(medication);
                        },
                      ),
                    ListTile(
                      leading: const Icon(Icons.today),
                      title: Text(l10n.remindOnce),
                      subtitle: Text(l10n.customTime),
                      onTap: () async {
                        // KNOWN ISSUE: Bottom sheet requires manual dismiss (swipe or tap "View")
                        // Fix attempted: Navigator reference capture before delay
                        final navigator = Navigator.of(bottomSheetContext);
                        await Future.delayed(const Duration(milliseconds: 100));
                        navigator.pop();
                        await _selectCustomReminderTime(medication);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createReminder(
    MedicationEntry medication,
    ReminderFrequency frequency,
    TimeOfDay? time,
  ) async {
    // ✅ Capture messages BEFORE async operations
    final l10n = AppLocalizations.of(context);
    final successMsg = l10n.reminderSet;
    final failedMsg = l10n.failedToCreateReminder;
    final viewLabel = l10n.view;
    final frequencyLabel = _getReminderFrequencyLabel(frequency, l10n);

    try {
      final now = DateTime.now();
      final scheduledTime = time != null
          ? DateTime(now.year, now.month, now.day, time.hour, time.minute)
          : now.add(const Duration(hours: 1));

      final reminder = Reminder(
        petId: medication.petId,
        type: ReminderType.medication,
        title: medication.medicationName,
        description: '${medication.dosage} - $frequencyLabel',
        scheduledTime: scheduledTime,
        frequency: frequency,
        linkedEntityId: medication.id,
      );

      await ref.read(reminderRepositoryProvider).addReminder(reminder);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMsg),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: viewLabel,
              textColor: Colors.white,
              onPressed: () => context.push('/settings'),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$failedMsg: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createMultipleReminders(MedicationEntry medication) async {
    // ✅ Capture messages BEFORE async operations
    final l10n = AppLocalizations.of(context);
    final failedMsg = l10n.failedToCreateReminder;
    final count = medication.administrationTimes.length;

    try {
      final now = DateTime.now();

      for (final time in medication.administrationTimes) {
        final scheduledTime =
            DateTime(now.year, now.month, now.day, time.hour, time.minute);

        final reminder = Reminder(
          petId: medication.petId,
          type: ReminderType.medication,
          title: medication.medicationName,
          description: '${medication.dosage} - ${time.format24Hour()}',
          scheduledTime: scheduledTime,
          frequency: ReminderFrequency.daily,
          linkedEntityId: medication.id,
        );

        await ref.read(reminderRepositoryProvider).addReminder(reminder);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.remindersCreated(count)),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$failedMsg: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectCustomReminderTime(MedicationEntry medication) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      await _createReminder(medication, ReminderFrequency.once, selectedTime);
    }
  }

  String _getReminderFrequencyLabel(
      ReminderFrequency frequency, AppLocalizations l10n) {
    switch (frequency) {
      case ReminderFrequency.once:
        return l10n.once;
      case ReminderFrequency.daily:
        return l10n.daily;
      case ReminderFrequency.twiceDaily:
        return l10n.twiceDaily;
      case ReminderFrequency.weekly:
        return l10n.weekly;
      case ReminderFrequency.custom:
        return l10n.custom;
    }
  }
}
