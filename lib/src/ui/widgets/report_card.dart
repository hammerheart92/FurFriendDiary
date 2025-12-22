import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/models/report_entry.dart';
import '../../../l10n/app_localizations.dart';
import '../../utils/date_helper.dart';
import '../../../theme/tokens/colors.dart';
import '../../../theme/tokens/spacing.dart';
import '../../../theme/tokens/shadows.dart';

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
    final l10n = AppLocalizations.of(context);

    // Theme detection
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final reportColor = _getReportColor();

    return Container(
      margin: EdgeInsets.only(bottom: DesignSpacing.sm),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main content padding
              Padding(
                padding: EdgeInsets.all(DesignSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
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
                            size: 24,
                          ),
                        ),
                        SizedBox(width: DesignSpacing.md),

                        // Title and date
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getLocalizedReportType(context),
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: primaryText,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                _getDateRange(),
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: secondaryText,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // Time badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: DesignSpacing.sm,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: reportColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getTimeAgo(),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: reportColor,
                            ),
                          ),
                        ),
                        SizedBox(width: DesignSpacing.sm),

                        // More options menu
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'delete') {
                              onDelete?.call();
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    color: isDark
                                        ? DesignColors.dDanger
                                        : DesignColors.lDanger,
                                  ),
                                  SizedBox(width: DesignSpacing.sm),
                                  Text(
                                    l10n.delete,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: isDark
                                          ? DesignColors.dDanger
                                          : DesignColors.lDanger,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          icon: Icon(
                            Icons.more_vert,
                            color: secondaryText,
                            size: 20,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: DesignSpacing.md),

                    // Stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          icon: Icons.calendar_today,
                          label: l10n.generated,
                          value: localizedShortDate(context, report.generatedDate),
                          color: DesignColors.highlightBlue,
                          primaryText: primaryText,
                          secondaryText: secondaryText,
                        ),
                        _buildStatItem(
                          icon: Icons.date_range,
                          label: l10n.period,
                          value: _getPeriodDuration(),
                          color: DesignColors.highlightTeal,
                          primaryText: primaryText,
                          secondaryText: secondaryText,
                        ),
                        _buildStatItem(
                          icon: Icons.analytics_outlined,
                          label: l10n.data,
                          value: _getDataSummary(context),
                          color: DesignColors.highlightPurple,
                          primaryText: primaryText,
                          secondaryText: secondaryText,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Summary section with beige/dark background
              if (_hasSummaryData())
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(DesignSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFFF5F3E8),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.subject,
                        size: 16,
                        color: secondaryText,
                      ),
                      SizedBox(width: DesignSpacing.sm),
                      Expanded(
                        child: Text(
                          _getSummaryText(context),
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: secondaryText,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color primaryText,
    required Color secondaryText,
  }) {
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
        SizedBox(height: 2),
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

  String _getLocalizedReportType(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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

  /// Get report type color using design tokens
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
