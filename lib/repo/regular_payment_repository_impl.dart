import '../db/database_helper.dart';
import '../domain/entities/regular_payment.dart';
import '../domain/models/regular_payment_model.dart';
import '../domain/repositories/regular_payment_repository.dart';

class RegularPaymentRepositoryImpl implements RegularPaymentRepository {
  final DatabaseHelper _dbHelper;

  RegularPaymentRepositoryImpl(this._dbHelper);

  @override
  Future<List<RegularPayment>> getAll() async {
    final models = await _dbHelper.getAllRegularPayments();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<RegularPayment?> getById(int id) async {
    return (await _dbHelper.getRegularPaymentById(id))?.toEntity();
  }

  @override
  Future<List<RegularPayment>> getByMonth(int month) async {
    final models = await _dbHelper.getRegularPaymentsByMonth(month);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<int> create(RegularPayment payment) {
    return _dbHelper.insertRegularPayment(
      RegularPaymentModel.fromEntity(payment),
    );
  }

  @override
  Future<void> update(RegularPayment payment) async {
    await _dbHelper.updateRegularPayment(
      RegularPaymentModel.fromEntity(payment),
    );
  }

  @override
  Future<void> delete(int id) async {
    await _dbHelper.deleteRegularPayment(id);
  }
}
