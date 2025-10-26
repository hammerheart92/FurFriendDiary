import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../../domain/models/medication_purchase.dart';
import '../../providers/inventory_providers.dart';
import '../../providers/medications_provider.dart';
import '../../ui/widgets/medication_card.dart'; // Import for StockUnitTranslation extension

class PurchaseHistoryScreen extends ConsumerWidget {
  final String medicationId;

  const PurchaseHistoryScreen({
    super.key,
    required this.medicationId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Get medication details
    final medicationsAsync = ref.watch(medicationsProvider);
    final medication = medicationsAsync.when(
      data: (meds) => meds.where((m) => m.id == medicationId).firstOrNull,
      loading: () => null,
      error: (_, __) => null,
    );

    // Get purchase history
    final purchases = ref.watch(purchaseHistoryProvider(medicationId));

    // Calculate statistics
    final totalSpent = purchases.fold<double>(
      0.0,
      (sum, purchase) => sum + purchase.cost,
    );

    final totalQuantity = purchases.fold<int>(
      0,
      (sum, purchase) => sum + purchase.quantity,
    );

    final averageCostPerUnit =
        totalQuantity > 0 ? totalSpent / totalQuantity : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          medication != null
              ? '${medication.medicationName} - ${l10n.purchaseHistory}'
              : l10n.purchaseHistory,
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          // Summary Card
          if (purchases.isNotEmpty)
            _buildSummaryCard(
              context,
              l10n,
              totalSpent,
              totalQuantity,
              averageCostPerUnit,
              l10n.translateStockUnit(medication?.stockUnit),
            ),

          // Purchase List
          Expanded(
            child: purchases.isEmpty
                ? _buildEmptyState(context, l10n)
                : _buildPurchaseList(context, l10n, purchases, ref,
                    l10n.translateStockUnit(medication?.stockUnit)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    AppLocalizations l10n,
    double totalSpent,
    int totalQuantity,
    double averageCostPerUnit,
    String stockUnit,
  ) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.purchaseHistory,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    l10n.totalSpent,
                    '\$${totalSpent.toStringAsFixed(2)}',
                    Icons.account_balance_wallet,
                    theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    context,
                    l10n.quantity,
                    '$totalQuantity $stockUnit',
                    Icons.inventory_2,
                    theme.colorScheme.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatItem(
              context,
              l10n.averageCostPerUnit,
              '\$${averageCostPerUnit.toStringAsFixed(2)}',
              Icons.analytics,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: Theme.of(context)
                  .colorScheme
                  .secondary
                  .withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noPurchases,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.addRefill,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseList(
    BuildContext context,
    AppLocalizations l10n,
    List<MedicationPurchase> purchases,
    WidgetRef ref,
    String stockUnit,
  ) {
    // Sort purchases by date (most recent first)
    final sortedPurchases = purchases.toList()
      ..sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));

    // Group purchases by month
    final groupedPurchases = <String, List<MedicationPurchase>>{};
    for (final purchase in sortedPurchases) {
      final monthKey = DateFormat('MMMM yyyy').format(purchase.purchaseDate);
      groupedPurchases.putIfAbsent(monthKey, () => []).add(purchase);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: groupedPurchases.length,
      itemBuilder: (context, index) {
        final monthKey = groupedPurchases.keys.elementAt(index);
        final monthPurchases = groupedPurchases[monthKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                monthKey,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
              ),
            ),

            // Purchases for this month
            ...monthPurchases.map((purchase) {
              return _buildPurchaseCard(
                  context, l10n, purchase, ref, stockUnit);
            }),
          ],
        );
      },
    );
  }

  Widget _buildPurchaseCard(
    BuildContext context,
    AppLocalizations l10n,
    MedicationPurchase purchase,
    WidgetRef ref,
    String stockUnit,
  ) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.shopping_bag,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          '${l10n.quantity}: ${purchase.quantity} $stockUnit',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(DateFormat('MMM dd, yyyy').format(purchase.purchaseDate)),
                const SizedBox(width: 12),
                Icon(
                  Icons.attach_money,
                  size: 14,
                  color: Colors.green,
                ),
                Text(
                  purchase.cost.toStringAsFixed(2),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            if (purchase.pharmacy != null && purchase.pharmacy!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.local_pharmacy,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    purchase.pharmacy!,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ],
            if (purchase.notes != null && purchase.notes!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.note,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      purchase.notes!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => _deletePurchase(context, ref, purchase),
          tooltip: l10n.deletePurchase,
        ),
      ),
    );
  }

  Future<void> _deletePurchase(
    BuildContext context,
    WidgetRef ref,
    MedicationPurchase purchase,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deletePurchase),
        content: Text(l10n.deletePurchaseConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        // Delete the purchase record
        final repository = ref.read(purchaseRepositoryProvider);
        await repository.deletePurchase(purchase.id);

        // Update the medication stock quantity by subtracting the deleted purchase quantity
        final medicationRepo = ref.read(medicationsRepositoryProvider);
        final medication = await medicationRepo.getMedicationById(medicationId);

        if (medication != null && medication.stockQuantity != null) {
          final newStock = (medication.stockQuantity! - purchase.quantity)
              .clamp(0, double.infinity)
              .toInt();
          await medicationRepo.updateStock(medicationId, newStock);
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.purchaseDeletedSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Refresh the providers
        ref.invalidate(purchaseHistoryProvider(medicationId));
        ref.invalidate(medicationsProvider);
        ref.invalidate(lowStockMedicationsProvider);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.failedToDeletePurchase),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
