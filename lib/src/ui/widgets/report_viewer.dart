import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/report_entry.dart';
import '../../../l10n/app_localizations.dart';

class ReportViewer extends StatelessWidget {
  final ReportEntry report;
  final VoidCallback? onClose;

  const ReportViewer({
    super.key,
    required this.report,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getLocalizedReportType(l10n)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: onClose ?? () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareReport(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Report header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getLocalizedReportType(l10n),
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${l10n.generatedOn} ${DateFormat('MMMM dd, yyyy').format(report.generatedDate)} ${l10n.at} ${DateFormat('HH:mm').format(report.generatedDate)}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildHeaderDetail(
                          l10n.startDate,
                          DateFormat('MMM dd, yyyy').format(report.startDate),
                          Icons.date_range,
                          Colors.blue,
                        ),
                      ),
                      Expanded(
                        child: _buildHeaderDetail(
                          l10n.endDate,
                          DateFormat('MMM dd, yyyy').format(report.endDate),
                          Icons.event,
                          Colors.green,
                        ),
                      ),
                      Expanded(
                        child: _buildHeaderDetail(
                          l10n.period,
                          '${report.endDate.difference(report.startDate).inDays + 1} ${l10n.days}',
                          Icons.schedule,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Summary section
          if (_hasSummaryData()) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.summary,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryContent(l10n),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Report content based on type
          ..._buildReportContent(theme, l10n),
        ],
      ),
    );
  }

  Widget _buildHeaderDetail(
      String label, String value, IconData icon, Color color) {
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
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  bool _hasSummaryData() {
    final summaryData = report.data['summary'];
    if (summaryData == null) return false;
    final summary = summaryData is Map<String, dynamic>
        ? summaryData
        : Map<String, dynamic>.from(summaryData as Map);
    return summary.isNotEmpty;
  }

  Widget _buildSummaryContent(AppLocalizations l10n) {
    final summaryData = report.data['summary'];
    final summary = summaryData is Map<String, dynamic>
        ? summaryData
        : Map<String, dynamic>.from(summaryData as Map);

    switch (report.reportType) {
      case 'Health Summary':
        return _buildHealthSummary(summary, l10n);
      case 'Medication History':
        return _buildMedicationSummary(summary, l10n);
      case 'Activity Report':
        return _buildActivitySummary(summary, l10n);
      case 'Veterinary Records':
        return _buildVeterinarySummary(summary, l10n);
      default:
        return const Text('No summary available');
    }
  }

  Widget _buildHealthSummary(
      Map<String, dynamic> summary, AppLocalizations l10n) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                l10n.medications,
                '${summary['activeMedications'] ?? 0}/${summary['totalMedications'] ?? 0}',
                l10n.activeTotal,
                Icons.medication,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                l10n.appointments,
                '${summary['completedAppointments'] ?? 0}/${summary['totalAppointments'] ?? 0}',
                l10n.completedTotal,
                Icons.local_hospital,
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                l10n.feedings,
                '${summary['totalFeedings'] ?? 0}',
                l10n.total,
                Icons.restaurant,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(), // Empty space for symmetry
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMedicationSummary(
      Map<String, dynamic> summary, AppLocalizations l10n) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                l10n.total,
                '${summary['totalMedications'] ?? 0}',
                l10n.medications,
                Icons.medication,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                l10n.active,
                '${summary['activeMedications'] ?? 0}',
                l10n.ongoing,
                Icons.play_circle,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                l10n.inactive,
                '${summary['inactiveMedications'] ?? 0}',
                l10n.completed,
                Icons.stop_circle,
                Colors.grey,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(), // Empty space for symmetry
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivitySummary(
      Map<String, dynamic> summary, AppLocalizations l10n) {
    final avgPerDay = summary['averageFeedingsPerDay'] ?? 0.0;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                l10n.totalFeedings,
                '${summary['totalFeedings'] ?? 0}',
                l10n.inPeriod,
                Icons.restaurant,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                l10n.dailyAverage,
                avgPerDay.toStringAsFixed(1),
                l10n.perDay,
                Icons.timeline,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVeterinarySummary(
      Map<String, dynamic> summary, AppLocalizations l10n) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                l10n.total,
                '${summary['totalAppointments'] ?? 0}',
                l10n.appointments,
                Icons.local_hospital,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                l10n.completed,
                '${summary['completedAppointments'] ?? 0}',
                l10n.finished,
                Icons.check_circle,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                l10n.pending,
                '${summary['pendingAppointments'] ?? 0}',
                l10n.upcoming,
                Icons.schedule,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(), // Empty space for symmetry
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildReportContent(ThemeData theme, AppLocalizations l10n) {
    final List<Widget> content = [];

    switch (report.reportType) {
      case 'Health Summary':
        content.addAll(_buildHealthContent(theme, l10n));
        break;
      case 'Medication History':
        content.addAll(_buildMedicationContent(theme, l10n));
        break;
      case 'Activity Report':
        content.addAll(_buildActivityContent(theme, l10n));
        break;
      case 'Veterinary Records':
        content.addAll(_buildVeterinaryContent(theme, l10n));
        break;
    }

    return content;
  }

  List<Widget> _buildHealthContent(ThemeData theme, AppLocalizations l10n) {
    final List<Widget> content = [];

    // Medications section
    final medications = report.data['medications'] as List<dynamic>? ?? [];
    if (medications.isNotEmpty) {
      content.add(_buildSectionHeader(
          theme, l10n.medications, Icons.medication, Colors.green));
      content.add(_buildDataTable(
        [l10n.name, l10n.dosage, l10n.status],
        medications
            .map((med) => [
                  med['medicationName']?.toString() ?? '',
                  med['dosage']?.toString() ?? '',
                  (med['isActive'] == true) ? l10n.active : l10n.inactive,
                ])
            .toList(),
      ));
      content.add(const SizedBox(height: 16));
    }

    // Appointments section
    final appointments = report.data['appointments'] as List<dynamic>? ?? [];
    if (appointments.isNotEmpty) {
      content.add(_buildSectionHeader(
          theme, l10n.appointments, Icons.local_hospital, Colors.blue));
      content.add(_buildDataTable(
        [l10n.date, l10n.veterinarian, l10n.reason],
        appointments
            .map((apt) => [
                  DateFormat('MMM dd')
                      .format(DateTime.parse(apt['appointmentDate'])),
                  apt['veterinarian']?.toString() ?? '',
                  apt['reason']?.toString() ?? '',
                ])
            .toList(),
      ));
      content.add(const SizedBox(height: 16));
    }

    return content;
  }

  List<Widget> _buildMedicationContent(ThemeData theme, AppLocalizations l10n) {
    final medications = report.data['medications'] as List<dynamic>? ?? [];
    if (medications.isEmpty) {
      return [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Text(
                l10n.noMedicationsFoundPeriod,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          ),
        ),
      ];
    }

    return [
      _buildSectionHeader(
          theme, l10n.medicationDetails, Icons.medication, Colors.green),
      _buildDataTable(
        [l10n.name, l10n.dosage, l10n.method, l10n.startDate, l10n.status],
        medications
            .map((med) => [
                  med['medicationName']?.toString() ?? '',
                  med['dosage']?.toString() ?? '',
                  med['administrationMethod']?.toString() ?? '',
                  DateFormat('MMM dd').format(DateTime.parse(med['startDate'])),
                  (med['isActive'] == true) ? l10n.active : l10n.inactive,
                ])
            .toList(),
      ),
    ];
  }

  List<Widget> _buildActivityContent(ThemeData theme, AppLocalizations l10n) {
    final feedings = report.data['feedings'] as List<dynamic>? ?? [];
    if (feedings.isEmpty) {
      return [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Text(
                l10n.noFeedingDataFoundPeriod,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          ),
        ),
      ];
    }

    return [
      _buildSectionHeader(
          theme, l10n.feedingHistory, Icons.restaurant, Colors.orange),
      _buildDataTable(
        [l10n.date, l10n.type, l10n.amount, l10n.timeLabel],
        feedings
            .map((feed) => [
                  DateFormat('MMM dd').format(DateTime.parse(feed['dateTime'])),
                  feed['foodType']?.toString() ?? '',
                  feed['amount']?.toString() ?? '',
                  DateFormat('HH:mm').format(DateTime.parse(feed['dateTime'])),
                ])
            .toList(),
      ),
    ];
  }

