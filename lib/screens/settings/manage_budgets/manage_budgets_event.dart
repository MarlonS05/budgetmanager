part of 'manage_budgets_bloc.dart';

@freezed
abstract class ManageBudgetsEvent with _$ManageBudgetsEvent {
  const factory ManageBudgetsEvent.started() = _Started;

  /// Dispatched when the user submits the create-budget form.
  const factory ManageBudgetsEvent.budgetCreated({
    required String name,
    required double limit,
    required bool isVisible,
  }) = _BudgetCreated;

  /// Dispatched when the user submits the edit-budget form.
  const factory ManageBudgetsEvent.budgetUpdated({
    required Budget budget,
    required String name,
    required double limit,
    required bool isVisible,
  }) = _BudgetUpdated;
}
