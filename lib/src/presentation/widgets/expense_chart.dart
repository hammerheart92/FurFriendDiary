import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
import 'package:fur_friend_diary/theme/tokens/colors.dart';
import 'package:fur_friend_diary/theme/tokens/spacing.dart';
import 'package:fur_friend_diary/theme/tokens/shadows.dart';

class ExpenseChart extends StatefulWidget {
  final Map<String, double> expensesByCategory;
  final String currencySymbol;

  const ExpenseChart({
    super.key,
    required this.expensesByCategory,
    this.currencySymbol = '\$',
  });

  @override
  State<ExpenseChart> createState() => _ExpenseChartState();
}

class _ExpenseChartState extends State<ExpenseChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Translate expense category from English to localized text
  String _translateCategory(String category, AppLocalizations l10n) {
    switch (category) {
      case 'Medications':
        return l10n.medications;
      case 'Appointments':
        return l10n.appointments;
      case 'Food':
        return 'Mâncare'; // TODO: Add to translations if needed
      case 'Other':
        return 'Altele'; // TODO: Add to translations if needed
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final totalExpense =
        widget.expensesByCategory.values.fold(0.0, (a, b) => a + b);

    if (totalExpense == 0) {
      return Container(
        padding: EdgeInsets.all(DesignSpacing.lg),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.sm,
        ),
        child: Center(
          child: Text(
            'No expenses recorded',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: secondaryText,
            ),
          ),
        ),
      );
    }

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
            l10n.expensesByCategory,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: primaryText,
            ),
          ),
          SizedBox(height: DesignSpacing.sm),
          Text(
            '${l10n.total}: ${widget.currencySymbol}${totalExpense.toStringAsFixed(2)}',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: DesignColors.highlightTeal,
            ),
          ),
          SizedBox(height: DesignSpacing.lg),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback:
                                (FlTouchEvent event, pieTouchResponse) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    pieTouchResponse == null ||
                                    pieTouchResponse.touchedSection == null) {
                                  _touchedIndex = -1;
                                  return;
                                }
                                _touchedIndex = pieTouchResponse
                                    .touchedSection!.touchedSectionIndex;
                              });
                            },
                          ),
                          borderData: FlBorderData(show: false),
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: _buildPieChartSections(totalExpense),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: DesignSpacing.md),
                Expanded(
                  child: _buildLegend(isDark, totalExpense),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(double totalExpense) {
    final categories = widget.expensesByCategory.entries.toList();
    final colors = _getCategoryColors();

    return List.generate(categories.length, (index) {
      final entry = categories[index];
      final percentage = (entry.value / totalExpense) * 100;
      final isTouched = index == _touchedIndex;
      final radius = isTouched ? 60.0 : 50.0;
      final fontSize = isTouched ? 14.0 : 12.0;

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: entry.value * _animation.value,
        title: percentage >= 5 ? '${percentage.toStringAsFixed(0)}%' : '',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        badgeWidget: isTouched
            ? Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  '${widget.currencySymbol}${entry.value.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        badgePositionPercentageOffset: 1.3,
      );
    });
  }

  Widget _buildLegend(bool isDark, double totalExpense) {
    final categories = widget.expensesByCategory.entries.toList();
    final colors = _getCategoryColors();
    final l10n = AppLocalizations.of(context)!;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(categories.length, (index) {
        final entry = categories[index];
        final percentage = (entry.value / totalExpense) * 100;

        return Padding(
          padding: EdgeInsets.symmetric(vertical: DesignSpacing.xs),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: DesignSpacing.xs + 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _translateCategory(entry.key, l10n),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: primaryText,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  List<Color> _getCategoryColors() {
    return [
      DesignColors.highlightPurple, // Medications
      DesignColors.highlightPink, // Appointments
      DesignColors.highlightYellow, // Food
      DesignColors.highlightTeal, // Other
      DesignColors.highlightBlue,
      DesignColors.highlightCoral,
    ];
  }
}

class MonthlyExpenseChart extends StatefulWidget {
  final Map<String, double> monthlyExpenses;
  final String currencySymbol;

  const MonthlyExpenseChart({
    super.key,
    required this.monthlyExpenses,
    this.currencySymbol = '\$',
  });

  @override
  State<MonthlyExpenseChart> createState() => _MonthlyExpenseChartState();
}

class _MonthlyExpenseChartState extends State<MonthlyExpenseChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;

    if (widget.monthlyExpenses.isEmpty) {
      return Container(
        padding: EdgeInsets.all(DesignSpacing.lg),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.sm,
        ),
        child: Center(
          child: Text(
            'No monthly data available',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: secondaryText,
            ),
          ),
        ),
      );
    }

    final maxExpense = widget.monthlyExpenses.values.reduce(math.max);
    final avgExpense = widget.monthlyExpenses.values.reduce((a, b) => a + b) /
        widget.monthlyExpenses.length;

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
            l10n.monthlyExpenses,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: primaryText,
            ),
          ),
          SizedBox(height: DesignSpacing.sm),
          Row(
            children: [
              _buildStatChip(
                context,
                l10n.average,
                '${widget.currencySymbol}${avgExpense.toStringAsFixed(2)}',
                DesignColors.highlightBlue,
              ),
              SizedBox(width: DesignSpacing.sm),
              _buildStatChip(
                context,
                l10n.highest,
                '${widget.currencySymbol}${maxExpense.toStringAsFixed(2)}',
                DesignColors.highlightCoral,
              ),
            ],
          ),
          SizedBox(height: DesignSpacing.lg),
          SizedBox(
            height: 200,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxExpense * 1.2,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (group) => isDark
                            ? DesignColors.lSurfaces
                            : DesignColors.dSurfaces,
                        tooltipRoundedRadius: 8,
                        tooltipPadding: const EdgeInsets.all(8),
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final monthKey = widget.monthlyExpenses.keys
                              .elementAt(groupIndex);
                          return BarTooltipItem(
                            '$monthKey\n${widget.currencySymbol}${rod.toY.toStringAsFixed(2)}',
                            GoogleFonts.inter(
                              color: isDark
                                  ? DesignColors.lPrimaryText
                                  : DesignColors.dPrimaryText,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >=
                                widget.monthlyExpenses.length) {
                              return const Text('');
                            }
                            final monthKey = widget.monthlyExpenses.keys
                                .elementAt(value.toInt());
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                monthKey,
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: secondaryText,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 50,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              widget.currencySymbol +
                                  value.toStringAsFixed(0),
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                color: secondaryText,
                              ),
                            );
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      // CRITICAL FIX: Prevent zero horizontalInterval
                      // When maxExpense is 0 or very small, interval becomes 0 causing crash
                      horizontalInterval: math.max(1.0, maxExpense / 5),
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: secondaryText.withOpacity(0.2),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: _buildBarGroups(maxExpense, isDark),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(double maxExpense, bool isDark) {
    final entries = widget.monthlyExpenses.entries.toList();
    final successColor = isDark ? DesignColors.dSuccess : DesignColors.lSuccess;
    final dangerColor = isDark ? DesignColors.dDanger : DesignColors.lDanger;

    return List.generate(entries.length, (index) {
      final expense = entries[index].value;
      final animatedValue = expense * _animation.value;

      // Color gradient based on expense level
      final intensity = expense / maxExpense;
      final color = Color.lerp(
        successColor, // Green for low
        dangerColor, // Red for high
        intensity,
      )!;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: animatedValue,
            color: color,
            width: 20,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(4),
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: maxExpense * 1.2,
              color: color.withOpacity(0.1),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildStatChip(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.sm + 4,
        vertical: DesignSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: DesignSpacing.xs),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
