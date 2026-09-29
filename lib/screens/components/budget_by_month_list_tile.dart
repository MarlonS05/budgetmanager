import 'package:budgetmanager/domain/entities/budget_by_month.dart';
import 'package:budgetmanager/screens/components/box_used_of_max.dart';
import 'package:budgetmanager/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

class BudgetByMonthListTile extends StatelessWidget {
  final BudgetByMonth budget;
  final VoidCallback onTap;
  final bool silent;

  const BudgetByMonthListTile(
    this.budget,
    this.onTap, {
    super.key,
    this.silent = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: silent ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(budget.name, style: textTheme.titleLarge),
              const SizedBox(height: 10),
              ProgressPill(budget.currentUsed, budget.limit),
            ],
          ),
        ),
      ),
    );
  }
}
