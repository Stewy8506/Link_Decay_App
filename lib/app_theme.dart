import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'utils/constants.dart';

// ─── Theme ─────────────────────────────────────────────────────────────────

ThemeData buildDarkTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: kBackgroundDark,
    colorScheme: const ColorScheme.dark(
      surface: kSurfaceDark,
      surfaceContainerHighest: kCardDark,
      primary: kAccent,
      secondary: kAccentMuted,
      outline: kBorderDark,
      onSurface: kTextPrimary,
      onPrimary: kBackgroundDark,
    ),
    textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: kTextPrimary,
      displayColor: kTextPrimary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: kBackgroundDark,
      foregroundColor: kTextPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: kSurfaceDark,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      titleTextStyle: GoogleFonts.inter(
        color: kTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: kSurfaceDark,
      // Subtle neutral indicator: no color, just a slightly lighter background
      indicatorColor: kBorderDark,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return GoogleFonts.inter(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          color: selected ? kTextPrimary : kTextTertiary,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? kTextPrimary : kTextTertiary,
          size: 22,
        );
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kCardDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadiusMD),
        borderSide: const BorderSide(color: kBorderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadiusMD),
        borderSide: const BorderSide(color: kBorderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadiusMD),
        // Neutral focus: slightly brighter border, no accent color
        borderSide: const BorderSide(color: kTextSecondary, width: 1.5),
      ),
      hintStyle: GoogleFonts.inter(color: kTextTertiary, fontSize: 15),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: kSpaceMD,
        vertical: kSpaceMD,
      ),
    ),
    cardTheme: CardThemeData(
      color: kCardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadiusMD),
        side: const BorderSide(color: kBorderDark, width: 0.5),
      ),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: const DividerThemeData(
      color: kBorderDark,
      thickness: 0.5,
      space: 0,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: kCardDark,
      contentTextStyle: GoogleFonts.inter(color: kTextPrimary, fontSize: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadiusMD),
        side: const BorderSide(color: kBorderDark),
      ),
      behavior: SnackBarBehavior.floating,
      actionTextColor: kTextPrimary,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: kSurfaceDark,
      modalBackgroundColor: kSurfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(kRadiusXL)),
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: kAccent,
      thumbColor: kTextPrimary,
      inactiveTrackColor: kBorderDark,
      overlayColor: kAccent.withValues(alpha: 0.1),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? kTextPrimary : kTextTertiary,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? kAccent.withValues(alpha: 0.5)
            : kBorderDark,
      ),
    ),
  );
}

ThemeData buildLightTheme() {
  final base = ThemeData.light(useMaterial3: true);
  const onBackground = Color(0xFF1C1917); // Stone-900
  const textSecondary = Color(0xFF78716C); // Stone-500
  const textTertiary = Color(0xFFD6D3D1); // Stone-300

  return base.copyWith(
    scaffoldBackgroundColor: kBackgroundLight,
    colorScheme: const ColorScheme.light(
      surface: kSurfaceLight,
      surfaceContainerHighest: kCardLight,
      primary: Color(0xFF78716C),   // Stone-500 as accent in light
      secondary: Color(0xFFA8A29E), // Stone-400
      outline: kBorderLight,
      onSurface: onBackground,
      onPrimary: Color(0xFFFAFAF9),
    ),
    textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: onBackground,
      displayColor: onBackground,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: kBackgroundLight,
      foregroundColor: onBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: kSurfaceLight,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      titleTextStyle: GoogleFonts.inter(
        color: onBackground,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: kSurfaceLight,
      indicatorColor: kBorderLight,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return GoogleFonts.inter(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          color: selected ? onBackground : textSecondary,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? onBackground : textSecondary,
          size: 22,
        );
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kCardLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadiusMD),
        borderSide: const BorderSide(color: kBorderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadiusMD),
        borderSide: const BorderSide(color: kBorderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadiusMD),
        borderSide: const BorderSide(color: textSecondary, width: 1.5),
      ),
      hintStyle: GoogleFonts.inter(color: textTertiary, fontSize: 15),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: kSpaceMD,
        vertical: kSpaceMD,
      ),
    ),
    cardTheme: CardThemeData(
      color: kCardLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadiusMD),
        side: const BorderSide(color: kBorderLight, width: 0.5),
      ),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: const DividerThemeData(
      color: kBorderLight,
      thickness: 0.5,
      space: 0,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: kCardLight,
      contentTextStyle: GoogleFonts.inter(color: onBackground, fontSize: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadiusMD),
        side: const BorderSide(color: kBorderLight),
      ),
      behavior: SnackBarBehavior.floating,
      actionTextColor: onBackground,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: kSurfaceLight,
      modalBackgroundColor: kSurfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(kRadiusXL)),
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: textSecondary,
      thumbColor: onBackground,
      inactiveTrackColor: textTertiary,
      overlayColor: textSecondary.withValues(alpha: 0.1),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? kBackgroundLight : textSecondary,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? onBackground.withValues(alpha: 0.7)
            : textTertiary,
      ),
    ),
  );
}
