import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
import 'package:fur_friend_diary/theme/tokens/colors.dart';
import 'package:fur_friend_diary/theme/tokens/spacing.dart';
import 'package:fur_friend_diary/theme/tokens/shadows.dart';

class ActivityChart extends StatefulWidget {
  final Map<String, double> activityData;

  const ActivityChart({
    super.key,
    required this.activityData,
  });

  @override
  State<ActivityChart> createState() => _ActivityChartState();
}

class _ActivityChartState extends State<ActivityChart>
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
      curve: Curves.easeOutCubic,
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
    final avgFeedings = widget.activityData['avgFeedings'] ?? 0.0;
    final avgWalks = widget.activityData['avgWalks'] ?? 0.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final feedingsColor = DesignColors.highlightYellow;
    final walksColor = DesignColors.highlightTeal;

    if (avgFeedings == 0 && avgWalks == 0) {
      return Container(
        padding: EdgeInsets.all(DesignSpacing.lg),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.sm,
        ),
        child: Center(
          child: Text(
            l10n.noDataAvailable,
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
            l10n.dailyActivityAverage,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: primaryText,
            ),
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
                    maxY: _getMaxY(avgFeedings, avgWalks),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (group) => isDark
                            ? DesignColors.lSurfaces
                            : DesignColors.dSurfaces,
                        tooltipRoundedRadius: 8,
                        tooltipPadding: const EdgeInsets.all(8),
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final label =
                              groupIndex == 0 ? l10n.feedings : l10n.walks;
                          return BarTooltipItem(
                            '$label\n${rod.toY.toStringAsFixed(1)} ${l10n.perDay}',
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
                          getTitlesWidget: (value, meta) {
                            switch (value.toInt()) {
                              case 0:
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    l10n.feedings,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: primaryText,
                                    ),
                                  ),
                                );
                              case 1:
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    l10n.walks,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: primaryText,
                                    ),
                                  ),
                                );
                              default:
                                return const Text('');
                            }
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toStringAsFixed(1),
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
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: secondaryText.withOpacity(0.2),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      BarChartGroupData(
                        x: 0,
                        barRods: [
                          BarChartRodData(
                            toY: avgFeedings * _animation.value,
                            gradient: LinearGradient(
                              colors: [
                                feedingsColor,
                                feedingsColor.withOpacity(0.7),
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            width: 50,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: _getMaxY(avgFeedings, avgWalks),
                              color: feedingsColor.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 1,
                        barRods: [
                          BarChartRodData(
                            toY: avgWalks * _animation.value,
                            gradient: LinearGradient(
                              colors: [
                                walksColor,
                                walksColor.withOpacity(0.7),
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            width: 50,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: _getMaxY(avgFeedings, avgWalks),
                              color: walksColor.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: DesignSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard(
                isDark,
                l10n.feedingsPerDay,
                avgFeedings.toStringAsFixed(1),
                feedingsColor,
                Icons.restaurant,
              ),
              _buildStatCard(
                isDark,
                l10n.walksPerDay,
                avgWalks.toStringAsFixed(1),
                walksColor,
                Icons.directions_walk,
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _getMaxY(double feedings, double walks) {
    final max = feedings > walks ? feedings : walks;
    if (max == 0) return 5.0;
    return (max * 1.2).ceilToDouble();
  }

  Widget _buildStatCard(
    bool isDark,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    final secondaryText = isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.md,
        vertical: DesignSpacing.sm + 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          SizedBox(height: DesignSpacing.xs),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
