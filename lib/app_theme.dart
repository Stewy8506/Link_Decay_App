import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'utils/constants.dart';

// ─── Theme Colors Schema ────────────────────────────────────────────────────

class PaletteColors {
  final Color bg;
  final Color surface;
  final Color card;
  final Color border;
  final Color text;
  final Color accent;
  final Color accentMuted;

  const PaletteColors({
    required this.bg,
    required this.surface,
    required this.card,
    required this.border,
    required this.text,
    required this.accent,
    required this.accentMuted,
  });
}

const _darkPalettes = {
  'warm_stone': PaletteColors(
    bg: Color(0xFF0C0C0C),
    surface: Color(0xFF161616),
    card: Color(0xFF1E1E1E),
    border: Color(0xFF2A2A2A),
    text: Color(0xFFEDEDEC),
    accent: Color(0xFFA8A29E),
    accentMuted: Color(0xFF78716C),
  ),
  'cold_slate': PaletteColors(
    bg: Color(0xFF0B0F19),
    surface: Color(0xFF151B26),
    card: Color(0xFF1F2937),
    border: Color(0xFF2D3748),
    text: Color(0xFFF9FAFB),
    accent: Color(0xFF9CA3AF),
    accentMuted: Color(0xFF6B7280),
  ),
  'forest_moss': PaletteColors(
    bg: Color(0xFF090B09),
    surface: Color(0xFF111411),
    card: Color(0xFF181F18),
    border: Color(0xFF232B23),
    text: Color(0xFFE8ECE8),
    accent: Color(0xFF8B9E8B),
    accentMuted: Color(0xFF5E6D5E),
  ),
  'pitch_charcoal': PaletteColors(
    bg: Color(0xFF000000),
    surface: Color(0xFF080808),
    card: Color(0xFF101010),
    border: Color(0xFF1A1A1A),
    text: Color(0xFFF3F3F3),
    accent: Color(0xFF8A8A8A),
    accentMuted: Color(0xFF5A5A5A),
  ),
};

const _lightPalettes = {
  'warm_stone': PaletteColors(
    bg: Color(0xFFFAFAF9),
    surface: Color(0xFFF5F5F4),
    card: Color(0xFFFFFFFF),
    border: Color(0xFFE7E5E4),
    text: Color(0xFF1C1917),
    accent: Color(0xFF78716C),
    accentMuted: Color(0xFFA8A29E),
  ),
  'cold_slate': PaletteColors(
    bg: Color(0xFFF8FAFC),
    surface: Color(0xFFF1F5F9),
    card: Color(0xFFFFFFFF),
    border: Color(0xFFE2E8F0),
    text: Color(0xFF0F172A),
    accent: Color(0xFF64748B),
    accentMuted: Color(0xFF94A3B8),
  ),
  'forest_moss': PaletteColors(
    bg: Color(0xFFF7F9F7),
    surface: Color(0xFFEFF2EF),
    card: Color(0xFFFFFFFF),
    border: Color(0xFFDFE3DF),
    text: Color(0xFF141A14),
    accent: Color(0xFF5D6E5D),
    accentMuted: Color(0xFF889B88),
  ),
  'pitch_charcoal': PaletteColors(
    bg: Color(0xFFFAFAFA),
    surface: Color(0xFFF3F3F3),
    card: Color(0xFFFFFFFF),
    border: Color(0xFFE5E5E5),
    text: Color(0xFF101010),
    accent: Color(0xFF5A5A5A),
    accentMuted: Color(0xFF8A8A8A),
  ),
};

// ─── Theme Customization Helpers ─────────────────────────────────────────────

Color? parseHexColor(String? hex) {
  if (hex == null || hex.isEmpty) return null;
  var hexColor = hex.replaceAll('#', '').toUpperCase();
  if (hexColor.length == 6) {
    hexColor = 'FF$hexColor';
  }
  final value = int.tryParse(hexColor, radix: 16);
  if (value != null) {
    return Color(value);
  }
  return null;
}

TextTheme getTextTheme(String font, TextTheme baseTextTheme) {
  switch (font.toLowerCase()) {
    case 'outfit':
      return GoogleFonts.outfitTextTheme(baseTextTheme);
    case 'playfair':
    case 'playfair display':
      return GoogleFonts.playfairDisplayTextTheme(baseTextTheme);
    case 'jetbrains mono':
    case 'mono':
      return GoogleFonts.jetBrainsMonoTextTheme(baseTextTheme);
    case 'inter':
    default:
      return GoogleFonts.interTextTheme(baseTextTheme);
  }
}

