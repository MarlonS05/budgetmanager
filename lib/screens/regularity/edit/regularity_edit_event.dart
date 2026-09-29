part of 'regularity_edit_bloc.dart';

@freezed
abstract class RegularityEditEvent with _$RegularityEditEvent {
  const factory RegularityEditEvent.started({int? id}) = _Started;
  const factory RegularityEditEvent.nameChanged({required String name}) =
      _NameChanged;
  const factory RegularityEditEvent.amountChanged({required String amount}) =
      _AmountChanged;
  const factory RegularityEditEvent.monthToggled({required int month}) =
      _MonthToggled;
  const factory RegularityEditEvent.saveTapped() = _SaveTapped;
  const factory RegularityEditEvent.deleteConfirmed() = _DeleteConfirmed;
  const factory RegularityEditEvent.backTapped() = _BackTapped;
}
