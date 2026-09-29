import 'package:budgetmanager/di/di.dart';
import 'package:budgetmanager/router/app_router.dart';
import 'package:budgetmanager/theme/app_theme_id.dart';
import 'package:budgetmanager/theme/app_themes.dart';
import 'package:budgetmanager/theme/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<ThemeCubit>(),
      child: BlocBuilder<ThemeCubit, AppThemeId>(
        builder: (context, themeId) {
          return MaterialApp.router(
            title: 'Budget Manager',
            theme: AppThemes.themeFor(themeId),
            routerConfig: getIt.get<AppRouter>().instance,
          );
        },
      ),
    );
  }
}
