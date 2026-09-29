part of 'index_bloc.dart';

@freezed
abstract class IndexEvent with _$IndexEvent {
  const factory IndexEvent.started({required int? monthId}) = _Started;
  const factory IndexEvent.refresh() = _Refresh;
  const factory IndexEvent.closeMonth() = _CloseMonth;
}
