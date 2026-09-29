import '../db/database_helper.dart';
import '../domain/entities/budget_by_month.dart';
import '../domain/models/budget_by_month_model.dart';
import '../domain/repositories/budget_by_month_repository.dart';

class BudgetByMonthRepositoryImpl implements BudgetByMonthRepository {
  final DatabaseHelper _dbHelper;

  BudgetByMonthRepositoryImpl(this._dbHelper);

  @override
  Future<List<BudgetByMonth>> getBudgetsByMonth(int monthId) async {
    final models = await _dbHelper.getBudgetsByMonth(monthId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<BudgetByMonth?> getBudgetByMonthById(int id) async {
    final model = await _dbHelper.getBudgetByMonthById(id);
    return model?.toEntity();
  }

  @override
  Future<void> updateCurrentUsed(int id, double newCurrentUsed) async {
    await _dbHelper.updateBudgetByMonthCurrentUsed(id, newCurrentUsed);
  }

  @override
  Future<int> createBudgetByMonth(
    BudgetByMonth budget, {
    required int monthId,
    required int budgetId,
  }) {
    return _dbHelper.insertBudgetByMonth(
      BudgetByMonthModel.fromEntity(budget, monthId: monthId, budgetId: budgetId),
    );
  }

  @override
  Future<void> updateBudgetByMonth(
    BudgetByMonth budget, {
    required int monthId,
    required int budgetId,
  }) async {
    await _dbHelper.updateBudgetByMonth(
      BudgetByMonthModel.fromEntity(budget, monthId: monthId, budgetId: budgetId),
    );
  }

  @override
  Future<void> deleteBudgetByMonth(int id) async {
    await _dbHelper.deleteBudgetByMonth(id);
  }

  @override
  Future<void> deleteBudgetsByMonth(int monthId) async {
    await _dbHelper.deleteBudgetsByMonth(monthId);
  }
}

