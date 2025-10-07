import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/medication_entry.dart';
import '../../providers/medications_provider.dart';
import '../../presentation/providers/pet_profile_provider.dart';
import '../widgets/medication_card.dart';
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
                final petMedications = medications
                    .where((med) => med.petId == petId)
                    .toList();

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
              _searchQuery.isNotEmpty ? l10n.noMedicationsMatchSearch : emptyMessage,
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
          );
        },
      ),
    );
  }

  Future<void> _toggleMedicationStatus(MedicationEntry medication) async {
    final l10n = AppLocalizations.of(context);
    try {
      await ref.read(medicationsProvider.notifier).toggleMedicationStatus(medication.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              medication.isActive
                  ? l10n.medicationMarkedInactive
                  : l10n.medicationMarkedActive
            ),
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
        await ref.read(medicationsProvider.notifier).deleteMedication(medication.id);

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
}