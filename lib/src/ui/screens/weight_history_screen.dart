import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
import 'package:fur_friend_diary/src/domain/models/weight_entry.dart';
import 'package:fur_friend_diary/src/presentation/providers/weight_provider.dart';
import 'package:fur_friend_diary/src/presentation/widgets/add_weight_dialog.dart';

class WeightHistoryScreen extends ConsumerWidget {
  const WeightHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final weightEntriesAsync = ref.watch(weightEntriesProvider);
    final latestWeight = ref.watch(latestWeightProvider);
    final weightChange = ref.watch(weightChangeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.weightTracking),
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

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Summary Card
                _buildSummaryCard(context, l10n, latestWeight, weightChange),
                
                const SizedBox(height: 16),
                
                // Chart
                _buildWeightChart(context, l10n, entries),
                
                const SizedBox(height: 16),
                
                // History List
                _buildHistoryList(context, l10n, entries, ref),
                
                // Bottom padding for FAB
                const SizedBox(height: 80),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $error', textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddWeightDialog(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.addWeight),
      ),
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
              Icons.monitor_weight_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noWeightEntries,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.addWeightToTrack,
              style: Theme.of(context).textTheme.bodyMedium,
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
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.currentWeight,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  latestWeight != null
                      ? '${latestWeight.weight.toStringAsFixed(1)} kg'
                      : '--',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (weightChange != null) ...[
                  const SizedBox(width: 16),
                  Chip(
                    label: Text(
                      '${weightChange > 0 ? '+' : ''}${weightChange.toStringAsFixed(1)} kg',
                      style: TextStyle(
                        color: weightChange > 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: (weightChange > 0 ? Colors.green : Colors.red)
                        .withOpacity(0.1),
                  ),
                ],
              ],
            ),
            if (latestWeight != null) ...[
              const SizedBox(height: 4),
              Text(
                DateFormat.yMMMd().format(latestWeight.date),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeightChart(
    BuildContext context,
    AppLocalizations l10n,
    List<WeightEntry> entries,
  ) {
    if (entries.length < 2) {
      return const SizedBox.shrink();
    }

    // Sort entries by date (oldest first for chart)
    final sortedEntries = entries.reversed.toList();
    
    final spots = sortedEntries.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.weight);
    }).toList();

    final minWeight = sortedEntries.map((e) => e.weight).reduce((a, b) => a < b ? a : b);
    final maxWeight = sortedEntries.map((e) => e.weight).reduce((a, b) => a > b ? a : b);
    final weightRange = maxWeight - minWeight;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.weightTrend,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toStringAsFixed(1)}kg',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < sortedEntries.length) {
                            final entry = sortedEntries[value.toInt()];
                            return Text(
                              DateFormat('M/d').format(entry.date),
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  minY: minWeight - (weightRange * 0.1),
                  maxY: maxWeight + (weightRange * 0.1),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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

  Widget _buildHistoryList(
    BuildContext context,
    AppLocalizations l10n,
    List<WeightEntry> entries,
    WidgetRef ref,
  ) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.history,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: entries.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final entry = entries[index];
              final previousEntry = index < entries.length - 1 ? entries[index + 1] : null;
              final change = previousEntry != null
                  ? entry.weight - previousEntry.weight
                  : null;

              return ListTile(
                leading: CircleAvatar(
                  child: Text('${entry.weight.toStringAsFixed(0)}'),
                ),
                title: Text('${entry.weight.toStringAsFixed(1)} kg'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(DateFormat.yMMMd().format(entry.date)),
                    if (entry.notes != null && entry.notes!.isNotEmpty)
                      Text(
                        entry.notes!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (change != null)
                      Chip(
                        label: Text(
                          '${change > 0 ? '+' : ''}${change.toStringAsFixed(1)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: change > 0 ? Colors.green : Colors.red,
                          ),
                        ),
                        backgroundColor: (change > 0 ? Colors.green : Colors.red)
                            .withOpacity(0.1),
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _confirmDelete(context, entry, ref),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteWeight),
        content: Text(l10n.deleteWeightConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repository = ref.read(weightRepositoryProvider);
      await repository.deleteWeightEntry(entry.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.weightDeleted)),
        );
      }
    }
  }

  void _showWeightInfo(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.aboutWeightTracking),
        content: Text(l10n.weightTrackingInfo),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }
}

