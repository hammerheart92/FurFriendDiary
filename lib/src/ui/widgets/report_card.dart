import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/report_entry.dart';

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
                                report.reportType,
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
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
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
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
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
                      icon: Icons.calendar_today,
                      label: 'Generated',
                      value: DateFormat('MMM dd').format(report.generatedDate),
                      color: Colors.blue,
                    ),
                  ),

                  // Date range duration
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.date_range,
                      label: 'Period',
                      value: _getPeriodDuration(),
                      color: Colors.green,
                    ),
                  ),

                  // Data summary
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.data_usage,
                      label: 'Data',
                      value: _getDataSummary(),
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
                            'Summary',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getSummaryText(),
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
    final startFormatted = DateFormat('MMM dd').format(report.startDate);
    final endFormatted = DateFormat('MMM dd, yyyy').format(report.endDate);
    return '$startFormatted - $endFormatted';
  }

  String _getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(report.generatedDate);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
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

  String _getDataSummary() {
    final summary = report.data['summary'] as Map<String, dynamic>?;
    if (summary == null) return '-';

    switch (report.reportType) {
      case 'Health Summary':
        final medications = summary['totalMedications'] ?? 0;
        final appointments = summary['totalAppointments'] ?? 0;
        return '${medications + appointments} items';
      case 'Medication History':
        final medications = summary['totalMedications'] ?? 0;
        return '$medications meds';
      case 'Activity Report':
        final feedings = summary['totalFeedings'] ?? 0;
        return '$feedings feeds';
      case 'Veterinary Records':
        final appointments = summary['totalAppointments'] ?? 0;
        return '$appointments visits';
      default:
        return '-';
    }
  }

  bool _hasSummaryData() {
    final summary = report.data['summary'] as Map<String, dynamic>?;
    return summary != null && summary.isNotEmpty;
  }

  String _getSummaryText() {
    final summary = report.data['summary'] as Map<String, dynamic>?;
    if (summary == null) return 'No summary available';

    switch (report.reportType) {
      case 'Health Summary':
        final totalMeds = summary['totalMedications'] ?? 0;
        final activeMeds = summary['activeMedications'] ?? 0;
        final totalApts = summary['totalAppointments'] ?? 0;
        final completedApts = summary['completedAppointments'] ?? 0;
        return 'Medications: $activeMeds active out of $totalMeds total. Appointments: $completedApts completed out of $totalApts total.';

      case 'Medication History':
        final totalMeds = summary['totalMedications'] ?? 0;
        final activeMeds = summary['activeMedications'] ?? 0;
        final inactiveMeds = summary['inactiveMedications'] ?? 0;
        return 'Total medications: $totalMeds ($activeMeds active, $inactiveMeds inactive)';

      case 'Activity Report':
        final totalFeedings = summary['totalFeedings'] ?? 0;
        final avgPerDay = summary['averageFeedingsPerDay'] ?? 0.0;
        return 'Total feedings: $totalFeedings (avg ${avgPerDay.toStringAsFixed(1)} per day)';

      case 'Veterinary Records':
        final totalApts = summary['totalAppointments'] ?? 0;
        final completedApts = summary['completedAppointments'] ?? 0;
        final pendingApts = summary['pendingAppointments'] ?? 0;
        return 'Total appointments: $totalApts ($completedApts completed, $pendingApts pending)';

      default:
        return 'Report data available';
    }
  }
}