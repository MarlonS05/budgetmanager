import 'package:budgetmanager/screens/components/adjust_button.dart';
import 'package:budgetmanager/screens/components/app_dialog.dart';
import 'package:budgetmanager/screens/components/layout/title_bar.dart';
import 'package:budgetmanager/screens/components/section_label.dart';
import 'package:budgetmanager/screens/live/show/show_bloc.dart';
import 'package:budgetmanager/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ShowView extends StatefulWidget {
  const ShowView({super.key});

  @override
  State<ShowView> createState() => _ShowViewState();
}

class _ShowViewState extends State<ShowView> {
  late final TextEditingController _customController;

  @override
  void initState() {
    super.initState();
    _customController = TextEditingController();
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  double _parseAmount() {
    final raw = _customController.text.trim();
    final normalized = raw.replaceAll(',', '.');
    return double.tryParse(normalized) ?? 0.0;
  }

  Future<void> _showFillToMaxDialog(BuildContext context) async {
    final bloc = context.read<ShowBloc>();

    return showAppDialog(
      context: context,
      title: 'Fill Budget to Max?',
      content: 'Do you want to set the used amount to the budget limit?',
      confirmLabel: 'Accept',
      onConfirm: () => bloc.add(const ShowEvent.fillToMax()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: BlocBuilder<ShowBloc, ShowState>(
        builder: (context, state) {
          final budget = state.budget;
          final ratio = budget.limit > 0 ? budget.currentUsed / budget.limit : 0.0;
          final percentUsed = (ratio * 100).clamp(0, 999).round();
          final remaining = (budget.limit - budget.currentUsed).clamp(0, double.infinity);

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ScreenHeader(title: budget.name),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          _formatAmount(budget.currentUsed),
                          textAlign: TextAlign.center,
                          style: textTheme.displayLarge,
                        ),
                        GestureDetector(
                          onLongPress: () => _showFillToMaxDialog(context),
                          child: Text(
                            'of ${_formatAmount(budget.limit)} €',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyLarge?.copyWith(
                              fontSize: 20,
                              color: colors.mutedText,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: ratio.clamp(0.0, 1.0),
                            minHeight: 10,
                            backgroundColor: colors.budgetRemaining,
                            valueColor: AlwaysStoppedAnimation(
                              colors.progressFillFor(
                                budget.currentUsed,
                                budget.limit,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$percentUsed% used',
                              style: textTheme.bodySmall,
                            ),
                            Text(
                              '${_formatAmount(remaining.toDouble())} € left',
                              style: textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        SectionLabel('Quick adjust'),
                        _AdjustGrid(
                          onAdjust: (amount) => context.read<ShowBloc>().add(
                            ShowEvent.adjusted(amount: amount),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SectionLabel('Custom amount'),
                        TextField(
                          controller: _customController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            hintText: '0',
                            suffixText: '€',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: AddAdjustButton(
                                label: 'Add',
                                onPressed: () {
                                  final amount = _parseAmount();
                                  if (amount > 0) {
                                    context.read<ShowBloc>().add(
                                      ShowEvent.adjusted(amount: amount),
                                    );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SubtractAdjustButton(
                                label: 'Subtract',
                                onPressed: () {
                                  final amount = _parseAmount();
                                  if (amount > 0) {
                                    context.read<ShowBloc>().add(
                                      ShowEvent.adjusted(amount: -amount),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
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

  String _formatAmount(double value) {
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value.toStringAsFixed(2);
  }
}

class _AdjustGrid extends StatelessWidget {
  final void Function(double amount) onAdjust;

  const _AdjustGrid({required this.onAdjust});

  @override
  Widget build(BuildContext context) {
    const amounts = [1.0, 5.0, 20.0, 50.0];

    return Column(
      children: [
        Row(
          children: amounts
              .map(
                (a) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: AddAdjustButton(
                      label: '+${a.toStringAsFixed(0)}',
                      onPressed: () => onAdjust(a),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        Row(
          children: amounts
              .map(
                (a) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: SubtractAdjustButton(
                      label: '-${a.toStringAsFixed(0)}',
                      onPressed: () => onAdjust(-a),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
