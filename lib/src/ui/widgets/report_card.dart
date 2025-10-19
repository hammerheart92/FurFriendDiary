import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/report_entry.dart';
import '../../../l10n/app_localizations.dart';
import '../../utils/date_helper.dart';

class ReportCard extends StatelessWidget {
  final ReportEntry report;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ReportCard({
    super.key,
    required this.report,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Report icon and type
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getReportColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getReportIcon(),
                            color: _getReportColor(),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getLocalizedReportType(context),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _getDateRange(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Generated date badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getReportColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getTimeAgo(),
                      style: TextStyle(
                        color: _getReportColor(),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // More options menu
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'delete':
                          onDelete?.call();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete, color: Colors.red),
                            const SizedBox(width: 8),
                            Text(l10n.delete),
                          ],
                        ),
                      ),
                    ],
                    child: const Icon(Icons.more_vert, size: 20),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Report details row
              Row(
                children: [
                  // Generated date
                  Expanded(
                    child: _buildDetailItem(
                      context: context,
                      icon: Icons.calendar_today,
                      label: l10n.generated,
                      value: localizedShortDate(context, report.generatedDate),
                      color: Colors.blue,
                    ),
                  ),

                  // Date range duration
                  Expanded(
                    child: _buildDetailItem(
                      context: context,
                      icon: Icons.date_range,
                      label: l10n.period,
                      value: _getPeriodDuration(),
                      color: Colors.green,
                    ),
                  ),

                  // Data summary
                  Expanded(
                    child: _buildDetailItem(
                      context: context,
                      icon: Icons.data_usage,
                      label: l10n.data,
                      value: _getDataSummary(context),
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),

              // Report summary section
              if (_hasSummaryData()) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.summarize,
                            size: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.summary,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getSummaryText(context),
                        style: theme.textTheme.bodySmall,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _getLocalizedReportType(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (report.reportType) {
      case 'Health Summary':
        return l10n.healthSummary;
      case 'Activity Report':
        return l10n.activityReport;
      case 'Veterinary Records':
        return l10n.veterinaryRecords;
      default:
        return report.reportType;
    }
  }

  IconData _getReportIcon() {
    switch (report.reportType) {
      case 'Health Summary':
        return Icons.health_and_safety;
      case 'Medication History':
        return Icons.medication;
      case 'Activity Report':
        return Icons.directions_walk;
      case 'Veterinary Records':
        return Icons.local_hospital;
      default:
        return Icons.assessment;
    }
  }

  Color _getReportColor() {
    switch (report.reportType) {
      case 'Health Summary':
        return Colors.blue;
      case 'Medication History':
        return Colors.green;
      case 'Activity Report':
        return Colors.orange;
      case 'Veterinary Records':
        return Colors.red;
      default:
        return Colors.purple;
    }
  }

  String _getDateRange() {
    // Use non-localized format for compact display
    final startFormatted = DateFormat('MMM dd').format(report.startDate);
    final endFormatted = DateFormat('MMM dd, yyyy').format(report.endDate);
    return '$startFormatted - $endFormatted';
  }

  String _getTimeAgo() {
    // Use the shared helper for consistent time ago formatting across the app
    // However, for compact display we'll use short format (d/h/m)
    final now = DateTime.now();
    final difference = now.difference(report.generatedDate);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return '<1m';
    }
  }

  String _getPeriodDuration() {
    final duration = report.endDate.difference(report.startDate);
    if (duration.inDays > 0) {
      return '${duration.inDays + 1}d';
    } else {
      return '1d';
    }
  }

  String _getDataSummary(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final summaryData = report.data['summary'];
    if (summaryData == null) return '-';
    final summary = summaryData is Map<String, dynamic>
        ? summaryData
        : Map<String, dynamic>.from(summaryData as Map);

    switch (report.reportType) {
      case 'Health Summary':
        final medications = summary['totalMedications'] ?? 0;
        final appointments = summary['totalAppointments'] ?? 0;
        return '${medications + appointments} ${l10n.items}';
      case 'Medication History':
        final medications = summary['totalMedications'] ?? 0;
        return '$medications meds';
      case 'Activity Report':
        final feedings = summary['totalFeedings'] ?? 0;
        return '$feedings ${l10n.feeds}';
      case 'Veterinary Records':
        final appointments = summary['totalAppointments'] ?? 0;
        return '$appointments ${l10n.visits}';
      default:
        return '-';
    }
  }

  bool _hasSummaryData() {
    final summaryData = report.data['summary'];
    if (summaryData == null) return false;
    final summary = summaryData is Map<String, dynamic>
        ? summaryData
        : Map<String, dynamic>.from(summaryData as Map);
    return summary.isNotEmpty;
  }

  String _getSummaryText(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final summaryData = report.data['summary'];
    if (summaryData == null) return 'No summary available';
    final summary = summaryData is Map<String, dynamic>
        ? summaryData
        : Map<String, dynamic>.from(summaryData as Map);

    switch (report.reportType) {
      case 'Health Summary':
        final totalMeds = summary['totalMedications'] ?? 0;
        final activeMeds = summary['activeMedications'] ?? 0;
        final totalApts = summary['totalAppointments'] ?? 0;
        final completedApts = summary['completedAppointments'] ?? 0;
        return '${l10n.medications}: $activeMeds ${l10n.active} ${l10n.outOf} $totalMeds ${l10n.total}. ${l10n.appointments}: $completedApts ${l10n.completed} ${l10n.outOf} $totalApts ${l10n.total}.';

      case 'Medication History':
        final totalMeds = summary['totalMedications'] ?? 0;
        final activeMeds = summary['activeMedications'] ?? 0;
        final inactiveMeds = summary['inactiveMedications'] ?? 0;
        return '${l10n.total} ${l10n.medications.toLowerCase()}: $totalMeds ($activeMeds ${l10n.active}, $inactiveMeds ${l10n.inactive})';

      case 'Activity Report':
        final totalFeedings = summary['totalFeedings'] ?? 0;
        final avgPerDay = summary['averageFeedingsPerDay'] ?? 0.0;
        return '${l10n.total} ${l10n.feeds}: $totalFeedings (${l10n.avg} ${avgPerDay.toStringAsFixed(1)} ${l10n.perDay})';

      case 'Veterinary Records':
        final totalApts = summary['totalAppointments'] ?? 0;
        final completedApts = summary['completedAppointments'] ?? 0;
        final pendingApts = summary['pendingAppointments'] ?? 0;
        return '${l10n.total} ${l10n.appointments.toLowerCase()}: $totalApts ($completedApts ${l10n.completed}, $pendingApts ${l10n.upcoming.toLowerCase()})';

      default:
        return 'Report data available';
    }
  }
}
