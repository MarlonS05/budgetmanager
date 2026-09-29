import 'package:budgetmanager/domain/entities/budget_by_month.dart';
import 'package:budgetmanager/screens/components/app_dialog.dart';
import 'package:budgetmanager/screens/components/budget_by_month_list_tile.dart';
import 'package:budgetmanager/screens/components/custom_list_tile.dart';
import 'package:budgetmanager/screens/components/custom_list_view.dart';
import 'package:budgetmanager/screens/components/layout/title_bar.dart';
import 'package:budgetmanager/screens/components/section_label.dart';
import 'package:budgetmanager/screens/components/summary_stat_card.dart';
import 'package:budgetmanager/screens/live/index/index_bloc.dart';
import 'package:budgetmanager/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class IndexView extends StatelessWidget {
  const IndexView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<IndexBloc, IndexState>(
      listener: (context, state) {
        final message = state.errorMessage;
        if (message != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      },
      builder: (context, state) {
        final nextMonth = state.month.date.month != 12
            ? DateTime(
                state.month.date.year,
                state.month.date.month + 1,
                state.month.date.day,
              )
            : DateTime(state.month.date.year + 1, 1, state.month.date.day);
        final canClose =
            nextMonth.isBefore(DateTime.now()) && state.month.closedOn == null;
        final income = state.month.income;
        final budgeted = state.incomeBudgeted;
        final budgetedPct = income > 0 ? (budgeted / income * 100) : 0.0;
        final spentPct = income > 0
            ? (state.incomeSpent / income * 100).round()
            : 0;
        final snapshotItems = state.regularPaymentSnapshot?.items ?? const [];
        final hasRegularPayments = state.month.closedOn == null
            ? state.regularPayments.isNotEmpty
            : snapshotItems.isNotEmpty;

        return Scaffold(
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canClose)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FloatingActionButton(
                    heroTag: 'close_month',
                    backgroundColor: colors.error,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    onPressed: () {
                      showAppDialog(
                        context: context,
                        title: 'Close Month',
                        content:
                            'You are about to close this month. This cannot be undone.\nReview your budget spendings, then return and tap approve.',
                        cancelLabel: 'Cancel',
                        confirmLabel: 'Approve',
                        isDestructive: true,
                        onConfirm: () {
                          context.read<IndexBloc>().add(
                            const IndexEvent.closeMonth(),
                          );
                        },
                      );
                    },
                    child: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ),
              FloatingActionButton.small(
                heroTag: 'refresh',
                backgroundColor: colors.surfaceSecondary,
                foregroundColor: colors.onScaffold,
                onPressed: () {
                  context.read<IndexBloc>().add(const IndexEvent.refresh());
                },
                child: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScreenHeader(title: state.month.name),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        SummaryStatCard(
                          label: 'Income spent',
                          value:
                              '${_fmt(state.incomeSpent)} of ${_fmt(income)} €',
                          badge: '$spentPct%',
                        ),
                        const SizedBox(width: 12),
                        SummaryStatCard(
                          label: 'Budgeted income',
                          value: '${_fmt(budgeted)} €',
                          badge: '${budgetedPct.toStringAsFixed(0)}%',
                        ),
                      ],
                    ),
                  ),
                  if (canClose)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.errorBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colors.error),
                        ),
                        child: Text(
                          'You are editing in an old Month. Please close this month before adding current expenses!',
                          style: textTheme.bodyLarge?.copyWith(
                            color: colors.error,
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: SectionLabel('Budgets'),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: CustomListView(
                        children: [
                          ...state.budgets.map(
                            (BudgetByMonth budget) => BudgetByMonthListTile(
                              budget,
                              () => context.push(
                                '/index/${state.month.id}/budget/${budget.id}',
                              ),
                            ),
                          ),
                          if (hasRegularPayments) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Divider(
                                height: 1,
                                thickness: 1,
                                color: colors.border,
                              ),
                            ),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: SectionLabel('Regular payments'),
                            ),
                            if (state.month.closedOn == null)
                              ...state.regularPayments.map(
                                (payment) => CustomListTile(
                                  title: payment.name,
                                  trailing: Text(
                                    '${_fmt(payment.amount)} €',
                                    style: textTheme.titleLarge,
                                  ),
                                  silent: true,
                                ),
                              )
                            else
                              ...snapshotItems.map(
                                (name) =>
                                    CustomListTile(title: name, silent: true),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _fmt(double value) {
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value.toStringAsFixed(2);
  }
}
