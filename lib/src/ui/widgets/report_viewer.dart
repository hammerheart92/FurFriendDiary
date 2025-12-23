import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/models/report_entry.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens/colors.dart';
import '../../../theme/tokens/spacing.dart';
import '../../../theme/tokens/shadows.dart';
import '../../utils/snackbar_helper.dart';

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

    // Theme detection
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor =
        isDark ? DesignColors.dBackground : DesignColors.lBackground;
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final reportColor = _getReportColor();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: primaryText),
          onPressed: onClose ?? () => Navigator.of(context).pop(),
        ),
        title: Text(
          _getLocalizedReportType(l10n),
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: DesignColors.highlightTeal),
            onPressed: () => _shareReport(context),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(DesignSpacing.md),
        children: [
          // Period Info Card
          Container(
            padding: EdgeInsets.all(DesignSpacing.lg),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Report icon container
                    Container(
                      padding: EdgeInsets.all(DesignSpacing.md),
                      decoration: BoxDecoration(
                        color: reportColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getReportIcon(),
                        color: reportColor,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: DesignSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getLocalizedReportType(l10n),
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: primaryText,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${l10n.generatedOn} ${DateFormat('MMMM dd, yyyy').format(report.generatedDate)} ${l10n.at} ${DateFormat('HH:mm').format(report.generatedDate)}',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: DesignSpacing.lg),
                // Stats row
                Row(
                  children: [
                    Expanded(
                      child: _buildHeaderDetail(
                        l10n.startDate,
                        DateFormat('MMM dd, yyyy').format(report.startDate),
                        Icons.date_range,
                        DesignColors.highlightBlue,
                        primaryText,
                        secondaryText,
                      ),
                    ),
                    Expanded(
                      child: _buildHeaderDetail(
                        l10n.endDate,
                        DateFormat('MMM dd, yyyy').format(report.endDate),
                        Icons.event,
                        DesignColors.highlightTeal,
                        primaryText,
                        secondaryText,
                      ),
                    ),
                    Expanded(
                      child: _buildHeaderDetail(
                        l10n.period,
                        '${report.endDate.difference(report.startDate).inDays + 1} ${l10n.days}',
                        Icons.schedule,
                        DesignColors.highlightPurple,
                        primaryText,
                        secondaryText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: DesignSpacing.md),

          // Summary section
          if (_hasSummaryData()) ...[
            Container(
              padding: EdgeInsets.all(DesignSpacing.lg),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.summary,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: primaryText,
                    ),
                  ),
                  SizedBox(height: DesignSpacing.md),
                  _buildSummaryContent(l10n, primaryText, secondaryText),
                ],
              ),
            ),
            SizedBox(height: DesignSpacing.md),
          ],

          // Report content based on type
          ..._buildReportContent(theme, l10n, isDark, surfaceColor, primaryText, secondaryText),
        ],
      ),
    );
  }

  Widget _buildHeaderDetail(
    String label,
    String value,
    IconData icon,
    Color color,
    Color primaryText,
    Color secondaryText,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: secondaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: primaryText,
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

  Widget _buildSummaryContent(
      AppLocalizations l10n, Color primaryText, Color secondaryText) {
    final summaryData = report.data['summary'];
    final summary = summaryData is Map<String, dynamic>
        ? summaryData
        : Map<String, dynamic>.from(summaryData as Map);

    switch (report.reportType) {
      case 'Health Summary':
        return _buildHealthSummary(summary, l10n, primaryText, secondaryText);
      case 'Medication History':
        return _buildMedicationSummary(summary, l10n, primaryText, secondaryText);
      case 'Activity Report':
        return _buildActivitySummary(summary, l10n, primaryText, secondaryText);
      case 'Veterinary Records':
        return _buildVeterinarySummary(summary, l10n, primaryText, secondaryText);
      default:
        return Text(
          'No summary available',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: secondaryText,
          ),
        );
    }
  }

  Widget _buildHealthSummary(Map<String, dynamic> summary, AppLocalizations l10n,
      Color primaryText, Color secondaryText) {
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
                DesignColors.highlightTeal,
                primaryText,
                secondaryText,
              ),
            ),
            SizedBox(width: DesignSpacing.sm),
            Expanded(
              child: _buildSummaryCard(
                l10n.appointments,
                '${summary['completedAppointments'] ?? 0}/${summary['totalAppointments'] ?? 0}',
                l10n.completedTotal,
                Icons.local_hospital,
                DesignColors.highlightBlue,
                primaryText,
                secondaryText,
              ),
            ),
          ],
        ),
        SizedBox(height: DesignSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                l10n.feedings,
                '${summary['totalFeedings'] ?? 0}',
                l10n.total,
                Icons.restaurant,
                DesignColors.highlightYellow,
                primaryText,
                secondaryText,
              ),
            ),
            SizedBox(width: DesignSpacing.sm),
            Expanded(
              child: Container(), // Empty space for symmetry
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMedicationSummary(Map<String, dynamic> summary,
      AppLocalizations l10n, Color primaryText, Color secondaryText) {
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
                DesignColors.highlightPink,
                primaryText,
                secondaryText,
              ),
            ),
            SizedBox(width: DesignSpacing.sm),
            Expanded(
              child: _buildSummaryCard(
                l10n.active,
                '${summary['activeMedications'] ?? 0}',
                l10n.ongoing,
                Icons.play_circle,
                DesignColors.highlightTeal,
                primaryText,
                secondaryText,
              ),
            ),
          ],
        ),
        SizedBox(height: DesignSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                l10n.inactive,
                '${summary['inactiveMedications'] ?? 0}',
                l10n.completed,
                Icons.stop_circle,
                DesignColors.highlightPurple,
                primaryText,
                secondaryText,
              ),
            ),
            SizedBox(width: DesignSpacing.sm),
            Expanded(
              child: Container(), // Empty space for symmetry
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivitySummary(Map<String, dynamic> summary,
      AppLocalizations l10n, Color primaryText, Color secondaryText) {
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
                DesignColors.highlightYellow,
                primaryText,
                secondaryText,
              ),
            ),
            SizedBox(width: DesignSpacing.sm),
            Expanded(
              child: _buildSummaryCard(
                l10n.dailyAverage,
                avgPerDay.toStringAsFixed(1),
                l10n.perDay,
                Icons.timeline,
                DesignColors.highlightPurple,
                primaryText,
                secondaryText,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVeterinarySummary(Map<String, dynamic> summary,
      AppLocalizations l10n, Color primaryText, Color secondaryText) {
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
                DesignColors.highlightCoral,
                primaryText,
                secondaryText,
              ),
            ),
            SizedBox(width: DesignSpacing.sm),
            Expanded(
              child: _buildSummaryCard(
                l10n.completed,
                '${summary['completedAppointments'] ?? 0}',
                l10n.finished,
                Icons.check_circle,
                DesignColors.highlightTeal,
                primaryText,
                secondaryText,
              ),
            ),
          ],
        ),
        SizedBox(height: DesignSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                l10n.pending,
                '${summary['pendingAppointments'] ?? 0}',
                l10n.upcoming,
                Icons.schedule,
                DesignColors.highlightYellow,
                primaryText,
                secondaryText,
              ),
            ),
            SizedBox(width: DesignSpacing.sm),
            Expanded(
              child: Container(), // Empty space for symmetry
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
    Color primaryText,
    Color secondaryText,
  ) {
    return Container(
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: DesignSpacing.sm),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: primaryText,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: secondaryText,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildReportContent(ThemeData theme, AppLocalizations l10n,
      bool isDark, Color surfaceColor, Color primaryText, Color secondaryText) {
    final List<Widget> content = [];

    switch (report.reportType) {
      case 'Health Summary':
        content.addAll(_buildHealthContent(
            theme, l10n, isDark, surfaceColor, primaryText, secondaryText));
        break;
      case 'Medication History':
        content.addAll(_buildMedicationContent(
            theme, l10n, isDark, surfaceColor, primaryText, secondaryText));
        break;
      case 'Activity Report':
        content.addAll(_buildActivityContent(
            theme, l10n, isDark, surfaceColor, primaryText, secondaryText));
        break;
      case 'Veterinary Records':
        content.addAll(_buildVeterinaryContent(
            theme, l10n, isDark, surfaceColor, primaryText, secondaryText));
        break;
    }

    return content;
  }

  List<Widget> _buildHealthContent(ThemeData theme, AppLocalizations l10n,
      bool isDark, Color surfaceColor, Color primaryText, Color secondaryText) {
    final List<Widget> content = [];

    // Medications section
    final medications = report.data['medications'] as List<dynamic>? ?? [];
    if (medications.isNotEmpty) {
      content.add(_buildSectionHeader(
          l10n.medications, Icons.medication, DesignColors.highlightTeal, primaryText));
      content.add(_buildDataTable(
        [l10n.name, l10n.dosage, l10n.status],
        medications
            .map((med) => [
                  med['medicationName']?.toString() ?? '',
                  med['dosage']?.toString() ?? '',
                  (med['isActive'] == true) ? l10n.active : l10n.inactive,
                ])
            .toList(),
        isDark: isDark,
        surfaceColor: surfaceColor,
        primaryText: primaryText,
      ));
      content.add(SizedBox(height: DesignSpacing.md));
    }

    // Appointments section
    final appointments = report.data['appointments'] as List<dynamic>? ?? [];
    if (appointments.isNotEmpty) {
      content.add(_buildSectionHeader(
          l10n.appointments, Icons.local_hospital, DesignColors.highlightBlue, primaryText));
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
        isDark: isDark,
        surfaceColor: surfaceColor,
        primaryText: primaryText,
      ));
      content.add(SizedBox(height: DesignSpacing.md));
    }

    return content;
  }

  List<Widget> _buildMedicationContent(ThemeData theme, AppLocalizations l10n,
      bool isDark, Color surfaceColor, Color primaryText, Color secondaryText) {
    final medications = report.data['medications'] as List<dynamic>? ?? [];
    if (medications.isEmpty) {
      return [
        _buildEmptyStateCard(
          l10n.noMedicationsFoundPeriod,
          Icons.medication_outlined,
          isDark,
          surfaceColor,
          secondaryText,
        ),
      ];
    }

    return [
      _buildSectionHeader(
          l10n.medicationDetails, Icons.medication, DesignColors.highlightPink, primaryText),
      _buildDataTable(
        [l10n.name, l10n.dosage, l10n.method, l10n.startDate, l10n.status],
        medications
            .map((med) => [
                  med['medicationName']?.toString() ?? '',
                  med['dosage']?.toString() ?? '',
                  _formatAdministrationMethod(
                      med['administrationMethod']?.toString() ?? '', l10n),
                  DateFormat('MMM dd').format(DateTime.parse(med['startDate'])),
                  (med['isActive'] == true) ? l10n.active : l10n.inactive,
                ])
            .toList(),
        isDark: isDark,
        surfaceColor: surfaceColor,
        primaryText: primaryText,
      ),
    ];
  }

  List<Widget> _buildActivityContent(ThemeData theme, AppLocalizations l10n,
      bool isDark, Color surfaceColor, Color primaryText, Color secondaryText) {
    final feedings = report.data['feedings'] as List<dynamic>? ?? [];
    if (feedings.isEmpty) {
      return [
        _buildEmptyStateCard(
          l10n.noFeedingDataFoundPeriod,
          Icons.restaurant_outlined,
          isDark,
          surfaceColor,
          secondaryText,
        ),
      ];
    }

    return [
      _buildSectionHeader(
          l10n.feedingHistory, Icons.restaurant, DesignColors.highlightYellow, primaryText),
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
        isDark: isDark,
        surfaceColor: surfaceColor,
        primaryText: primaryText,
      ),
    ];
  }

  List<Widget> _buildVeterinaryContent(ThemeData theme, AppLocalizations l10n,
      bool isDark, Color surfaceColor, Color primaryText, Color secondaryText) {
    final appointments = report.data['appointments'] as List<dynamic>? ?? [];
    if (appointments.isEmpty) {
      return [
        _buildEmptyStateCard(
          l10n.noVeterinaryAppointmentsFoundPeriod,
          Icons.local_hospital_outlined,
          isDark,
          surfaceColor,
          secondaryText,
        ),
      ];
    }

    return [
      _buildSectionHeader(
          l10n.appointmentHistory, Icons.local_hospital, DesignColors.highlightCoral, primaryText),
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
        isDark: isDark,
        surfaceColor: surfaceColor,
        primaryText: primaryText,
      ),
    ];
  }

  Widget _buildEmptyStateCard(
    String message,
    IconData icon,
    bool isDark,
    Color surfaceColor,
    Color secondaryText,
  ) {
    return Container(
      padding: EdgeInsets.all(DesignSpacing.xl),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: secondaryText.withOpacity(0.5),
            ),
            SizedBox(height: DesignSpacing.md),
            Text(
              message,
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

  Widget _buildSectionHeader(
      String title, IconData icon, Color color, Color primaryText) {
    return Padding(
      padding: EdgeInsets.only(bottom: DesignSpacing.sm, top: DesignSpacing.sm),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(width: DesignSpacing.sm),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable(
    List<String> headers,
    List<List<String>> rows, {
    required bool isDark,
    required Color surfaceColor,
    required Color primaryText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 16,
            headingRowHeight: 48,
            dataRowMinHeight: 44,
            dataRowMaxHeight: 52,
            headingRowColor: WidgetStateProperty.all(
              isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F3E8),
            ),
            columns: headers
                .map((header) => DataColumn(
                      label: Text(
                        header,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: primaryText,
                        ),
                      ),
                    ))
                .toList(),
            rows: rows
                .map((row) => DataRow(
                      cells: row
                          .map((cell) => DataCell(
                                Text(
                                  cell,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: primaryText,
                                  ),
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
        return DesignColors.highlightBlue;
      case 'Medication History':
        return DesignColors.highlightPink;
      case 'Activity Report':
        return DesignColors.highlightYellow;
      case 'Veterinary Records':
        return DesignColors.highlightCoral;
      default:
        return DesignColors.highlightTeal;
    }
  }

  void _shareReport(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // For now, just show a message that sharing functionality could be implemented
    SnackBarHelper.showInfo(context, l10n.shareFunctionalityPlaceholder);
  }

  String _getLocalizedReportType(AppLocalizations l10n) {
    switch (report.reportType) {
      case 'Health Summary':
        return l10n.healthSummary;
      case 'Medication History':
        return l10n.medicationHistory;
      case 'Activity Report':
        return l10n.activityReport;
      case 'Veterinary Records':
        return l10n.veterinaryRecords;
      default:
        return report.reportType;
    }
  }

  /// Format administration method string to localized human-readable text
  String _formatAdministrationMethod(String method, AppLocalizations l10n) {
    // Handle different possible formats: "Oral", "oral", "administrationMethodOral"
    final cleanMethod = method
        .replaceAll('administrationMethod', '')
        .replaceAll('AdministrationMethod', '')
        .toLowerCase()
        .trim();

    switch (cleanMethod) {
      case 'oral':
        return l10n.administrationMethodOral;
      case 'topical':
      case 'topic':
        return l10n.administrationMethodTopical;
      case 'injection':
      case 'injecție':
        return l10n.administrationMethodInjection;
      case 'eye drops':
      case 'eyedrops':
        return l10n.administrationMethodEyeDrops;
      case 'ear drops':
      case 'eardrops':
        return l10n.administrationMethodEarDrops;
      case 'inhaled':
      case 'inhalat':
        return l10n.administrationMethodInhaled;
      case 'other':
      case 'altele':
        return l10n.administrationMethodOther;
      default:
        // Fallback: capitalize first letter if method is not empty
        return cleanMethod.isEmpty
            ? method
            : cleanMethod[0].toUpperCase() + cleanMethod.substring(1);
    }
  }
}
