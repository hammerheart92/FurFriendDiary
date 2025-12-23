import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/tokens/colors.dart';
import '../../theme/tokens/spacing.dart';

/// Centralized SnackBar helper for consistent design token styling
/// across the entire application.
///
/// Usage:
/// ```dart
/// SnackBarHelper.showSuccess(context, 'Item saved successfully!');
/// SnackBarHelper.showError(context, 'Failed to save item');
/// SnackBarHelper.showWarning(context, 'No pet selected');
/// SnackBarHelper.showInfo(context, 'Feature coming soon');
/// ```
class SnackBarHelper {
  SnackBarHelper._();

  static const Duration _defaultDuration = Duration(seconds: 3);
  static const double _borderRadius = 12.0;

  /// Shows a success SnackBar with teal background.
  /// Use for: Created, Added, Saved, Updated, Completed actions.
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = _defaultDuration,
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: DesignColors.highlightTeal,
      textColor: Colors.white,
      duration: duration,
      action: action,
    );
  }

  /// Shows an error SnackBar with danger/red background.
  /// Use for: Failed operations, Invalid input, Permission denied.
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = _defaultDuration,
    SnackBarAction? action,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _showSnackBar(
      context,
      message: message,
      backgroundColor: isDark ? DesignColors.dDanger : DesignColors.lDanger,
      textColor: Colors.white,
      duration: duration,
      action: action,
    );
  }

  /// Shows a warning SnackBar with yellow/amber background.
  /// Use for: No active pet, Low stock, Upcoming deadlines.
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = _defaultDuration,
    SnackBarAction? action,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _showSnackBar(
      context,
      message: message,
      backgroundColor: isDark ? DesignColors.dWarning : DesignColors.lWarning,
      textColor: Colors.black87,
      duration: duration,
      action: action,
    );
  }

  /// Shows an info SnackBar with coral/surface background.
  /// Use for: General information, Feature coming soon, Cancelled actions.
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = _defaultDuration,
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message: message,
      backgroundColor: DesignColors.highlightCoral,
      textColor: Colors.white,
      duration: duration,
      action: action,
    );
  }

  /// Internal method to show a styled SnackBar with design tokens.
  static void _showSnackBar(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required Color textColor,
    required Duration duration,
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        margin: EdgeInsets.all(DesignSpacing.md),
        duration: duration,
        action: action != null
            ? SnackBarAction(
                label: action.label,
                textColor: textColor.withOpacity(0.9),
                onPressed: action.onPressed,
              )
            : null,
      ),
    );
  }

  /// Shows a success SnackBar with an undo action.
  /// Useful for delete operations that can be undone.
  static void showSuccessWithUndo(
    BuildContext context,
    String message, {
    required VoidCallback onUndo,
    Duration duration = const Duration(seconds: 5),
  }) {
    showSuccess(
      context,
      message,
      duration: duration,
      action: SnackBarAction(
        label: 'UNDO',
        textColor: Colors.white,
        onPressed: onUndo,
      ),
    );
  }
}
