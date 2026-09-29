part of 'history_index_bloc.dart';

@freezed
abstract class HistoryIndexEvent with _$HistoryIndexEvent {
  const factory HistoryIndexEvent.started() = _Started;
  const factory HistoryIndexEvent.openMonth({required int monthId}) =
      _OpenMonth;
}
