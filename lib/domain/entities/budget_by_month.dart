import 'dart:math';

class BudgetByMonth {
  final int id;
  final String name;
  final double currentUsed;
  final double limit;

  BudgetByMonth(this.id, this.name, this.currentUsed, this.limit);

  factory BudgetByMonth.empty() {
    return BudgetByMonth(0, '', 0.0, 0.0);
  }

  factory BudgetByMonth.dummy() {
    Random random = Random();
    return BudgetByMonth(
      random.nextInt(1000),
      'Budget ${random.nextInt(100)}',
      (random.nextDouble() * 100).round() / 100,
      (random.nextDouble() * 1000).round() / 100,
    );
  }
}
