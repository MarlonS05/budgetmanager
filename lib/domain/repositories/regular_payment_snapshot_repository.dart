import '../entities/regular_payment_snapshot.dart';

abstract interface class RegularPaymentSnapshotRepository {
  Future<RegularPaymentSnapshot?> getByMonthId(int monthId);
  Future<Map<int, RegularPaymentSnapshot>> getByMonthIds(List<int> monthIds);
  Future<int> create(RegularPaymentSnapshot snapshot);
}
