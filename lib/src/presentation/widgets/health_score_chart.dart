import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:fur_friend_diary/l10n/app_localizations.dart';

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

  Color _getScoreColor() {
    if (widget.score >= 80) return const Color(0xFF10B981); // Green - Excellent
    if (widget.score >= 60) return const Color(0xFFF59E0B); // Orange - Good
    if (widget.score >= 40)
      return const Color(0xFFFB923C); // Light Orange - Fair
    return const Color(0xFFEF4444); // Red - Low
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
    final color = _getScoreColor();
    final label = _getScoreLabel(context);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              l10n.healthScore,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
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
                            style: theme.textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          Text(
                            label,
                            style: theme.textTheme.bodyMedium?.copyWith(
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
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildLegendItem(
                    theme, l10n.excellentRange, const Color(0xFF10B981)),
                _buildLegendItem(
                    theme, l10n.goodRange, const Color(0xFFF59E0B)),
                _buildLegendItem(
                    theme, l10n.fairRange, const Color(0xFFFB923C)),
                _buildLegendItem(theme, l10n.lowRange, const Color(0xFFEF4444)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(ThemeData theme, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
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
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
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
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, backgroundPaint);

    // Progress arc with gradient effect
    if (progress > 0) {
      final progressPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            color.withValues(alpha: 0.7),
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
