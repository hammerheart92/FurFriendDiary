import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/report_entry.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text(report.reportType),
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
                              report.reportType,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Generated on ${DateFormat('MMMM dd, yyyy \'at\' HH:mm').format(report.generatedDate)}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
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
                          'Start Date',
                          DateFormat('MMM dd, yyyy').format(report.startDate),
                          Icons.date_range,
                          Colors.blue,
                        ),
                      ),
                      Expanded(
                        child: _buildHeaderDetail(
                          'End Date',
                          DateFormat('MMM dd, yyyy').format(report.endDate),
                          Icons.event,
                          Colors.green,
                        ),
                      ),
                      Expanded(
                        child: _buildHeaderDetail(
                          'Period',
                          '${report.endDate.difference(report.startDate).inDays + 1} days',
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
                      'Summary',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryContent(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Report content based on type
          ..._buildReportContent(theme),
        ],
      ),
    );
  }

  Widget _buildHeaderDetail(String label, String value, IconData icon, Color color) {
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
    final summary = report.data['summary'] as Map<String, dynamic>?;
    return summary != null && summary.isNotEmpty;
  }

  Widget _buildSummaryContent() {
    final summary = report.data['summary'] as Map<String, dynamic>;

    switch (report.reportType) {
      case 'Health Summary':
        return _buildHealthSummary(summary);
      case 'Medication History':
        return _buildMedicationSummary(summary);
      case 'Activity Report':
        return _buildActivitySummary(summary);
      case 'Veterinary Records':
        return _buildVeterinarySummary(summary);
      default:
        return const Text('No summary available');
    }
  }

  Widget _buildHealthSummary(Map<String, dynamic> summary) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Medications',
                '${summary['activeMedications'] ?? 0}/${summary['totalMedications'] ?? 0}',
                'Active/Total',
                Icons.medication,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Appointments',
                '${summary['completedAppointments'] ?? 0}/${summary['totalAppointments'] ?? 0}',
                'Completed/Total',
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
                'Feedings',
                '${summary['totalFeedings'] ?? 0}',
                'Total',
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

  Widget _buildMedicationSummary(Map<String, dynamic> summary) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total',
                '${summary['totalMedications'] ?? 0}',
                'Medications',
                Icons.medication,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Active',
                '${summary['activeMedications'] ?? 0}',
                'Ongoing',
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
                'Inactive',
                '${summary['inactiveMedications'] ?? 0}',
                'Completed',
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

  Widget _buildActivitySummary(Map<String, dynamic> summary) {
    final avgPerDay = summary['averageFeedingsPerDay'] ?? 0.0;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total Feedings',
                '${summary['totalFeedings'] ?? 0}',
                'In period',
                Icons.restaurant,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Daily Average',
                avgPerDay.toStringAsFixed(1),
                'Per day',
                Icons.timeline,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVeterinarySummary(Map<String, dynamic> summary) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Total',
                '${summary['totalAppointments'] ?? 0}',
                'Appointments',
                Icons.local_hospital,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Completed',
                '${summary['completedAppointments'] ?? 0}',
                'Finished',
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
                'Pending',
                '${summary['pendingAppointments'] ?? 0}',
                'Upcoming',
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

  Widget _buildSummaryCard(String title, String value, String subtitle, IconData icon, Color color) {
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

  List<Widget> _buildReportContent(ThemeData theme) {
    final List<Widget> content = [];

    switch (report.reportType) {
      case 'Health Summary':
        content.addAll(_buildHealthContent(theme));
        break;
      case 'Medication History':
        content.addAll(_buildMedicationContent(theme));
        break;
      case 'Activity Report':
        content.addAll(_buildActivityContent(theme));
        break;
      case 'Veterinary Records':
        content.addAll(_buildVeterinaryContent(theme));
        break;
    }

    return content;
  }

  List<Widget> _buildHealthContent(ThemeData theme) {
    final List<Widget> content = [];

    // Medications section
    final medications = report.data['medications'] as List<dynamic>? ?? [];
    if (medications.isNotEmpty) {
      content.add(_buildSectionHeader(theme, 'Medications', Icons.medication, Colors.green));
      content.add(_buildDataTable(
        ['Name', 'Dosage', 'Status'],
        medications.map((med) => [
          med['medicationName']?.toString() ?? '',
          med['dosage']?.toString() ?? '',
          (med['isActive'] == true) ? 'Active' : 'Inactive',
        ]).toList(),
      ));
      content.add(const SizedBox(height: 16));
    }

    // Appointments section
    final appointments = report.data['appointments'] as List<dynamic>? ?? [];
    if (appointments.isNotEmpty) {
      content.add(_buildSectionHeader(theme, 'Appointments', Icons.local_hospital, Colors.blue));
      content.add(_buildDataTable(
        ['Date', 'Veterinarian', 'Reason'],
        appointments.map((apt) => [
          DateFormat('MMM dd').format(DateTime.parse(apt['appointmentDate'])),
          apt['veterinarian']?.toString() ?? '',
          apt['reason']?.toString() ?? '',
        ]).toList(),
      ));
      content.add(const SizedBox(height: 16));
    }

    return content;
  }

  List<Widget> _buildMedicationContent(ThemeData theme) {
    final medications = report.data['medications'] as List<dynamic>? ?? [];
    if (medications.isEmpty) {
      return [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Text(
                'No medications found for this period',
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
      _buildSectionHeader(theme, 'Medication Details', Icons.medication, Colors.green),
      _buildDataTable(
        ['Name', 'Dosage', 'Method', 'Start Date', 'Status'],
        medications.map((med) => [
          med['medicationName']?.toString() ?? '',
          med['dosage']?.toString() ?? '',
          med['administrationMethod']?.toString() ?? '',
          DateFormat('MMM dd').format(DateTime.parse(med['startDate'])),
          (med['isActive'] == true) ? 'Active' : 'Inactive',
        ]).toList(),
      ),
    ];
  }

  List<Widget> _buildActivityContent(ThemeData theme) {
    final feedings = report.data['feedings'] as List<dynamic>? ?? [];
    if (feedings.isEmpty) {
      return [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Text(
                'No feeding data found for this period',
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
      _buildSectionHeader(theme, 'Feeding History', Icons.restaurant, Colors.orange),
      _buildDataTable(
        ['Date', 'Type', 'Amount', 'Time'],
        feedings.map((feed) => [
          DateFormat('MMM dd').format(DateTime.parse(feed['dateTime'])),
          feed['foodType']?.toString() ?? '',
          feed['amount']?.toString() ?? '',
          DateFormat('HH:mm').format(DateTime.parse(feed['dateTime'])),
        ]).toList(),
      ),
    ];
  }

  List<Widget> _buildVeterinaryContent(ThemeData theme) {
    final appointments = report.data['appointments'] as List<dynamic>? ?? [];
    if (appointments.isEmpty) {
      return [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Text(
                'No veterinary appointments found for this period',
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
      _buildSectionHeader(theme, 'Appointment History', Icons.local_hospital, Colors.blue),
      _buildDataTable(
        ['Date', 'Veterinarian', 'Clinic', 'Reason', 'Status'],
        appointments.map((apt) => [
          DateFormat('MMM dd').format(DateTime.parse(apt['appointmentDate'])),
          apt['veterinarian']?.toString() ?? '',
          apt['clinic']?.toString() ?? '',
          apt['reason']?.toString() ?? '',
          (apt['isCompleted'] == true) ? 'Completed' : 'Pending',
        ]).toList(),
      ),
    ];
  }

  Widget _buildSectionHeader(ThemeData theme, String title, IconData icon, Color color) {
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
            columns: headers.map((header) => DataColumn(
              label: Text(
                header,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )).toList(),
            rows: rows.map((row) => DataRow(
              cells: row.map((cell) => DataCell(
                Text(
                  cell,
                  style: const TextStyle(fontSize: 12),
                ),
              )).toList(),
            )).toList(),
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
    // For now, just show a message that sharing functionality could be implemented
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality would be implemented here'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}