  List<Widget> _buildVeterinaryContent(ThemeData theme, AppLocalizations l10n) {
    final appointments = report.data['appointments'] as List<dynamic>? ?? [];
    if (appointments.isEmpty) {
      return [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Text(
                l10n.noVeterinaryAppointmentsFoundPeriod,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          ),
        ),
      ];
    }

    return [
      _buildSectionHeader(
          theme, l10n.appointmentHistory, Icons.local_hospital, Colors.blue),
      _buildDataTable(
        [l10n.date, l10n.veterinarian, l10n.clinic, l10n.reason, l10n.status],
        appointments
            .map((apt) => [
                  DateFormat('MMM dd')
                      .format(DateTime.parse(apt['appointmentDate'])),
                  apt['veterinarian']?.toString() ?? '',
                  apt['clinic']?.toString() ?? '',
                  apt['reason']?.toString() ?? '',
                  (apt['isCompleted'] == true) ? l10n.completed : l10n.pending,
                ])
            .toList(),
      ),
    ];
  }

  Widget _buildSectionHeader(
      ThemeData theme, String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(List<String> headers, List<List<String>> rows) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 16,
            headingRowHeight: 40,
            dataRowHeight: 40,
            columns: headers
                .map((header) => DataColumn(
                      label: Text(
                        header,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ))
                .toList(),
            rows: rows
                .map((row) => DataRow(
                      cells: row
                          .map((cell) => DataCell(
                                Text(
                                  cell,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ))
                          .toList(),
                    ))
                .toList(),
          ),
        ),
      ),
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

  void _shareReport(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // For now, just show a message that sharing functionality could be implemented
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.shareFunctionalityPlaceholder),
        backgroundColor: Colors.blue,
      ),
    );
  }

  String _getLocalizedReportType(AppLocalizations l10n) {
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
}
