import 'package:bloc/bloc.dart';
import 'package:budgetmanager/domain/entities/budget_by_month.dart';
import 'package:budgetmanager/domain/entities/month.dart';
import 'package:budgetmanager/domain/entities/regular_payment.dart';
import 'package:budgetmanager/domain/entities/regular_payment_snapshot.dart';
import 'package:budgetmanager/domain/repositories/budget_by_month_repository.dart';
import 'package:budgetmanager/domain/repositories/month_repository.dart';
import 'package:budgetmanager/domain/repositories/regular_payment_repository.dart';
import 'package:budgetmanager/domain/repositories/regular_payment_snapshot_repository.dart';
import 'package:budgetmanager/domain/entities/month_income_totals.dart';
import 'package:budgetmanager/domain/use_cases/month/close_month_result.dart';
import 'package:budgetmanager/domain/use_cases/month/close_month_use_case.dart';
import 'package:budgetmanager/router/app_router.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'index_bloc.freezed.dart';
part 'index_event.dart';
part 'index_state.dart';

class IndexBloc extends Bloc<IndexEvent, IndexState> {
  final AppRouter router;
  final MonthRepository repoMonth;
  final BudgetByMonthRepository repoBudgetByMonth;
  final RegularPaymentRepository repoRegularPayment;
  final RegularPaymentSnapshotRepository repoRegularPaymentSnapshot;
  final CloseMonthUseCase closeMonthUseCase;

  IndexBloc(
    this.router,
    this.repoMonth,
    this.repoBudgetByMonth,
    this.repoRegularPayment,
    this.repoRegularPaymentSnapshot,
    this.closeMonthUseCase,
  ) : super(IndexState.initial()) {
    on<_Started>((event, emit) async {
      if (event.monthId == null) {
        router.goHome();
        return;
      }

      final data = await _load(event.monthId!);
      if (data == null) {
        router.goHome();
        return;
      }
      emit(
        state.copyWith(
          month: data.month,
          budgets: data.budgets,
          regularPayments: data.regularPayments,
          regularPaymentSnapshot: data.snapshot,
          errorMessage: null,
        ),
      );
    });

    on<_Refresh>((event, emit) async {
      final data = await _load(state.month.id);
      if (data == null) return;
      emit(
        state.copyWith(
          month: data.month,
          budgets: data.budgets,
          regularPayments: data.regularPayments,
          regularPaymentSnapshot: data.snapshot,
          errorMessage: null,
        ),
      );
    });

    on<_CloseMonth>((event, emit) async {
      try {
        final result = await closeMonthUseCase(state.month.id);
        if (result == CloseMonthResult.completed) {
          router.goHome();
        }
      } catch (_) {
        const message = 'Could not close the month. Please try again.';
        await _emitPersisted(emit, state.month.id, errorMessage: message);
      }
    });
  }

  Future<void> _emitPersisted(
    Emitter<IndexState> emit,
    int monthId, {
    required String? errorMessage,
  }) async {
    final data = await _load(monthId);
    if (data == null) return;
    emit(
      state.copyWith(
        month: data.month,
        budgets: data.budgets,
        regularPayments: data.regularPayments,
        regularPaymentSnapshot: data.snapshot,
        errorMessage: errorMessage,
      ),
    );
  }

  Future<_IndexData?> _load(int monthId) async {
    final month = await repoMonth.getMonth(monthId);
    if (month == null) return null;

    final budgets = await repoBudgetByMonth.getBudgetsByMonth(monthId);
    final loadedMonth = Month(
      month.id,
      month.income,
      month.name,
      budgets,
      month.date,
      month.closedOn,
    );
    if (loadedMonth.closedOn == null) {
      final payments = await repoRegularPayment.getByMonth(
        loadedMonth.date.month,
      );
      return _IndexData(
        month: loadedMonth,
        budgets: budgets,
        regularPayments: payments,
        snapshot: null,
      );
    }

    final snapshot = await repoRegularPaymentSnapshot.getByMonthId(monthId);
    return _IndexData(
      month: loadedMonth,
      budgets: budgets,
      regularPayments: const [],
      snapshot: snapshot,
    );
  }
}

class _IndexData {
  final Month month;
  final List<BudgetByMonth> budgets;
  final List<RegularPayment> regularPayments;
  final RegularPaymentSnapshot? snapshot;

  const _IndexData({
    required this.month,
    required this.budgets,
    required this.regularPayments,
    required this.snapshot,
  });
}
