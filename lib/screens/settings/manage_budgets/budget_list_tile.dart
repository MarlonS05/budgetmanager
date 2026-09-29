import 'package:budgetmanager/domain/entities/budget.dart';
import 'package:budgetmanager/screens/components/custom_list_tile.dart';
import 'package:budgetmanager/screens/settings/manage_budgets/edit_budget_modal.dart';
import 'package:budgetmanager/screens/settings/manage_budgets/manage_budgets_bloc.dart';
import 'package:budgetmanager/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// List tile that displays a single budget and opens the edit modal on tap.
class BudgetListTile extends StatelessWidget {
  final Budget budget;

  const BudgetListTile({super.key, required this.budget});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bool isVisible = budget.hiddenOn == null;

    return CustomListTile(
      title: budget.name,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            size: 18,
            color: colors.mutedText,
          ),
          const SizedBox(width: 12),
          Text(
            '${budget.limit.toStringAsFixed(2)} €',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios_sharp, size: 16),
        ],
      ),
      onTap: () => _showEditBudgetModal(context, budget),
    );
  }

  void _showEditBudgetModal(BuildContext context, Budget budget) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => BlocProvider.value(
        value: BlocProvider.of<ManageBudgetsBloc>(context),
        child: EditBudgetModal(budget: budget),
      ),
    );
  }
}
