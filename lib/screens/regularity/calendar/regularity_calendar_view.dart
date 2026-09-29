import 'package:budgetmanager/domain/entities/regular_payment.dart';
import 'package:budgetmanager/screens/components/app_dialog.dart';
import 'package:budgetmanager/screens/components/custom_list_tile.dart';
import 'package:budgetmanager/screens/components/layout/title_bar.dart';
import 'package:budgetmanager/screens/constants/month_names.dart';
import 'package:budgetmanager/screens/regularity/calendar/regularity_calendar_bloc.dart';
import 'package:budgetmanager/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegularityCalendarView extends StatelessWidget {
  const RegularityCalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: BlocConsumer<RegularityCalendarBloc, RegularityCalendarState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScreenHeader(
                  title: 'Regularity Calendar',
                  onBack: () {
                    context.read<RegularityCalendarBloc>().add(
                      const RegularityCalendarEvent.backTapped(),
                    );
                  },
                ),
                Expanded(
                  child: state.isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: colors.primaryAction,
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                DateTime.now().year.toString(),
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colors.mutedText,
                                ),
                              ),
                              const SizedBox(height: 12),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: 12,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: 1.05,
                                    ),
                                itemBuilder: (context, index) {
                                  final month = index + 1;
                                  final payments = state.payments
                                      .where(
                                        (payment) =>
                                            payment.occursInMonth(month),
                                      )
                                      .toList();
                                  final total = payments.fold<double>(
                                    0,
                                    (sum, payment) => sum + payment.amount,
                                  );
                                  return _MonthCell(
                                    month: MonthNames.short[index],
                                    total: total,
                                    onTap: () => _showMonthDialog(
                                      context,
                                      month,
                                      payments,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 54,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colors.primaryAction,
                                    foregroundColor:
                                        colors.primaryActionForeground,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    context.read<RegularityCalendarBloc>().add(
                                      const RegularityCalendarEvent.openCreate(),
                                    );
                                  },
                                  child: const Icon(Icons.add),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showMonthDialog(
    BuildContext context,
    int month,
    List<RegularPayment> payments,
  ) async {
    final bloc = context.read<RegularityCalendarBloc>();
    final colors = context.appColors;
    final paymentId = await showAppDialog<int>(
      context: context,
      title: MonthNames.long[month - 1],
      contentWidget: _RegularityMonthContent(payments: payments),
      cancelLabel: null,
      barrierColor: colors.onScaffold.withValues(alpha: 0.5),
    );
    if (paymentId != null) {
      bloc.add(RegularityCalendarEvent.openEdit(id: paymentId));
    }
  }
}

class _MonthCell extends StatelessWidget {
  const _MonthCell({
    required this.month,
    required this.total,
    required this.onTap,
  });

  final String month;
  final double total;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(month.toUpperCase(), style: textTheme.labelMedium),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_formatAmount(total)} €',
                  style: textTheme.titleLarge,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RegularityMonthContent extends StatelessWidget {
  const _RegularityMonthContent({required this.payments});

  final List<RegularPayment> payments;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;
    final total = payments.fold<double>(
      0,
      (sum, payment) => sum + payment.amount,
    );

    return SizedBox(
      width: double.maxFinite,
      height: MediaQuery.sizeOf(context).height * 0.52,
      child: Column(
        children: [
          Expanded(
            child: payments.isEmpty
                ? Center(
                    child: Text(
                      'No regular payments in this month.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: colors.mutedText,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: payments.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final payment = payments[index];
                      return CustomListTile(
                        title: payment.name,
                        subtitle: '${_formatAmount(payment.amount)} €',
                        onTap: () => Navigator.of(context).pop(payment.id),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceSecondary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                Expanded(child: Text('TOTAL', style: textTheme.labelMedium)),
                Text('${_formatAmount(total)} €', style: textTheme.titleLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatAmount(double value) {
  return value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);
}
