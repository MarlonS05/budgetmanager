import 'package:budgetmanager/screens/ai_insights/ai_insights_bloc.dart';
import 'package:budgetmanager/screens/ai_insights/ai_insights_view.dart';
import 'package:budgetmanager/screens/history/history_index/history_index_bloc.dart';
import 'package:budgetmanager/screens/history/history_index/history_index_view.dart';
import 'package:budgetmanager/screens/history/history_show/history_show_bloc.dart';
import 'package:budgetmanager/screens/history/history_show/history_show_view.dart';
import 'package:budgetmanager/screens/home/home_view.dart';
import 'package:budgetmanager/screens/live/index/index_bloc.dart';
import 'package:budgetmanager/screens/live/index/index_view.dart';
import 'package:budgetmanager/screens/live/show/show_bloc.dart';
import 'package:budgetmanager/screens/live/show/show_view.dart';
import 'package:budgetmanager/screens/regularity/calendar/regularity_calendar_bloc.dart';
import 'package:budgetmanager/screens/regularity/calendar/regularity_calendar_view.dart';
import 'package:budgetmanager/screens/regularity/edit/regularity_edit_bloc.dart';
import 'package:budgetmanager/screens/regularity/edit/regularity_edit_view.dart';
import 'package:budgetmanager/screens/settings/manage_budgets/manage_budgets_bloc.dart';
import 'package:budgetmanager/screens/settings/manage_budgets/manage_budgets_view.dart';
import 'package:budgetmanager/screens/settings/settings_bloc.dart';
import 'package:budgetmanager/screens/settings/settings_view.dart';
import 'package:budgetmanager/screens/settings/update_income/update_income_bloc.dart';
import 'package:budgetmanager/screens/settings/update_income/update_income_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../di/di.dart';
// Import your screens here
import '../screens/home/home_bloc.dart';

class AppRouter {
  final GoRouter instance = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<HomeBloc>()..add(HomeEvent.started()),
          child: const HomeView(),
        ),
      ),
      GoRoute(
        path: '/index/:monthId',
        builder: (context, state) {
          int targetMonthId =
              int.tryParse(state.pathParameters['monthId'] ?? '') ?? -1;

          return BlocProvider(
            create: (_) =>
                getIt<IndexBloc>()
                  ..add(IndexEvent.started(monthId: targetMonthId)),
            child: const IndexView(),
          );
        },
      ),
      GoRoute(
        path: '/index/:monthId/budget/:budgetByMonthId',
        builder: (context, state) {
          final monthId =
              int.tryParse(state.pathParameters['monthId'] ?? '') ?? -1;
          final budgetByMonthId =
              int.tryParse(state.pathParameters['budgetByMonthId'] ?? '') ?? -1;

          return BlocProvider(
            create: (_) => getIt<ShowBloc>()
              ..add(
                ShowEvent.started(
                  monthId: monthId,
                  budgetByMonthId: budgetByMonthId,
                ),
              ),
            child: const ShowView(),
          );
        },
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) {
          return BlocProvider(
            create: (_) =>
                getIt<HistoryIndexBloc>()..add(HistoryIndexEvent.started()),
            child: const HistoryIndexView(),
          );
        },
      ),
      GoRoute(
        path: '/history/:monthId',
        builder: (context, state) {
          final monthId =
              int.tryParse(state.pathParameters['monthId'] ?? '') ?? -1;

          return BlocProvider(
            create: (_) =>
                getIt<HistoryShowBloc>()
                  ..add(HistoryShowEvent.started(monthId: monthId)),
            child: const HistoryShowView(),
          );
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => BlocProvider(
          create: (_) => getIt<SettingsBloc>()..add(SettingsEvent.started()),
          child: const SettingsView(),
        ),
      ),
      GoRoute(
        path: '/settings/manage-budgets',
        builder: (context, state) => BlocProvider(
          create: (_) =>
              getIt<ManageBudgetsBloc>()..add(ManageBudgetsEvent.started()),
          child: const ManageBudgetsView(),
        ),
      ),
      GoRoute(
        path: '/settings/update-income',
        builder: (context, state) => BlocProvider(
          create: (_) =>
              getIt<UpdateIncomeBloc>()..add(UpdateIncomeEvent.started()),
          child: const UpdateIncomeView(),
        ),
      ),
      GoRoute(
        path: '/ai-insights',
        builder: (context, state) => BlocProvider(
          create: (_) =>
              getIt<AiInsightsBloc>()..add(AiInsightsEvent.started()),
          child: const AiInsightsView(),
        ),
      ),
      GoRoute(
        path: '/regularity',
        builder: (context, state) => BlocProvider(
          create: (_) =>
              getIt<RegularityCalendarBloc>()
                ..add(const RegularityCalendarEvent.started()),
          child: const RegularityCalendarView(),
        ),
      ),
      GoRoute(
        path: '/regularity/edit',
        builder: (context, state) => BlocProvider(
          create: (_) =>
              getIt<RegularityEditBloc>()
                ..add(const RegularityEditEvent.started()),
          child: const RegularityEditView(),
        ),
      ),
      GoRoute(
        path: '/regularity/edit/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? -1;
          return BlocProvider(
            create: (_) =>
                getIt<RegularityEditBloc>()
                  ..add(RegularityEditEvent.started(id: id)),
            child: const RegularityEditView(),
          );
        },
      ),
      // Define your routes here. Example:
      // GoRoute(
      //   path: '/history',
      //   builder: (context, state) => HistoryScreen(),
      // ),
      // GoRoute(
      //   path: '/live',
      //   builder: (context, state) => LiveScreen(),
      // ),
    ],
    // Optionally add errorBuilder, redirect, etc.
  );

  void go(String path, {Object? extra}) {
    instance.go(path, extra: extra);
  }

  Future<T?> push<T extends Object?>(String path, {Object? extra}) {
    return instance.push<T>(path, extra: extra);
  }

  void pop() {
    instance.pop();
  }

  void goHome({Object? extra}) {
    instance.go('/', extra: extra);
  }
}
