import '../../entities/regular_payment_snapshot.dart';
import '../../repositories/month_repository.dart';
import '../../repositories/regular_payment_repository.dart';
import '../../repositories/regular_payment_snapshot_repository.dart';
import 'close_month_result.dart';

class CloseMonthUseCase {
  final MonthRepository _monthRepository;
  final RegularPaymentRepository _regularPaymentRepository;
  final RegularPaymentSnapshotRepository _snapshotRepository;

  const CloseMonthUseCase(
    this._monthRepository,
    this._regularPaymentRepository,
    this._snapshotRepository,
  );

  /// Persists the regular-payment snapshot first, then closes the month.
  ///
  /// The two writes stay on separate repository methods. Snapshot-first
  /// makes the freeze durable: a retry after a failed close reuses the
  /// already stored snapshot instead of recapturing live payments.
  Future<CloseMonthResult> call(int monthId) async {
    final month = await _monthRepository.getMonth(monthId);
    if (month == null) return CloseMonthResult.notFound;

    if (month.closedOn != null) return CloseMonthResult.completed;

    var snapshot = await _snapshotRepository.getByMonthId(monthId);
    if (snapshot == null) {
      final payments = await _regularPaymentRepository.getByMonth(
        month.date.month,
      );
      snapshot = RegularPaymentSnapshot(
        id: 0,
        monthId: monthId,
        amount: payments.fold(0, (sum, payment) => sum + payment.amount),
        items: payments.map((payment) => payment.name).toList(growable: false),
      );
      await _snapshotRepository.create(snapshot);
    }

    await _monthRepository.closeMonth(monthId);
    return CloseMonthResult.completed;
  }
}
