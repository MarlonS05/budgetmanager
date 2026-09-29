part of 'history_show_bloc.dart';

@freezed
abstract class HistoryShowEvent with _$HistoryShowEvent {
  const factory HistoryShowEvent.started({required int monthId}) = _Started;
  const factory HistoryShowEvent.edit() = _Edit;
}
