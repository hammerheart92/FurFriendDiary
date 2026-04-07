import 'package:flutter/material.dart';
import 'package:fur_friend_diary/theme/tokens/colors.dart';

/// A reusable icon button with a tap scale animation.
///
/// Scales down to 0.85 on press and back to 1.0 on release, providing
/// tactile feedback. The default icon color adapts to the current theme
/// brightness using [DesignColors] text tokens.
class AnimatedIconButton extends StatefulWidget {
  /// Creates an [AnimatedIconButton].
  ///
  /// [icon] is the icon to display.
  /// [onPressed] is the callback invoked on tap.
  /// [iconColor] overrides the default theme-aware secondary text color.
  /// [size] overrides the default icon size.
  const AnimatedIconButton({
    required this.icon,
    super.key,
    this.onPressed,
    this.iconColor,
    this.size,
  });

  /// The icon data to render.
  final IconData icon;

  /// Called when the button is tapped.
  final VoidCallback? onPressed;

  /// Color of the icon. Falls back to [DesignColors.lSecondaryText] or
  /// [DesignColors.dSecondaryText] depending on brightness.
  final Color? iconColor;

  /// Size of the icon in logical pixels.
  final double? size;

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton> {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = widget.iconColor ??
        (isDark ? DesignColors.dSecondaryText : DesignColors.lSecondaryText);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        child: Icon(
          widget.icon,
          color: color,
          size: widget.size,
        ),
      ),
    );
  }
}
