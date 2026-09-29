part of 'settings_bloc.dart';

@freezed
abstract class SettingsEvent with _$SettingsEvent {
  const factory SettingsEvent.started() = _Started;
  const factory SettingsEvent.openManageBudgets() = _OpenManageBudgets;
  const factory SettingsEvent.openUpdateMonthlyIncome() = _OpenUpdateMonthlyIncome;
}
