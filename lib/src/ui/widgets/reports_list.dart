import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/models/report_entry.dart';
import '../../presentation/providers/care_data_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens/colors.dart';
import '../../../theme/tokens/spacing.dart';
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

  /// Get localized report name based on report type
  static String getLocalizedReportName(
      String reportType, AppLocalizations l10n) {
    // Map English report type constants to localized strings
    switch (reportType) {
      case 'Health Summary':
        return l10n.healthSummary;
      case 'Medication History':
        return l10n.medicationHistory;
      case 'Activity Report':
        return l10n.activityReport;
      case 'Veterinary Records':
        return l10n.veterinaryRecords;
      default:
        // Fallback to original if unknown type
        return reportType;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Theme detection
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final dangerColor = isDark ? DesignColors.dDanger : DesignColors.lDanger;

    // If reports are provided, use them directly (for filtered views)
    // Otherwise, fetch all reports from provider
    if (reports != null) {
      if (reports!.isEmpty) {
        return _buildEmptyState(context, isDark, secondaryText);
      }

      // Sort reports by generation date (newest first)
      final sortedReports = [...reports!];
      sortedReports.sort((a, b) => b.generatedDate.compareTo(a.generatedDate));

      return ListView.builder(
        padding: EdgeInsets.all(DesignSpacing.md),
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
          return _buildEmptyState(context, isDark, secondaryText);
        }

        // Sort reports by generation date (newest first)
        final sortedReports = [...fetchedReports];
        sortedReports
            .sort((a, b) => b.generatedDate.compareTo(a.generatedDate));

        return ListView.builder(
          padding: EdgeInsets.all(DesignSpacing.md),
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
      loading: () => Center(
        child: CircularProgressIndicator(
          color: DesignColors.highlightTeal,
        ),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: EdgeInsets.all(DesignSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: dangerColor,
              ),
              SizedBox(height: DesignSpacing.md),
              Text(
                'Failed to load reports',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
              ),
              SizedBox(height: DesignSpacing.sm),
              Text(
                error.toString(),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: DesignSpacing.md),
              ElevatedButton(
                onPressed: () => ref.invalidate(reportsByPetIdProvider(petId)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignColors.highlightTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Retry',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, bool isDark, Color secondaryText) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(DesignSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assessment_outlined,
              size: 80,
              color: secondaryText.withOpacity(0.5),
            ),
            SizedBox(height: DesignSpacing.lg),
            Text(
              l10n.noReportsFound,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: secondaryText,
              ),
            ),
            SizedBox(height: DesignSpacing.xl),
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                onPressed: onAddReport,
                icon: const Icon(Icons.add),
                label: Text(
                  l10n.generateReport,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignColors.highlightTeal,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: DesignSpacing.md,
                  ),
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
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final formatter = DateFormat.yMMMd(locale.languageCode);
    final formattedDate = formatter.format(report.generatedDate);

    // Theme detection
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final primaryText =
        isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final dangerColor = isDark ? DesignColors.dDanger : DesignColors.lDanger;

    // Get localized report name
    final localizedReportName = getLocalizedReportName(report.reportType, l10n);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          l10n.deleteReport,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
        content: Text(
          l10n.deleteReportConfirmation(localizedReportName, formattedDate),
          style: GoogleFonts.inter(
            fontSize: 14,
            color: secondaryText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: secondaryText,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              l10n.cancel,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: dangerColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              l10n.delete,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await ref.read(reportProviderProvider.notifier).deleteReport(report.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.reportDeletedSuccessfully,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              backgroundColor: DesignColors.highlightTeal,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.all(DesignSpacing.md),
            ),
          );
        }
      } catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to delete report: $error',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              backgroundColor:
                  isDark ? DesignColors.dDanger : DesignColors.lDanger,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.all(DesignSpacing.md),
            ),
          );
        }
      }
    }
  }
}
