import 'package:bloc/bloc.dart';
import 'package:budgetmanager/domain/entities/month.dart';
import 'package:budgetmanager/domain/repositories/month_repository.dart';
import 'package:budgetmanager/router/app_router.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_income_event.dart';
part 'update_income_state.dart';
part 'update_income_bloc.freezed.dart';

class UpdateIncomeBloc extends Bloc<UpdateIncomeEvent, UpdateIncomeState> {
  final AppRouter router;
  final MonthRepository repoMonth;

  UpdateIncomeBloc(this.router, this.repoMonth)
      : super(UpdateIncomeState.initial()) {
    // Load the current month's income on startup.
    on<_Started>((event, emit) async {
      final monthId = await repoMonth.getCurrentMonthId();
      final month = await repoMonth.getMonth(monthId);
      if (month != null) {
        emit(state.copyWith(month: month, income: month.income));
      }
    });

    // Persist the updated income for the current month.
    on<_IncomeUpdated>((event, emit) async {
      final month = state.month;

      final updatedMonth = Month(
        month.id,
        event.income,
        month.name,
        month.budgets,
        month.date,
        month.closedOn,
      );
      await repoMonth.updateMonth(updatedMonth);
      emit(state.copyWith(month: updatedMonth, income: event.income));
      router.pop();
    });
  }
}
