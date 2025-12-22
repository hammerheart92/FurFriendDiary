import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import 'package:fur_friend_diary/l10n/app_localizations.dart';
import 'package:fur_friend_diary/theme/tokens/colors.dart';
import 'package:fur_friend_diary/theme/tokens/spacing.dart';
import 'package:fur_friend_diary/theme/tokens/shadows.dart';

class HealthScoreChart extends StatefulWidget {
  final double score;

  const HealthScoreChart({
    super.key,
    required this.score,
  });

  @override
  State<HealthScoreChart> createState() => _HealthScoreChartState();
}

class _HealthScoreChartState extends State<HealthScoreChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(HealthScoreChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Restart animation if score changes
    if (oldWidget.score != widget.score) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getScoreColor(bool isDark) {
    if (widget.score >= 80) return isDark ? DesignColors.dSuccess : DesignColors.lSuccess;
    if (widget.score >= 60) return DesignColors.highlightYellow;
    if (widget.score >= 40) return DesignColors.highlightCoral;
    return isDark ? DesignColors.dDanger : DesignColors.lDanger;
  }

  String _getScoreLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (widget.score >= 80) return l10n.healthScoreExcellent;
    if (widget.score >= 60) return l10n.healthScoreGood;
    if (widget.score >= 40) return l10n.healthScoreFair;
    return l10n.healthScoreLow;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _getScoreColor(isDark);
    final label = _getScoreLabel(context);
    final l10n = AppLocalizations.of(context)!;
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;
    final surfaceColor = isDark ? DesignColors.dSurfaces : DesignColors.lSurfaces;
    final successColor = isDark ? DesignColors.dSuccess : DesignColors.lSuccess;
    final dangerColor = isDark ? DesignColors.dDanger : DesignColors.lDanger;

    return Container(
      padding: EdgeInsets.all(DesignSpacing.lg),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark ? DesignShadows.darkMd : DesignShadows.md,
      ),
      child: Column(
        children: [
          Text(
            l10n.healthScore,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: primaryText,
            ),
          ),
          SizedBox(height: DesignSpacing.lg),
          SizedBox(
            width: 200,
            height: 200,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                final animatedScore =
                    (widget.score * _animation.value).toStringAsFixed(0);
                return CustomPaint(
                  painter: _CircularProgressPainter(
                    progress: (widget.score / 100) * _animation.value,
                    color: color,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          animatedScore,
                          style: GoogleFonts.poppins(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        Text(
                          label,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: DesignSpacing.lg),
          Wrap(
            spacing: DesignSpacing.md,
            runSpacing: DesignSpacing.sm,
            alignment: WrapAlignment.center,
            children: [
              _buildLegendItem(isDark, l10n.excellentRange, successColor),
              _buildLegendItem(isDark, l10n.goodRange, DesignColors.highlightYellow),
              _buildLegendItem(isDark, l10n.fairRange, DesignColors.highlightCoral),
              _buildLegendItem(isDark, l10n.lowRange, dangerColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(bool isDark, String label, Color color) {
    final primaryText = isDark ? DesignColors.dPrimaryText : DesignColors.lPrimaryText;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: DesignSpacing.sm + 2,
        vertical: DesignSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: DesignSpacing.xs + 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CircularProgressPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    const strokeWidth = 20.0;

    // Background circle
    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, backgroundPaint);

    // Progress arc with gradient effect
    if (progress > 0) {
      final progressPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            color.withOpacity(0.7),
            color,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        -math.pi / 2, // Start from top
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
