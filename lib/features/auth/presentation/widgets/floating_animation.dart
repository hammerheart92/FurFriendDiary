import 'package:flutter/material.dart';

/// A widget that applies a continuous gentle floating (up/down wave)
/// animation to its [child].
///
/// Uses an [AnimationController] with [Tween<double>] and
/// [Transform.translate] to move the child vertically in a smooth loop.
/// The animation repeats indefinitely with reverse, creating a gentle
/// bobbing motion. [Transform.translate] is used for performance as it
/// operates at the compositor level without triggering relayout.
class FloatingAnimation extends StatefulWidget {
  /// Creates a [FloatingAnimation].
  ///
  /// [child] is the widget to animate.
  /// [offset] controls how many logical pixels the child moves up and down
  /// (defaults to 8.0).
  /// [duration] controls the full cycle time (defaults to 2500ms).
  /// [curve] controls the animation easing (defaults to [Curves.easeInOut]).
  const FloatingAnimation({
    required this.child,
    super.key,
    this.offset = 8.0,
    this.duration,
    this.curve = Curves.easeInOut,
  });

  /// The widget to float.
  final Widget child;

  /// The vertical displacement in logical pixels. Defaults to 8.0.
  final double offset;

  /// Duration of one full up-down cycle. Defaults to 2500 milliseconds.
  final Duration? duration;

  /// The easing curve for the animation. Defaults to [Curves.easeInOut].
  final Curve curve;

  @override
  State<FloatingAnimation> createState() => _FloatingAnimationState();
}

class _FloatingAnimationState extends State<FloatingAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? const Duration(milliseconds: 2500),
    );
    _animation = Tween<double>(
      begin: -widget.offset,
      end: widget.offset,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, _animation.value),
        child: child,
      ),
      child: widget.child,
    );
  }
}
