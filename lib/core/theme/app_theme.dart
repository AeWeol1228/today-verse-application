import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Sepia + Gold color tokens ──────────────────────────────────
class AppColors {
  // Light
  static const lightBg        = Color(0xFFF0E8D8);
  static const lightBg2       = Color(0xFFE8DEC9);
  static const lightBg3       = Color(0xFFDDD0B4);
  static const lightPaper     = Color(0xFFF7F0E0);
  static const lightTextHi    = Color(0xFF2C2218);
  static const lightTextMid   = Color(0xFF6B5A47);
  static const lightTextLo    = Color(0xFF9C8B72);
  static const lightGold      = Color(0xFF8B6914);
  static const lightGoldSoft  = Color(0xFFB58A2A);
  static const lightLine      = Color(0x245F4114);
  static const lightLineStrong= Color(0x3D5F4114);

  // Dark
  static const darkBg         = Color(0xFF1C1A16);
  static const darkBg2        = Color(0xFF25221C);
  static const darkBg3        = Color(0xFF2F2B23);
  static const darkPaper      = Color(0xFF221F1A);
  static const darkTextHi     = Color(0xFFECE1CA);
  static const darkTextMid    = Color(0xFFA89B82);
  static const darkTextLo     = Color(0xFF6E6452);
  static const darkGold       = Color(0xFFD4A843);
  static const darkGoldSoft   = Color(0xFFC4972F);
  static const darkLine       = Color(0x24D4A843);
  static const darkLineStrong = Color(0x3DD4A843);
}

// ── Runtime token accessor via BuildContext ────────────────────
extension TVTheme on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get tvBg         => isDark ? AppColors.darkBg        : AppColors.lightBg;
  Color get tvBg2        => isDark ? AppColors.darkBg2       : AppColors.lightBg2;
  Color get tvBg3        => isDark ? AppColors.darkBg3       : AppColors.lightBg3;
  Color get tvPaper      => isDark ? AppColors.darkPaper     : AppColors.lightPaper;
  Color get tvTextHi     => isDark ? AppColors.darkTextHi    : AppColors.lightTextHi;
  Color get tvTextMid    => isDark ? AppColors.darkTextMid   : AppColors.lightTextMid;
  Color get tvTextLo     => isDark ? AppColors.darkTextLo    : AppColors.lightTextLo;
  Color get tvGold       => isDark ? AppColors.darkGold      : AppColors.lightGold;
  Color get tvGoldSoft   => isDark ? AppColors.darkGoldSoft  : AppColors.lightGoldSoft;
  Color get tvLine       => isDark ? AppColors.darkLine      : AppColors.lightLine;
  Color get tvLineStrong => isDark ? AppColors.darkLineStrong: AppColors.lightLineStrong;
  Color get tvGoldBg     => tvGold.withValues(alpha: 0.10);
}

// ── ThemeData ──────────────────────────────────────────────────
class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark  => _build(Brightness.dark);

  static ThemeData _build(Brightness b) {
    final dark = b == Brightness.dark;
    final textHi  = dark ? AppColors.darkTextHi  : AppColors.lightTextHi;
    final textMid = dark ? AppColors.darkTextMid  : AppColors.lightTextMid;
    final textLo  = dark ? AppColors.darkTextLo   : AppColors.lightTextLo;
    final gold    = dark ? AppColors.darkGold      : AppColors.lightGold;
    final bg2     = dark ? AppColors.darkBg2       : AppColors.lightBg2;
    final line    = dark ? AppColors.darkLine      : AppColors.lightLine;

    return ThemeData(
      brightness: b,
      scaffoldBackgroundColor: dark ? AppColors.darkBg : AppColors.lightBg,
      colorScheme: ColorScheme(
        brightness: b,
        primary:   gold,
        onPrimary: dark ? AppColors.darkBg : AppColors.lightBg,
        secondary: dark ? AppColors.darkGoldSoft : AppColors.lightGoldSoft,
        onSecondary: textHi,
        surface:   bg2,
        onSurface: textHi,
        error:     const Color(0xFFA04125),
        onError:   Colors.white,
        outline:   line,
      ),
      textTheme: TextTheme(
        // Verse body — 나눔명조 21px / 1.9
        headlineMedium: GoogleFonts.nanumMyeongjo(
          fontSize: 21, height: 1.9,
          fontWeight: FontWeight.w400,
          color: textHi, letterSpacing: -0.1,
        ),
        // Book title — 나눔명조 ExtraBold 44px
        displayMedium: GoogleFonts.nanumMyeongjo(
          fontSize: 44, height: 1.1,
          fontWeight: FontWeight.w800,
          color: textHi, letterSpacing: 0.9,
        ),
        // Cormorant italic subtitle (English / date)
        displaySmall: GoogleFonts.cormorantGaramond(
          fontSize: 22, fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w400,
          color: textMid, letterSpacing: 0.2,
        ),
        // Body description — Noto Sans KR 16px
        bodyMedium: GoogleFonts.notoSansKr(
          fontSize: 16, height: 1.85,
          fontWeight: FontWeight.w400,
          color: textHi,
        ),
        // UI body — Noto Sans KR 15px medium
        bodyLarge: GoogleFonts.notoSansKr(
          fontSize: 15, fontWeight: FontWeight.w500,
          color: textHi,
        ),
        // Meta / caption — Cormorant 12px
        bodySmall: GoogleFonts.cormorantGaramond(
          fontSize: 12, color: textLo, letterSpacing: 0.7,
        ),
        // Reference label — Cormorant gold 14px
        labelMedium: GoogleFonts.cormorantGaramond(
          fontSize: 14, color: gold, letterSpacing: 1.7,
        ),
        // Section header — Noto Sans KR 12px
        labelSmall: GoogleFonts.notoSansKr(
          fontSize: 12, color: textLo,
          fontWeight: FontWeight.w500, letterSpacing: 1.9,
        ),
      ),
      useMaterial3: true,
    );
  }
}
