import 'package:budgetmanager/screens/components/custom_switch.dart';
import 'package:budgetmanager/screens/settings/manage_budgets/manage_budgets_bloc.dart';
import 'package:budgetmanager/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateBudgetModal extends StatefulWidget {
  const CreateBudgetModal({super.key});

  @override
  State<CreateBudgetModal> createState() => _CreateBudgetModalState();
}

class _CreateBudgetModalState extends State<CreateBudgetModal> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _limitController = TextEditingController();
  bool _isVisible = true;

  @override
  void dispose() {
    _nameController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  double _parseAmount() {
    final raw = _limitController.text.trim();
    final normalized = raw.replaceAll(',', '.');
    return double.tryParse(normalized) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: colors.borderMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text('New Budget', style: textTheme.headlineMedium),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _limitController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Limit',
              suffixText: '€',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Visible', style: textTheme.titleMedium),
              CustomSwitch(
                value: _isVisible,
                onChanged: (val) => setState(() => _isVisible = val),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: colors.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primaryAction,
                    foregroundColor: colors.primaryActionForeground,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    final name = _nameController.text.trim();
                    final limit = _parseAmount();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Name cannot be empty.')),
                      );
                      return;
                    }
                    if (limit < 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid limit.'),
                        ),
                      );
                      return;
                    }
                    context.read<ManageBudgetsBloc>().add(
                      ManageBudgetsEvent.budgetCreated(
                        name: name,
                        limit: limit,
                        isVisible: _isVisible,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Create'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
