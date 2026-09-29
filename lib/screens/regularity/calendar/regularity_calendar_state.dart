part of 'regularity_calendar_bloc.dart';

@freezed
abstract class RegularityCalendarState with _$RegularityCalendarState {
  factory RegularityCalendarState({
    required List<RegularPayment> payments,
    required bool isLoading,
    required String? errorMessage,
  }) = _RegularityCalendarState;

  factory RegularityCalendarState.initial() {
    return RegularityCalendarState(
      payments: [],
      isLoading: true,
      errorMessage: null,
    );
  }
}
