import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _cream = Color(0xFFFAF6F0);
  static const _darkBg = Color(0xFF1A1A1A);
  static const _gold = Color(0xFF8B6914);
  static const _darkGold = Color(0xFFD4A843);

  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: _cream,
        colorScheme: const ColorScheme.light(
          primary: _gold,
          surface: _cream,
        ),
        textTheme: TextTheme(
          headlineMedium: GoogleFonts.nanumMyeongjo(
            fontSize: 22,
            height: 2.0,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF2C2C2C),
          ),
          bodyMedium: GoogleFonts.notoSansKr(
            fontSize: 14,
            height: 1.8,
            color: const Color(0xFF555555),
          ),
          bodySmall: GoogleFonts.notoSansKr(
            fontSize: 12,
            color: const Color(0xFFAAAAAA),
            letterSpacing: 1.2,
          ),
          labelMedium: GoogleFonts.nanumMyeongjo(
            fontSize: 15,
            color: _gold,
            fontWeight: FontWeight.w600,
          ),
        ),
        useMaterial3: true,
      );

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: _darkBg,
        colorScheme: const ColorScheme.dark(
          primary: _darkGold,
          surface: _darkBg,
        ),
        textTheme: TextTheme(
          headlineMedium: GoogleFonts.nanumMyeongjo(
            fontSize: 22,
            height: 2.0,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFEEEEEE),
          ),
          bodyMedium: GoogleFonts.notoSansKr(
            fontSize: 14,
            height: 1.8,
            color: const Color(0xFFAAAAAA),
          ),
          bodySmall: GoogleFonts.notoSansKr(
            fontSize: 12,
            color: const Color(0xFF666666),
            letterSpacing: 1.2,
          ),
          labelMedium: GoogleFonts.nanumMyeongjo(
            fontSize: 15,
            color: _darkGold,
            fontWeight: FontWeight.w600,
          ),
        ),
        useMaterial3: true,
      );
}
