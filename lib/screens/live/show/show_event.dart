part of 'show_bloc.dart';

@freezed
abstract class ShowEvent with _$ShowEvent {
  /// Loads the budget identified by [budgetByMonthId] for the given [monthId].
  const factory ShowEvent.started({
    required int monthId,
    required int budgetByMonthId,
  }) = _Started;

  /// Adjusts the current used amount by [amount] (positive or negative).
  const factory ShowEvent.adjusted({required double amount}) = _Adjusted;

  /// Fills the current used amount to the budget limit.
  const factory ShowEvent.fillToMax() = _FillToMax;
}
