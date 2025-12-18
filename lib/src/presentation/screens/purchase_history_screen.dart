import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fur_friend_diary/theme/tokens/colors.dart';
import 'package:fur_friend_diary/theme/tokens/spacing.dart';
import 'package:fur_friend_diary/theme/tokens/shadows.dart';
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
    final isDark = theme.brightness == Brightness.dark;

    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final backgroundColor =
        isDark ? DesignColors.dBackground : DesignColors.lBackground;

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
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          medication?.medicationName ?? l10n.purchaseHistory,
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
          // Summary Card
          if (purchases.isNotEmpty)
            _buildSummaryCard(
              context,
              l10n,
              totalSpent,
              totalQuantity,
              averageCostPerUnit,
              l10n.translateStockUnit(medication?.stockUnit),
              isDark,
              primaryText,
              secondaryText,
            ),

          // Purchase List
          Expanded(
            child: purchases.isEmpty
                ? _buildEmptyState(context, l10n, isDark, primaryText, secondaryText)
                : _buildPurchaseList(context, l10n, purchases, ref,
                    l10n.translateStockUnit(medication?.stockUnit), isDark, primaryText, secondaryText),
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
    bool isDark,
    Color primaryText,
    Color secondaryText,
  ) {
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final successColor = isDark ? DesignColors.dSuccess : DesignColors.lSuccess;

    return Container(
      margin: const EdgeInsets.all(DesignSpacing.lg),
      padding: const EdgeInsets.all(DesignSpacing.lg),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.purchaseHistory,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: primaryText,
            ),
          ),
          const SizedBox(height: DesignSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  l10n.totalSpent,
                  '\$${totalSpent.toStringAsFixed(2)}',
                  Icons.account_balance_wallet,
                  DesignColors.highlightTeal,
                  primaryText,
                  secondaryText,
                ),
              ),
              const SizedBox(width: DesignSpacing.md),
              Expanded(
                child: _buildStatItem(
                  l10n.quantity,
                  '$totalQuantity $stockUnit',
                  Icons.inventory_2,
                  DesignColors.highlightPink,
                  primaryText,
                  secondaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignSpacing.md),
          _buildStatItem(
            l10n.averageCostPerUnit,
            '\$${averageCostPerUnit.toStringAsFixed(2)}',
            Icons.bar_chart,
            successColor,
            primaryText,
            secondaryText,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
    Color primaryText,
    Color secondaryText,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: DesignSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: secondaryText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
    Color primaryText,
    Color secondaryText,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DesignSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: secondaryText.withOpacity(0.4),
            ),
            const SizedBox(height: DesignSpacing.md),
            Text(
              l10n.noPurchases,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DesignSpacing.sm),
            Text(
              l10n.addRefill,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: secondaryText,
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
    bool isDark,
    Color primaryText,
    Color secondaryText,
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
      padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.lg),
      itemCount: groupedPurchases.length,
      itemBuilder: (context, index) {
        final monthKey = groupedPurchases.keys.elementAt(index);
        final monthPurchases = groupedPurchases[monthKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: DesignSpacing.md),
              child: Text(
                monthKey,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
              ),
            ),

            // Purchases for this month
            ...monthPurchases.map((purchase) {
              return _buildPurchaseCard(
                context,
                l10n,
                purchase,
                ref,
                stockUnit,
                isDark,
                primaryText,
                secondaryText,
              );
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
    bool isDark,
    Color primaryText,
    Color secondaryText,
  ) {
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final successColor = isDark ? DesignColors.dSuccess : DesignColors.lSuccess;
    final dangerColor = isDark ? DesignColors.dDanger : DesignColors.lDanger;

    return Container(
      margin: const EdgeInsets.only(bottom: DesignSpacing.md),
      padding: const EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shopping bag icon container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: DesignColors.highlightTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shopping_bag,
              color: DesignColors.highlightTeal,
              size: 24,
            ),
          ),
          const SizedBox(width: DesignSpacing.md),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quantity and Cost row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${purchase.quantity} $stockUnit',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: primaryText,
                        ),
                      ),
                    ),
                    Text(
                      '\$${purchase.cost.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: successColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DesignSpacing.xs),
                // Date
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: secondaryText,
                    ),
                    const SizedBox(width: DesignSpacing.xs),
                    Text(
                      DateFormat('MMM dd, yyyy').format(purchase.purchaseDate),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: secondaryText,
                      ),
                    ),
                  ],
                ),
                // Pharmacy
                if (purchase.pharmacy != null &&
                    purchase.pharmacy!.isNotEmpty) ...[
                  const SizedBox(height: DesignSpacing.xs),
                  Row(
                    children: [
                      Icon(
                        Icons.store,
                        size: 14,
                        color: secondaryText,
                      ),
                      const SizedBox(width: DesignSpacing.xs),
                      Expanded(
                        child: Text(
                          purchase.pharmacy!,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: secondaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                // Notes
                if (purchase.notes != null && purchase.notes!.isNotEmpty) ...[
                  const SizedBox(height: DesignSpacing.xs),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.note,
                        size: 14,
                        color: secondaryText,
                      ),
                      const SizedBox(width: DesignSpacing.xs),
                      Expanded(
                        child: Text(
                          purchase.notes!,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: secondaryText,
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
          ),
          const SizedBox(width: DesignSpacing.sm),
          // Delete button
          IconButton(
            icon: Icon(Icons.delete_outline, color: dangerColor),
            onPressed: () => _deletePurchase(context, ref, purchase, isDark, primaryText, secondaryText),
            tooltip: l10n.deletePurchase,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePurchase(
    BuildContext context,
    WidgetRef ref,
    MedicationPurchase purchase,
    bool isDark,
    Color primaryText,
    Color secondaryText,
  ) async {
    final l10n = AppLocalizations.of(context);
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final dangerColor = isDark ? DesignColors.dDanger : DesignColors.lDanger;
    final successColor = isDark ? DesignColors.dSuccess : DesignColors.lSuccess;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          l10n.deletePurchase,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
        content: Text(
          l10n.deletePurchaseConfirm,
          style: GoogleFonts.inter(color: secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              l10n.cancel,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                color: secondaryText,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: dangerColor,
            ),
            child: Text(
              l10n.delete,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: dangerColor,
              ),
            ),
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
              content: Text(
                l10n.purchaseDeletedSuccessfully,
                style: GoogleFonts.inter(color: Colors.white),
              ),
              backgroundColor: successColor,
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
              content: Text(
                l10n.failedToDeletePurchase,
                style: GoogleFonts.inter(color: Colors.white),
              ),
              backgroundColor: dangerColor,
            ),
          );
        }
      }
    }
  }
}
