import 'package:budgetmanager/domain/entities/month.dart';
import 'package:budgetmanager/screens/components/nav_card.dart';
import 'package:budgetmanager/screens/home/home_bloc.dart';
import 'package:budgetmanager/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final month = state.currentMonth;
          final spent = state.incomeTotals.spent;
          final progress = month.income > 0 ? spent / month.income : 0.0;
          final percent = (progress * 100).clamp(0, 999).toInt();

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onLongPress: () {
                      context.read<HomeBloc>().add(HomeEvent.refresh());
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BUDGET MANAGER', style: textTheme.labelMedium),
                        const SizedBox(height: 8),
                        Text('Budget\nManaged', style: textTheme.headlineLarge),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _CurrentMonthHeroCard(
                    month: month,
                    spent: spent,
                    percent: percent,
                    progress: progress.clamp(0.0, 1.0),
                    onTap: () =>
                        context.read<HomeBloc>().add(HomeEvent.openLive()),
                  ),
                  const SizedBox(height: 12),
                  NavCard(
                    title: 'History',
                    subtitle: 'Past months overview',
                    icon: Icons.history_rounded,
                    onTap: () =>
                        context.read<HomeBloc>().add(HomeEvent.openHistory()),
                  ),
                  NavCard(
                    title: 'Regularity Calendar',
                    subtitle: 'Recurring payments by month',
                    icon: Icons.calendar_month_outlined,
                    onTap: () => context.read<HomeBloc>().add(
                      const HomeEvent.openRegularity(),
                    ),
                  ),
                  NavCard(
                    title: 'Settings',
                    subtitle: 'Budgets, income & themes',
                    icon: Icons.settings_outlined,
                    onTap: () =>
                        context.read<HomeBloc>().add(HomeEvent.openSettings()),
                  ),
                  NavCard(
                    title: 'Analyse spending',
                    subtitle: 'Compare months with AI',
                    icon: Icons.auto_awesome_outlined,
                    onTap: () => context.read<HomeBloc>().add(
                      HomeEvent.openAiInsights(),
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

class _CurrentMonthHeroCard extends StatelessWidget {
  final Month month;
  final double spent;
  final int percent;
  final double progress;
  final VoidCallback onTap;

  const _CurrentMonthHeroCard({
    required this.month,
    required this.spent,
    required this.percent,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colors.navLive,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CURRENT MONTH',
                            style: textTheme.labelMedium?.copyWith(
                              color: colors.primaryActionForeground.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            month.name,
                            style: textTheme.headlineLarge?.copyWith(
                              color: colors.primaryActionForeground,
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_format(spent)} of ${_format(month.income)} € spent',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colors.primaryActionForeground.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '$percent%',
                      style: textTheme.headlineLarge?.copyWith(
                        color: colors.primaryActionForeground,
                        fontSize: 28,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 6,
                child: Row(
                  children: [
                    Expanded(
                      flex: (progress * 100).round().clamp(0, 100),
                      child: Container(color: colors.primaryActionForeground),
                    ),
                    Expanded(
                      flex: (100 - (progress * 100).round()).clamp(0, 100),
                      child: Container(
                        color: colors.primaryActionForeground.withValues(
                          alpha: 0.25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _format(double value) {
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value.toStringAsFixed(2);
  }
}
