part of 'manage_budgets_bloc.dart';

@freezed
abstract class ManageBudgetsState with _$ManageBudgetsState {
  factory ManageBudgetsState({
    required List<Budget> budgets,
  }) = _ManageBudgetsState;

  factory ManageBudgetsState.initial() => ManageBudgetsState(budgets: []);
}
