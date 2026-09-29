part of 'home_bloc.dart';

@freezed
abstract class HomeState with _$HomeState {
  const HomeState._();

  const factory HomeState({
    required Month currentMonth,
    required double regularPaymentsTotal,
  }) = _HomeState;

  factory HomeState.initial() =>
      HomeState(currentMonth: Month.empty(), regularPaymentsTotal: 0);

  MonthIncomeTotals get incomeTotals => MonthIncomeTotals.fromMonth(
    currentMonth,
    regularPayments: regularPaymentsTotal,
  );
}
