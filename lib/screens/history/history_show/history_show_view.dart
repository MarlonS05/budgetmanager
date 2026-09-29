import 'package:budgetmanager/domain/entities/budget_by_month.dart';
import 'package:budgetmanager/screens/components/budget_by_month_list_tile.dart';
import 'package:budgetmanager/screens/components/custom_list_tile.dart';
import 'package:budgetmanager/screens/components/custom_list_view.dart';
import 'package:budgetmanager/screens/components/layout/title_bar.dart';
import 'package:budgetmanager/screens/components/section_label.dart';
import 'package:budgetmanager/screens/components/summary_stat_card.dart';
import 'package:budgetmanager/screens/history/history_show/history_show_bloc.dart';
import 'package:budgetmanager/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Read-only history detail view for a single month.
class HistoryShowView extends StatelessWidget {
  const HistoryShowView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<HistoryShowBloc, HistoryShowState>(
      builder: (context, state) {
        final spentPct = state.month.income > 0
            ? (state.incomeSpent / state.month.income * 100).round()
            : 0;
        final snapshot = state.regularPaymentSnapshot;
        final hasRegularPayments = snapshot?.items.isNotEmpty ?? false;

        return Scaffold(
          floatingActionButton: FloatingActionButton(
            backgroundColor: colors.primaryAction,
            foregroundColor: colors.primaryActionForeground,
            onPressed: () {
              context.read<HistoryShowBloc>().add(
                const HistoryShowEvent.edit(),
              );
            },
            child: const Icon(Icons.edit_note_rounded),
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
                              '${_fmt(state.incomeSpent)} of ${_fmt(state.month.income)} €',
                          badge: '$spentPct%',
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: CustomListView(
                        children: [
                          ...state.budgets.map(
                            (BudgetByMonth budget) => BudgetByMonthListTile(
                              budget,
                              () {},
                              silent: true,
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
                            ...snapshot!.items.map(
                              (name) =>
                                  CustomListTile(title: name, silent: true),
                            ),
                            CustomListTile(
                              title: 'Total',
                              trailing: Text(
                                '${_fmt(snapshot.amount)} €',
                                style: textTheme.titleLarge,
                              ),
                              silent: true,
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
