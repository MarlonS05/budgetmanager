part of 'index_bloc.dart';

@freezed
abstract class IndexState with _$IndexState {
  const IndexState._();

  factory IndexState({
    required Month month,
    required List<BudgetByMonth> budgets,
    required List<RegularPayment> regularPayments,
    required RegularPaymentSnapshot? regularPaymentSnapshot,
    required String? errorMessage,
  }) = _Initial;

  factory IndexState.initial() => IndexState(
    month: Month.empty(),
    budgets: [],
    regularPayments: [],
    regularPaymentSnapshot: null,
    errorMessage: null,
  );

  double get regularPaymentsTotal => month.closedOn == null
      ? regularPayments.fold(0.0, (sum, payment) => sum + payment.amount)
      : regularPaymentSnapshot?.amount ?? 0;

  MonthIncomeTotals get incomeTotals =>
      MonthIncomeTotals.fromMonth(month, regularPayments: regularPaymentsTotal);

  double get incomeSpent => incomeTotals.spent;

  double get incomeBudgeted => incomeTotals.budgeted;
}
