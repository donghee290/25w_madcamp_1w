import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors
          .baseGray, // Assuming Base Gray #3E3E4E is background or similar
      // Wait, scaffold background in main.dart was Color(0xFF2E2E3E).
      // User spec: "base gray color: #3E3E4E", "base black color: #1E1E1E".
      // But MainScreen used 0xFF2E2E3E.
      // Let's check subButtonBorder which is #2E2E3E.
      // User didn't specify a "Background Color" explicitly in the list except "base black".
      // However, usually dark apps use something dark.
      // Figma spec might imply #2E2E3E is the background if it was used before.
      // Let's use AppColors.subButtonBorder (which is #2E2E3E) for scaffold if consistent,
      // Or stick to 0xFF2E2E3E.
      // Actually, spec said "Primary Gradient ends at #3E3E4E".
      // Let's use Color(0xFF2E2E3E) as a constant in AppColors if not present?
      // Ah, subButtonBorder is #2E2E3E.
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(
          0xFF2E2E3E,
        ), // Keeping mostly consistent with previous
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'HYcysM',
          fontSize: 20,
          color: AppColors.baseWhite,
        ),
      ),
      fontFamily: 'HYkanM', // Default font
      colorScheme: const ColorScheme.dark(
        primary: AppColors.baseYellow,
        secondary: AppColors.baseBlue,
        surface: AppColors.baseGray,
        error: AppColors.baseRed,
        onPrimary: AppColors.baseBlue, // Text on Yellow is Blue
        onSecondary: AppColors.baseWhite,
        onSurface: AppColors.baseWhite,
        onError: AppColors.baseWhite,
      ),
      // Defined text styles if needed
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: AppColors.baseWhite, fontFamily: 'HYkanM'),
        titleLarge: TextStyle(color: AppColors.baseWhite, fontFamily: 'HYcysM'),
        titleMedium: TextStyle(
          color: AppColors.baseWhite,
          fontFamily: 'HYkanB',
        ),
      ),
    );
  }
}
