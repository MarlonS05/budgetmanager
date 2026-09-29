part of 'ai_insights_bloc.dart';

@freezed
abstract class AiInsightsEvent with _$AiInsightsEvent {
  /// Load all available months for the dropdowns.
  const factory AiInsightsEvent.started() = _Started;

  /// User selected a new start month.
  const factory AiInsightsEvent.startMonthChanged({required Month? month}) =
      _StartMonthChanged;

  /// User selected a new end month.
  const factory AiInsightsEvent.endMonthChanged({required Month? month}) =
      _EndMonthChanged;

  /// User tapped "Analyze" — run on-device AI inference.
  const factory AiInsightsEvent.analyzeRequested() = _AnalyzeRequested;
}
