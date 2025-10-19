import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../domain/models/medication_entry.dart';
import '../../providers/inventory_providers.dart';
import '../../providers/medications_provider.dart';
import '../providers/pet_profile_provider.dart';
import '../widgets/add_refill_dialog.dart';

class MedicationInventoryScreen extends ConsumerStatefulWidget {
  const MedicationInventoryScreen({super.key});

  @override
  ConsumerState<MedicationInventoryScreen> createState() =>
      _MedicationInventoryScreenState();
}

class _MedicationInventoryScreenState
    extends ConsumerState<MedicationInventoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final currentPet = ref.watch(currentPetProfileProvider);

    if (currentPet == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.medicationInventory),
        ),
        body: Center(
          child: Text(l10n.noActivePetFound),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.medicationInventory),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.colorScheme.onPrimary,
          labelColor: theme.colorScheme.onPrimary,
          unselectedLabelColor:
              theme.colorScheme.onPrimary.withValues(alpha: 0.7),
          tabs: [
            Tab(text: l10n.all),
            Tab(text: l10n.lowStock),
            Tab(text: l10n.statistics),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AllMedicationsTab(petId: currentPet.id),
          _LowStockTab(petId: currentPet.id),
          _StatisticsTab(petId: currentPet.id),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPurchaseDialog(context),
        icon: const Icon(Icons.add_shopping_cart),
        label: Text(l10n.recordPurchase),
        backgroundColor: theme.colorScheme.primary,
      ),
    );
  }

  void _showAddPurchaseDialog(BuildContext context) {
    final currentPet = ref.read(currentPetProfileProvider);
    if (currentPet == null) return;

    final medicationsAsync = ref.read(medicationsProvider);
    final medications = medicationsAsync.when(
      data: (meds) =>
          meds.where((m) => m.petId == currentPet.id && m.isActive).toList(),
      loading: () => <MedicationEntry>[],
      error: (_, __) => <MedicationEntry>[],
    );

    if (medications.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).noMedicationsFound),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AddRefillDialog(medication: medications.first),
    );
  }
}

class _AllMedicationsTab extends ConsumerWidget {
  final String petId;

