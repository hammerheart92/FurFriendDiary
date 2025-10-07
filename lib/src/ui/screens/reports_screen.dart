
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/report_entry.dart';
import '../../presentation/providers/care_data_provider.dart';
import '../../presentation/providers/pet_profile_provider.dart';
import '../widgets/reports_list.dart';
import '../widgets/report_generation_form.dart';
import '../widgets/report_viewer.dart';
import '../../../l10n/app_localizations.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reports),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noPetSelected,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.pleaseSetupPetFirst,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormView(ThemeData theme, String petId) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.generateReport),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            setState(() {
              _showForm = false;
            });
          },
          icon: const Icon(Icons.close),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reports),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.colorScheme.onPrimary,
          labelColor: theme.colorScheme.onPrimary,
          unselectedLabelColor: theme.colorScheme.onPrimary.withOpacity(0.7),
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: l10n.searchReports,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.background,
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
                      reports.where((report) =>
                        report.reportType == l10n.healthSummary ||
                        report.reportType == l10n.veterinaryRecords).toList(),
                      l10n.noHealthReportsFound,
                      theme,
                      petId,
                    ),
                    _buildReportsList(
                      reports.where((report) => report.reportType == l10n.medicationHistory).toList(),
                      l10n.noMedicationReportsFound,
                      theme,
                      petId,
                    ),
                    _buildReportsList(
                      reports.where((report) => report.reportType == l10n.activityReport).toList(),
                      l10n.noActivityReportsFound,
                      theme,
                      petId,
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('${l10n.errorLoadingReports}: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(reportsByPetIdProvider(petId)),
                      child: Text(l10n.retry),
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
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: Text(l10n.generateReport),
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
    
    // Filter reports based on search query
    final filteredReports = reports.where((report) {
      if (_searchQuery.isEmpty) return true;
      return report.reportType.toLowerCase().contains(_searchQuery);
    }).toList();

    // Sort by generation date (newest first)
    filteredReports.sort((a, b) => b.generatedDate.compareTo(a.generatedDate));

    if (filteredReports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assessment,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty ? l10n.noReportsMatchSearch : emptyMessage,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                l10n.tryAdjustingSearchTerms,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ],
          ],
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
