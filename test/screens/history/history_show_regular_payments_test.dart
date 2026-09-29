import 'package:budgetmanager/domain/entities/budget_by_month.dart';
import 'package:budgetmanager/domain/entities/month.dart';
import 'package:budgetmanager/domain/entities/regular_payment_snapshot.dart';
import 'package:budgetmanager/domain/repositories/month_repository.dart';
import 'package:budgetmanager/domain/repositories/regular_payment_snapshot_repository.dart';
import 'package:budgetmanager/router/app_router.dart';
import 'package:budgetmanager/screens/components/custom_list_tile.dart';
import 'package:budgetmanager/screens/history/history_show/history_show_bloc.dart';
import 'package:budgetmanager/screens/history/history_show/history_show_view.dart';
import 'package:budgetmanager/theme/app_theme_id.dart';
import 'package:budgetmanager/theme/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('history uses the frozen regular-payment snapshot', (
    tester,
  ) async {
    final month = Month(
      8,
      3000,
      'September 2026',
      [BudgetByMonth(1, 'Food', 100, 400)],
      DateTime(2026, 9),
      DateTime(2026, 10, 1),
    );
    final bloc = HistoryShowBloc(
      AppRouter(),
      _MonthRepository(month),
      _SnapshotRepository(
        const RegularPaymentSnapshot(
          id: 3,
          monthId: 8,
          amount: 915.5,
          items: ['Rent', 'Streaming'],
        ),
      ),
    )..add(const HistoryShowEvent.started(monthId: 8));
    addTearDown(bloc.close);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemes.themeFor(AppThemeId.lightPlain),
        home: BlocProvider.value(value: bloc, child: const HistoryShowView()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1015.50 of 3000 €'), findsOneWidget);
    expect(find.text('REGULAR PAYMENTS'), findsOneWidget);
    expect(find.text('Rent'), findsOneWidget);
    expect(find.text('Streaming'), findsOneWidget);
    expect(find.text('915.50 €'), findsOneWidget);

    final regularTiles = tester
        .widgetList<CustomListTile>(find.byType(CustomListTile))
        .where(
          (tile) =>
              tile.title == 'Rent' ||
              tile.title == 'Streaming' ||
              tile.title == 'Total',
        );
    expect(regularTiles, hasLength(3));
    expect(regularTiles.every((tile) => tile.silent), isTrue);
  });
}

class _MonthRepository implements MonthRepository {
  final Month month;

  _MonthRepository(this.month);

  @override
  Future<Month?> getMonth(int id) async => month;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SnapshotRepository implements RegularPaymentSnapshotRepository {
  final RegularPaymentSnapshot snapshot;

  _SnapshotRepository(this.snapshot);

  @override
  Future<RegularPaymentSnapshot?> getByMonthId(int monthId) async => snapshot;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
