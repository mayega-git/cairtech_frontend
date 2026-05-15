import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Radius tokens (cf Design/styles.css --r-sm/md/lg/xl).
class AppRadius {
  AppRadius._();
  static const double sm = 6;
  static const double md = 10;
  static const double lg = 16;
  static const double xl = 22;
  static const double pill = 999;
}

/// Spacing tokens (multiples de 4).
class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.ink,
        onPrimary: Colors.white,
        secondary: AppColors.accent,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.ink,
        error: AppColors.danger,
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.serif(size: 56),
        displayMedium: AppTypography.serif(size: 44),
        displaySmall: AppTypography.serif(size: 32),
        headlineLarge: AppTypography.serif(size: 28),
        headlineMedium: AppTypography.serif(size: 22, weight: FontWeight.w500),
        titleLarge: AppTypography.sans(size: 17, weight: FontWeight.w600),
        titleMedium: AppTypography.sans(size: 15, weight: FontWeight.w500),
        bodyLarge: AppTypography.sans(size: 14),
        bodyMedium: AppTypography.sans(size: 13),
        bodySmall: AppTypography.sans(size: 12, color: AppColors.muted),
        labelLarge: AppTypography.sans(size: 13, weight: FontWeight.w500),
        labelMedium: AppTypography.mono(size: 11),
        labelSmall: AppTypography.eyebrow(),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bg,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.sans(size: 17, weight: FontWeight.w600),
      ),
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.hair, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        labelStyle: AppTypography.eyebrow(),
        floatingLabelStyle: AppTypography.eyebrow(color: AppColors.ink),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.hair, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.hair, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.ink, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.danger, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.pill)),
          textStyle: AppTypography.sans(
              size: 14, weight: FontWeight.w500, color: Colors.white),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          minimumSize: const Size.fromHeight(48),
          side: const BorderSide(color: AppColors.hair, width: 1),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.pill)),
          textStyle: AppTypography.sans(size: 14, weight: FontWeight.w500),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.hair,
        space: 1,
        thickness: 1,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.ink,
        unselectedItemColor: AppColors.muted2,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle:
            AppTypography.sans(size: 10, weight: FontWeight.w500),
        unselectedLabelStyle:
            AppTypography.sans(size: 10, weight: FontWeight.w500),
      ),
    );
  }
}
