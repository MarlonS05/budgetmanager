import 'package:budgetmanager/theme/app_theme_id.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeRepository {
  static const _themeKey = 'app_theme_id';

  Future<AppThemeId> loadThemeId() async {
    final prefs = await SharedPreferences.getInstance();
    return AppThemeId.fromStorage(prefs.getString(_themeKey));
  }

  Future<void> saveThemeId(AppThemeId id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, id.name);
  }
}
