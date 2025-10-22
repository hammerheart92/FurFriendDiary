import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalExpense =
        widget.expensesByCategory.values.fold(0.0, (a, b) => a + b);

    if (totalExpense == 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No expenses recorded',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expenses by Category',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Total: ${widget.currencySymbol}${totalExpense.toStringAsFixed(2)}',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildLegend(theme, totalExpense),
                  ),
                ],
              ),
            ),
          ],
        ),
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
                      color: Colors.black.withValues(alpha: 0.1),
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

  Widget _buildLegend(ThemeData theme, double totalExpense) {
    final categories = widget.expensesByCategory.entries.toList();
    final colors = _getCategoryColors();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(categories.length, (index) {
        final entry = categories[index];
        final percentage = (entry.value / totalExpense) * 100;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
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
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 10,
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
      const Color(0xFF6366F1), // Indigo - Medications
      const Color(0xFFEC4899), // Pink - Appointments
      const Color(0xFFF59E0B), // Amber - Food
      const Color(0xFF10B981), // Green - Other
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFF06B6D4), // Cyan
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
    final theme = Theme.of(context);

    if (widget.monthlyExpenses.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No monthly data available',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      );
    }

    final maxExpense = widget.monthlyExpenses.values.reduce(math.max);
    final avgExpense = widget.monthlyExpenses.values.reduce((a, b) => a + b) /
        widget.monthlyExpenses.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Expenses',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildStatChip(
                  context,
                  'Average',
                  '${widget.currencySymbol}${avgExpense.toStringAsFixed(2)}',
                  Colors.blue,
                ),
                const SizedBox(width: 8),
                _buildStatChip(
                  context,
                  'Highest',
                  '${widget.currencySymbol}${maxExpense.toStringAsFixed(2)}',
                  Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 24),
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
                          getTooltipColor: (group) =>
                              theme.colorScheme.inverseSurface,
                          tooltipRoundedRadius: 8,
                          tooltipPadding: const EdgeInsets.all(8),
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final monthKey = widget.monthlyExpenses.keys
                                .elementAt(groupIndex);
                            return BarTooltipItem(
                              '$monthKey\n${widget.currencySymbol}${rod.toY.toStringAsFixed(2)}',
                              TextStyle(
                                color: theme.colorScheme.onInverseSurface,
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
                                  style: const TextStyle(fontSize: 10),
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
                                style: const TextStyle(fontSize: 10),
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
                        horizontalInterval: maxExpense / 5,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: theme.colorScheme.outline
                                .withValues(alpha: 0.2),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: _buildBarGroups(maxExpense),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups(double maxExpense) {
    final entries = widget.monthlyExpenses.entries.toList();

    return List.generate(entries.length, (index) {
      final expense = entries[index].value;
      final animatedValue = expense * _animation.value;

      // Color gradient based on expense level
      final intensity = expense / maxExpense;
      final color = Color.lerp(
        const Color(0xFF10B981), // Green for low
        const Color(0xFFEF4444), // Red for high
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
              color: color.withValues(alpha: 0.1),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
