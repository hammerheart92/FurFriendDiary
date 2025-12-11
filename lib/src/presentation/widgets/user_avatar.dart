import 'package:flutter/material.dart';

/// A circular avatar widget that displays user initials.
///
/// Generates initials from the user's name and displays them
/// in a colored circle. Color is derived from the name hash
/// for consistency.
class UserAvatar extends StatelessWidget {
  final String? name;
  final double radius;
  final TextStyle? textStyle;

  const UserAvatar({
    super.key,
    this.name,
    this.radius = 32,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(name);
    final backgroundColor = _getBackgroundColor(context, name);
    final textColor = _getTextColor(backgroundColor);

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: Text(
        initials,
        style: textStyle ??
            TextStyle(
              fontSize: radius * 0.65,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
      ),
    );
  }

  /// Generate initials from name.
  /// Returns up to 2 characters from first letters of words.
  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'PO'; // Default: Pet Owner
    }

    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length == 1) {
      // Single word: take first 2 characters
      return words[0].substring(0, words[0].length >= 2 ? 2 : 1).toUpperCase();
    }

    // Multiple words: take first character of first two words
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  /// Generate a consistent background color based on the name.
  Color _getBackgroundColor(BuildContext context, String? name) {
    if (name == null || name.trim().isEmpty) {
      return Theme.of(context).colorScheme.primaryContainer;
    }

    // List of pleasant background colors
    final colors = [
      Colors.blue[100]!,
      Colors.green[100]!,
      Colors.orange[100]!,
      Colors.purple[100]!,
      Colors.teal[100]!,
      Colors.pink[100]!,
      Colors.indigo[100]!,
      Colors.cyan[100]!,
    ];

    // Use name hash to pick a consistent color
    final hash = name.hashCode.abs();
    return colors[hash % colors.length];
  }

  /// Get appropriate text color for the background.
  Color _getTextColor(Color backgroundColor) {
    // Calculate luminance to determine if we need dark or light text
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}
