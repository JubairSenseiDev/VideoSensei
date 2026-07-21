import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// VideoSensei design tokens — extracted from jubairsensei.com (2026-07-21).
/// Full reference: THEME.md
abstract class AppColors {
  // ── Dark palette ──────────────────────────────────────────────────────────
  static const darkBg = Color(0xFF0A0A0B);
  static const darkSurface = Color(0xFF141415);
  static const darkSurfaceVariant = Color(0xFF1C1C1E);
  static const darkBorder = Color(0xFF2A2A2E);

  // Accent — signature neon green
  static const accentGreen = Color(0xFF00FF88);
  static const accentGreenDim = Color(0xFF00CC6E);
  static const accentGreenMuted = Color(0x3300FF88); // 20% opacity

  // Preset badge colours (dark)
  static const presetLiteCyan = Color(0xFF22D3EE);
  static const presetBalancedGreen = Color(0xFF00FF88);
  static const presetCrystalBlue = Color(0xFF3B82F6);
  static const presetSenseiPurple = Color(0xFFA855F7);

  // Text
  static const darkTextPrimary = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0xFFA1A1AA);
  static const darkTextMuted = Color(0xFF52525B);

  // ── Light palette ─────────────────────────────────────────────────────────
  static const lightBg = Color(0xFFF0F0EC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceVariant = Color(0xFFF4F4F0);
  static const lightBorder = Color(0xFFE4E4E0);
  static const accentForestGreen = Color(0xFF008246);
  static const lightTextPrimary = Color(0xFF1E1914);
  static const lightTextSecondary = Color(0xFF57534E);
  static const lightTextMuted = Color(0xFFA8A29E);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const success = Color(0xFF00FF88);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);
}

abstract class AppTypography {
  static TextTheme _buildTextTheme({required bool dark}) {
    final color = dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondary = dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return TextTheme(
      // Display — Cabinet Grotesk
      displayLarge: _cabinet(size: 57, weight: FontWeight.w800, color: color),
      displayMedium: _cabinet(size: 45, weight: FontWeight.w700, color: color),
      displaySmall: _cabinet(size: 36, weight: FontWeight.w700, color: color),
      // Headline — Cabinet Grotesk
      headlineLarge: _cabinet(size: 32, weight: FontWeight.w700, color: color),
      headlineMedium: _cabinet(size: 28, weight: FontWeight.w700, color: color),
      headlineSmall: _cabinet(size: 24, weight: FontWeight.w600, color: color),
      // Title — Satoshi
      titleLarge: _satoshi(size: 22, weight: FontWeight.w600, color: color),
      titleMedium: _satoshi(size: 16, weight: FontWeight.w600, color: color),
      titleSmall: _satoshi(size: 14, weight: FontWeight.w500, color: color),
      // Body — Satoshi
      bodyLarge: _satoshi(size: 16, weight: FontWeight.w400, color: color),
      bodyMedium: _satoshi(size: 14, weight: FontWeight.w400, color: color),
      bodySmall: _satoshi(size: 12, weight: FontWeight.w400, color: secondary),
      // Label — JetBrains Mono (numbers, stats)
      labelLarge: _mono(size: 14, weight: FontWeight.w500, color: color),
      labelMedium: _mono(size: 12, weight: FontWeight.w500, color: color),
      labelSmall: _mono(size: 11, weight: FontWeight.w400, color: secondary),
    );
  }

  static TextStyle _cabinet({
    required double size,
    required FontWeight weight,
    required Color color,
  }) =>
      GoogleFonts.getFont(
        'Cabinet Grotesk',
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: -0.5,
      );

  static TextStyle _satoshi({
    required double size,
    required FontWeight weight,
    required Color color,
  }) =>
      GoogleFonts.getFont(
        'Satoshi',
        fontSize: size,
        fontWeight: weight,
        color: color,
      );

  static TextStyle _mono({
    required double size,
    required FontWeight weight,
    required Color color,
  }) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        fontWeight: weight,
        color: color,
      );

  static TextTheme dark() => _buildTextTheme(dark: true);
  static TextTheme light() => _buildTextTheme(dark: false);
}

abstract class AppTheme {
  static ThemeData dark() {
    final cs = ColorScheme.fromSeed(
      seedColor: AppColors.accentGreen,
      brightness: Brightness.dark,
    ).copyWith(
      surface: AppColors.darkBg,
      onSurface: AppColors.darkTextPrimary,
      primary: AppColors.accentGreen,
      onPrimary: AppColors.darkBg,
      secondary: AppColors.presetCrystalBlue,
      onSecondary: AppColors.darkTextPrimary,
      surfaceContainerHighest: AppColors.darkSurfaceVariant,
      outline: AppColors.darkBorder,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: AppColors.darkBg,
      textTheme: AppTypography.dark(),
      cardTheme: CardTheme(
        color: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        elevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accentGreen,
          foregroundColor: AppColors.darkBg,
          textStyle: AppTypography.dark().labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accentGreen,
          side: const BorderSide(color: AppColors.darkBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size(double.infinity, 52),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentGreen, width: 2),
        ),
        labelStyle: TextStyle(color: AppColors.darkTextSecondary),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTypography.dark().headlineSmall,
        iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.accentGreen,
        unselectedItemColor: AppColors.darkTextMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkSurfaceVariant,
        contentTextStyle: AppTypography.dark().bodyMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData light() {
    final cs = ColorScheme.fromSeed(
      seedColor: AppColors.accentForestGreen,
      brightness: Brightness.light,
    ).copyWith(
      surface: AppColors.lightBg,
      onSurface: AppColors.lightTextPrimary,
      primary: AppColors.accentForestGreen,
      onPrimary: Colors.white,
      secondary: AppColors.presetCrystalBlue,
      onSecondary: Colors.white,
      surfaceContainerHighest: AppColors.lightSurfaceVariant,
      outline: AppColors.lightBorder,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: AppColors.lightBg,
      textTheme: AppTypography.light(),
      cardTheme: CardTheme(
        color: AppColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        elevation: 0,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTypography.light().headlineSmall,
        iconTheme: const IconThemeData(color: AppColors.lightTextPrimary),
      ),
    );
  }
}
