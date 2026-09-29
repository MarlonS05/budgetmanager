part of 'history_show_bloc.dart';

@freezed
abstract class HistoryShowState with _$HistoryShowState {
  const HistoryShowState._();

  factory HistoryShowState({
    required Month month,
    required List<BudgetByMonth> budgets,
    required RegularPaymentSnapshot? regularPaymentSnapshot,
  }) = _HistoryShowState;

  factory HistoryShowState.initial() => HistoryShowState(
    month: Month.empty(),
    budgets: [],
    regularPaymentSnapshot: null,
  );

  MonthIncomeTotals get incomeTotals => MonthIncomeTotals.fromMonth(
    month,
    regularPayments: regularPaymentSnapshot?.amount ?? 0,
  );

  double get incomeSpent => incomeTotals.spent;
}
