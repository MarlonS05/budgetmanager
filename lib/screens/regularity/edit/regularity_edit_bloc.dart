import 'package:budgetmanager/domain/entities/regular_payment.dart';
import 'package:budgetmanager/domain/entities/regular_payment_validator.dart';
import 'package:budgetmanager/domain/repositories/regular_payment_repository.dart';
import 'package:budgetmanager/router/app_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'regularity_edit_event.dart';
part 'regularity_edit_state.dart';
part 'regularity_edit_bloc.freezed.dart';

class RegularityEditBloc
    extends Bloc<RegularityEditEvent, RegularityEditState> {
  final AppRouter router;
  final RegularPaymentRepository repository;

  /// Shared across save and delete so concurrent events cannot both write.
  bool _writeInFlight = false;

  RegularityEditBloc(this.router, this.repository)
    : super(RegularityEditState.initial()) {
    on<_Started>(_onStarted);
    on<_NameChanged>((event, emit) {
      emit(state.copyWith(name: event.name, errorMessage: null));
    });
    on<_AmountChanged>((event, emit) {
      emit(state.copyWith(amountText: event.amount, errorMessage: null));
    });
    on<_MonthToggled>((event, emit) {
      final months = Set<int>.from(state.months);
      months.contains(event.month)
          ? months.remove(event.month)
          : months.add(event.month);
      emit(state.copyWith(months: months, errorMessage: null));
    });
    on<_SaveTapped>(_onSave);
    on<_DeleteConfirmed>(_onDelete);
    on<_BackTapped>((event, emit) {
      if (state.isLoading || state.isSaving) return;
      router.pop();
    });
  }

  bool get _isWriteBlocked =>
      state.isLoading || state.isSaving || _writeInFlight;

  Future<void> _onStarted(
    _Started event,
    Emitter<RegularityEditState> emit,
  ) async {
    if (event.id == null) {
      emit(state.copyWith(isLoading: false));
      return;
    }
    if (event.id! <= 0) {
      router.pop();
      return;
    }

    try {
      final payment = await repository.getById(event.id!);
      if (payment == null) {
        router.pop();
        return;
      }

      emit(
        state.copyWith(
          id: payment.id,
          name: payment.name,
          amountText: _formatEditableAmount(payment.amount),
          months: Set<int>.from(payment.months),
          isLoading: false,
          errorMessage: null,
        ),
      );
    } catch (_) {
      router.pop();
    }
  }

  Future<void> _onSave(
    _SaveTapped event,
    Emitter<RegularityEditState> emit,
  ) async {
    if (_isWriteBlocked) return;

    final validationError = RegularPaymentValidator.validate(
      name: state.name,
      amountText: state.amountText,
      months: state.months,
    );
    if (validationError != null) {
      if (state.errorMessage == validationError) {
        emit(state.copyWith(errorMessage: null));
      }
      emit(state.copyWith(errorMessage: validationError));
      return;
    }

    _writeInFlight = true;
    emit(state.copyWith(isSaving: true, errorMessage: null));
    try {
      final payment = RegularPayment(
        id: state.id,
        name: state.name.trim(),
        amount: double.parse(state.amountText.trim().replaceAll(',', '.')),
        months: Set<int>.from(state.months),
      );

      if (state.isEditing) {
        await repository.update(payment);
      } else {
        await repository.create(payment);
      }
      router.pop();
    } catch (_) {
      _writeInFlight = false;
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: 'Could not save regular payment.',
        ),
      );
    }
  }

  Future<void> _onDelete(
    _DeleteConfirmed event,
    Emitter<RegularityEditState> emit,
  ) async {
    if (!state.isEditing || _isWriteBlocked) return;

    _writeInFlight = true;
    emit(state.copyWith(isSaving: true, errorMessage: null));
    try {
      await repository.delete(state.id);
      router.pop();
    } catch (_) {
      _writeInFlight = false;
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: 'Could not delete regular payment.',
        ),
      );
    }
  }

  String _formatEditableAmount(double amount) {
    return amount == amount.roundToDouble()
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
  }
}
