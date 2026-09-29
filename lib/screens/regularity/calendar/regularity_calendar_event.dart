part of 'regularity_calendar_bloc.dart';

@freezed
abstract class RegularityCalendarEvent with _$RegularityCalendarEvent {
  const factory RegularityCalendarEvent.started() = _Started;
  const factory RegularityCalendarEvent.refresh() = _Refresh;
  const factory RegularityCalendarEvent.openCreate() = _OpenCreate;
  const factory RegularityCalendarEvent.openEdit({required int id}) = _OpenEdit;
  const factory RegularityCalendarEvent.backTapped() = _BackTapped;
}
