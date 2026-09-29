import 'package:budgetmanager/repo/theme_repository.dart';
import 'package:budgetmanager/router/app_router.dart';
import 'package:budgetmanager/theme/theme_cubit.dart';
import 'package:budgetmanager/screens/ai_insights/ai_insights_bloc.dart';
import 'package:budgetmanager/screens/history/history_index/history_index_bloc.dart';
import 'package:budgetmanager/screens/history/history_show/history_show_bloc.dart';
import 'package:budgetmanager/screens/live/index/index_bloc.dart';
import 'package:budgetmanager/screens/live/show/show_bloc.dart';
import 'package:budgetmanager/screens/regularity/calendar/regularity_calendar_bloc.dart';
import 'package:budgetmanager/screens/regularity/edit/regularity_edit_bloc.dart';
import 'package:budgetmanager/screens/settings/manage_budgets/manage_budgets_bloc.dart';
import 'package:budgetmanager/screens/settings/settings_bloc.dart';
import 'package:budgetmanager/screens/settings/update_income/update_income_bloc.dart';
import 'package:get_it/get_it.dart';

// Example imports for demonstration purposes:
// import '../screens/live/live_screen.dart';
// import '../screens/history/history_screen.dart';
// import '../domain/models/month_model.dart';
// import '../domain/models/category.dart';
// import '../bloc/budget_bloc.dart';
import '../db/database_helper.dart';
import '../domain/repositories/budget_by_month_repository.dart';
import '../domain/repositories/budget_repository.dart';
import '../domain/repositories/month_repository.dart';
import '../domain/repositories/regular_payment_repository.dart';
import '../domain/repositories/regular_payment_snapshot_repository.dart';
import '../domain/use_cases/month/close_month_use_case.dart';
import '../repo/budget_by_month_repository_impl.dart';
import '../repo/budget_repository_impl.dart';
import '../repo/month_repository_impl.dart';
import '../repo/regular_payment_repository_impl.dart';
import '../repo/regular_payment_snapshot_repository_impl.dart';
import '../screens/home/home_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // Register database/helper singletons

  await registerDatabase();

  registerRouter();

  registerTheme();

  registerRepositories();

  registerUseCases();

  // Register models (if needed, usually not registered directly)
  // getIt.registerFactory<Month>(() => Month.empty());
  // getIt.registerFactory<Category>(() => Category.empty());

  // Register BLoCs or Cubits
  registerScreens();

  // Register views/screens (if you want to inject dependencies)
  // getIt.registerFactory<LiveScreen>(() => LiveScreen());
  // getIt.registerFactory<HistoryScreen>(() => HistoryScreen());
}

Future<void> registerDatabase() async {
  final dbHelper = DatabaseHelper();
  // Eagerly initialize the database to ensure it's ready before the app starts
  await dbHelper.database;
  getIt.registerSingleton<DatabaseHelper>(dbHelper);
}

void registerRouter() {
  getIt.registerSingleton<AppRouter>(AppRouter());
}

void registerTheme() {
  getIt.registerLazySingleton<ThemeRepository>(() => ThemeRepository());
  getIt.registerSingleton<ThemeCubit>(
    ThemeCubit(getIt<ThemeRepository>())..loadTheme(),
  );
}

void registerRepositories() {
  getIt.registerLazySingleton<MonthRepository>(
    () => MonthRepositoryImpl(getIt<DatabaseHelper>()),
  );
  getIt.registerLazySingleton<BudgetRepository>(
    () => BudgetRepositoryImpl(getIt<DatabaseHelper>()),
  );
  getIt.registerLazySingleton<BudgetByMonthRepository>(
    () => BudgetByMonthRepositoryImpl(getIt<DatabaseHelper>()),
  );
  getIt.registerLazySingleton<RegularPaymentRepository>(
    () => RegularPaymentRepositoryImpl(getIt<DatabaseHelper>()),
  );
  getIt.registerLazySingleton<RegularPaymentSnapshotRepository>(
    () => RegularPaymentSnapshotRepositoryImpl(getIt<DatabaseHelper>()),
  );
}

void registerUseCases() {
  getIt.registerLazySingleton<CloseMonthUseCase>(
    () => CloseMonthUseCase(getIt.get(), getIt.get(), getIt.get()),
  );
}

void registerScreens() {
  getIt.registerFactory<HomeBloc>(
    () => HomeBloc(getIt.get(), getIt.get(), getIt.get()),
  );

  // Active Month
  getIt.registerFactory<IndexBloc>(
    () => IndexBloc(
      getIt.get(),
      getIt.get(),
      getIt.get(),
      getIt.get(),
      getIt.get(),
      getIt.get(),
    ),
  );
  getIt.registerFactory<ShowBloc>(() => ShowBloc(getIt.get(), getIt.get()));
  getIt.registerFactory<SettingsBloc>(() => SettingsBloc(getIt.get()));
  getIt.registerFactory<ManageBudgetsBloc>(
    () => ManageBudgetsBloc(getIt.get(), getIt.get()),
  );
  getIt.registerFactory<UpdateIncomeBloc>(
    () => UpdateIncomeBloc(getIt.get(), getIt.get()),
  );

  // History
  getIt.registerFactory<HistoryIndexBloc>(
    () => HistoryIndexBloc(getIt.get(), getIt.get(), getIt.get()),
  );
  getIt.registerFactory<HistoryShowBloc>(
    () => HistoryShowBloc(getIt.get(), getIt.get(), getIt.get()),
  );

  // AI Insights
  getIt.registerFactory<AiInsightsBloc>(
    () => AiInsightsBloc(getIt.get(), getIt.get(), getIt.get()),
  );

  // Regularity Calendar
  getIt.registerFactory<RegularityCalendarBloc>(
    () => RegularityCalendarBloc(getIt.get(), getIt.get()),
  );
  getIt.registerFactory<RegularityEditBloc>(
    () => RegularityEditBloc(getIt.get(), getIt.get()),
  );
}
