import 'package:flutter/material.dart';


ThemeData _baseTheme(ColorScheme scheme) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,

    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      centerTitle: false,
    ),

    cardTheme: CardThemeData(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(16.0),
    ),

    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: scheme.surface,
      selectedItemColor: scheme.primary,
      unselectedItemColor: scheme.onSurface.withValues(alpha: 0.6),
      elevation: 2,
    ),

    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 24.0),
    ),

    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: TextStyle(color: scheme.onInverseSurface),
    ),
  );
}

ThemeData lightTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF2AB3A6), // BrandColors.teal
    brightness: Brightness.light,
  );
  return _baseTheme(scheme.copyWith(
    secondary: const Color(0xFFFF8FA3), // BrandColors.pink
    surface: const Color(0xFFF5EAD1), // BrandColors.cream
    onSurface: const Color(0xFF1C1B1F), // BrandColors.charcoal
  ));
}

ThemeData darkTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF2AB3A6), // BrandColors.teal
    brightness: Brightness.dark,
  );
  return _baseTheme(scheme.copyWith(
    secondary: const Color(0xFFFF8FA3), // BrandColors.pink
  ));
}

