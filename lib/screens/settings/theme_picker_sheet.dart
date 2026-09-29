import 'package:budgetmanager/theme/app_theme_colors.dart';
import 'package:budgetmanager/theme/app_theme_id.dart';
import 'package:budgetmanager/theme/app_themes.dart';
import 'package:budgetmanager/theme/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemePickerSheet extends StatelessWidget {
  const ThemePickerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;
    final currentTheme = context.watch<ThemeCubit>().state;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: colors.borderMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text('Color Theme', style: textTheme.headlineMedium),
          const SizedBox(height: 16),
          _ThemeSection(
            title: 'Light',
            themes: AppThemeId.lightThemes,
            currentTheme: currentTheme,
          ),
          const SizedBox(height: 12),
          _ThemeSection(
            title: 'Dark',
            themes: AppThemeId.darkThemes,
            currentTheme: currentTheme,
          ),
        ],
      ),
    );
  }
}

class _ThemeSection extends StatelessWidget {
  const _ThemeSection({
    required this.title,
    required this.themes,
    required this.currentTheme,
  });

  final String title;
  final List<AppThemeId> themes;
  final AppThemeId currentTheme;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: textTheme.labelMedium,
        ),
        const SizedBox(height: 8),
        ...themes.map((themeId) {
          final isSelected = themeId == currentTheme;
          final swatches = AppThemes.previewSwatches(themeId);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () {
                  context.read<ThemeCubit>().setTheme(themeId);
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? colors.primaryAction : colors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: swatches
                            .map(
                              (color) => Container(
                                width: 16,
                                height: 16,
                                margin: const EdgeInsets.only(right: 4),
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: colors.borderMuted,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          themeId.styleName,
                          style: textTheme.titleLarge,
                        ),
                      ),
                      Icon(
                        isSelected
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        color: isSelected
                            ? colors.primaryAction
                            : colors.mutedTextLight,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

void showThemePickerSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (_) => BlocProvider.value(
      value: context.read<ThemeCubit>(),
      child: const ThemePickerSheet(),
    ),
  );
}
