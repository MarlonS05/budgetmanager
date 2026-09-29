import 'package:budgetmanager/domain/entities/regular_payment.dart';
import 'package:budgetmanager/domain/repositories/regular_payment_repository.dart';
import 'package:budgetmanager/router/app_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'regularity_calendar_event.dart';
part 'regularity_calendar_state.dart';
part 'regularity_calendar_bloc.freezed.dart';

class RegularityCalendarBloc
    extends Bloc<RegularityCalendarEvent, RegularityCalendarState> {
  final AppRouter router;
  final RegularPaymentRepository repository;

  /// Shared across create and edit so a second tap cannot stack another push.
  bool _isOpeningEditor = false;

  RegularityCalendarBloc(this.router, this.repository)
    : super(RegularityCalendarState.initial()) {
    on<_Started>((event, emit) => _load(emit));
    on<_Refresh>((event, emit) => _load(emit));
    on<_OpenCreate>((event, emit) => _openEditor('/regularity/edit', emit));
    on<_OpenEdit>(
      (event, emit) => _openEditor('/regularity/edit/${event.id}', emit),
    );
    on<_BackTapped>((event, emit) => router.pop());
  }

  Future<void> _openEditor(
    String path,
    Emitter<RegularityCalendarState> emit,
  ) async {
    if (_isOpeningEditor) return;
    _isOpeningEditor = true;
    try {
      await router.push(path);
      await _load(emit);
    } finally {
      _isOpeningEditor = false;
    }
  }

  Future<void> _load(Emitter<RegularityCalendarState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final payments = await repository.getAll();
      emit(
        state.copyWith(
          payments: payments,
          isLoading: false,
          errorMessage: null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Could not load regular payments.',
        ),
      );
    }
  }
}
