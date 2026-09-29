import 'dart:async';

import 'package:budgetmanager/domain/entities/regular_payment.dart';
import 'package:budgetmanager/domain/repositories/regular_payment_repository.dart';
import 'package:budgetmanager/router/app_router.dart';
import 'package:budgetmanager/screens/regularity/calendar/regularity_calendar_bloc.dart';
import 'package:budgetmanager/screens/regularity/edit/regularity_edit_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calendar clears loading and exposes repository failures', () async {
    final bloc = RegularityCalendarBloc(AppRouter(), _FailingRepository());

    final expectation = expectLater(
      bloc.stream,
      emitsThrough(
        predicate<RegularityCalendarState>(
          (state) =>
              !state.isLoading &&
              state.errorMessage == 'Could not load regular payments.',
        ),
      ),
    );
    bloc.add(const RegularityCalendarEvent.started());

    await expectation;
    await bloc.close();
  });

  test('edit pops when loading the existing entry throws', () async {
    final router = _RecordingRouter();
    final bloc = RegularityEditBloc(router, _FailingRepository());
    bloc.add(const RegularityEditEvent.started(id: 42));

    await router.popped;
    expect(bloc.state.isLoading, isTrue);
    await bloc.close();
  });

  test('edit pops when the existing entry is missing', () async {
    final router = _RecordingRouter();
    final bloc = RegularityEditBloc(router, _MissingRepository());
    bloc.add(const RegularityEditEvent.started(id: 42));

    await router.popped;
    expect(bloc.state.isLoading, isTrue);
    await bloc.close();
  });

  test(
    'edit pops malformed identifiers without querying the repository',
    () async {
      final router = _RecordingRouter();
      final repository = _MissingRepository();
      final bloc = RegularityEditBloc(router, repository);
      bloc.add(const RegularityEditEvent.started(id: -1));

      await router.popped;
      expect(repository.getByIdCalls, 0);
      await bloc.close();
    },
  );

  test('edit ignores back while saving and pops once after success', () async {
    final router = _RecordingRouter();
    final repository = _PendingWriteRepository();
    final bloc = RegularityEditBloc(router, repository);

    await _startCreateReadyToSave(bloc);

    final saving = bloc.stream.firstWhere((state) => state.isSaving);
    bloc.add(const RegularityEditEvent.saveTapped());
    await saving;
    bloc.add(const RegularityEditEvent.backTapped());
    await Future<void>.delayed(Duration.zero);
    expect(router.popCount, 0);

    repository.createResult.complete(1);
    await router.popped;
    expect(router.popCount, 1);
    await bloc.close();
  });

  test('edit drops a second save while the first write is pending', () async {
    final router = _RecordingRouter();
    final repository = _PendingWriteRepository();
    final bloc = RegularityEditBloc(router, repository);

    await _startCreateReadyToSave(bloc);

    final saving = bloc.stream.firstWhere((state) => state.isSaving);
    bloc
      ..add(const RegularityEditEvent.saveTapped())
      ..add(const RegularityEditEvent.saveTapped());
    await saving;
    await Future<void>.delayed(Duration.zero);

    expect(repository.createCalls, 1);
    expect(router.popCount, 0);

    repository.createResult.complete(1);
    await router.popped;
    expect(repository.createCalls, 1);
    expect(router.popCount, 1);
    await bloc.close();
  });

  test('edit drops delete while a save write is pending', () async {
    final router = _RecordingRouter();
    final repository = _PendingWriteRepository(
      existing: const RegularPayment(
        id: 7,
        name: 'Rent',
        amount: 100,
        months: {1},
      ),
    );
    final bloc = RegularityEditBloc(router, repository);

    final loaded = bloc.stream.firstWhere((state) => !state.isLoading);
    bloc.add(const RegularityEditEvent.started(id: 7));
    await loaded;

    final saving = bloc.stream.firstWhere((state) => state.isSaving);
    bloc
      ..add(const RegularityEditEvent.saveTapped())
      ..add(const RegularityEditEvent.deleteConfirmed());
    await saving;
    await Future<void>.delayed(Duration.zero);

    expect(repository.updateCalls, 1);
    expect(repository.deleteCalls, 0);
    expect(router.popCount, 0);

    repository.updateResult.complete();
    await router.popped;
    expect(repository.updateCalls, 1);
    expect(repository.deleteCalls, 0);
    expect(router.popCount, 1);
    await bloc.close();
  });

  test(
    'calendar ignores create and edit pushes until the active push returns',
    () async {
      final router = _PendingPushRouter();
      final bloc = RegularityCalendarBloc(router, _EmptyRepository());

      bloc.add(const RegularityCalendarEvent.openCreate());
      await router.firstPush.future;
      bloc
        ..add(const RegularityCalendarEvent.openCreate())
        ..add(const RegularityCalendarEvent.openEdit(id: 7));
      await Future<void>.delayed(Duration.zero);

      expect(router.pushedPaths, ['/regularity/edit']);

      router.pushGate.complete();
      await bloc.stream.firstWhere((state) => !state.isLoading);

      bloc.add(const RegularityCalendarEvent.openEdit(id: 7));
      await router.secondPush.future;
      expect(router.pushedPaths, ['/regularity/edit', '/regularity/edit/7']);
      await bloc.close();
    },
  );
}

