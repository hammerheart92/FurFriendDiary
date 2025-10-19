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

  void _showReminderDialog(MedicationEntry medication) {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
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
                      title: const Text('Remind Daily'),
                      subtitle: medication.administrationTimes.isNotEmpty
                          ? Text(
                              'First dose: ${medication.administrationTimes.first.format24Hour()}')
                          : null,
                      onTap: () async {
                        Navigator.pop(context);
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
                        title: const Text('Remind All Doses'),
                        subtitle: Text(
                            '${medication.administrationTimes.length} times daily'),
                        onTap: () async {
                          Navigator.pop(context);
                          await _createMultipleReminders(medication);
                        },
                      ),
                    ListTile(
                      leading: const Icon(Icons.today),
                      title: const Text('Remind Once'),
                      subtitle: const Text('Custom time'),
                      onTap: () async {
                        Navigator.pop(context);
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

    try {
      final now = DateTime.now();
      final scheduledTime = time != null
          ? DateTime(now.year, now.month, now.day, time.hour, time.minute)
          : now.add(const Duration(hours: 1));

      final reminder = Reminder(
        petId: medication.petId,
        type: ReminderType.medication,
        title: medication.medicationName,
        description: '${medication.dosage} - ${medication.frequency}',
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
}
