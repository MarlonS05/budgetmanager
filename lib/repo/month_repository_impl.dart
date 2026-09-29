import '../db/database_helper.dart';
import '../domain/entities/month.dart';
import '../domain/models/month_model.dart';
import '../domain/repositories/month_repository.dart';

class MonthRepositoryImpl implements MonthRepository {
  final DatabaseHelper _dbHelper;

  MonthRepositoryImpl(this._dbHelper);

  @override
  Future<List<Month>> getAllMonths() async {
    final models = await _dbHelper.getAllMonths();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Month?> getMonth(int id) async {
    MonthModel? model = await _dbHelper.getMonth(id);
    return model?.toEntity();
  }

  @override
  Future<int> createMonth(Month month) {
    return _dbHelper.insertMonth(MonthModel.fromEntity(month));
  }

  @override
  Future<void> updateMonth(Month month) async {
    await _dbHelper.updateMonth(MonthModel.fromEntity(month));
  }

  @override
  Future<void> deleteMonth(int id) async {
    await _dbHelper.deleteMonth(id);
  }

  @override
  Future<int> getCurrentMonthId() {
    return _dbHelper.getCurrentMonthId();
  }

  @override
  Future<void> closeMonth(int monthId) async {
    MonthModel? oldMonth = await _dbHelper.getMonth(monthId);
    if (oldMonth != null) {
      oldMonth = oldMonth.copyWith(closedOn: DateTime.now());
      await _dbHelper.updateMonth(oldMonth);
    }
  }
}
