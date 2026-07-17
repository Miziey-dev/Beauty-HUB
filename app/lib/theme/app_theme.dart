import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens.dart';

/// Named text styles built from the type scale in tokens.dart plus the
/// two brand typefaces. Screens/components should reference these (e.g.
/// `Theme.of(context).textTheme.displaySmall`, or `BhTextStyles.display`
/// directly) rather than constructing their own TextStyle.
class BhTextStyles {
  BhTextStyles._();

  static TextStyle get display => GoogleFonts.fraunces(
        fontSize: BhFontSize.display,
        fontWeight: FontWeight.w600,
        color: BhColors.inkPlum,
      );

  static TextStyle get title => GoogleFonts.fraunces(
        fontSize: BhFontSize.title,
        fontWeight: FontWeight.w600,
        color: BhColors.inkPlum,
      );

  static TextStyle get body => GoogleFonts.karla(
        fontSize: BhFontSize.body,
        fontWeight: FontWeight.w400,
        color: BhColors.inkPlum,
      );

  static TextStyle get bodyBold => GoogleFonts.karla(
        fontSize: BhFontSize.body,
        fontWeight: FontWeight.w700,
        color: BhColors.inkPlum,
      );

  static TextStyle get caption => GoogleFonts.karla(
        fontSize: BhFontSize.caption,
        fontWeight: FontWeight.w400,
        color: BhColors.mauve,
      );

  static TextStyle get buttonLabel => GoogleFonts.karla(
        fontSize: BhFontSize.body,
        fontWeight: FontWeight.w800,
        color: BhColors.white,
      );
}

final ThemeData bhTheme = _buildTheme();

ThemeData _buildTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: BhColors.hibiscus,
    brightness: Brightness.light,
    primary: BhColors.hibiscus,
    onPrimary: BhColors.white,
    secondary: BhColors.gold,
    surface: BhColors.white,
    onSurface: BhColors.inkPlum,
    error: BhColors.hibiscus,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: BhColors.porcelain,
    fontFamily: GoogleFonts.karla().fontFamily,
    textTheme: TextTheme(
      displaySmall: BhTextStyles.display,
      titleMedium: BhTextStyles.title,
      bodyMedium: BhTextStyles.body,
      bodyLarge: BhTextStyles.bodyBold,
      labelSmall: BhTextStyles.caption,
      labelLarge: BhTextStyles.buttonLabel,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: BhColors.porcelain,
      foregroundColor: BhColors.inkPlum,
      elevation: 0,
      titleTextStyle: BhTextStyles.title,
    ),
    cardTheme: CardThemeData(
      color: BhColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(BhRadii.card)),
      margin: EdgeInsets.zero,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: BhColors.hibiscus,
        foregroundColor: BhColors.white,
        textStyle: BhTextStyles.buttonLabel,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: BhSpacing.lg),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(BhRadii.button)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: BhColors.inkPlum,
        side: const BorderSide(color: BhColors.line),
        textStyle: BhTextStyles.bodyBold,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: BhSpacing.lg),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(BhRadii.button)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: BhColors.hibiscus,
        textStyle: BhTextStyles.bodyBold,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: BhColors.white,
      selectedColor: BhColors.hibiscusSoft,
      labelStyle: BhTextStyles.bodyBold,
      side: const BorderSide(color: BhColors.line),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(BhRadii.chip)),
      padding: const EdgeInsets.symmetric(horizontal: BhSpacing.sm, vertical: BhSpacing.xs / 2),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: BhColors.white,
      hintStyle: BhTextStyles.body.copyWith(color: BhColors.mauve),
      labelStyle: BhTextStyles.body.copyWith(color: BhColors.mauve),
      contentPadding: const EdgeInsets.symmetric(horizontal: BhSpacing.md, vertical: BhSpacing.sm),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(BhRadii.button),
        borderSide: const BorderSide(color: BhColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(BhRadii.button),
        borderSide: const BorderSide(color: BhColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(BhRadii.button),
        borderSide: const BorderSide(color: BhColors.hibiscus, width: 1.5),
      ),
    ),
    dividerTheme: const DividerThemeData(color: BhColors.line, space: 1),
  );
}
