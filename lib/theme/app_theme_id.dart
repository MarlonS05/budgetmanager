enum AppThemeId {
  lightLegacy,
  lightPlain,
  lightColorful,
  darkLegacy,
  darkPlain,
  darkColorful;

  bool get isDark => switch (this) {
        AppThemeId.lightLegacy ||
        AppThemeId.lightPlain ||
        AppThemeId.lightColorful =>
          false,
        _ => true,
      };

  String get paletteName => isDark ? 'Dark' : 'Light';

  String get styleName => switch (this) {
        AppThemeId.lightLegacy => 'Legacy',
        AppThemeId.darkLegacy => 'Dark Forest',
        AppThemeId.lightPlain || AppThemeId.darkPlain => 'Plain',
        AppThemeId.lightColorful || AppThemeId.darkColorful => 'Colorful',
      };

  String get displayName => switch (this) {
        AppThemeId.darkLegacy => 'Dark Forest',
        _ => '$paletteName · $styleName',
      };

  static List<AppThemeId> get lightThemes =>
      values.where((id) => !id.isDark).toList();

  static List<AppThemeId> get darkThemes =>
      values.where((id) => id.isDark).toList();

  static AppThemeId fromStorage(String? value) {
    return switch (value) {
      'classic' => AppThemeId.lightLegacy,
      'ocean' || 'forest' || 'sunset' => AppThemeId.lightColorful,
      final stored? when values.any((id) => id.name == stored) =>
        values.firstWhere((id) => id.name == stored),
      _ => AppThemeId.lightPlain,
    };
  }
}
