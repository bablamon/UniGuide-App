import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Brand colors ─────────────────────────────────────────────────────────
  static const Color accent = Color(0xFFE8440A);
  static const Color accentLight = Color(0xFFFDE8E0);
  static const Color accentDark = Color(0xFFC03008);
  static const Color green = Color(0xFF2A9D6E);
  static const Color greenLight = Color(0xFFE0F5EC);
  static const Color greenDark = Color(0xFF0F6E56);

  // ── Light mode static colors (used by all existing screens) ──────────────
  static const Color bg = Color(0xFFF5F3EE);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color bgSurface = Color(0xFFF0EDE8);
  static const Color bgDark = Color(0xFF1A1A1A);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF888888);
  static const Color textHint = Color(0xFFBBBBBB);
  static const Color border = Color(0xFFE0DDD8);
  static const Color borderStrong = Color(0xFFD0CEC8);

  // ── Dark mode static colors ───────────────────────────────────────────────
  static const Color bgDarkMode = Color(0xFF0D0D0D);
  static const Color bgCardDark = Color(0xFF1A1A1A);
  static const Color bgSurfaceDark = Color(0xFF232323);
  static const Color textPrimaryDark = Color(0xFFF0EDE8);
  static const Color textSecondaryDark = Color(0xFF8A8A8A);
  static const Color textHintDark = Color(0xFF4A4A4A);
  static const Color borderDark = Color(0xFF282828);
  static const Color borderLight = Color(0xFFE0DDD8);

  // ── Themes ────────────────────────────────────────────────────────────────
  // static final — computed once per app lifetime, not rebuilt on every MaterialApp access.
  static final ThemeData light = _build(Brightness.light);
  static final ThemeData dark = _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final bgColor      = isDark ? bgDarkMode   : bg;
    final cardColor    = isDark ? bgCardDark   : bgCard;
    final inputFill    = isDark ? bgSurfaceDark : bgCard;

    final primaryText  = isDark ? textPrimaryDark  : textPrimary;
    final hintColor    = isDark ? textHintDark : textHint;
    final borderColor  = isDark ? borderDark   : border;
    final darkBg       = isDark ? const Color(0xFF2A2A2A) : bgDark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bgColor,
      textTheme: GoogleFonts.dmSansTextTheme(
        ThemeData(brightness: brightness).textTheme,
      ),
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: accent,
        secondary: green,
        surface: cardColor,
        error: const Color(0xFFE24B4A),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: primaryText,
        onError: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: primaryText),
        titleTextStyle: TextStyle(
          color: primaryText,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: borderColor, width: isDark ? 0.75 : 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        hintStyle: TextStyle(color: hintColor, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: borderColor, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: borderColor, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: accent, width: isDark ? 1.0 : 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0xFFE24B4A), width: 1),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0xFFE24B4A), width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cardColor,
        selectedColor: darkBg,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: primaryText,
        ),
        secondaryLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        side: BorderSide(color: borderColor, width: 0.5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardColor,
        selectedItemColor: accent,
        unselectedItemColor: hintColor,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
      ),
      dividerTheme: DividerThemeData(color: borderColor, thickness: 0.5, space: 0),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkBg,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 13),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// Text styles — color intentionally omitted so they inherit from theme
class AppText {
  static const TextStyle h1 = TextStyle(fontSize: 28, fontWeight: FontWeight.w700, height: 1.2);
  static const TextStyle h2 = TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.2);
  static const TextStyle h3 = TextStyle(fontSize: 17, fontWeight: FontWeight.w600);
  static const TextStyle body = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.6);
  static const TextStyle bodySmall = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.5);
  static const TextStyle label = TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.4);
  static const TextStyle caption = TextStyle(fontSize: 10, fontWeight: FontWeight.w500);
}