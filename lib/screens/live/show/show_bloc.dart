import 'package:bloc/bloc.dart';
import 'package:budgetmanager/domain/entities/budget_by_month.dart';
import 'package:budgetmanager/domain/repositories/budget_by_month_repository.dart';
import 'package:budgetmanager/router/app_router.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'show_bloc.freezed.dart';
part 'show_event.dart';
part 'show_state.dart';

class ShowBloc extends Bloc<ShowEvent, ShowState> {
  final AppRouter router;
  final BudgetByMonthRepository repoBudgetByMonth;

  ShowBloc(this.router, this.repoBudgetByMonth) : super(ShowState.initial()) {
    // Load the budget data for the given budgetByMonthId.
    on<_Started>((event, emit) async {
      final budget = await repoBudgetByMonth.getBudgetByMonthById(
        event.budgetByMonthId,
      );

      if (budget != null) {
        emit(state.copyWith(budget: budget, monthId: event.monthId));
      } else {
        // Navigate back if the budget cannot be found.
        router.pop();
      }
    });

    // Adjust the current used amount and persist the change.
    // The currentUsed is clamped to a minimum of 0 to avoid negative values.
    on<_Adjusted>((event, emit) async {
      final newCurrentUsed =
          (state.budget.currentUsed + event.amount).clamp(0.0, double.infinity);
      final updated = BudgetByMonth(
        state.budget.id,
        state.budget.name,
        newCurrentUsed,
        state.budget.limit,
      );
      await repoBudgetByMonth.updateCurrentUsed(updated.id, updated.currentUsed);
      emit(state.copyWith(budget: updated));
    });

    // Fill the current used amount to the budget limit.
    on<_FillToMax>((event, emit) async {
      final updated = BudgetByMonth(
        state.budget.id,
        state.budget.name,
        state.budget.limit,
        state.budget.limit,
      );
      await repoBudgetByMonth.updateCurrentUsed(updated.id, updated.currentUsed);
      emit(state.copyWith(budget: updated));
    });
  }
}
