import 'package:bloc/bloc.dart';
import 'package:budgetmanager/domain/entities/budget_by_month.dart';
import 'package:budgetmanager/domain/entities/month.dart';
import 'package:budgetmanager/domain/entities/month_income_totals.dart';
import 'package:budgetmanager/domain/entities/regular_payment_snapshot.dart';
import 'package:budgetmanager/domain/repositories/month_repository.dart';
import 'package:budgetmanager/domain/repositories/regular_payment_snapshot_repository.dart';
import 'package:budgetmanager/router/app_router.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'history_show_bloc.freezed.dart';
part 'history_show_event.dart';
part 'history_show_state.dart';

class HistoryShowBloc extends Bloc<HistoryShowEvent, HistoryShowState> {
  final AppRouter router;
  final MonthRepository repoMonth;
  final RegularPaymentSnapshotRepository repoRegularPaymentSnapshot;

  HistoryShowBloc(this.router, this.repoMonth, this.repoRegularPaymentSnapshot)
    : super(HistoryShowState.initial()) {
    // Load the month and its budgets for the read-only history detail view.
    on<_Started>((event, emit) async {
      final month = await repoMonth.getMonth(event.monthId);

      if (month == null) {
        router.pop();
        return;
      }

      final RegularPaymentSnapshot? snapshot = await repoRegularPaymentSnapshot
          .getByMonthId(month.id);
      emit(
        state.copyWith(
          month: month,
          budgets: month.budgets,
          regularPaymentSnapshot: snapshot,
        ),
      );
    });

    on<_Edit>((event, emit) {
      router.push("/index/${state.month.id}");
    });
  }
}
