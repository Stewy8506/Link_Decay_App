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
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: GoogleFonts.inter(
        color: kTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: kSurfaceDark,
      indicatorColor: kAccent.withValues(alpha: 0.15),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return GoogleFonts.inter(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          color: selected ? kAccent : kTextSecondary,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? kAccent : kTextSecondary,
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
        borderSide: const BorderSide(color: kAccent, width: 1.5),
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
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: kSurfaceDark,
      modalBackgroundColor: kSurfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(kRadiusXL)),
      ),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: kAccent,
      thumbColor: kAccent,
      inactiveTrackColor: kBorderDark,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? kAccent : kTextSecondary,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? kAccent.withValues(alpha: 0.3)
            : kBorderDark,
      ),
    ),
  );
}

ThemeData buildLightTheme() {
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: kBackgroundLight,
    colorScheme: const ColorScheme.light(
      surface: kSurfaceLight,
      surfaceContainerHighest: kCardLight,
      primary: kAccent,
      secondary: kAccentMuted,
      outline: kBorderLight,
    ),
    textTheme: GoogleFonts.interTextTheme(base.textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: kBackgroundLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: GoogleFonts.inter(
        color: const Color(0xFF0A0A0B),
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: kSurfaceLight,
      indicatorColor: kAccent.withValues(alpha: 0.1),
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
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: kSurfaceLight,
      modalBackgroundColor: kSurfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(kRadiusXL)),
      ),
    ),
  );
}
