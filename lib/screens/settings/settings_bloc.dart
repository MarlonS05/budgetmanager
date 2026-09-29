import 'package:bloc/bloc.dart';
import 'package:budgetmanager/router/app_router.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_event.dart';
part 'settings_state.dart';
part 'settings_bloc.freezed.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final AppRouter router;

  SettingsBloc(this.router) : super(const SettingsState.initial()) {
    on<_Started>((event, emit) {
      // No initialisation required for the settings screen
    });
    on<_OpenManageBudgets>((event, emit) {
      router.push('/settings/manage-budgets');
    });
    on<_OpenUpdateMonthlyIncome>((event, emit) {
      router.push('/settings/update-income');
    });
  }
}
