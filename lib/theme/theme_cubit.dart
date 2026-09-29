import 'package:budgetmanager/repo/theme_repository.dart';
import 'package:budgetmanager/theme/app_theme_id.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<AppThemeId> {
  ThemeCubit(this._repository) : super(AppThemeId.lightLegacy);

  final ThemeRepository _repository;

  Future<void> loadTheme() async {
    final id = await _repository.loadThemeId();
    emit(id);
  }

  Future<void> setTheme(AppThemeId id) async {
    await _repository.saveThemeId(id);
    emit(id);
  }
}
