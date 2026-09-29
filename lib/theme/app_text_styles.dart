import 'package:budgetmanager/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextTheme textTheme(AppThemeColors colors) {
    final nunito = GoogleFonts.nunitoTextTheme();
    final inter = GoogleFonts.interTextTheme();
    final dmMono = GoogleFonts.dmMonoTextTheme();

    return TextTheme(
      displayLarge: dmMono.displayLarge?.copyWith(
        fontSize: 56,
        fontWeight: FontWeight.bold,
        color: colors.onScaffold,
      ),
      headlineLarge: nunito.headlineLarge?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: colors.onScaffold,
      ),
      headlineMedium: nunito.headlineMedium?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: colors.onScaffold,
      ),
      titleLarge: nunito.titleLarge?.copyWith(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: colors.onScaffold,
      ),
      titleMedium: inter.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: colors.onScaffold,
      ),
      bodyLarge: inter.bodyLarge?.copyWith(
        fontSize: 16,
        color: colors.onScaffold,
      ),
      bodyMedium: inter.bodyMedium?.copyWith(
        fontSize: 14,
        color: colors.mutedText,
      ),
      bodySmall: inter.bodySmall?.copyWith(
        fontSize: 13,
        color: colors.mutedTextLight,
      ),
      labelLarge: inter.labelLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: colors.onScaffold,
      ),
      labelMedium: inter.labelMedium?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: colors.mutedTextLight,
      ),
      labelSmall: dmMono.labelSmall?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: colors.onScaffold,
      ),
    );
  }
}

extension AppTextStylesContext on BuildContext {
  TextTheme get appTextStyles => Theme.of(this).textTheme;
}
