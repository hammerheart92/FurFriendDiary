import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import 'package:fur_friend_diary/theme/tokens/colors.dart';
import 'package:fur_friend_diary/theme/tokens/spacing.dart';
import 'package:fur_friend_diary/theme/tokens/shadows.dart';
import '../../domain/models/medication_entry.dart';
import '../../providers/inventory_providers.dart';
import '../../providers/medications_provider.dart';
import '../providers/pet_profile_provider.dart';
import '../widgets/add_refill_dialog.dart';
import '../../ui/widgets/medication_card.dart'; // Import for StockUnitTranslation extension

/// Enum for tab selection
enum _InventoryTab { all, lowStock, statistics }

class MedicationInventoryScreen extends ConsumerStatefulWidget {
  const MedicationInventoryScreen({super.key});

  @override
  ConsumerState<MedicationInventoryScreen> createState() =>
      _MedicationInventoryScreenState();
}

class _MedicationInventoryScreenState
    extends ConsumerState<MedicationInventoryScreen> {
  _InventoryTab _selectedTab = _InventoryTab.all;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final currentPet = ref.watch(currentPetProfileProvider);
    final isDark = theme.brightness == Brightness.dark;

    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final backgroundColor =
        isDark ? DesignColors.dBackground : DesignColors.lBackground;

    if (currentPet == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: Text(
            l10n.medicationInventory,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: primaryText,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: primaryText),
        ),
        body: Center(
          child: Text(
            l10n.noActivePetFound,
            style: GoogleFonts.inter(color: secondaryText),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.medicationInventory,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryText),
      ),
      body: Column(
        children: [
          // Pill-shaped tab selector
          _buildTabSelector(l10n, isDark, secondaryText),
          // Tab content
          Expanded(
            child: _buildTabContent(currentPet.id),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector(
    AppLocalizations l10n,
    bool isDark,
    Color secondaryText,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: DesignSpacing.lg,
        vertical: DesignSpacing.md,
      ),
      padding: const EdgeInsets.all(DesignSpacing.xs),
      decoration: BoxDecoration(
        color: isDark
            ? DesignColors.dSurfaces.withOpacity(0.5)
            : DesignColors.lSurfaces,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: secondaryText.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildTabButton(
            label: l10n.all,
            isSelected: _selectedTab == _InventoryTab.all,
            onTap: () => setState(() => _selectedTab = _InventoryTab.all),
            isDark: isDark,
            secondaryText: secondaryText,
          ),
          _buildTabButton(
            label: l10n.lowStock,
            isSelected: _selectedTab == _InventoryTab.lowStock,
            onTap: () => setState(() => _selectedTab = _InventoryTab.lowStock),
            isDark: isDark,
            secondaryText: secondaryText,
          ),
          _buildTabButton(
            label: l10n.statistics,
            isSelected: _selectedTab == _InventoryTab.statistics,
            onTap: () => setState(() => _selectedTab = _InventoryTab.statistics),
            isDark: isDark,
            secondaryText: secondaryText,
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    required Color secondaryText,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: DesignSpacing.sm),
          decoration: BoxDecoration(
            color: isSelected ? DesignColors.highlightPink : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : secondaryText,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(String petId) {
    switch (_selectedTab) {
      case _InventoryTab.all:
        return _AllMedicationsTab(petId: petId);
      case _InventoryTab.lowStock:
        return _LowStockTab(petId: petId);
      case _InventoryTab.statistics:
        return _StatisticsTab(petId: petId);
    }
  }
}

class _AllMedicationsTab extends ConsumerWidget {
  final String petId;

  const _AllMedicationsTab({required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final medicationsAsync = ref.watch(medicationsProvider);
    final isDark = theme.brightness == Brightness.dark;

    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return medicationsAsync.when(
      data: (allMedications) {
        final medications = allMedications
            .where((m) => m.petId == petId && m.isActive)
            .toList();

        if (medications.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(DesignSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.medication_outlined,
                    size: 64,
                    color: secondaryText.withOpacity(0.4),
                  ),
                  const SizedBox(height: DesignSpacing.md),
                  Text(
                    l10n.noMedicationsTracked,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: primaryText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          color: DesignColors.highlightPink,
          onRefresh: () async {
            ref.invalidate(medicationsProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignSpacing.lg,
              vertical: DesignSpacing.sm,
            ),
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
      loading: () => const Center(
        child: CircularProgressIndicator(color: DesignColors.highlightPink),
      ),
      error: (error, _) => Center(
        child: Text(
          'Error: $error',
          style: GoogleFonts.inter(color: DesignColors.highlightCoral),
        ),
      ),
    );
  }
}

class _LowStockTab extends ConsumerWidget {
  final String petId;

  const _LowStockTab({required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final lowStockMeds = ref.watch(lowStockMedicationsProvider(petId));
    final isDark = theme.brightness == Brightness.dark;

    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final successColor = isDark ? DesignColors.dSuccess : DesignColors.lSuccess;

    if (lowStockMeds.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(DesignSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 64,
                color: successColor.withOpacity(0.6),
              ),
              const SizedBox(height: DesignSpacing.md),
              Text(
                l10n.noLowStockMedications,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: primaryText,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: DesignColors.highlightPink,
      onRefresh: () async {
        ref.invalidate(medicationsProvider);
        ref.invalidate(lowStockMedicationsProvider(petId));
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignSpacing.lg,
          vertical: DesignSpacing.sm,
        ),
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
    final isDark = theme.brightness == Brightness.dark;

    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final successColor = isDark ? DesignColors.dSuccess : DesignColors.lSuccess;

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
          color: DesignColors.highlightPink,
          onRefresh: () async {
            ref.invalidate(medicationsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignSpacing.lg,
              vertical: DesignSpacing.sm,
            ),
            children: [
              // Total Spent This Month Card
              _buildStatCard(
                icon: Icons.calendar_month,
                iconColor: DesignColors.highlightTeal,
                title: l10n.totalSpentThisMonth,
                amount: monthCost,
                subtitle: l10n.last30Days,
                surfaceColor: surfaceColor,
                primaryText: primaryText,
                secondaryText: secondaryText,
                isDark: isDark,
              ),

              const SizedBox(height: DesignSpacing.md),

              // Total Spent All Time Card
              _buildStatCard(
                icon: Icons.account_balance_wallet,
                iconColor: DesignColors.highlightPink,
                title: l10n.totalSpentAllTime,
                amount: totalCost,
                subtitle: l10n.allPurchases,
                surfaceColor: surfaceColor,
                primaryText: primaryText,
                secondaryText: secondaryText,
                isDark: isDark,
              ),

              const SizedBox(height: DesignSpacing.md),

              // Average Cost Card
              _buildStatCard(
                icon: Icons.bar_chart,
                iconColor: successColor,
                title: l10n.averageCostPerMedication,
                amount: averageCost,
                subtitle: l10n.perMedication,
                surfaceColor: surfaceColor,
                primaryText: primaryText,
                secondaryText: secondaryText,
                isDark: isDark,
              ),

              const SizedBox(height: DesignSpacing.xl),

              // Top 5 Most Expensive Medications
              if (top5.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: DesignSpacing.md),
                  child: Text(
                    l10n.topExpensiveMedications,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: primaryText,
                    ),
                  ),
                ),
                ...top5.asMap().entries.map((entry) {
                  final index = entry.key;
                  final medication = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: DesignSpacing.sm),
                    padding: const EdgeInsets.all(DesignSpacing.md),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.sm,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: DesignColors.highlightTeal.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: DesignColors.highlightTeal,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: DesignSpacing.md),
                        Expanded(
                          child: Text(
                            medication.key,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: primaryText,
                            ),
                          ),
                        ),
                        Text(
                          '\$${medication.value.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: primaryText,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: DesignColors.highlightPink),
      ),
      error: (error, _) => Center(
        child: Text(
          'Error: $error',
          style: GoogleFonts.inter(color: DesignColors.highlightCoral),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required double amount,
    required String subtitle,
    required Color surfaceColor,
    required Color primaryText,
    required Color secondaryText,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(DesignSpacing.lg),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 28,
            ),
          ),
          const SizedBox(width: DesignSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: secondaryText,
                  ),
                ),
                const SizedBox(height: DesignSpacing.xs),
                Text(
                  '\$${amount.toStringAsFixed(2)}',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: DesignSpacing.xs),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: secondaryText,
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
    final isDark = theme.brightness == Brightness.dark;

    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final successColor = isDark ? DesignColors.dSuccess : DesignColors.lSuccess;
    final warningColor =
        isDark ? DesignColors.dWarning : DesignColors.lWarning;
    final dangerColor = isDark ? DesignColors.dDanger : DesignColors.lDanger;

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
        statusColor = successColor;
        statusText = l10n.sufficient;
        statusIcon = Icons.check_circle;
        break;
      case StockStatus.low:
        statusColor = warningColor;
        statusText = l10n.lowStock;
        statusIcon = Icons.warning;
        break;
      case StockStatus.critical:
        statusColor = dangerColor;
        statusText = l10n.critical;
        statusIcon = Icons.error;
        break;
      case StockStatus.notTracked:
        statusColor = secondaryText;
        statusText = l10n.notTrackedEnum;
        statusIcon = Icons.help_outline;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: DesignSpacing.md),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.push('/purchase-history/${medication.id}');
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(DesignSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (showWarning)
                      Icon(
                        Icons.warning_amber_rounded,
                        color: dangerColor,
                        size: 24,
                      ),
                    if (showWarning) const SizedBox(width: DesignSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medication.medicationName,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: primaryText,
                            ),
                          ),
                          Text(
                            medication.dosage,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignSpacing.sm,
                        vertical: DesignSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: statusColor, width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusIcon,
                            size: 16,
                            color: statusColor,
                          ),
                          const SizedBox(width: DesignSpacing.xs),
                          Text(
                            statusText,
                            style: GoogleFonts.inter(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DesignSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (medication.stockQuantity != null) ...[
                            Text(
                              l10n.pillsLeft(
                                medication.stockQuantity.toString(),
                                l10n.translateStockUnit(medication.stockUnit),
                              ),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: primaryText,
                              ),
                            ),
                            if (daysUntilEmpty != null)
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: DesignSpacing.xs),
                                child: Text(
                                  '$daysUntilEmpty ${l10n.daysUntilEmpty}',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: secondaryText,
                                  ),
                                ),
                              ),
                          ] else
                            Text(
                              l10n.stockNotTracked,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: secondaryText,
                              ),
                            ),
                          if (lastPurchase != null)
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: DesignSpacing.xs),
                              child: Text(
                                '${l10n.lastPurchase}: ${DateFormat('MMM dd, yyyy').format(lastPurchase.purchaseDate)}',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: secondaryText,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: DesignColors.highlightTeal.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () => _showRefillDialog(context, ref),
                        icon: const Icon(Icons.add_shopping_cart),
                        tooltip: l10n.refill,
                        iconSize: 22,
                        color: DesignColors.highlightTeal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
