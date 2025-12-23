import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
import 'package:fur_friend_diary/src/domain/models/weight_entry.dart';
import 'package:fur_friend_diary/src/presentation/providers/weight_provider.dart';
import 'package:fur_friend_diary/src/presentation/widgets/add_weight_dialog.dart';
import 'package:fur_friend_diary/theme/tokens/colors.dart';
import 'package:fur_friend_diary/theme/tokens/spacing.dart';
import 'package:fur_friend_diary/theme/tokens/shadows.dart';
import 'package:fur_friend_diary/src/utils/snackbar_helper.dart';

class WeightHistoryScreen extends ConsumerWidget {
  const WeightHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor =
        isDark ? DesignColors.dBackground : DesignColors.lBackground;

    final weightEntriesAsync = ref.watch(weightEntriesProvider);
    final latestWeight = ref.watch(latestWeightProvider);
    final weightChange = ref.watch(weightChangeProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.weightTracking,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showWeightInfo(context),
            tooltip: l10n.info,
          ),
        ],
      ),
      body: weightEntriesAsync.when(
        data: (entries) {
          if (entries.isEmpty) {
            return _buildEmptyState(context, l10n);
          }

          // Get filtered entries for chart
          final filteredEntries = ref.watch(filteredWeightEntriesProvider);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Summary Card
                _buildSummaryCard(context, l10n, latestWeight, weightChange),

                SizedBox(height: DesignSpacing.md),

                // Chart
                _buildWeightChart(context, l10n, filteredEntries, ref),

                SizedBox(height: DesignSpacing.md),

                // History List
                _buildHistoryList(context, l10n, entries, ref),

                // Bottom padding for FAB
                const SizedBox(height: 80),
              ],
            ),
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(
            color: DesignColors.highlightTeal,
          ),
        ),
        error: (error, stack) => _buildErrorState(context, l10n, error),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddWeightDialog(context),
        backgroundColor: DesignColors.highlightTeal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(
          l10n.addWeight,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.monitor_weight_outlined,
              size: 80,
              color: DesignColors.highlightTeal.withOpacity(0.5),
            ),
            SizedBox(height: DesignSpacing.md),
            Text(
              l10n.noWeightEntries,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: primaryText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: DesignSpacing.sm),
            Text(
              l10n.addWeightToTrack,
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

  Widget _buildErrorState(
      BuildContext context, AppLocalizations l10n, Object error) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: DesignColors.lDanger,
            ),
            SizedBox(height: DesignSpacing.md),
            Text(
              'Error: $error',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: primaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    AppLocalizations l10n,
    WeightEntry? latestWeight,
    double? weightChange,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Container(
      margin: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: DesignColors.highlightTeal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
        border: Border.all(
          color: DesignColors.highlightTeal.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.currentWeight,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: secondaryText,
              ),
            ),
            SizedBox(height: DesignSpacing.sm),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Large weight number with Quicksand font
                Text(
                  latestWeight != null
                      ? latestWeight.weight.toStringAsFixed(1)
                      : '--',
                  style: GoogleFonts.quicksand(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: primaryText,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: DesignSpacing.sm),
                  child: Text(
                    ' kg',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: secondaryText,
                    ),
                  ),
                ),
                SizedBox(width: DesignSpacing.md),
                if (weightChange != null) _buildChangeBadge(weightChange),
              ],
            ),
            if (latestWeight != null) ...[
              SizedBox(height: DesignSpacing.xs),
              Text(
                DateFormat.yMMMd().format(latestWeight.date),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: secondaryText,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build styled change badge (red for loss, green for gain)
  Widget _buildChangeBadge(double change) {
    final isGain = change > 0;
    final color = isGain ? DesignColors.lSuccess : DesignColors.lDanger;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.sm,
        vertical: DesignSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isGain ? Icons.arrow_upward : Icons.arrow_downward,
            size: 14,
            color: color,
          ),
          SizedBox(width: DesignSpacing.xs),
          Text(
            '${isGain ? '+' : ''}${change.toStringAsFixed(1)} kg',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightChart(
    BuildContext context,
    AppLocalizations l10n,
    List<WeightEntry> entries,
    WidgetRef ref,
  ) {
    if (entries.length < 2) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final selectedPeriod = ref.watch(weightPeriodProvider);

    // Sort entries by date (oldest first for chart)
    final sortedEntries = entries.reversed.toList();

    final spots = sortedEntries.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.weight);
    }).toList();

    final minWeight =
        sortedEntries.map((e) => e.weight).reduce((a, b) => a < b ? a : b);
    final maxWeight =
        sortedEntries.map((e) => e.weight).reduce((a, b) => a > b ? a : b);
    final weightRange = maxWeight - minWeight;
    final safeRange = weightRange > 0 ? weightRange : 1.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: DesignSpacing.md),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
      ),
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.weightTrend,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: primaryText,
                  ),
                ),
                // Period Selector Dropdown
                _buildPeriodDropdown(context, ref, selectedPeriod, l10n),
              ],
            ),
            SizedBox(height: DesignSpacing.md),
            SizedBox(
              height: 120,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  minY: minWeight - (safeRange * 0.1),
                  maxY: maxWeight + (safeRange * 0.1),
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) =>
                          DesignColors.highlightTeal,
                      tooltipRoundedRadius: 8,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final entry = sortedEntries[spot.x.toInt()];
                          return LineTooltipItem(
                            '${entry.weight.toStringAsFixed(1)} kg\n${DateFormat('M/d').format(entry.date)}',
                            GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: DesignColors.highlightTeal,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: DesignColors.highlightTeal,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: DesignColors.highlightTeal.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build period dropdown selector
  Widget _buildPeriodDropdown(
    BuildContext context,
    WidgetRef ref,
    WeightPeriod selected,
    AppLocalizations l10n,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Period labels - using localized strings
    String getPeriodLabel(WeightPeriod period) {
      switch (period) {
        case WeightPeriod.week:
          return l10n.periodWeek;
        case WeightPeriod.month:
          return l10n.periodMonth;
        case WeightPeriod.all:
          return l10n.periodAll;
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.sm,
        vertical: DesignSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: DesignColors.highlightTeal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DesignColors.highlightTeal.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<WeightPeriod>(
          value: selected,
          isDense: true,
          icon: Icon(
            Icons.calendar_today,
            size: 14,
            color: DesignColors.highlightTeal,
          ),
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: DesignColors.highlightTeal,
          ),
          dropdownColor:
              isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces,
          items: WeightPeriod.values.map((period) {
            return DropdownMenuItem(
              value: period,
              child: Text(getPeriodLabel(period)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              ref.read(weightPeriodProvider.notifier).state = value;
            }
          },
        ),
      ),
    );
  }

  Widget _buildHistoryList(
    BuildContext context,
    AppLocalizations l10n,
    List<WeightEntry> entries,
    WidgetRef ref,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: EdgeInsets.only(
            left: DesignSpacing.md,
            top: DesignSpacing.lg,
            bottom: DesignSpacing.sm,
          ),
          child: Text(
            l10n.history.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: DesignColors.highlightTeal,
              letterSpacing: 0.5,
            ),
          ),
        ),
        // History Items
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            final previousEntry =
                index < entries.length - 1 ? entries[index + 1] : null;
            final change = previousEntry != null
                ? entry.weight - previousEntry.weight
                : null;
            final entryNumber = entries.length - index;

            return Container(
              margin: EdgeInsets.symmetric(
                horizontal: DesignSpacing.md,
                vertical: DesignSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.sm,
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: DesignSpacing.md,
                  vertical: DesignSpacing.xs,
                ),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: DesignColors.highlightTeal.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: DesignColors.highlightTeal.withOpacity(0.3),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '#$entryNumber',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: DesignColors.highlightTeal,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  '${entry.weight.toStringAsFixed(1)} kg',
                  style: GoogleFonts.quicksand(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: primaryText,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: DesignSpacing.xs),
                    Text(
                      DateFormat.yMMMd().format(entry.date),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: secondaryText,
                      ),
                    ),
                    if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                      SizedBox(height: DesignSpacing.xs),
                      Text(
                        entry.notes!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: secondaryText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (change != null) _buildSmallChangeBadge(change),
                    SizedBox(width: DesignSpacing.xs),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: secondaryText,
                      ),
                      onPressed: () => _confirmDelete(context, entry, ref),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Small change badge for history items
  Widget _buildSmallChangeBadge(double change) {
    final isGain = change > 0;
    final color = isGain ? DesignColors.lSuccess : DesignColors.lDanger;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '${isGain ? '+' : ''}${change.toStringAsFixed(1)}',
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Future<void> _showAddWeightDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => const AddWeightDialog(),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WeightEntry entry,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          l10n.deleteWeight,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
        content: Text(
          l10n.deleteWeightConfirm,
          style: GoogleFonts.inter(color: primaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              l10n.cancel,
              style: GoogleFonts.inter(
                color: isDark
                    ? DesignColors.dSecondaryText
                    : DesignColors.lSecondaryText,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: DesignColors.lDanger),
            child: Text(
              l10n.delete,
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repository = ref.read(weightRepositoryProvider);
      await repository.deleteWeightEntry(entry.id);

      if (context.mounted) {
        SnackBarHelper.showSuccess(context, l10n.weightDeleted);
      }
    }
  }

  void _showWeightInfo(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          l10n.aboutWeightTracking,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
        content: Text(
          l10n.weightTrackingInfo,
          style: GoogleFonts.inter(color: primaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: DesignColors.highlightTeal,
            ),
            child: Text(
              l10n.close,
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
