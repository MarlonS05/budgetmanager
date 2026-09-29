import '../entities/budget_by_month.dart';

abstract interface class BudgetByMonthRepository {
  Future<List<BudgetByMonth>> getBudgetsByMonth(int monthId);
  Future<BudgetByMonth?> getBudgetByMonthById(int id);
  Future<int> createBudgetByMonth(BudgetByMonth budget, {required int monthId, required int budgetId});
  Future<void> updateBudgetByMonth(BudgetByMonth budget, {required int monthId, required int budgetId});
  Future<void> updateCurrentUsed(int id, double newCurrentUsed);
  Future<void> deleteBudgetByMonth(int id);
  Future<void> deleteBudgetsByMonth(int monthId);
}

