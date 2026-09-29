import 'package:budgetmanager/domain/entities/budget_by_month.dart';
import 'package:budgetmanager/domain/entities/month.dart';
import 'package:budgetmanager/domain/entities/month_income_totals.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('adds regular payments to spent and budgeted income', () {
    final month = Month(
      1,
      3000,
      'September 2026',
      [BudgetByMonth(1, 'Food', 125, 400), BudgetByMonth(2, 'Fun', 75, 200)],
      DateTime(2026, 9),
      null,
    );

    final totals = MonthIncomeTotals.fromMonth(month, regularPayments: 950);

    expect(totals.spent, 1150);
    expect(totals.budgeted, 1550);
  });
}
