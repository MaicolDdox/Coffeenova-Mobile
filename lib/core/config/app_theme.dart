import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.color1,
        primary: AppColors.color1,
        onPrimary: AppColors.color3,
        secondary: AppColors.color2,
        onSecondary: AppColors.color3,
        surface: Colors.white,
        onSurface: AppColors.color3,
      ),
    );

    final textTheme = GoogleFonts.poppinsTextTheme(base.textTheme).apply(
      bodyColor: AppColors.color3,
      displayColor: AppColors.color3,
    );

    return base.copyWith(
      scaffoldBackgroundColor: Colors.white,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.color3,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.color3,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.color1,
          foregroundColor: AppColors.color3,
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          elevation: 1,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.color5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.color5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.color1, width: 1.5),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(color: AppColors.color4),
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.color4.withValues(alpha: 0.7)),
      ),
      chipTheme: base.chipTheme.copyWith(
        labelStyle: textTheme.labelMedium?.copyWith(color: AppColors.color3, fontWeight: FontWeight.w600),
        backgroundColor: AppColors.color2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.color1),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 1,
        shadowColor: AppColors.color1.withValues(alpha: 0.35),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.color5),
        ),
      ),
    );
  }
}
