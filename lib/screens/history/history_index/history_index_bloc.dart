import 'package:bloc/bloc.dart';
import 'package:budgetmanager/domain/entities/month.dart';
import 'package:budgetmanager/domain/entities/regular_payment_snapshot.dart';
import 'package:budgetmanager/domain/repositories/month_repository.dart';
import 'package:budgetmanager/domain/repositories/regular_payment_snapshot_repository.dart';
import 'package:budgetmanager/router/app_router.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'history_index_event.dart';
part 'history_index_state.dart';
part 'history_index_bloc.freezed.dart';

class HistoryIndexBloc extends Bloc<HistoryIndexEvent, HistoryIndexState> {
  final AppRouter router;
  final MonthRepository repoMonth;
  final RegularPaymentSnapshotRepository repoRegularPaymentSnapshot;

  HistoryIndexBloc(this.router, this.repoMonth, this.repoRegularPaymentSnapshot)
    : super(HistoryIndexState.initial()) {
    // Load all months ordered by most recent first.
    on<_Started>((event, emit) async {
      final months = await repoMonth.getAllMonths();
      final Map<int, RegularPaymentSnapshot> snapshots =
          await repoRegularPaymentSnapshot.getByMonthIds(
            months.map((month) => month.id).toList(growable: false),
          );
      emit(state.copyWith(months: months, regularPaymentSnapshots: snapshots));
    });

    // Navigate to the history detail view for the given month.
    on<_OpenMonth>((event, emit) {
      router.push('/history/${event.monthId}');
    });
  }
}
