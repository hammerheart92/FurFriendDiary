import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/models/report_entry.dart';
import '../../presentation/providers/care_data_provider.dart';
import 'report_card.dart';

class ReportsList extends ConsumerWidget {
  final String petId;
  final List<ReportEntry>? reports;
  final VoidCallback? onAddReport;
  final Function(ReportEntry)? onViewReport;

  const ReportsList({
    super.key,
    required this.petId,
    this.reports,
    this.onAddReport,
    this.onViewReport,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If reports are provided, use them directly (for filtered views)
    // Otherwise, fetch all reports from provider
    if (reports != null) {
      if (reports!.isEmpty) {
        return _buildEmptyState(context);
      }

      // Sort reports by generation date (newest first)
      final sortedReports = [...reports!];
      sortedReports.sort((a, b) => b.generatedDate.compareTo(a.generatedDate));

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sortedReports.length,
        itemBuilder: (context, index) {
          final report = sortedReports[index];
          return ReportCard(
            report: report,
            onTap: () => onViewReport?.call(report),
            onDelete: () => _showDeleteDialog(context, ref, report),
          );
        },
      );
    }

    // Fallback to fetching from provider if no reports provided
    final reportsAsync = ref.watch(reportsByPetIdProvider(petId));

    return reportsAsync.when(
      data: (fetchedReports) {
        if (fetchedReports.isEmpty) {
          return _buildEmptyState(context);
        }

        // Sort reports by generation date (newest first)
        final sortedReports = [...fetchedReports];
        sortedReports
            .sort((a, b) => b.generatedDate.compareTo(a.generatedDate));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sortedReports.length,
          itemBuilder: (context, index) {
            final report = sortedReports[index];
            return ReportCard(
              report: report,
              onTap: () => onViewReport?.call(report),
              onDelete: () => _showDeleteDialog(context, ref, report),
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load reports',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(reportsByPetIdProvider(petId)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assessment,
              size: 80,
              color: theme.colorScheme.outline.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Reports Yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Generate comprehensive reports about your pet\'s health, activities, and care history.\nTap the + button to create your first report.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                onPressed: onAddReport,
                icon: const Icon(Icons.add),
                label: const Text('Generate Report'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(
      BuildContext context, WidgetRef ref, ReportEntry report) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report'),
        content: Text(
          'Are you sure you want to delete the "${report.reportType}" report from ${DateFormat('MMM dd, yyyy').format(report.generatedDate)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await ref.read(reportProviderProvider.notifier).deleteReport(report.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Report deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete report: $error'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
