import 'month.dart';

class MonthIncomeTotals {
  final double spent;
  final double budgeted;

  const MonthIncomeTotals({required this.spent, required this.budgeted});

  factory MonthIncomeTotals.fromMonth(
    Month month, {
    required double regularPayments,
  }) {
    return MonthIncomeTotals(
      spent: month.totalUsed + regularPayments,
      budgeted: month.budgetedIncomeAmount + regularPayments,
    );
  }
}
