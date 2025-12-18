import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fur_friend_diary/theme/tokens/colors.dart';

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
  )).copyWith(
    datePickerTheme: DatePickerThemeData(
      backgroundColor: DesignColors.lSurfaces,
      headerBackgroundColor: DesignColors.highlightBlue.withOpacity(0.1),
      headerForegroundColor: DesignColors.lPrimaryText,
      dayForegroundColor: WidgetStatePropertyAll(DesignColors.lPrimaryText),
      todayForegroundColor:
          const WidgetStatePropertyAll(DesignColors.highlightBlue),
      todayBackgroundColor: const WidgetStatePropertyAll(Colors.transparent),
      todayBorder: const BorderSide(color: DesignColors.highlightBlue, width: 2),
      dayOverlayColor:
          WidgetStatePropertyAll(DesignColors.highlightBlue.withOpacity(0.1)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      dayStyle: GoogleFonts.inter(fontSize: 14, color: DesignColors.lPrimaryText),
      weekdayStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: DesignColors.lSecondaryText,
      ),
      yearStyle: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: DesignColors.lPrimaryText,
      ),
    ),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: DesignColors.lSurfaces,
      hourMinuteColor: DesignColors.highlightBlue.withOpacity(0.1),
      hourMinuteTextColor: DesignColors.lPrimaryText,
      dialBackgroundColor: DesignColors.highlightBlue.withOpacity(0.05),
      dialHandColor: DesignColors.highlightBlue,
      dialTextColor: DesignColors.lPrimaryText,
      entryModeIconColor: DesignColors.highlightBlue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      hourMinuteShape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

ThemeData darkTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF2AB3A6), // BrandColors.teal
    brightness: Brightness.dark,
  );
  return _baseTheme(scheme.copyWith(
    secondary: const Color(0xFFFF8FA3), // BrandColors.pink
  )).copyWith(
    datePickerTheme: DatePickerThemeData(
      backgroundColor: DesignColors.dSurfaces,
      headerBackgroundColor: DesignColors.highlightBlue.withOpacity(0.15),
      headerForegroundColor: DesignColors.dPrimaryText,
      dayForegroundColor: WidgetStatePropertyAll(DesignColors.dPrimaryText),
      todayForegroundColor:
          const WidgetStatePropertyAll(DesignColors.highlightBlue),
      todayBackgroundColor: const WidgetStatePropertyAll(Colors.transparent),
      todayBorder: const BorderSide(color: DesignColors.highlightBlue, width: 2),
      dayOverlayColor:
          WidgetStatePropertyAll(DesignColors.highlightBlue.withOpacity(0.2)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      dayStyle: GoogleFonts.inter(fontSize: 14, color: DesignColors.dPrimaryText),
      weekdayStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: DesignColors.dSecondaryText,
      ),
      yearStyle: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: DesignColors.dPrimaryText,
      ),
    ),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: DesignColors.dSurfaces,
      hourMinuteColor: DesignColors.highlightBlue.withOpacity(0.2),
      hourMinuteTextColor: DesignColors.dPrimaryText,
      dialBackgroundColor: DesignColors.highlightBlue.withOpacity(0.1),
      dialHandColor: DesignColors.highlightBlue,
      dialTextColor: DesignColors.dPrimaryText,
      entryModeIconColor: DesignColors.highlightBlue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      hourMinuteShape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
