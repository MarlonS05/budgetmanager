import 'package:bloc/bloc.dart';
import 'package:budgetmanager/domain/entities/budget.dart';
import 'package:budgetmanager/domain/repositories/budget_repository.dart';
import 'package:budgetmanager/router/app_router.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'manage_budgets_event.dart';
part 'manage_budgets_state.dart';
part 'manage_budgets_bloc.freezed.dart';

class ManageBudgetsBloc extends Bloc<ManageBudgetsEvent, ManageBudgetsState> {
  final AppRouter router;
  final BudgetRepository repoBudget;

  ManageBudgetsBloc(this.router, this.repoBudget)
      : super(ManageBudgetsState.initial()) {
    // Load all budgets from the repository on startup.
    on<_Started>((event, emit) async {
      final budgets = await repoBudget.getAllBudgets();
      emit(state.copyWith(budgets: budgets));
    });

    // Persist a new budget and reload the list.
    on<_BudgetCreated>((event, emit) async {
      final newBudget = Budget(
        id: 0,
        name: event.name,
        limit: event.limit,
        hiddenOn: event.isVisible ? null : DateTime.now(),
      );
      await repoBudget.createBudget(newBudget);
      final budgets = await repoBudget.getAllBudgets();
      emit(state.copyWith(budgets: budgets));
    });

    // Persist the edited budget and reload the list.
    on<_BudgetUpdated>((event, emit) async {
      final updatedBudget = Budget(
        id: event.budget.id,
        name: event.name,
        limit: event.limit,
        hiddenOn: event.isVisible
            ? null
            : (event.budget.hiddenOn ?? DateTime.now()),
      );
      await repoBudget.updateBudget(updatedBudget);
      final budgets = await repoBudget.getAllBudgets();
      emit(state.copyWith(budgets: budgets));
    });
  }
}
