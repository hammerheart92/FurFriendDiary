import 'package:flutter/material.dart';
import 'package:fur_friend_diary/theme/tokens/colors.dart';
import 'package:fur_friend_diary/theme/tokens/shadows.dart';
import 'package:fur_friend_diary/theme/tokens/spacing.dart';

/// A reusable elevated button with a press animation (scale down on tap,
/// scale back on release).
///
/// Accepts a generic [child] widget so callers can pass icon+text rows,
/// rich layouts, or any other content. The button applies a colored shadow
/// from [DesignShadows] and disables visually when [onPressed] is null.
class AnimatedElevatedButton extends StatefulWidget {
  /// Creates an [AnimatedElevatedButton].
  ///
  /// [child] is the content displayed inside the button.
  /// [onPressed] is the callback invoked on tap; pass null to disable.
  /// [backgroundColor] overrides the default [DesignColors.highlightBlue].
  /// [size] overrides the default full-width, vertically padded sizing.
  const AnimatedElevatedButton({
    required this.child,
    super.key,
    this.onPressed,
    this.backgroundColor,
    this.size,
  });

  /// The widget displayed inside the button.
  final Widget child;

  /// Called when the button is tapped. Pass null to disable the button.
  final VoidCallback? onPressed;

  /// Background color of the button. Defaults to [DesignColors.highlightBlue].
  final Color? backgroundColor;

  /// Optional fixed size for the button. When null the button stretches to
  /// full width with vertical padding of [DesignSpacing.md].
  final Size? size;

  @override
  State<AnimatedElevatedButton> createState() =>
      _AnimatedElevatedButtonState();
}

class _AnimatedElevatedButtonState extends State<AnimatedElevatedButton> {
  bool _isPressed = false;

  bool get _isEnabled => widget.onPressed != null;

  void _onTapDown(TapDownDetails _) {
    if (!_isEnabled) return;
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails _) {
    if (!_isEnabled) return;
    setState(() => _isPressed = false);
    widget.onPressed?.call();
  }

  void _onTapCancel() {
    if (!_isEnabled) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = _isEnabled
        ? (widget.backgroundColor ?? DesignColors.highlightBlue)
        : (isDark ? DesignColors.dDisabled : DesignColors.lDisabled);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: Container(
          width: widget.size?.width ?? double.infinity,
          height: widget.size?.height,
          padding: widget.size != null
              ? null
              : const EdgeInsets.symmetric(vertical: DesignSpacing.md),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(DesignSpacing.md),
            boxShadow:
                _isEnabled ? DesignShadows.primary(bg) : DesignShadows.none,
          ),
          alignment: Alignment.center,
          child: widget.child,
        ),
      ),
    );
  }
}
