import '../db/database_helper.dart';
import '../domain/entities/regular_payment_snapshot.dart';
import '../domain/models/regular_payment_snapshot_model.dart';
import '../domain/repositories/regular_payment_snapshot_repository.dart';

class RegularPaymentSnapshotRepositoryImpl
    implements RegularPaymentSnapshotRepository {
  final DatabaseHelper _dbHelper;

  RegularPaymentSnapshotRepositoryImpl(this._dbHelper);

  @override
  Future<int> create(RegularPaymentSnapshot snapshot) {
    return _dbHelper.insertRegularPaymentSnapshot(
      RegularPaymentSnapshotModel.fromEntity(snapshot),
    );
  }

  @override
  Future<RegularPaymentSnapshot?> getByMonthId(int monthId) async {
    final model = await _dbHelper.getRegularPaymentSnapshotByMonthId(monthId);
    return model?.toEntity();
  }

  @override
  Future<Map<int, RegularPaymentSnapshot>> getByMonthIds(
    List<int> monthIds,
  ) async {
    final models = await _dbHelper.getRegularPaymentSnapshotsByMonthIds(
      monthIds,
    );
    return {for (final model in models) model.monthId: model.toEntity()};
  }
}
