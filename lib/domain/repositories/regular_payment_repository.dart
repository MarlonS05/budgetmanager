import '../entities/regular_payment.dart';

abstract interface class RegularPaymentRepository {
  Future<List<RegularPayment>> getAll();
  Future<RegularPayment?> getById(int id);
  Future<List<RegularPayment>> getByMonth(int month);
  Future<int> create(RegularPayment payment);
  Future<void> update(RegularPayment payment);
  Future<void> delete(int id);
}
