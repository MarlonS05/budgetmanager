import 'package:budgetmanager/domain/entities/budget.dart';
import '../../domain/entities/month.dart';

class BudgetDisplay {
  final Month month;
  final Budget budget;

  BudgetDisplay(this.month, this.budget);

  String get name => budget.name;
  double get limit => budget.limit;
}
