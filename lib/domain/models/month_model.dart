import 'package:budgetmanager/domain/models/budget_by_month_model.dart';

import '../entities/month.dart';

class MonthModel {
  final int id;
  final DateTime? closedOn;
  final DateTime date;
  final double income;
  final List<BudgetByMonthModel> budgets;

  MonthModel({
    required this.id,
    required this.closedOn,
    required this.date,
    required this.income,
    required this.budgets,
  });

  factory MonthModel.empty() {
    return MonthModel(
      id: 0,
      date: DateTime.now(),
      closedOn: null,
      income: 0.0,
      budgets: [],
    );
  }

  factory MonthModel.fromMap(
    Map<String, dynamic> map,
    List<BudgetByMonthModel> budgets,
  ) {
    return MonthModel(
      id: (map['id'] as num).toInt(),
      date: DateTime.parse(map['date'] as String),
      closedOn: map['closedOn'] != null ? DateTime.parse(map['closedOn'] as String) : null,
      income: (map['income'] as num).toDouble(),
      budgets: budgets,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != 0) 'id': id,
      'date': date.toIso8601String(),
      'closedOn': closedOn?.toIso8601String(),
      'income': income,
    };
  }

  // to entity
  Month toEntity() {
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    String name = '${monthNames[date.month - 1]} ${date.year}';
    return Month(
      id,
      income,
      name,
      budgets.map((b) => b.toEntity()).toList(),
      date,
      closedOn,
    );
  }

  factory MonthModel.fromEntity(Month month) {
    return MonthModel(
      id: month.id,
      date: month.date,
      closedOn: month.closedOn,
      income: month.income,
      budgets: month.budgets
          .map(
            (b) => BudgetByMonthModel(
              id: b.id,
              monthId: month.id,
              budgetId: b.id,
              budgetName: b.name,
              currentUsed: b.currentUsed,
              oldLimit: b.limit,
            ),
          )
          .toList(),
    );
  }

  MonthModel copyWith({
    int? id,
    DateTime? closedOn,
    DateTime? date,
    double? income,
    List<BudgetByMonthModel>? budgets,
  }) {
    return MonthModel(
      id: id ?? this.id,
      closedOn: closedOn ?? this.closedOn,
      date: date ?? this.date,
      income: income ?? this.income,
      budgets: budgets ?? this.budgets,
    );
  }
}
