import '../entities/budget.dart';

class BudgetModel {
  final int id;
  final String name;
  final double limit;
  final DateTime? hiddenOn;

  BudgetModel({
    required this.id,
    required this.name,
    required this.limit,
    required this.hiddenOn,
  });

  factory BudgetModel.empty() {
    return BudgetModel(id: 0, name: 'empty', limit: 0, hiddenOn: null);
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: (map['id'] as num).toInt(),
      name: map['name'] as String,
      limit: (map['max_amount'] as num).toDouble(),
      hiddenOn: map['hiddenOn'] != null ? DateTime.parse(map['hiddenOn'] as String) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != 0) 'id': id,
      'name': name,
      'max_amount': limit,
      'hiddenOn': hiddenOn?.toIso8601String(),
    };
  }

  Budget toEntity() {
    return Budget(id: id, name: name, limit: limit, hiddenOn: hiddenOn);
  }

  factory BudgetModel.fromEntity(Budget budget) {
    return BudgetModel(
      id: budget.id,
      name: budget.name,
      limit: budget.limit,
      hiddenOn: budget.hiddenOn,
    );
  }
}
