part of 'ai_insights_bloc.dart';

/// Status of the AI analysis.
enum AiInsightsStatus {
  /// No analysis has been triggered yet.
  idle,

  /// AI inference is currently running.
  loading,

  /// Inference completed successfully.
  success,

  /// Device does not support on-device AI (AICore not available).
  unsupported,

  /// An unexpected error occurred during inference.
  error,
}

@freezed
abstract class AiInsightsState with _$AiInsightsState {
  factory AiInsightsState({
    /// All available months (closed + current open), for the dropdowns.
    required List<Month> months,

    /// Selected start month for the analysis range.
    required Month? startMonth,

    /// Selected end month for the analysis range.
    required Month? endMonth,

    /// Current analysis status.
    required AiInsightsStatus status,

    /// AI-generated insight text (populated after a successful analysis).
    required String? insightText,

    /// Error message when status is [AiInsightsStatus.error].
    required String? errorMessage,
  }) = _AiInsightsState;

  factory AiInsightsState.initial() => AiInsightsState(
        months: [],
        startMonth: null,
        endMonth: null,
        status: AiInsightsStatus.idle,
        insightText: null,
        errorMessage: null,
      );
}
