import 'package:flutter/material.dart';

class AppColors {
  // Surfaces & Backgrounds
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFCBD5E1);

  // Brand & Primary
  static const Color navyDark = Color(0xFF0F172A);
  static const Color navyText = Color(0xFF1E293B);
  static const Color navyMuted = Color(0xFF64748B);

  // Teal Accent
  static const Color tealPrimary = Color(0xFF0D9488);
  static const Color tealDark = Color(0xFF0F766E);
  static const Color tealLight = Color(0xFFCCFBF1);
  static const Color tealBorder = Color(0xFF99F6E4);

  // Semantic Status Colors
  static const Color healthyGreen = Color(0xFF16A34A);
  static const Color healthyGreenBg = Color(0xFFDCFCE7);
  static const Color healthyGreenBorder = Color(0xFF86EFAC);

  static const Color warningAmber = Color(0xFFD97706);
  static const Color warningAmberBg = Color(0xFFFEF3C7);
  static const Color warningAmberBorder = Color(0xFFFDE68A);

  static const Color rejectRed = Color(0xFFDC2626);
  static const Color rejectRedBg = Color(0xFFFEE2E2);
  static const Color rejectRedBorder = Color(0xFFFCA5A5);

  static const Color infoBlue = Color(0xFF2563EB);
  static const Color infoBlueBg = Color(0xFFDBEAFE);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.tealPrimary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.tealLight,
        onPrimaryContainer: AppColors.tealDark,
        surface: AppColors.surface,
        onSurface: AppColors.navyText,
        error: AppColors.rejectRed,
        onError: Colors.white,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.navyDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.navyDark,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: AppColors.navyDark),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.tealPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.navyText,
          side: const BorderSide(color: AppColors.borderSubtle),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.tealPrimary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(color: AppColors.navyMuted, fontSize: 14),
        hintStyle: const TextStyle(color: AppColors.navyMuted, fontSize: 14),
      ),
    );
  }
}
