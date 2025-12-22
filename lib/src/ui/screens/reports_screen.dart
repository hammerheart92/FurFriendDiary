import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/models/report_entry.dart';
import '../../presentation/providers/care_data_provider.dart';
import '../../presentation/providers/pet_profile_provider.dart';
import '../widgets/reports_list.dart';
import '../widgets/report_generation_form.dart';
import '../widgets/report_viewer.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/tokens/colors.dart';
import '../../../theme/tokens/spacing.dart';
import '../../../theme/tokens/shadows.dart';

/// Internal tab keys for logic and filtering
class ReportTab {
  static const String all = 'all';
  static const String health = 'health';
  static const String medications = 'medications';
  static const String activity = 'activity';
}

/// Report type constants - MUST match values in ReportEntry.reportType
class ReportTypeConstants {
  static const String healthSummary = 'Health Summary';
  static const String medicationHistory = 'Medication History';
  static const String activityReport = 'Activity Report';
  static const String veterinaryRecords = 'Veterinary Records';
}

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  bool _showForm = false;
  ReportEntry? _viewingReport;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final activePet = ref.watch(currentPetProfileProvider);

    if (activePet == null) {
      return _buildNoPetView(theme);
    }

    if (_showForm) {
      return _buildFormView(theme, activePet.id);
    }

    if (_viewingReport != null) {
      return _buildReportView(theme);
    }

    return _buildReportsView(theme, activePet.id);
  }

  Widget _buildNoPetView(ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor =
        isDark ? DesignColors.dBackground : DesignColors.lBackground;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.reports,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: DesignColors.highlightTeal,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(DesignSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.pets,
                size: 64,
                color: secondaryText.withOpacity(0.5),
              ),
              SizedBox(height: DesignSpacing.md),
              Text(
                l10n.noPetSelected,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: secondaryText,
                ),
              ),
              SizedBox(height: DesignSpacing.sm),
              Text(
                l10n.pleaseSetupPetFirst,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: secondaryText.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormView(ThemeData theme, String petId) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: DesignColors.highlightTeal,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            setState(() {
              _showForm = false;
            });
          },
          icon: const Icon(Icons.close, color: Colors.white),
        ),
        title: Text(
          l10n.generateReport,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: ReportGenerationForm(
        onGenerated: () {
          setState(() {
            _showForm = false;
          });
        },
        onCancelled: () {
          setState(() {
            _showForm = false;
          });
        },
      ),
    );
  }

  Widget _buildReportView(ThemeData theme) {
    return ReportViewer(
      report: _viewingReport!,
      onClose: () {
        setState(() {
          _viewingReport = null;
        });
      },
    );
  }

  Widget _buildReportsView(ThemeData theme, String petId) {
    final l10n = AppLocalizations.of(context);
    final reportsAsync = ref.watch(reportsByPetIdProvider(petId));

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

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.reports,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: DesignColors.highlightTeal,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          isScrollable: true,
          tabs: [
            Tab(text: l10n.all),
            Tab(text: l10n.health),
            Tab(text: l10n.medications),
            Tab(text: l10n.activity),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            margin: EdgeInsets.all(DesignSpacing.md),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.sm,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              style: GoogleFonts.inter(
                fontSize: 14,
                color: primaryText,
              ),
              decoration: InputDecoration(
                hintText: l10n.searchReports,
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: secondaryText,
                ),
                prefixIcon: Icon(Icons.search, color: secondaryText),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                        icon: Icon(Icons.clear, color: secondaryText),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(DesignSpacing.md),
              ),
            ),
          ),

          // Tabs content
          Expanded(
            child: reportsAsync.when(
              data: (reports) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildReportsList(
                      reports,
                      l10n.noReportsFound,
                      theme,
                      petId,
                    ),
                    _buildReportsList(
                      reports
                          .where((report) =>
                              report.reportType ==
                                  ReportTypeConstants.healthSummary ||
                              report.reportType ==
                                  ReportTypeConstants.veterinaryRecords)
                          .toList(),
                      l10n.noHealthReportsFound,
                      theme,
                      petId,
                    ),
                    _buildReportsList(
                      reports
                          .where((report) =>
                              report.reportType ==
                              ReportTypeConstants.medicationHistory)
                          .toList(),
                      l10n.noMedicationReportsFound,
                      theme,
                      petId,
                    ),
                    _buildReportsList(
                      reports
                          .where((report) =>
                              report.reportType ==
                              ReportTypeConstants.activityReport)
                          .toList(),
                      l10n.noActivityReportsFound,
                      theme,
                      petId,
                    ),
                  ],
                );
              },
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: DesignColors.highlightTeal,
                ),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: isDark ? DesignColors.dDanger : DesignColors.lDanger,
                    ),
                    SizedBox(height: DesignSpacing.md),
                    Text(
                      '${l10n.errorLoadingReports}: $error',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: primaryText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: DesignSpacing.md),
                    ElevatedButton(
                      onPressed: () =>
                          ref.invalidate(reportsByPetIdProvider(petId)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignColors.highlightTeal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.retry,
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            _showForm = true;
          });
        },
        backgroundColor: DesignColors.highlightTeal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(
          l10n.generateReport,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildReportsList(
    List<ReportEntry> reports,
    String emptyMessage,
    ThemeData theme,
    String petId,
  ) {
    final l10n = AppLocalizations.of(context);

    // Theme detection for empty state
    final isDark = theme.brightness == Brightness.dark;
    final secondaryText =
        isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    // Filter reports based on search query
    final filteredReports = reports.where((report) {
      if (_searchQuery.isEmpty) return true;
      return report.reportType.toLowerCase().contains(_searchQuery);
    }).toList();

    // Sort by generation date (newest first)
    filteredReports.sort((a, b) => b.generatedDate.compareTo(a.generatedDate));

    if (filteredReports.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(DesignSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.assessment_outlined,
                size: 64,
                color: secondaryText.withOpacity(0.5),
              ),
              SizedBox(height: DesignSpacing.md),
              Text(
                _searchQuery.isNotEmpty
                    ? l10n.noReportsMatchSearch
                    : emptyMessage,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: secondaryText,
                ),
                textAlign: TextAlign.center,
              ),
              if (_searchQuery.isNotEmpty) ...[
                SizedBox(height: DesignSpacing.sm),
                Text(
                  l10n.tryAdjustingSearchTerms,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: secondaryText.withOpacity(0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(reportsByPetIdProvider(petId));
      },
      child: ReportsList(
        petId: petId,
        reports: filteredReports,
        onAddReport: () {
          setState(() {
            _showForm = true;
          });
        },
        onViewReport: (report) {
          setState(() {
            _viewingReport = report;
          });
        },
      ),
    );
  }
}
