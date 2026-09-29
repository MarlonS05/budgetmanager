import 'package:budgetmanager/domain/entities/month_income_totals.dart';
import 'package:budgetmanager/screens/components/custom_list_view.dart';
import 'package:budgetmanager/screens/components/layout/title_bar.dart';
import 'package:budgetmanager/screens/components/month_list_tile.dart';
import 'package:budgetmanager/screens/history/history_index/history_index_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HistoryIndexView extends StatelessWidget {
  const HistoryIndexView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<HistoryIndexBloc, HistoryIndexState>(
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ScreenHeader(title: 'History'),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: CustomListView(
                        children: state.months
                            .map(
                              (month) => MonthListTile(
                                month,
                                () => context.read<HistoryIndexBloc>().add(
                                  HistoryIndexEvent.openMonth(
                                    monthId: month.id,
                                  ),
                                ),
                                spentOverride: MonthIncomeTotals.fromMonth(
                                  month,
                                  regularPayments:
                                      state
                                          .regularPaymentSnapshots[month.id]
                                          ?.amount ??
                                      0,
                                ).spent,
                              ),
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
    );
  }
}
