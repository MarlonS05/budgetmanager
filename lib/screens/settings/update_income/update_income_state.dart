part of 'update_income_bloc.dart';

@freezed
abstract class UpdateIncomeState with _$UpdateIncomeState {
  factory UpdateIncomeState({
    required Month month,
    required double income,
  }) = _UpdateIncomeState;

  factory UpdateIncomeState.initial() =>
      UpdateIncomeState(month: Month.empty(), income: 0.0);
}
