import 'package:budgetmanager/domain/entities/budget_by_month.dart';
import 'package:budgetmanager/domain/entities/month.dart';
import 'package:budgetmanager/domain/entities/regular_payment.dart';
import 'package:budgetmanager/domain/entities/regular_payment_snapshot.dart';
import 'package:budgetmanager/domain/repositories/budget_by_month_repository.dart';
import 'package:budgetmanager/domain/repositories/month_repository.dart';
import 'package:budgetmanager/domain/repositories/regular_payment_repository.dart';
import 'package:budgetmanager/domain/repositories/regular_payment_snapshot_repository.dart';
import 'package:budgetmanager/domain/use_cases/month/close_month_use_case.dart';
import 'package:budgetmanager/router/app_router.dart';
import 'package:budgetmanager/screens/components/custom_list_tile.dart';
import 'package:budgetmanager/screens/live/index/index_bloc.dart';
import 'package:budgetmanager/screens/live/index/index_view.dart';
import 'package:budgetmanager/theme/app_theme_id.dart';
import 'package:budgetmanager/theme/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('live month renders regular payments as silent display rows', (
    tester,
  ) async {
    final monthRepository = _MonthRepository(
      Month(8, 3000, 'September 2026', [], DateTime(2026, 9), null),
    );
    final regularRepository = _RegularPaymentRepository([
      const RegularPayment(id: 1, name: 'Rent', amount: 900, months: {9}),
      const RegularPayment(id: 2, name: 'Streaming', amount: 15.5, months: {9}),
    ]);
    final snapshotRepository = _SnapshotRepository();
    final bloc = IndexBloc(
      AppRouter(),
      monthRepository,
      _BudgetRepository([BudgetByMonth(1, 'Food', 100, 400)]),
      regularRepository,
      snapshotRepository,
      CloseMonthUseCase(monthRepository, regularRepository, snapshotRepository),
    )..add(const IndexEvent.started(monthId: 8));
    addTearDown(bloc.close);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemes.themeFor(AppThemeId.lightPlain),
        home: BlocProvider.value(value: bloc, child: const IndexView()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1015.50 of 3000 €'), findsOneWidget);
    expect(find.text('1315.50 €'), findsOneWidget);
    expect(find.text('REGULAR PAYMENTS'), findsOneWidget);
    expect(find.text('Rent'), findsOneWidget);
    expect(find.text('900 €'), findsOneWidget);
    expect(find.text('Streaming'), findsOneWidget);
    expect(find.text('15.50 €'), findsOneWidget);

    final regularTiles = tester
        .widgetList<CustomListTile>(find.byType(CustomListTile))
        .where((tile) => tile.title == 'Rent' || tile.title == 'Streaming');
    expect(regularTiles, hasLength(2));
    expect(
      regularTiles.every((tile) => tile.silent && tile.onTap == null),
      isTrue,
    );
  });
}

class _MonthRepository implements MonthRepository {
  final Month month;

  _MonthRepository(this.month);

  @override
  Future<Month?> getMonth(int id) async => month;

  @override
  Future<void> closeMonth(int monthId) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _BudgetRepository implements BudgetByMonthRepository {
  final List<BudgetByMonth> budgets;

  _BudgetRepository(this.budgets);

  @override
  Future<List<BudgetByMonth>> getBudgetsByMonth(int monthId) async => budgets;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _RegularPaymentRepository implements RegularPaymentRepository {
  final List<RegularPayment> payments;

  _RegularPaymentRepository(this.payments);

  @override
  Future<List<RegularPayment>> getByMonth(int month) async => payments;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SnapshotRepository implements RegularPaymentSnapshotRepository {
  @override
  Future<int> create(RegularPaymentSnapshot snapshot) async => 1;

  @override
  Future<RegularPaymentSnapshot?> getByMonthId(int monthId) async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
