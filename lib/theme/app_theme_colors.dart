import 'package:flutter/material.dart';

@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors({
    required this.scaffoldBackground,
    required this.primaryAction,
    required this.primaryActionForeground,
    required this.primaryLight,
    required this.accent,
    required this.accentForeground,
    required this.border,
    required this.borderMuted,
    required this.navLive,
    required this.navHistory,
    required this.navSettings,
    required this.navAi,
    required this.budgetUsed,
    required this.budgetRemaining,
    required this.success,
    required this.warning,
    required this.warningBackground,
    required this.error,
    required this.errorBackground,
    required this.mutedText,
    required this.mutedTextLight,
    required this.progressUsed,
    required this.progressEmpty,
    required this.surface,
    required this.surfaceSecondary,
    required this.switchInactive,
    required this.aiAccent,
    required this.aiBackground,
    required this.backButtonBackground,
    required this.onScaffold,
  });

  final Color scaffoldBackground;
  final Color primaryAction;
  final Color primaryActionForeground;
  final Color primaryLight;
  final Color accent;
  final Color accentForeground;
  final Color border;
  final Color borderMuted;
  final Color navLive;
  final Color navHistory;
  final Color navSettings;
  final Color navAi;
  final Color budgetUsed;
  final Color budgetRemaining;
  final Color success;
  final Color warning;
  final Color warningBackground;
  final Color error;
  final Color errorBackground;
  final Color mutedText;
  final Color mutedTextLight;
  final Color progressUsed;
  final Color progressEmpty;
  final Color surface;
  final Color surfaceSecondary;
  final Color switchInactive;
  final Color aiAccent;
  final Color aiBackground;
  final Color backButtonBackground;
  final Color onScaffold;

  /// Progress pill fill color based on usage percentage.
  Color progressFillFor(double used, double max) {
    if (max <= 0) return mutedTextLight;
    final ratio = used / max;
    if (used <= 0) return mutedTextLight;
    if (ratio > 1) return error;
    if (ratio >= 1) return success;
    if (ratio >= 0.5) return aiAccent;
    return budgetUsed;
  }

  @override
  AppThemeColors copyWith({
    Color? scaffoldBackground,
    Color? primaryAction,
    Color? primaryActionForeground,
    Color? primaryLight,
    Color? accent,
    Color? accentForeground,
    Color? border,
    Color? borderMuted,
    Color? navLive,
    Color? navHistory,
    Color? navSettings,
    Color? navAi,
    Color? budgetUsed,
    Color? budgetRemaining,
    Color? success,
    Color? warning,
    Color? warningBackground,
    Color? error,
    Color? errorBackground,
    Color? mutedText,
    Color? mutedTextLight,
    Color? progressUsed,
    Color? progressEmpty,
    Color? surface,
    Color? surfaceSecondary,
    Color? switchInactive,
    Color? aiAccent,
    Color? aiBackground,
    Color? backButtonBackground,
    Color? onScaffold,
  }) {
    return AppThemeColors(
      scaffoldBackground: scaffoldBackground ?? this.scaffoldBackground,
      primaryAction: primaryAction ?? this.primaryAction,
      primaryActionForeground:
          primaryActionForeground ?? this.primaryActionForeground,
      primaryLight: primaryLight ?? this.primaryLight,
      accent: accent ?? this.accent,
      accentForeground: accentForeground ?? this.accentForeground,
      border: border ?? this.border,
      borderMuted: borderMuted ?? this.borderMuted,
      navLive: navLive ?? this.navLive,
      navHistory: navHistory ?? this.navHistory,
      navSettings: navSettings ?? this.navSettings,
      navAi: navAi ?? this.navAi,
      budgetUsed: budgetUsed ?? this.budgetUsed,
      budgetRemaining: budgetRemaining ?? this.budgetRemaining,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      warningBackground: warningBackground ?? this.warningBackground,
      error: error ?? this.error,
      errorBackground: errorBackground ?? this.errorBackground,
      mutedText: mutedText ?? this.mutedText,
      mutedTextLight: mutedTextLight ?? this.mutedTextLight,
      progressUsed: progressUsed ?? this.progressUsed,
      progressEmpty: progressEmpty ?? this.progressEmpty,
      surface: surface ?? this.surface,
      surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
      switchInactive: switchInactive ?? this.switchInactive,
      aiAccent: aiAccent ?? this.aiAccent,
      aiBackground: aiBackground ?? this.aiBackground,
      backButtonBackground:
          backButtonBackground ?? this.backButtonBackground,
      onScaffold: onScaffold ?? this.onScaffold,
    );
  }

  @override
  AppThemeColors lerp(AppThemeColors? other, double t) {
    if (other == null) return this;
    return AppThemeColors(
      scaffoldBackground:
          Color.lerp(scaffoldBackground, other.scaffoldBackground, t)!,
      primaryAction: Color.lerp(primaryAction, other.primaryAction, t)!,
      primaryActionForeground: Color.lerp(
          primaryActionForeground, other.primaryActionForeground, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentForeground:
          Color.lerp(accentForeground, other.accentForeground, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderMuted: Color.lerp(borderMuted, other.borderMuted, t)!,
      navLive: Color.lerp(navLive, other.navLive, t)!,
      navHistory: Color.lerp(navHistory, other.navHistory, t)!,
      navSettings: Color.lerp(navSettings, other.navSettings, t)!,
      navAi: Color.lerp(navAi, other.navAi, t)!,
      budgetUsed: Color.lerp(budgetUsed, other.budgetUsed, t)!,
      budgetRemaining:
          Color.lerp(budgetRemaining, other.budgetRemaining, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningBackground:
          Color.lerp(warningBackground, other.warningBackground, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorBackground: Color.lerp(errorBackground, other.errorBackground, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      mutedTextLight: Color.lerp(mutedTextLight, other.mutedTextLight, t)!,
      progressUsed: Color.lerp(progressUsed, other.progressUsed, t)!,
      progressEmpty: Color.lerp(progressEmpty, other.progressEmpty, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceSecondary:
          Color.lerp(surfaceSecondary, other.surfaceSecondary, t)!,
      switchInactive: Color.lerp(switchInactive, other.switchInactive, t)!,
      aiAccent: Color.lerp(aiAccent, other.aiAccent, t)!,
      aiBackground: Color.lerp(aiBackground, other.aiBackground, t)!,
      backButtonBackground:
          Color.lerp(backButtonBackground, other.backButtonBackground, t)!,
      onScaffold: Color.lerp(onScaffold, other.onScaffold, t)!,
    );
  }
}

extension AppThemeColorsContext on BuildContext {
  AppThemeColors get appColors =>
      Theme.of(this).extension<AppThemeColors>()!;
}

extension ReadableOnColor on Color {
  Color get readableForeground =>
      computeLuminance() > 0.5 ? const Color(0xFF1A1A1A) : Colors.white;
}
