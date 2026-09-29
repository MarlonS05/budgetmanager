import '../entities/budget.dart';

abstract interface class BudgetRepository {
  Future<List<Budget>> getAllBudgets();
  Future<int> createBudget(Budget budget);
  Future<void> updateBudget(Budget budget);
  Future<void> deleteBudget(int id);
}