  const _AllMedicationsTab({required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final medicationsAsync = ref.watch(medicationsProvider);

    return medicationsAsync.when(
      data: (allMedications) {
        final medications = allMedications
            .where((m) => m.petId == petId && m.isActive)
            .toList();

        if (medications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.medication_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.noMedicationsTracked,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(medicationsProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: medications.length,
            itemBuilder: (context, index) {
              final medication = medications[index];
              return _MedicationInventoryCard(
                medication: medication,
                showWarning: false,
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Error: $error'),
      ),
    );
  }
}

class _LowStockTab extends ConsumerWidget {
  final String petId;

  const _LowStockTab({required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lowStockMeds = ref.watch(lowStockMedicationsProvider(petId));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(medicationsProvider);
        ref.invalidate(lowStockMedicationsProvider(petId));
      },
      child: lowStockMeds.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.green[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noLowStockMedications,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: lowStockMeds.length,
              itemBuilder: (context, index) {
                final medication = lowStockMeds[index];
                return _MedicationInventoryCard(
                  medication: medication,
                  showWarning: true,
                );
              },
            ),
    );
  }
}

class _StatisticsTab extends ConsumerWidget {
  final String petId;

  const _StatisticsTab({required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    final monthCost = ref.watch(totalMedicationCostProvider(
      PetCostQuery(petId,
          dateRange: DateRange(startDate: thirtyDaysAgo, endDate: now)),
    ));

    final totalCost = ref.watch(totalMedicationCostProvider(
      PetCostQuery(petId, dateRange: null),
    ));

    final medicationsAsync = ref.watch(medicationsProvider);

    return medicationsAsync.when(
      data: (allMedications) {
        final medications = allMedications
            .where((m) => m.petId == petId && m.isActive)
            .toList();

        final averageCost =
            medications.isNotEmpty ? totalCost / medications.length : 0.0;

        // Calculate top 5 most expensive medications
        final medicationCosts = <String, double>{};
        for (final med in medications) {
          final purchases = ref.watch(purchaseHistoryProvider(med.id));
          final cost = purchases.fold<double>(
            0.0,
            (sum, purchase) => sum + purchase.cost,
          );
          if (cost > 0) {
            medicationCosts[med.medicationName] = cost;
          }
        }

        final topMedications = medicationCosts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final top5 = topMedications.take(5).toList();

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(medicationsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Total Spent This Month Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.totalSpentThisMonth,
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '\$${monthCost.toStringAsFixed(2)}',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.last30Days,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Total Spent All Time Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            color: theme.colorScheme.secondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.totalSpentAllTime,
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '\$${totalCost.toStringAsFixed(2)}',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.allPurchases,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Average Cost Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.analytics,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.averageCostPerMedication,
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '\$${averageCost.toStringAsFixed(2)}',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.perMedication,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Top 5 Most Expensive Medications
              if (top5.isNotEmpty) ...[
                Text(
                  l10n.topExpensiveMedications,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...top5.asMap().entries.map((entry) {
                  final index = entry.key;
                  final medication = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        medication.key,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      trailing: Text(
                        '\$${medication.value.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Error: $error'),
      ),
    );
  }
}

class _MedicationInventoryCard extends ConsumerWidget {
  final MedicationEntry medication;
  final bool showWarning;

  const _MedicationInventoryCard({
    required this.medication,
    required this.showWarning,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final stockStatus = ref.watch(stockStatusProvider(medication.id));
    final daysUntilEmpty = ref.watch(daysUntilEmptyProvider(medication.id));
    final purchases = ref.watch(purchaseHistoryProvider(medication.id));

    final lastPurchase = purchases.isNotEmpty
        ? purchases
            .reduce((a, b) => a.purchaseDate.isAfter(b.purchaseDate) ? a : b)
        : null;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (stockStatus) {
      case StockStatus.sufficient:
        statusColor = Colors.green;
        statusText = l10n.sufficient;
        statusIcon = Icons.check_circle;
        break;
      case StockStatus.low:
        statusColor = Colors.orange;
        statusText = l10n.lowStock;
        statusIcon = Icons.warning;
        break;
      case StockStatus.critical:
        statusColor = Colors.red;
        statusText = l10n.critical;
        statusIcon = Icons.error;
        break;
      case StockStatus.notTracked:
        statusColor = Colors.grey;
        statusText = l10n.notTrackedEnum;
        statusIcon = Icons.help_outline;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.push('/purchase-history/${medication.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (showWarning)
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                      size: 24,
                    ),
                  if (showWarning) const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medication.medicationName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          medication.dosage,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: statusColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          size: 16,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (medication.stockQuantity != null) ...[
                          Text(
                            '${medication.stockQuantity} ${medication.stockUnit ?? 'units'} left',
                            style: theme.textTheme.bodyMedium,
                          ),
                          if (daysUntilEmpty != null)
                            Text(
                              '$daysUntilEmpty ${l10n.daysUntilEmpty}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                        ] else
                          Text(
                            l10n.stockNotTracked,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        if (lastPurchase != null)
                          Text(
                            '${l10n.lastPurchase}: ${DateFormat('MMM dd, yyyy').format(lastPurchase.purchaseDate)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showRefillDialog(context, ref),
                    icon: const Icon(Icons.add_shopping_cart),
                    tooltip: l10n.refill,
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      foregroundColor: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showRefillDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AddRefillDialog(medication: medication),
    );

    if (result == true) {
      // Refresh all inventory providers after successful purchase
      ref.invalidate(medicationsProvider);
      ref.invalidate(lowStockMedicationsProvider(medication.petId));
      ref.invalidate(purchaseHistoryProvider(medication.id));
    }
  }
}