TextStyle getFontTextStyle(
  String font, {
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  double? letterSpacing,
}) {
  switch (font.toLowerCase()) {
    case 'outfit':
      return GoogleFonts.outfit(fontSize: fontSize, fontWeight: fontWeight, color: color, letterSpacing: letterSpacing);
    case 'playfair':
    case 'playfair display':
      return GoogleFonts.playfairDisplay(fontSize: fontSize, fontWeight: fontWeight, color: color, letterSpacing: letterSpacing);
    case 'jetbrains mono':
    case 'mono':
      return GoogleFonts.jetBrainsMono(fontSize: fontSize, fontWeight: fontWeight, color: color, letterSpacing: letterSpacing);
    case 'inter':
    default:
      return GoogleFonts.inter(fontSize: fontSize, fontWeight: fontWeight, color: color, letterSpacing: letterSpacing);
  }
}

TextStyle getTitleStyle(String font, {required Color color}) {
  switch (font.toLowerCase()) {
    case 'outfit':
      return GoogleFonts.outfit(color: color, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.3);
    case 'playfair':
    case 'playfair display':
      return GoogleFonts.playfairDisplay(color: color, fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.3);
    case 'jetbrains mono':
    case 'mono':
      return GoogleFonts.jetBrainsMono(color: color, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.3);
    case 'inter':
    default:
      return GoogleFonts.inter(color: color, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: -0.3);
  }
}

// ─── Theme Builders ─────────────────────────────────────────────────────────

ThemeData buildDarkTheme(
  String paletteName, {
  Color? customAccent,
  Color? customBg,
  String fontFamily = 'inter',
}) {
  final basePalette = _darkPalettes[paletteName] ?? _darkPalettes['warm_stone']!;
  
  // Custom accent / bg override
  final accentColor = customAccent ?? basePalette.accent;
  final accentMutedColor = customAccent != null 
      ? customAccent.withValues(alpha: 0.6) 
      : basePalette.accentMuted;
      
  final bg = customBg ?? basePalette.bg;
  final surface = customBg != null 
      ? Color.alphaBlend(Colors.white.withValues(alpha: 0.05), customBg)
      : basePalette.surface;
  final card = customBg != null 
      ? Color.alphaBlend(Colors.white.withValues(alpha: 0.1), customBg)
      : basePalette.card;
  final border = customBg != null 
      ? Color.alphaBlend(Colors.white.withValues(alpha: 0.18), customBg)
      : basePalette.border;

  final p = PaletteColors(
    bg: bg,
    surface: surface,
    card: card,
    border: border,
    text: basePalette.text,
    accent: accentColor,
    accentMuted: accentMutedColor,
  );

  final base = ThemeData.dark(useMaterial3: true);
  
  return base.copyWith(
    scaffoldBackgroundColor: p.bg,
    cardColor: p.card,
    colorScheme: ColorScheme.dark(
      surface: p.surface,
      surfaceContainerHighest: p.card,
      primary: p.accent,
      secondary: p.accentMuted,
      outline: p.border,
      onSurface: p.text,
      onPrimary: p.bg,
    ),
    textTheme: getTextTheme(fontFamily, base.textTheme).apply(
      bodyColor: p.text,
      displayColor: p.text,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: p.bg,
      foregroundColor: p.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: p.surface,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      titleTextStyle: getTitleStyle(fontFamily, color: p.text),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.surface,
      indicatorColor: p.border,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return getFontTextStyle(
          fontFamily,
          fontSize: 11,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          color: selected ? p.text : p.accentMuted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? p.text : p.accentMuted,
          size: 22,
        );
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadiusMD),
        borderSide: BorderSide(color: p.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadiusMD),
        borderSide: BorderSide(color: p.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadiusMD),
        borderSide: BorderSide(color: p.accent, width: 1.5),
      ),
      hintStyle: getFontTextStyle(fontFamily, color: p.accentMuted, fontSize: 15),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: kSpaceMD,
        vertical: kSpaceMD,
      ),
    ),
    cardTheme: CardThemeData(
      color: p.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadiusMD),
        side: BorderSide(color: p.border, width: 0.5),
      ),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: DividerThemeData(
      color: p.border,
      thickness: 0.5,
      space: 0,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: p.card,
      contentTextStyle: getFontTextStyle(fontFamily, color: p.text, fontSize: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadiusMD),
        side: BorderSide(color: p.border),
      ),
      behavior: SnackBarBehavior.floating,
      actionTextColor: p.text,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.surface,
      modalBackgroundColor: p.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(kRadiusXL)),
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: p.accent,
      thumbColor: p.text,
      inactiveTrackColor: p.border,
      overlayColor: p.accent.withValues(alpha: 0.1),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? p.bg : p.accentMuted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? p.accent.withValues(alpha: 0.5)
            : p.border,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: p.card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadiusLG),
        side: BorderSide(color: p.border, width: 0.5),
      ),
      titleTextStyle: getFontTextStyle(
        fontFamily,
        color: p.text,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: getFontTextStyle(
        fontFamily,
        color: p.text.withValues(alpha: 0.8),
        fontSize: 14,
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: p.card,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadiusMD),
        side: BorderSide(color: p.border, width: 0.5),
      ),
      textStyle: getFontTextStyle(
        fontFamily,
        color: p.text,
        fontSize: 14,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: p.surface,
      disabledColor: p.surface.withValues(alpha: 0.5),
      selectedColor: p.accent,
      secondarySelectedColor: p.accent,
      labelStyle: getFontTextStyle(fontFamily, color: p.text, fontSize: 12),
      secondaryLabelStyle: getFontTextStyle(fontFamily, color: p.bg, fontSize: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: p.border, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: p.accent,
        foregroundColor: p.bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusMD)),
        textStyle: getFontTextStyle(fontFamily, fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: p.accent,
        textStyle: getFontTextStyle(fontFamily, fontWeight: FontWeight.w500, fontSize: 14),
      ),
    ),
  );
}

