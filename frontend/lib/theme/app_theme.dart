import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // الألوان الرياضية الفخمة المستوحاة بدقة من تصميم v0 / Lovable
  static const Color background = Color(0xFF0B0F17);
  static const Color surface = Color(0xFF131B2A);
  static const Color surfaceHigher = Color(0xFF182337);
  static const Color surfaceHighlight = Color(0xFF1E2D44);
  static const Color border = Color(0xFF1F2D44);
  static const Color borderLight = Color(0xFF2C3E5B);

  // النيون الليموني / الأخضر الفسفوري الرياضي
  static const Color primaryNeon = Color(0xFFB4F82C);
  static const Color primaryNeonDark = Color(0xFF9DE318);
  static const Color accentCyan = Color(0xFF00E5FF);
  static const Color goldPR = Color(0xFFF59E0B);
  static const Color redDanger = Color(0xFFEF4444);

  // النصوص
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8A9BAE);
  static const Color textMuted = Color(0xFF56677A);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primaryNeon,
      colorScheme: const ColorScheme.dark(
        primary: primaryNeon,
        secondary: accentCyan,
        surface: surface,
        error: redDanger,
      ),
      textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme).copyWith(
        headlineLarge: GoogleFonts.cairo(
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w800,
        ),
        headlineMedium: GoogleFonts.cairo(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: GoogleFonts.cairo(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: GoogleFonts.cairo(
          color: textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: GoogleFonts.cairo(
          color: textSecondary,
          fontSize: 13,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }
}
