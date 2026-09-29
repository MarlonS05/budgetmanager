part of 'history_index_bloc.dart';

@freezed
abstract class HistoryIndexState with _$HistoryIndexState {
  factory HistoryIndexState({
    required List<Month> months,
    required Map<int, RegularPaymentSnapshot> regularPaymentSnapshots,
  }) = _HistoryIndexState;

  factory HistoryIndexState.initial() =>
      HistoryIndexState(months: [], regularPaymentSnapshots: {});
}
