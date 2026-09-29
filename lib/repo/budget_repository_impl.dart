import '../db/database_helper.dart';
import '../domain/entities/budget.dart';
import '../domain/models/budget_model.dart';
import '../domain/repositories/budget_repository.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final DatabaseHelper _dbHelper;

  BudgetRepositoryImpl(this._dbHelper);

  @override
  Future<List<Budget>> getAllBudgets() async {
    final models = await _dbHelper.getAllBudgets();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<int> createBudget(Budget budget) async {
    int result = await _dbHelper.insertBudget(BudgetModel.fromEntity(budget));

    // Create budgetbymonth for the current month
    int currentMonthId = await _dbHelper.getCurrentMonthId();
    await _dbHelper.insertNewBudgetByMonth(currentMonthId, result);

    return result;
  }

  @override
  Future<void> updateBudget(Budget budget) async {
    await _dbHelper.updateBudget(BudgetModel.fromEntity(budget));
    // Update oldLimit of budgetbymonth for the current month
    int currentMonthId = await _dbHelper.getCurrentMonthId();
    await _dbHelper.updateOldLimitForBudgetByMonth(
      currentMonthId,
      budget.id,
      budget.limit,
    );
  }

  @override
  Future<void> deleteBudget(int id) async {
    await _dbHelper.deleteBudget(id);
  }
}
