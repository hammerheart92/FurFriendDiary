import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
import 'package:fur_friend_diary/theme/tokens/colors.dart';
import 'package:fur_friend_diary/theme/tokens/spacing.dart';
import 'package:fur_friend_diary/theme/tokens/shadows.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final backgroundColor = isDark ? DesignColors.dBackground : DesignColors.lBackground;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;

    if (currentPet == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          title: Text(
            l10n.reportsAndAnalytics,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: primaryText,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(DesignSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: DesignColors.highlightTeal.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.pets_outlined,
                    size: 48,
                    color: DesignColors.highlightTeal,
                  ),
                ),
                SizedBox(height: DesignSpacing.lg),
                Text(
                  l10n.noPetSelected,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: primaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: DesignSpacing.sm),
                Text(
                  l10n.pleaseSetupPetFirst,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: secondaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.reportsAndAnalytics,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: DesignColors.highlightTeal),
            tooltip: l10n.shareReport,
            onPressed: () => _handleExport(context, l10n, currentPet),
          ),
          PopupMenuButton<DateRange>(
            icon: Icon(Icons.date_range, color: DesignColors.highlightTeal),
            color: surfaceColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (range) {
              setState(() => _selectedRange = range);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: DateRange.sevenDays,
                child: Text(
                  l10n.last7Days,
                  style: GoogleFonts.inter(fontSize: 14, color: primaryText),
                ),
              ),
              PopupMenuItem(
                value: DateRange.thirtyDays,
                child: Text(
                  l10n.last30Days,
                  style: GoogleFonts.inter(fontSize: 14, color: primaryText),
                ),
              ),
              PopupMenuItem(
                value: DateRange.ninetyDays,
                child: Text(
                  l10n.last90Days,
                  style: GoogleFonts.inter(fontSize: 14, color: primaryText),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Custom pill-shaped tab selector
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: DesignSpacing.md,
              vertical: DesignSpacing.sm,
            ),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.sm,
            ),
            child: Row(
              children: [
                _buildTabButton(l10n.overview, 0, primaryText, secondaryText),
                _buildTabButton(l10n.health, 1, primaryText, secondaryText),
                _buildTabButton(l10n.activity, 2, primaryText, secondaryText),
              ],
            ),
          ),
          // Tab content
          Expanded(
            child: RefreshIndicator(
              color: DesignColors.highlightTeal,
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
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index, Color primaryText, Color secondaryText) {
    final isSelected = _tabController.index == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _tabController.animateTo(index);
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: DesignSpacing.sm),
          decoration: BoxDecoration(
            color: isSelected ? DesignColors.highlightTeal : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : secondaryText,
            ),
          ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(DesignSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.healthMetrics,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: primaryText,
            ),
          ),
          SizedBox(height: DesignSpacing.md),

          // Health Score Breakdown
          healthScoreAsync.when(
            data: (score) {
              final scoreColor = _getHealthScoreColor(score);
              return Container(
                padding: EdgeInsets.all(DesignSpacing.md),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.healthScore,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: primaryText,
                      ),
                    ),
                    SizedBox(height: DesignSpacing.sm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: score / 100,
                        minHeight: 12,
                        backgroundColor: scoreColor.withOpacity(0.2),
                        color: scoreColor,
                      ),
                    ),
                    SizedBox(height: DesignSpacing.sm),
                    Text(
                      '${score.toStringAsFixed(0)}/100',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: scoreColor,
                      ),
                    ),
                    SizedBox(height: DesignSpacing.md),
                    Text(
                      l10n.healthScoreDescription,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: secondaryText,
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => Container(
              height: 150,
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.sm,
              ),
              child: Center(
                child: CircularProgressIndicator(
                  color: DesignColors.highlightTeal,
                  strokeWidth: 3,
                ),
              ),
            ),
            error: (error, _) => Container(
              padding: EdgeInsets.all(DesignSpacing.md),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.sm,
              ),
              child: Text(
                'Error: $error',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark ? DesignColors.dDanger : DesignColors.lDanger,
                ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(DesignSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.activityMetrics,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: primaryText,
            ),
          ),
          SizedBox(height: DesignSpacing.md),

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
                        DesignColors.highlightYellow,
                      ),
                    ),
                    SizedBox(width: DesignSpacing.sm),
                    Expanded(
                      child: _buildActivitySummaryCard(
                        context,
                        l10n.totalWalks,
                        levels['totalWalks']?.toInt().toString() ?? '0',
                        Icons.pets,
                        DesignColors.highlightTeal,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: DesignSpacing.md),
                ActivityChart(activityData: levels),
              ],
            ),
            loading: () => Container(
              height: 300,
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.sm,
              ),
              child: Center(
                child: CircularProgressIndicator(
                  color: DesignColors.highlightTeal,
                  strokeWidth: 3,
                ),
              ),
            ),
            error: (error, _) => Container(
              padding: EdgeInsets.all(DesignSpacing.md),
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.sm,
              ),
              child: Text(
                'Error: $error',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark ? DesignColors.dDanger : DesignColors.lDanger,
                ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Container(
      padding: EdgeInsets.all(DesignSpacing.sm),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.sm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          SizedBox(height: DesignSpacing.xs),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: DesignSpacing.xs),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: secondaryText,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Container(
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.sm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          SizedBox(height: DesignSpacing.sm),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: DesignSpacing.xs),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: secondaryText,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingStatCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.sm,
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: DesignColors.highlightTeal,
          strokeWidth: 3,
        ),
      ),
    );
  }

  Widget _buildErrorStatCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final dangerColor = isDark ? DesignColors.dDanger : DesignColors.lDanger;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.sm,
      ),
      child: Center(
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: dangerColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.error_outline, color: dangerColor, size: 20),
        ),
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
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
      final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: DesignColors.highlightCoral,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.noPetSelected,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: primaryText,
                ),
              ),
            ],
          ),
          backgroundColor: surfaceColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
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
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
        final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
        final dangerColor = isDark ? DesignColors.dDanger : DesignColors.lDanger;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: dangerColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.failedToExportReport,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: primaryText,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: surfaceColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
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
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
      final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: DesignColors.highlightTeal,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.generatingReport,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: primaryText,
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 30), // Long duration for generation
          backgroundColor: surfaceColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
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
      final successIsDark = Theme.of(context).brightness == Brightness.dark;
      final successSurface = successIsDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
      final successText = successIsDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
      final successColor = successIsDark ? DesignColors.dSuccess : DesignColors.lSuccess;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: successColor, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.reportGeneratedSuccessfully,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: successText,
                ),
              ),
            ],
          ),
          backgroundColor: successSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
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
      final errorIsDark = Theme.of(context).brightness == Brightness.dark;
      final errorSurface = errorIsDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
      final errorText = errorIsDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
      final dangerColor = errorIsDark ? DesignColors.dDanger : DesignColors.lDanger;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: dangerColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.failedToGeneratePDF(e.toString()),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: errorText,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: errorSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: l10n.close,
            textColor: DesignColors.highlightTeal,
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
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
      final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: DesignColors.highlightTeal,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.generatingReport,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: primaryText,
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 30),
          backgroundColor: surfaceColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
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
      final successIsDark = Theme.of(context).brightness == Brightness.dark;
      final successSurface = successIsDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
      final successText = successIsDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
      final successColor = successIsDark ? DesignColors.dSuccess : DesignColors.lSuccess;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: successColor, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.reportGeneratedSuccessfully,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: successText,
                ),
              ),
            ],
          ),
          backgroundColor: successSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
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
      final errorIsDark = Theme.of(context).brightness == Brightness.dark;
      final errorSurface = errorIsDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
      final errorText = errorIsDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
      final dangerColor = errorIsDark ? DesignColors.dDanger : DesignColors.lDanger;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: dangerColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.failedToGeneratePDF(e.toString()),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: errorText,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: errorSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: l10n.close,
            textColor: DesignColors.highlightTeal,
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
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
      final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: DesignColors.highlightTeal,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.generatingReport,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: primaryText,
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 30),
          backgroundColor: surfaceColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
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
      final successIsDark = Theme.of(context).brightness == Brightness.dark;
      final successSurface = successIsDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
      final successText = successIsDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
      final successColor = successIsDark ? DesignColors.dSuccess : DesignColors.lSuccess;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: successColor, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.reportGeneratedSuccessfully,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: successText,
                ),
              ),
            ],
          ),
          backgroundColor: successSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
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
      final errorIsDark = Theme.of(context).brightness == Brightness.dark;
      final errorSurface = errorIsDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
      final errorText = errorIsDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
      final dangerColor = errorIsDark ? DesignColors.dDanger : DesignColors.lDanger;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: dangerColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.failedToShareReport,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: errorText,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: errorSurface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: l10n.close,
            textColor: DesignColors.highlightTeal,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;

    return Container(
      padding: EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: DesignColors.highlightYellow.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.lightbulb,
                  color: DesignColors.highlightYellow,
                  size: 20,
                ),
              ),
              SizedBox(width: DesignSpacing.sm),
              Text(
                l10n.recommendations,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: primaryText,
                ),
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.md),
          ...recommendations.map((rec) => Padding(
                padding: EdgeInsets.only(bottom: DesignSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: DesignColors.highlightTeal,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: DesignSpacing.sm),
                    Expanded(
                      child: Text(
                        _getTranslatedRecommendation(rec),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
