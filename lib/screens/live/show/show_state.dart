part of 'show_bloc.dart';

@freezed
abstract class ShowState with _$ShowState {
  factory ShowState({
    required BudgetByMonth budget,
    required int monthId,
  }) = _ShowState;

  factory ShowState.initial() => ShowState(
        budget: BudgetByMonth.empty(),
        monthId: 0,
      );
}
