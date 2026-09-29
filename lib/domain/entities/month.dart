import 'dart:math';

import 'package:budgetmanager/domain/entities/budget_by_month.dart';

class Month {
  final int id;
  final String name;
  final DateTime date;
  final DateTime? closedOn;
  final double income;
  final List<BudgetByMonth> budgets;

  Month(this.id, this.income, this.name, this.budgets, this.date, this.closedOn);

  factory Month.empty() {
    return Month(0, 0.0, '', [], DateTime.now(), null);
  }

  factory Month.dummy() {
    Random random = Random();
    return Month(
      random.nextInt(1000),
      (random.nextDouble() * 5000).round() / 100,
      'Month ${random.nextInt(12) + 1}',
      List.generate(random.nextInt(5) + 1, (_) => BudgetByMonth.dummy()),
      DateTime.now(),
      null,
    );
  }

  double get totalUsed => budgets.fold(0.0, (sum, b) => sum + b.currentUsed);

  // Sum of all budget limit values, representing how much income has been allocated to budgets
  double get budgetedIncomeAmount => budgets.fold(0.0, (sum, b) => sum + b.limit);
}
