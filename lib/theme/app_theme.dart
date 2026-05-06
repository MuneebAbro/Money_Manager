import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // — Brand Palette —
  static const primaryColor   = Color(0xFF6C63FF); // electric violet
  static const incomeColor    = Color(0xFF00D2A0); // emerald green
  static const expenseColor   = Color(0xFFFF5C7C); // coral red
  static const warningColor   = Color(0xFFFFB547); // amber

  // — Light surface tokens —
  static const lightBg        = Color(0xFFF4F6FF);
  static const lightCard      = Color(0xFFFFFFFF);
  static const lightBorder    = Color(0xFFE8EAFF);

  // — Dark surface tokens —
  static const darkBg         = Color(0xFF0A0E1A);
  static const darkSurface    = Color(0xFF111827);
  static const darkCard       = Color(0xFF161D2F);
  static const darkBorder     = Color(0xFF1E2A45);

  static const cardRadius     = 20.0;
  static const inputRadius    = 14.0;

  // ── LIGHT THEME ──────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
    return base.copyWith(
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary:         primaryColor,
        onPrimary:       Colors.white,
        secondary:       incomeColor,
        onSecondary:     Colors.white,
        error:           expenseColor,
        onError:         Colors.white,
        surface:         lightCard,
        onSurface:       Color(0xFF0D1117),
        surfaceContainerHighest: lightBg,
      ),
      scaffoldBackgroundColor: lightBg,
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displaySmall:  GoogleFonts.inter(fontWeight: FontWeight.w800, letterSpacing: -1.0),
        headlineMedium: GoogleFonts.inter(fontWeight: FontWeight.w700, letterSpacing: -0.5),
        titleLarge:    GoogleFonts.inter(fontWeight: FontWeight.w700, letterSpacing: -0.3, fontSize: 20),
        titleMedium:   GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
        titleSmall:    GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
        bodyLarge:     GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 16),
        bodyMedium:    GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 14, color: Color(0xFF374151)),
        bodySmall:     GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 12, color: Color(0xFF6B7280)),
        labelLarge:    GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
        labelSmall:    GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 11, letterSpacing: 0.5),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: const BorderSide(color: lightBorder, width: 1),
        ),
        color: lightCard,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: GoogleFonts.inter(
          color: const Color(0xFF0D1117),
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: Color(0xFF374151)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF0F2FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: lightBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: expenseColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: expenseColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: GoogleFonts.inter(color: const Color(0xFF6B7280), fontWeight: FontWeight.w500),
        hintStyle: GoogleFonts.inter(color: const Color(0xFF9CA3AF), fontSize: 14),
        prefixIconColor: const Color(0xFF6B7280),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(inputRadius)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(inputRadius)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFEEEFFF),
        selectedColor: primaryColor,
        labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: const DividerThemeData(color: lightBorder, thickness: 1, space: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF0D1117),
        contentTextStyle: GoogleFonts.inter(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  // ── DARK THEME ───────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.dark);
    return base.copyWith(
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary:         primaryColor,
        onPrimary:       Colors.white,
        secondary:       incomeColor,
        onSecondary:     Colors.white,
        error:           expenseColor,
        onError:         Colors.white,
        surface:         darkCard,
        onSurface:       Color(0xFFF9FAFB),
        surfaceContainerHighest: darkSurface,
      ),
      scaffoldBackgroundColor: darkBg,
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displaySmall:   GoogleFonts.inter(fontWeight: FontWeight.w800, letterSpacing: -1.0, color: Colors.white),
        headlineMedium: GoogleFonts.inter(fontWeight: FontWeight.w700, letterSpacing: -0.5, color: Colors.white),
        titleLarge:     GoogleFonts.inter(fontWeight: FontWeight.w700, letterSpacing: -0.3, fontSize: 20, color: Colors.white),
        titleMedium:    GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16, color: Colors.white),
        titleSmall:     GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white),
        bodyLarge:      GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 16, color: Color(0xFFE5E7EB)),
        bodyMedium:     GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 14, color: Color(0xFF9CA3AF)),
        bodySmall:      GoogleFonts.inter(fontWeight: FontWeight.w400, fontSize: 12, color: Color(0xFF6B7280)),
        labelLarge:     GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white),
        labelSmall:     GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 11, letterSpacing: 0.5, color: Color(0xFF9CA3AF)),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
        color: darkCard,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: Color(0xFF9CA3AF)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: darkBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: expenseColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(inputRadius),
          borderSide: const BorderSide(color: expenseColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: GoogleFonts.inter(color: const Color(0xFF6B7280), fontWeight: FontWeight.w500),
        hintStyle: GoogleFonts.inter(color: const Color(0xFF4B5563), fontSize: 14),
        prefixIconColor: const Color(0xFF6B7280),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(inputRadius)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(inputRadius)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkCard,
        selectedColor: primaryColor,
        labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white),
        side: const BorderSide(color: darkBorder, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: const DividerThemeData(color: darkBorder, thickness: 1, space: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkCard,
        contentTextStyle: GoogleFonts.inter(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
