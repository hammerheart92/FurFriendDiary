import 'package:flutter/material.dart';

/// A reusable text button with a tap scale animation.
///
/// Accepts a generic [child] widget so callers can provide their own
/// [Text], [RichText], or any other content. Scales to 0.95 on press
/// and back to 1.0 on release for tactile feedback.
class AnimatedTextButton extends StatefulWidget {
  /// Creates an [AnimatedTextButton].
  ///
  /// [child] is the widget displayed inside the button area.
  /// [onPressed] is the callback invoked on tap; pass null to disable.
  const AnimatedTextButton({
    required this.child,
    super.key,
    this.onPressed,
  });

  /// The widget displayed inside the button.
  final Widget child;

  /// Called when the button is tapped. Pass null to disable interaction.
  final VoidCallback? onPressed;

  @override
  State<AnimatedTextButton> createState() => _AnimatedTextButtonState();
}

class _AnimatedTextButtonState extends State<AnimatedTextButton> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails _) =>
      setState(() => _isPressed = true);

  void _onTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
    widget.onPressed?.call();
  }

  void _onTapCancel() => setState(() => _isPressed = false);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}
