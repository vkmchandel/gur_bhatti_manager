import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// High-contrast “Industrial Fintech” theme for outdoor/sunlight readability.
abstract final class AppTheme {
  // Richer Palette
  static const Color primaryGreen = Color(0xFF064E3B); // Deep Emerald
  static const Color accentGold = Color(0xFFF59E0B);   // Jaggery Gold
  static const Color surfaceGray = Color(0xFFF1F5F9);  // Clean Slate
  static const Color cardWhite = Colors.white;
  static const Color textInk = Color(0xFF0F172A);

  static ThemeData get light {
    final colorScheme = ColorScheme.light(
      primary: primaryGreen,
      onPrimary: Colors.white,
      secondary: accentGold,
      onSecondary: Colors.white,
      surface: surfaceGray,
      onSurface: textInk,
      error: const Color(0xFFDC2626),
      surfaceContainerHighest: const Color(0xFFE2E8F0),
    );

    final baseTextTheme = GoogleFonts.interTextTheme();
    final textTheme = baseTextTheme.copyWith(
      headlineLarge: GoogleFonts.outfit(
        fontWeight: FontWeight.w800,
        color: textInk,
        letterSpacing: -1,
      ),
      headlineSmall: GoogleFonts.outfit(
        fontWeight: FontWeight.w700,
        color: textInk,
      ),
      titleLarge: GoogleFonts.outfit(
        fontWeight: FontWeight.w700,
        fontSize: 22,
        color: textInk,
      ),
      titleMedium: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: textInk,
      ),
      labelLarge: GoogleFonts.inter(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: primaryGreen,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: surfaceGray,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: const IconThemeData(color: primaryGreen),
      ),
      cardTheme: CardThemeData(
        color: cardWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: textTheme.labelLarge?.copyWith(color: Colors.white),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: accentGold.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelLarge?.copyWith(fontSize: 12, color: primaryGreen);
          }
          return textTheme.labelLarge?.copyWith(fontSize: 12, color: const Color(0xFF64748B));
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryGreen);
          }
          return const IconThemeData(color: Color(0xFF94A3B8));
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentGold,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
