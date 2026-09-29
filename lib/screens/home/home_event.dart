part of 'home_bloc.dart';

@freezed
class HomeEvent with _$HomeEvent {
  const factory HomeEvent.started() = _Started;
  const factory HomeEvent.refresh() = _Refresh;
  const factory HomeEvent.openLive() = _openLive;
  const factory HomeEvent.openHistory() = _openHistory;
  const factory HomeEvent.openRegularity() = _OpenRegularity;
  const factory HomeEvent.openSettings() = _openSettings;
  const factory HomeEvent.openAiInsights() = _openAiInsights;
}
