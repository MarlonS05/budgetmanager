import '../entities/month.dart';

abstract interface class MonthRepository {
  Future<List<Month>> getAllMonths();
  Future<Month?> getMonth(int id);
  Future<int> createMonth(Month month);
  Future<void> updateMonth(Month month);
  Future<void> deleteMonth(int id);
  Future<int> getCurrentMonthId();
  Future<void> closeMonth(int monthId);
}