ThemeData buildLightTheme(
  String paletteName, {
  Color? customAccent,
  Color? customBg,
  String fontFamily = 'inter',
}) {
  final basePalette = _lightPalettes[paletteName] ?? _lightPalettes['warm_stone']!;
  
  // Custom accent / bg override
  final accentColor = customAccent ?? basePalette.accent;
  final accentMutedColor = customAccent != null 
      ? customAccent.withValues(alpha: 0.6) 
      : basePalette.accentMuted;
      
  final bg = customBg ?? basePalette.bg;
  final card = customBg != null ? Colors.white : basePalette.card;
  final surface = customBg != null 
      ? Color.alphaBlend(Colors.black.withValues(alpha: 0.04), customBg)
      : basePalette.surface;
  final border = customBg != null 
      ? Color.alphaBlend(Colors.black.withValues(alpha: 0.08), customBg)
      : basePalette.border;

  final p = PaletteColors(
    bg: bg,
    surface: surface,
    card: card,
    border: border,
    text: basePalette.text,
    accent: accentColor,
    accentMuted: accentMutedColor,
  );

  final base = ThemeData.light(useMaterial3: true);

  return base.copyWith(
    scaffoldBackgroundColor: p.bg,
    cardColor: p.card,
    colorScheme: ColorScheme.light(
      surface: p.surface,
      surfaceContainerHighest: p.card,
      primary: p.accent,
      secondary: p.accentMuted,
      outline: p.border,
      onSurface: p.text,
      onPrimary: p.bg,
    ),
    textTheme: getTextTheme(fontFamily, base.textTheme).apply(
      bodyColor: p.text,
      displayColor: p.text,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: p.bg,
      foregroundColor: p.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: p.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      titleTextStyle: getTitleStyle(fontFamily, color: p.text),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.surface,
      indicatorColor: p.border,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return getFontTextStyle(
          fontFamily,
          fontSize: 11,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          color: selected ? p.text : p.accentMuted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? p.text : p.accentMuted,
          size: 22,
        );
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadiusMD),
        borderSide: BorderSide(color: p.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadiusMD),
        borderSide: BorderSide(color: p.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadiusMD),
        borderSide: BorderSide(color: p.accent, width: 1.5),
      ),
      hintStyle: getFontTextStyle(fontFamily, color: p.accentMuted, fontSize: 15),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: kSpaceMD,
        vertical: kSpaceMD,
      ),
    ),
    cardTheme: CardThemeData(
      color: p.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadiusMD),
        side: BorderSide(color: p.border, width: 0.5),
      ),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: DividerThemeData(
      color: p.border,
      thickness: 0.5,
      space: 0,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: p.card,
      contentTextStyle: getFontTextStyle(fontFamily, color: p.text, fontSize: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadiusMD),
        side: BorderSide(color: p.border),
      ),
      behavior: SnackBarBehavior.floating,
      actionTextColor: p.text,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.surface,
      modalBackgroundColor: p.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(kRadiusXL)),
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: p.accent,
      thumbColor: p.text,
      inactiveTrackColor: p.border,
      overlayColor: p.accent.withValues(alpha: 0.1),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? p.bg : p.accentMuted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? p.text.withValues(alpha: 0.7)
            : p.border,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: p.card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadiusLG),
        side: BorderSide(color: p.border, width: 0.5),
      ),
      titleTextStyle: getFontTextStyle(
        fontFamily,
        color: p.text,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: getFontTextStyle(
        fontFamily,
        color: p.text.withValues(alpha: 0.8),
        fontSize: 14,
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: p.card,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadiusMD),
        side: BorderSide(color: p.border, width: 0.5),
      ),
      textStyle: getFontTextStyle(
        fontFamily,
        color: p.text,
        fontSize: 14,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: p.surface,
      disabledColor: p.surface.withValues(alpha: 0.5),
      selectedColor: p.accent,
      secondarySelectedColor: p.accent,
      labelStyle: getFontTextStyle(fontFamily, color: p.text, fontSize: 12),
      secondaryLabelStyle: getFontTextStyle(fontFamily, color: p.bg, fontSize: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: p.border, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: p.accent,
        foregroundColor: p.bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusMD)),
        textStyle: getFontTextStyle(fontFamily, fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: p.accent,
        textStyle: getFontTextStyle(fontFamily, fontWeight: FontWeight.w500, fontSize: 14),
      ),
    ),
  );
}
