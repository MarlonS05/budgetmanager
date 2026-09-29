part of 'update_income_bloc.dart';

@freezed
abstract class UpdateIncomeEvent with _$UpdateIncomeEvent {
  const factory UpdateIncomeEvent.started() = _Started;

  /// Dispatched when the user submits the updated income value.
  const factory UpdateIncomeEvent.incomeUpdated({
    required double income,
  }) = _IncomeUpdated;
}
