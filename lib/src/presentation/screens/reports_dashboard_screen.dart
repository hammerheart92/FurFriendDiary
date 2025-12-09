import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
import 'package:fur_friend_diary/src/presentation/providers/pet_profile_provider.dart';
import 'package:fur_friend_diary/src/presentation/providers/analytics_provider.dart';
import 'package:fur_friend_diary/src/presentation/providers/vaccinations_provider.dart';
import 'package:fur_friend_diary/src/presentation/providers/care_data_provider.dart';
import 'package:fur_friend_diary/src/presentation/widgets/health_score_chart.dart';
import 'package:fur_friend_diary/src/presentation/widgets/activity_chart.dart';
import 'package:fur_friend_diary/src/presentation/widgets/expense_chart.dart';
import 'package:fur_friend_diary/src/presentation/widgets/export_options_dialog.dart';
import '../providers/pdf_consent_provider.dart';

enum DateRange { sevenDays, thirtyDays, ninetyDays }

class ReportsDashboardScreen extends ConsumerStatefulWidget {
  const ReportsDashboardScreen({super.key});

  @override
  ConsumerState<ReportsDashboardScreen> createState() =>
      _ReportsDashboardScreenState();
}

class _ReportsDashboardScreenState extends ConsumerState<ReportsDashboardScreen>
    with SingleTickerProviderStateMixin {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.none,
    ),
  );

  late TabController _tabController;
  DateRange _selectedRange = DateRange.thirtyDays;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int get _daysForRange {
    switch (_selectedRange) {
      case DateRange.sevenDays:
        return 7;
      case DateRange.thirtyDays:
        return 30;
      case DateRange.ninetyDays:
        return 90;
    }
  }

  /// Get normalized date range (without time component) to prevent infinite provider refetches
  ({DateTime start, DateTime end}) get _normalizedDateRange {
    final now = DateTime.now();
    // Normalize to midnight to prevent microsecond changes from triggering provider refetches
    final endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final startDate = DateTime(
      now.year,
      now.month,
      now.day - _daysForRange,
      0,
      0,
      0,
    );
    return (start: startDate, end: endDate);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentPet = ref.watch(currentPetProfileProvider);

    if (currentPet == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.reportsAndAnalytics)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.pets_outlined,
                  size: 80,
                  color: Theme.of(context)
                      .colorScheme
                      .secondary
                      .withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.noPetSelected,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.pleaseSetupPetFirst,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reportsAndAnalytics),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: l10n.shareReport,
            onPressed: () => _handleExport(context, l10n, currentPet),
          ),
          PopupMenuButton<DateRange>(
            icon: const Icon(Icons.date_range),
            onSelected: (range) {
              setState(() => _selectedRange = range);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: DateRange.sevenDays,
                child: Text(l10n.last7Days),
              ),
              PopupMenuItem(
                value: DateRange.thirtyDays,
                child: Text(l10n.last30Days),
              ),
              PopupMenuItem(
                value: DateRange.ninetyDays,
                child: Text(l10n.last90Days),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.overview),
            Tab(text: l10n.health),
            Tab(text: l10n.activity),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(healthScoreProvider);
          ref.invalidate(medicationAdherenceProvider);
          ref.invalidate(activityLevelsProvider);
          ref.invalidate(weightTrendProvider);
          ref.invalidate(monthlyExpensesProvider);

          // PHASE 4C PROVIDERS - Re-enabled with fixed date normalization
          ref.invalidate(expensesByCategoryProvider);
          ref.invalidate(monthlyExpensesChartProvider);
          ref.invalidate(recommendationsProvider);
        },
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(context, l10n, currentPet.id),
            _buildHealthTab(context, l10n, currentPet.id),
            _buildActivityTab(context, l10n, currentPet.id),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(
      BuildContext context, AppLocalizations l10n, String petId) {
    final healthScoreAsync = ref.watch(healthScoreProvider(petId));
    final medicationAdherenceAsync = ref.watch(
      medicationAdherenceProvider((petId: petId, days: _daysForRange)),
    );
    final weightTrend = ref.watch(weightTrendProvider(petId));
    final monthlyExpensesAsync = ref.watch(monthlyExpensesProvider(petId));

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Health Score Card
          healthScoreAsync.when(
            data: (score) => HealthScoreChart(score: score),
            loading: () => const Card(
              child: SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (error, _) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error: $error'),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Quick Stats Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              // Medication Adherence
              medicationAdherenceAsync.when(
                data: (adherence) => _buildStatCard(
                  context,
                  l10n.medicationAdherence,
                  '${adherence.toStringAsFixed(0)}%',
                  Icons.medication,
                  adherence >= 80 ? Colors.green : Colors.orange,
                ),
                loading: () => _buildLoadingStatCard(context),
                error: (_, __) => _buildErrorStatCard(context),
              ),

              // Activity Level
              _buildStatCard(
                context,
                l10n.activityLevels,
                _getActivityLabel(l10n, healthScoreAsync.value ?? 0),
                Icons.directions_run,
                Colors.blue,
              ),

              // Weight Trend
              _buildStatCard(
                context,
                l10n.weightTrend,
                _getWeightTrendLabel(l10n, weightTrend),
                Icons.monitor_weight,
                _getWeightTrendColor(weightTrend),
              ),

              // Monthly Expenses
              monthlyExpensesAsync.when(
                data: (expenses) => _buildStatCard(
                  context,
                  l10n.totalExpenses,
                  '\$${expenses.toStringAsFixed(2)}',
                  Icons.attach_money,
                  Colors.purple,
                ),
                loading: () => _buildLoadingStatCard(context),
                error: (_, __) => _buildErrorStatCard(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // PHASE 4C ADDITIONS - Now with fixed date normalization
          // Expense Charts
          _buildExpenseSection(context, l10n, petId),
          const SizedBox(height: 16),

          // Recommendations
          _buildRecommendationsSection(context, l10n, petId),
        ],
      ),
    );
  }

  // PHASE 4C METHODS - Fixed to use normalized dates
  Widget _buildExpenseSection(
      BuildContext context, AppLocalizations l10n, String petId) {
    // Use normalized date range to prevent infinite provider refetches
    final dateRange = _normalizedDateRange;
    final expensesAsync = ref.watch(
      expensesByCategoryProvider(petId, dateRange.start, dateRange.end),
    );
    final monthlyExpensesAsync = ref.watch(
      monthlyExpensesChartProvider(petId, 6),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Category breakdown pie chart
        expensesAsync.when(
          data: (expenses) {
            if (expenses.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      l10n.noDataAvailable,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              );
            }
            return ExpenseChart(
              expensesByCategory: expenses,
              currencySymbol: '\$',
            );
          },
          loading: () => const Card(
            child: SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (error, _) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 16),

        // Monthly expenses bar chart
        monthlyExpensesAsync.when(
          data: (expenses) {
            if (expenses.isEmpty) {
              return const SizedBox.shrink();
            }
            return MonthlyExpenseChart(
              monthlyExpenses: expenses,
              currencySymbol: '\$',
            );
          },
          loading: () => const Card(
            child: SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (error, _) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildRecommendationsSection(
      BuildContext context, AppLocalizations l10n, String petId) {
    final recommendationsAsync = ref.watch(recommendationsProvider(petId));

    return recommendationsAsync.when(
      data: (recommendations) {
        if (recommendations.isEmpty) {
          return const SizedBox.shrink();
        }
        return _RecommendationsCard(
          recommendations: recommendations,
          l10n: l10n,
        );
      },
      loading: () => const Card(
        child: SizedBox(
          height: 150,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildHealthTab(
      BuildContext context, AppLocalizations l10n, String petId) {
    final healthScoreAsync = ref.watch(healthScoreProvider(petId));

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.healthMetrics,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Health Score Breakdown
          healthScoreAsync.when(
            data: (score) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.healthScore,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: score / 100,
                      minHeight: 12,
                      backgroundColor: Colors.grey[300],
                      color: _getHealthScoreColor(score),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${score.toStringAsFixed(0)}/100',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.healthScoreDescription,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            loading: () => const Card(
              child: SizedBox(
                height: 150,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (error, _) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTab(
      BuildContext context, AppLocalizations l10n, String petId) {
    final activityLevelsAsync = ref.watch(
      activityLevelsProvider((petId: petId, days: _daysForRange)),
    );

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.activityMetrics,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Activity Summary
          activityLevelsAsync.when(
            data: (levels) => Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildActivitySummaryCard(
                        context,
                        l10n.totalFeedings,
                        levels['totalFeedings']?.toInt().toString() ?? '0',
                        Icons.restaurant,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActivitySummaryCard(
                        context,
                        l10n.totalWalks,
                        levels['totalWalks']?.toInt().toString() ?? '0',
                        Icons.pets,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ActivityChart(activityData: levels),
              ],
            ),
            loading: () => const Card(
              child: SizedBox(
                height: 300,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (error, _) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 18,
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingStatCard(BuildContext context) {
    return const Card(
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorStatCard(BuildContext context) {
    return Card(
      child: Center(
        child: Icon(Icons.error_outline, color: Colors.red[300]),
      ),
    );
  }

  String _getActivityLabel(AppLocalizations l10n, double healthScore) {
    if (healthScore >= 70) return l10n.activityHigh;
    if (healthScore >= 40) return l10n.activityMedium;
    return l10n.activityLow;
  }

  String _getWeightTrendLabel(AppLocalizations l10n, String trend) {
    switch (trend) {
      case 'stable':
        return l10n.stable;
      case 'gaining':
        return l10n.gaining;
      case 'losing':
        return l10n.losing;
      default:
        return l10n.stable;
    }
  }

  Color _getWeightTrendColor(String trend) {
    switch (trend) {
      case 'stable':
        return Colors.green;
      case 'gaining':
        return Colors.blue;
      case 'losing':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getHealthScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  // Export and Share functionality
  Future<void> _handleExport(
    BuildContext context,
    AppLocalizations l10n,
    dynamic currentPet,
  ) async {
    if (currentPet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noPetSelected)),
      );
      return;
    }

    final option = await showExportOptionsDialog(context);
    if (option == null) return;

    // Check consent ONLY for PDF exports (not for text summaries)
    if (option == ExportOption.fullReport ||
        option == ExportOption.vetSummary) {
      if (!context.mounted) return;

      final consentService = ref.read(pdfConsentServiceProvider.notifier);
      final hasConsent = await consentService.checkConsentBeforeExport(context);

      if (!hasConsent) {
        // User declined consent or dialog was dismissed
        return;
      }
    }

    final pdfService = ref.read(pdfExportServiceProvider);
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: _daysForRange));

    try {
      switch (option) {
        case ExportOption.fullReport:
          await _exportFullReport(
              context, l10n, pdfService, currentPet, startDate, endDate);
          break;
        case ExportOption.vetSummary:
          await _exportVetSummary(context, l10n, pdfService, currentPet);
          break;
        case ExportOption.textSummary:
          await _shareTextSummary(
              context, l10n, pdfService, currentPet, startDate, endDate);
          break;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedToExportReport)),
        );
      }
    }
  }

  Future<void> _exportFullReport(
    BuildContext context,
    AppLocalizations l10n,
    dynamic pdfService,
    dynamic pet,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      _logger.i('📄 Step 1: Starting PDF export...');

      // Show non-blocking loading feedback using SnackBar
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Text(l10n.generatingReport),
            ],
          ),
          duration: const Duration(seconds: 30), // Long duration for generation
          backgroundColor: Colors.blue.shade700,
        ),
      );

      _logger.i('✅ Step 2: Loading indicator shown (SnackBar)');

      // Fetch additional data for enhanced PDF
      _logger.i('📄 Step 2.5: Fetching additional data...');
      final vaccinations = await ref.read(
        vaccinationsByPetIdProvider(pet.id).future,
      );
      final activeMedications = await ref.read(
        activeMedicationsByPetIdProvider(pet.id).future,
      );
      // Get upcoming appointments (next 30 days from today)
      final upcomingAppointments = await ref.read(
        appointmentsByDateRangeProvider(
          pet.id,
          DateTime.now(),
          DateTime.now().add(const Duration(days: 30)),
        ).future,
      );
      _logger.i(
          '✅ Step 2.5: Fetched ${vaccinations.length} vaccinations, ${activeMedications.length} medications, ${upcomingAppointments.length} appointments');

      // Generate PDF
      _logger.i('📄 Step 3: Generating PDF...');
      final filePath = await pdfService
          .generateHealthReport(
        pet: pet,
        startDate: startDate,
        endDate: endDate,
        l10n: l10n,
        vaccinations: vaccinations,
        activeMedications: activeMedications,
        upcomingAppointments: upcomingAppointments,
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('PDF generation timed out after 30 seconds');
        },
      );

      _logger.i('✅ Step 4: PDF generated: $filePath');

      // Dismiss loading SnackBar
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _logger.i('🔄 Step 5: Loading indicator dismissed');

      // Small delay to ensure UI is stable
      await Future.delayed(const Duration(milliseconds: 200));

      // Share PDF immediately - NO INTERMEDIATE DIALOGS
      _logger.i('📤 Step 6: Opening share dialog...');

      if (!context.mounted) return;
      await pdfService.shareReport(
        filePath,
        subject: l10n.emailSubject,
        text: l10n.emailBody,
      );

      _logger.i('✅ Step 7: Share completed');

      // Show brief success message (non-blocking)
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text(l10n.reportGeneratedSuccessfully),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e, stackTrace) {
      _logger.e('❌ ERROR in PDF export: $e');
      _logger.e('Stack trace: $stackTrace');

      // Ensure loading is dismissed on error
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }

      // Show error message (non-blocking)
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.failedToGeneratePDF(e.toString()),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: l10n.close,
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  Future<void> _exportVetSummary(
    BuildContext context,
    AppLocalizations l10n,
    dynamic pdfService,
    dynamic pet,
  ) async {
    try {
      _logger.i('📄 Step 1: Starting vet summary export...');

      // Show non-blocking loading feedback
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Text(l10n.generatingReport),
            ],
          ),
          duration: const Duration(seconds: 30),
          backgroundColor: Colors.blue.shade700,
        ),
      );

      _logger.i('✅ Step 2: Loading indicator shown');

      // Generate vet summary PDF
      _logger.i('📄 Step 3: Generating vet summary...');
      final filePath = await pdfService
          .generateVetSummary(
        pet: pet,
        l10n: l10n,
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Vet summary generation timed out after 30 seconds');
        },
      );

      _logger.i('✅ Step 4: Vet summary generated: $filePath');

      // Dismiss loading
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _logger.i('🔄 Step 5: Loading indicator dismissed');

      await Future.delayed(const Duration(milliseconds: 200));

      // Share immediately
      _logger.i('📤 Step 6: Opening share dialog...');
      if (!context.mounted) return;
      await pdfService.shareReport(
        filePath,
        subject: l10n.vetSummaryEmailSubject,
        text: l10n.vetSummaryEmailBody,
      );

      _logger.i('✅ Step 7: Share completed');

      // Success message
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text(l10n.reportGeneratedSuccessfully),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e, stackTrace) {
      _logger.e('❌ ERROR in vet summary export: $e');
      _logger.e('Stack trace: $stackTrace');

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.failedToGeneratePDF(e.toString()),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: l10n.close,
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  Future<void> _shareTextSummary(
    BuildContext context,
    AppLocalizations l10n,
    dynamic pdfService,
    dynamic pet,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      _logger.i('📄 Step 1: Starting text summary export...');

      // Show non-blocking loading feedback
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Text(l10n.generatingReport),
            ],
          ),
          duration: const Duration(seconds: 30),
          backgroundColor: Colors.blue.shade700,
        ),
      );

      _logger.i('✅ Step 2: Loading indicator shown');

      // Generate text summary
      _logger.i('📄 Step 3: Generating text summary...');
      final summary = await pdfService
          .generateTextSummary(
        pet: pet,
        startDate: startDate,
        endDate: endDate,
        l10n: l10n,
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Text summary generation timed out after 30 seconds');
        },
      );

      _logger.i('✅ Step 4: Text summary generated');

      // Dismiss loading
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _logger.i('🔄 Step 5: Loading indicator dismissed');

      await Future.delayed(const Duration(milliseconds: 200));

      // Share immediately
      _logger.i('📤 Step 6: Opening share dialog...');
      if (!context.mounted) return;
      await pdfService.shareTextSummary(
        summary,
        subject: l10n.textSummaryEmailSubject,
      );

      _logger.i('✅ Step 7: Share completed');

      // Success message
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text(l10n.reportGeneratedSuccessfully),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e, stackTrace) {
      _logger.e('❌ ERROR in text summary export: $e');
      _logger.e('Stack trace: $stackTrace');

      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.failedToShareReport,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: l10n.close,
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }
}

/// Widget for displaying recommendations (PHASE 4C)
class _RecommendationsCard extends StatelessWidget {
  final List<String> recommendations;
  final AppLocalizations l10n;

  const _RecommendationsCard({
    required this.recommendations,
    required this.l10n,
  });

  /// Translate recommendation key to localized text
  String _getTranslatedRecommendation(String key) {
    switch (key) {
      case 'recSetMedicationReminders':
        return l10n.recSetMedicationReminders;
      case 'recConsiderVetWeightGain':
        return l10n.recConsiderVetWeightGain;
      case 'recConsiderVetWeightLoss':
        return l10n.recConsiderVetWeightLoss;
      case 'recIncreaseDailyWalks':
        return l10n.recIncreaseDailyWalks;
      case 'recReviewMedicationCosts':
        return l10n.recReviewMedicationCosts;
      case 'recScheduleVetCheckup':
        return l10n.recScheduleVetCheckup;
      default:
        return key; // Fallback to key if unknown
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.recommendations,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...recommendations.map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _getTranslatedRecommendation(rec),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
