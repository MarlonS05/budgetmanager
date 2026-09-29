import 'package:budgetmanager/screens/components/custom_list_view.dart';
import 'package:budgetmanager/screens/components/layout/title_bar.dart';
import 'package:budgetmanager/screens/settings/manage_budgets/budget_list_tile.dart';
import 'package:budgetmanager/screens/settings/manage_budgets/create_budget_modal.dart';
import 'package:budgetmanager/screens/settings/manage_budgets/manage_budgets_bloc.dart';
import 'package:budgetmanager/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ManageBudgetsView extends StatelessWidget {
  const ManageBudgetsView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: BlocBuilder<ManageBudgetsBloc, ManageBudgetsState>(
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ScreenHeader(title: 'Manage Budgets'),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: state.budgets.isEmpty
                          ? Center(
                              child: Text(
                                'No budgets yet.\nTap + to add one.',
                                textAlign: TextAlign.center,
                                style: textTheme.bodyLarge?.copyWith(
                                  color: colors.mutedTextLight,
                                ),
                              ),
                            )
                          : CustomListView(
                              children: state.budgets
                                  .map(
                                    (budget) =>
                                        BudgetListTile(budget: budget),
                                  )
                                  .toList(),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colors.primaryAction,
        foregroundColor: colors.primaryActionForeground,
        onPressed: () => _showCreateBudgetModal(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateBudgetModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: BlocProvider.of<ManageBudgetsBloc>(context),
        child: const CreateBudgetModal(),
      ),
    );
  }
}
