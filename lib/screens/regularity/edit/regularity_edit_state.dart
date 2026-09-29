part of 'regularity_edit_bloc.dart';

@freezed
abstract class RegularityEditState with _$RegularityEditState {
  factory RegularityEditState({
    required int id,
    required String name,
    required String amountText,
    required Set<int> months,
    required bool isLoading,
    required bool isSaving,
    required String? errorMessage,
  }) = _RegularityEditState;

  factory RegularityEditState.initial() {
    return RegularityEditState(
      id: 0,
      name: '',
      amountText: '',
      months: {},
      isLoading: true,
      isSaving: false,
      errorMessage: null,
    );
  }
}

extension RegularityEditStateX on RegularityEditState {
  bool get isEditing => id != 0;
}