Future<void> _startCreateReadyToSave(RegularityEditBloc bloc) async {
  final loaded = bloc.stream.firstWhere((state) => !state.isLoading);
  bloc.add(const RegularityEditEvent.started());
  await loaded;

  final formReady = bloc.stream.firstWhere(
    (state) =>
        state.name == 'Rent' &&
        state.amountText == '100' &&
        state.months.contains(1),
  );
  bloc
    ..add(const RegularityEditEvent.nameChanged(name: 'Rent'))
    ..add(const RegularityEditEvent.amountChanged(amount: '100'))
    ..add(const RegularityEditEvent.monthToggled(month: 1));
  await formReady;
}

class _RecordingRouter extends AppRouter {
  final _popped = Completer<void>();
  int popCount = 0;

  Future<void> get popped => _popped.future;

  @override
  void pop() {
    popCount++;
    if (!_popped.isCompleted) _popped.complete();
  }
}

class _FailingRepository implements RegularPaymentRepository {
  Never _fail() => throw Exception('Database unavailable');

  @override
  Future<int> create(RegularPayment payment) async => _fail();

  @override
  Future<void> delete(int id) async => _fail();

  @override
  Future<List<RegularPayment>> getAll() async => _fail();

  @override
  Future<RegularPayment?> getById(int id) async => _fail();

  @override
  Future<List<RegularPayment>> getByMonth(int month) async => _fail();

  @override
  Future<void> update(RegularPayment payment) async => _fail();
}

class _MissingRepository implements RegularPaymentRepository {
  int getByIdCalls = 0;

  @override
  Future<RegularPayment?> getById(int id) async {
    getByIdCalls++;
    return null;
  }

  @override
  Future<int> create(RegularPayment payment) => throw UnimplementedError();

  @override
  Future<void> delete(int id) => throw UnimplementedError();

  @override
  Future<List<RegularPayment>> getAll() => throw UnimplementedError();

  @override
  Future<List<RegularPayment>> getByMonth(int month) =>
      throw UnimplementedError();

  @override
  Future<void> update(RegularPayment payment) => throw UnimplementedError();
}

class _PendingWriteRepository implements RegularPaymentRepository {
  _PendingWriteRepository({this.existing});

  final RegularPayment? existing;
  final createResult = Completer<int>();
  final updateResult = Completer<void>();
  int createCalls = 0;
  int updateCalls = 0;
  int deleteCalls = 0;

  @override
  Future<int> create(RegularPayment payment) {
    createCalls++;
    return createResult.future;
  }

  @override
  Future<void> delete(int id) async {
    deleteCalls++;
  }

  @override
  Future<List<RegularPayment>> getAll() => throw UnimplementedError();

  @override
  Future<RegularPayment?> getById(int id) async => existing;

  @override
  Future<List<RegularPayment>> getByMonth(int month) =>
      throw UnimplementedError();

  @override
  Future<void> update(RegularPayment payment) {
    updateCalls++;
    return updateResult.future;
  }
}

class _EmptyRepository implements RegularPaymentRepository {
  @override
  Future<int> create(RegularPayment payment) => throw UnimplementedError();

  @override
  Future<void> delete(int id) => throw UnimplementedError();

  @override
  Future<List<RegularPayment>> getAll() async => [];

  @override
  Future<RegularPayment?> getById(int id) => throw UnimplementedError();

  @override
  Future<List<RegularPayment>> getByMonth(int month) =>
      throw UnimplementedError();

  @override
  Future<void> update(RegularPayment payment) => throw UnimplementedError();
}

class _PendingPushRouter extends AppRouter {
  final firstPush = Completer<void>();
  final secondPush = Completer<void>();
  final pushGate = Completer<void>();
  final pushedPaths = <String>[];

  @override
  Future<T?> push<T extends Object?>(String path, {Object? extra}) async {
    pushedPaths.add(path);
    if (!firstPush.isCompleted) {
      firstPush.complete();
    } else if (!secondPush.isCompleted) {
      secondPush.complete();
    }
    await pushGate.future;
    return null;
  }
}
