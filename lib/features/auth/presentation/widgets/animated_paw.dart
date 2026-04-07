import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fur_friend_diary/theme/tokens/colors.dart';

/// A decorative animated paw print widget used as background decoration
/// on the Sign Up screen.
///
/// Renders a [FontAwesomeIcons.paw] icon with an entrance animation that
/// fades in and scales up using [Curves.elasticOut]. An optional [delay]
/// allows staggered appearances when multiple paws are placed together.
/// A static rotation is applied via [rotationDegrees].
class AnimatedPaw extends StatefulWidget {
  /// Creates an [AnimatedPaw].
  ///
  /// [size] controls the icon size in logical pixels.
  /// [color] overrides the default semi-transparent highlight blue.
  /// [rotationDegrees] applies a static rotation (converted to radians
  /// internally).
  /// [delay] postpones the start of the entrance animation for staggering.
  const AnimatedPaw({
    required this.size,
    super.key,
    this.color,
    this.rotationDegrees = 0,
    this.delay,
  });

  /// Size of the paw icon in logical pixels.
  final double size;

  /// Color of the paw icon. Defaults to
  /// [DesignColors.highlightBlue] at 30% opacity.
  final Color? color;

  /// Rotation angle in degrees. Converted to radians internally.
  final double rotationDegrees;

  /// Optional delay before the entrance animation starts, enabling
  /// staggered appearances of multiple paws.
  final Duration? delay;

  @override
  State<AnimatedPaw> createState() => _AnimatedPawState();
}

class _AnimatedPawState extends State<AnimatedPaw>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _opacity = Tween<double>(begin: 0, end: 1).animate(curved);
    _scale = Tween<double>(begin: 0.3, end: 1.0).animate(curved);

    if (widget.delay != null) {
      Future.delayed(widget.delay!, () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color =
        widget.color ?? DesignColors.highlightBlue.withOpacity(0.3);
    final radians = widget.rotationDegrees * math.pi / 180;

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Opacity(
        opacity: _opacity.value.clamp(0.0, 1.0),
        child: Transform.rotate(
          angle: radians,
          child: Transform.scale(
            scale: _scale.value,
            child: FaIcon(
              FontAwesomeIcons.paw,
              size: widget.size,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
