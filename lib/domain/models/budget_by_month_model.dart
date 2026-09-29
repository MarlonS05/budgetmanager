import 'package:budgetmanager/domain/entities/budget_by_month.dart';

class BudgetByMonthModel {
  final int id;
  final int monthId;
  final int budgetId;
  final String budgetName;
  final double currentUsed;
  final double oldLimit;

  BudgetByMonthModel({
    required this.id,
    required this.monthId,
    required this.budgetId,
    required this.budgetName,
    required this.currentUsed,
    required this.oldLimit,
  });

  factory BudgetByMonthModel.empty() {
    return BudgetByMonthModel(
      id: 0,
      monthId: 0,
      budgetId: 0,
      budgetName: '',
      currentUsed: 0.0,
      oldLimit: 0.0,
    );
  }

  factory BudgetByMonthModel.fromMap(Map<String, dynamic> map) {
    return BudgetByMonthModel(
      id: (map['id'] as num?)?.toInt() ?? 0,
      monthId: (map['month_id'] as num).toInt(),
      budgetId: (map['budget_id'] as num).toInt(),
      budgetName: (map['budget_name'] as String?) ?? '',
      currentUsed: (map['current_used'] as num).toDouble(),
      oldLimit: (map['old_limit'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != 0) 'id': id,
      'month_id': monthId,
      'budget_id': budgetId,
      'current_used': currentUsed,
      'old_limit': oldLimit,
    };
  }

  BudgetByMonth toEntity() {
    return BudgetByMonth(id, budgetName, currentUsed, oldLimit);
  }

  factory BudgetByMonthModel.fromEntity(
    BudgetByMonth budget, {
    required int monthId,
    required int budgetId,
  }) {
    return BudgetByMonthModel(
      id: budget.id,
      monthId: monthId,
      budgetId: budgetId,
      budgetName: budget.name,
      currentUsed: budget.currentUsed,
      oldLimit: budget.limit,
    );
  }
}
