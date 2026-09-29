import 'package:budgetmanager/domain/entities/month.dart';
import 'package:budgetmanager/domain/entities/regular_payment.dart';
import 'package:budgetmanager/domain/entities/regular_payment_snapshot.dart';
import 'package:budgetmanager/domain/repositories/month_repository.dart';
import 'package:budgetmanager/domain/repositories/regular_payment_repository.dart';
import 'package:budgetmanager/domain/repositories/regular_payment_snapshot_repository.dart';
import 'package:budgetmanager/domain/use_cases/month/close_month_result.dart';
import 'package:budgetmanager/domain/use_cases/month/close_month_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CloseMonthUseCase', () {
    test('returns notFound when the month does not exist', () async {
      final monthRepository = _MonthRepository(null);
      final snapshotRepository = _SnapshotRepository();
      final useCase = CloseMonthUseCase(
        monthRepository,
        _RegularPaymentRepository([]),
        snapshotRepository,
      );

      expect(await useCase(12), CloseMonthResult.notFound);
      expect(monthRepository.closedMonthIds, isEmpty);
      expect(snapshotRepository.created, isEmpty);
    });

    test(
      'returns completed without writes when the month is already closed',
      () async {
        final monthRepository = _MonthRepository(
          _month(closedOn: DateTime(2026, 10, 1)),
        );
        final snapshotRepository = _SnapshotRepository();
        final useCase = CloseMonthUseCase(
          monthRepository,
          _RegularPaymentRepository([]),
          snapshotRepository,
        );

        expect(await useCase(12), CloseMonthResult.completed);
        expect(monthRepository.closedMonthIds, isEmpty);
        expect(snapshotRepository.created, isEmpty);
      },
    );

    test('saves the snapshot first, then closes', () async {
      final order = <String>[];
      final monthRepository = _MonthRepository(_month(), order: order);
      final snapshotRepository = _SnapshotRepository(order: order);
      final useCase = CloseMonthUseCase(
        monthRepository,
        _RegularPaymentRepository(_payments),
        snapshotRepository,
      );

      expect(await useCase(12), CloseMonthResult.completed);
      expect(order, ['snapshot', 'close']);
      expect(monthRepository.closedMonthIds, [12]);
      expect(snapshotRepository.created.single.items, ['Rent', 'Streaming']);
      expect(snapshotRepository.created.single.amount, 915.5);
    });

    test('saves an empty snapshot when there are no payments', () async {
      final snapshotRepository = _SnapshotRepository();
      final useCase = CloseMonthUseCase(
        _MonthRepository(_month()),
        _RegularPaymentRepository([]),
        snapshotRepository,
      );

      expect(await useCase(12), CloseMonthResult.completed);
      expect(snapshotRepository.created.single.items, isEmpty);
      expect(snapshotRepository.created.single.amount, 0);
    });

    test('does not close when snapshot create throws', () async {
      final monthRepository = _MonthRepository(_month());
      final snapshotRepository = _SnapshotRepository(failCreate: true);
      final useCase = CloseMonthUseCase(
        monthRepository,
        _RegularPaymentRepository(_payments),
        snapshotRepository,
      );

      await expectLater(useCase(12), throwsStateError);
      expect(monthRepository.closedMonthIds, isEmpty);
    });

    test('keeps the stored snapshot when close throws', () async {
      final monthRepository = _MonthRepository(_month(), failClose: true);
      final snapshotRepository = _SnapshotRepository();
      final useCase = CloseMonthUseCase(
        monthRepository,
        _RegularPaymentRepository(_payments),
        snapshotRepository,
      );

      await expectLater(useCase(12), throwsStateError);
      expect(monthRepository.closedMonthIds, isEmpty);
      expect(snapshotRepository.created, hasLength(1));
      expect(snapshotRepository.created.single.amount, 915.5);
    });

    test(
      'retry after a failed close only closes, without recapturing payments',
      () async {
        final order = <String>[];
        final monthRepository = _MonthRepository(
          _month(),
          order: order,
          failCloseOnce: true,
        );
        final snapshotRepository = _SnapshotRepository(order: order);
        final changingPayments = _RegularPaymentRepository(_payments);
        final useCase = CloseMonthUseCase(
          monthRepository,
          changingPayments,
          snapshotRepository,
        );

        await expectLater(useCase(12), throwsStateError);
        changingPayments.payments = const [
          RegularPayment(id: 9, name: 'Changed later', amount: 1, months: {9}),
        ];

        expect(await useCase(12), CloseMonthResult.completed);
        expect(order, ['snapshot', 'close', 'close']);
        expect(snapshotRepository.created, hasLength(1));
        expect(snapshotRepository.created.single.items, ['Rent', 'Streaming']);
        expect(monthRepository.closedMonthIds, [12]);
      },
    );

    test('duplicate close after success does not write again', () async {
      final monthRepository = _MonthRepository(_month());
      final snapshotRepository = _SnapshotRepository();
      final useCase = CloseMonthUseCase(
        monthRepository,
        _RegularPaymentRepository(_payments),
        snapshotRepository,
      );

      expect(await useCase(12), CloseMonthResult.completed);
      expect(await useCase(12), CloseMonthResult.completed);
      expect(monthRepository.closedMonthIds, [12]);
      expect(snapshotRepository.created, hasLength(1));
    });
  });
}

const _payments = [
  RegularPayment(id: 1, name: 'Rent', amount: 900, months: {9}),
  RegularPayment(id: 2, name: 'Streaming', amount: 15.5, months: {9}),
];

Month _month({DateTime? closedOn}) {
  return Month(12, 3000, 'September 2026', [], DateTime(2026, 9), closedOn);
}

class _MonthRepository implements MonthRepository {
  Month? month;
  final List<String>? order;
  final bool failClose;
  final bool failCloseOnce;
  var _failedCloseOnce = false;
  final List<int> closedMonthIds = [];

  _MonthRepository(
    this.month, {
    this.order,
    this.failClose = false,
    this.failCloseOnce = false,
  });

  @override
  Future<Month?> getMonth(int id) async => month;

  @override
  Future<void> closeMonth(int monthId) async {
    order?.add('close');
    if (failClose) throw StateError('close failed');
    if (failCloseOnce && !_failedCloseOnce) {
      _failedCloseOnce = true;
      throw StateError('close failed once');
    }
    closedMonthIds.add(monthId);
    final current = month;
    if (current != null) {
      month = Month(
        current.id,
        current.income,
        current.name,
        current.budgets,
        current.date,
        DateTime(2026, 10, 1),
      );
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _RegularPaymentRepository implements RegularPaymentRepository {
  List<RegularPayment> payments;

  _RegularPaymentRepository(this.payments);

  @override
  Future<List<RegularPayment>> getByMonth(int month) async {
    expect(month, 9);
    return payments;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SnapshotRepository implements RegularPaymentSnapshotRepository {
  final List<String>? order;
  final bool failCreate;
  final List<RegularPaymentSnapshot> created = [];

  _SnapshotRepository({this.order, this.failCreate = false});

  @override
  Future<int> create(RegularPaymentSnapshot snapshot) async {
    order?.add('snapshot');
    if (failCreate) throw StateError('create failed');
    created.add(snapshot);
    return created.length;
  }

  @override
  Future<RegularPaymentSnapshot?> getByMonthId(int monthId) async {
    for (final snapshot in created.reversed) {
      if (snapshot.monthId == monthId) return snapshot;
    }
    return null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
