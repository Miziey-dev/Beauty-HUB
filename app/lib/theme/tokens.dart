import 'package:flutter/material.dart';

/// Raw design-system constants. Every color, text style, radius, spacing
/// value, shadow, and duration used anywhere in the app should trace back
/// to a constant defined here -- nothing in theme/ or screens/ should
/// contain a literal Color(0x...) or TextStyle outside this file.
class BhColors {
  BhColors._();

  static const inkPlum = Color(0xFF2B1B2C);
  static const porcelain = Color(0xFFFFF8F3);
  static const hibiscus = Color(0xFFD6386B);
  static const hibiscusSoft = Color(0xFFFBE9F0);
  static const gold = Color(0xFFD9A441);
  static const confirmGreen = Color(0xFF2E9E6B);
  static const mauve = Color(0xFF8A7480);
  static const line = Color(0xFFF0E4E9);
  static const white = Color(0xFFFFFFFF);
}

class BhSpacing {
  BhSpacing._();

  /// Base spacing unit -- every gap/padding in the app should be a
  /// multiple of this.
  static const unit = 4.0;

  static const xs = unit * 2; // 8
  static const sm = unit * 3; // 12
  static const md = unit * 4; // 16
  static const lg = unit * 6; // 24
  static const xl = unit * 8; // 32

  /// Standard horizontal screen padding.
  static const screenHorizontal = md;
}

class BhRadii {
  BhRadii._();

  static const card = 18.0;
  static const button = 14.0;
  static const chip = 999.0; // pill
  static const imageTile = 14.0;
}

class BhShadows {
  BhShadows._();

  /// Soft card shadow: blur 14, ~7% inkPlum.
  static List<BoxShadow> get card => [
        BoxShadow(
          color: BhColors.inkPlum.withValues(alpha: 0.07),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ];

  /// Subtle glow under primary (hibiscus) buttons.
  static List<BoxShadow> get primaryButtonGlow => [
        BoxShadow(
          color: BhColors.hibiscus.withValues(alpha: 0.28),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];
}

class BhDurations {
  BhDurations._();

  static const fast = Duration(milliseconds: 120);
  static const medium = Duration(milliseconds: 220);
  static const slow = Duration(milliseconds: 360);
}

/// Type scale (sizes only -- font family/weight live in [BhTextStyles],
/// which needs a BuildContext-free GoogleFonts call and so lives in
/// app_theme.dart instead of here).
class BhFontSize {
  BhFontSize._();

  static const display = 26.0;
  static const title = 19.0;
  static const body = 13.5;
  static const caption = 11.5;
}
