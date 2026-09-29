import 'package:budgetmanager/screens/components/layout/title_bar.dart';
import 'package:budgetmanager/screens/settings/update_income/update_income_bloc.dart';
import 'package:budgetmanager/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UpdateIncomeView extends StatefulWidget {
  const UpdateIncomeView({super.key});

  @override
  State<UpdateIncomeView> createState() => _UpdateIncomeViewState();
}

class _UpdateIncomeViewState extends State<UpdateIncomeView> {
  final TextEditingController _incomeController = TextEditingController();

  @override
  void dispose() {
    _incomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return BlocConsumer<UpdateIncomeBloc, UpdateIncomeState>(
      listener: (context, state) {
        if (_incomeController.text.isEmpty) {
          _incomeController.text = state.income.toStringAsFixed(2);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ScreenHeader(title: 'Update Income'),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: colors.border),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${state.month.name} and onwards:',
                                  style: textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: _incomeController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  decoration: const InputDecoration(
                                    labelText: 'Income',
                                    suffixText: '€',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.primaryAction,
                              foregroundColor: colors.primaryActionForeground,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () {
                              final income = double.tryParse(
                                _incomeController.text,
                              );
                              if (income == null || income < 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Please enter a valid income.'),
                                  ),
                                );
                                return;
                              }
                              context.read<UpdateIncomeBloc>().add(
                                UpdateIncomeEvent.incomeUpdated(
                                  income: income,
                                ),
                              );
                            },
                            child: Text('Save', style: textTheme.labelLarge),
                          ),
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
}
