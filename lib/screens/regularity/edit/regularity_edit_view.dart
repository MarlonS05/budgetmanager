import 'package:budgetmanager/screens/components/app_dialog.dart';
import 'package:budgetmanager/screens/components/layout/title_bar.dart';
import 'package:budgetmanager/screens/components/section_label.dart';
import 'package:budgetmanager/screens/constants/month_names.dart';
import 'package:budgetmanager/screens/regularity/edit/regularity_edit_bloc.dart';
import 'package:budgetmanager/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegularityEditView extends StatefulWidget {
  const RegularityEditView({super.key});

  @override
  State<RegularityEditView> createState() => _RegularityEditViewState();
}

class _RegularityEditViewState extends State<RegularityEditView> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocConsumer<RegularityEditBloc, RegularityEditState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage ||
          previous.isLoading != current.isLoading,
      listener: (context, state) {
        _syncController(_nameController, state.name);
        _syncController(_amountController, state.amountText);
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      builder: (context, state) {
        return PopScope(
          canPop: !state.isLoading && !state.isSaving,
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScreenHeader(
                    title: state.isEditing ? 'Edit payment' : 'New payment',
                    backEnabled: !state.isLoading && !state.isSaving,
                    onBack: () {
                      context.read<RegularityEditBloc>().add(
                        const RegularityEditEvent.backTapped(),
                      );
                    },
                    trailing: state.isEditing
                        ? IconButton(
                            tooltip: 'Delete payment',
                            onPressed: state.isSaving
                                ? null
                                : () => _confirmDelete(context),
                            icon: Icon(
                              Icons.delete_outline,
                              color: colors.error,
                            ),
                          )
                        : null,
                  ),
                  Expanded(
                    child: state.isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: colors.primaryAction,
                            ),
                          )
                        : SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(
                              20,
                              0,
                              20,
                              MediaQuery.viewInsetsOf(context).bottom + 96,
                            ),
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
                                    children: [
                                      TextField(
                                        controller: _nameController,
                                        textCapitalization:
                                            TextCapitalization.sentences,
                                        decoration: const InputDecoration(
                                          labelText: 'Name',
                                        ),
                                        onChanged: (name) {
                                          context
                                              .read<RegularityEditBloc>()
                                              .add(
                                                RegularityEditEvent.nameChanged(
                                                  name: name,
                                                ),
                                              );
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      TextField(
                                        controller: _amountController,
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        inputFormatters: [
                                          _DecimalTextInputFormatter(),
                                        ],
                                        decoration: const InputDecoration(
                                          labelText: 'Amount',
                                          suffixText: '€',
                                        ),
                                        onChanged: (amount) {
                                          context.read<RegularityEditBloc>().add(
                                            RegularityEditEvent.amountChanged(
                                              amount: amount,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const SectionLabel('Months'),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: 12,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 12,
                                        mainAxisSpacing: 12,
                                        childAspectRatio: 1.8,
                                      ),
                                  itemBuilder: (context, index) {
                                    final month = index + 1;
                                    return _MonthSelectCell(
                                      label: MonthNames.short[index],
                                      isSelected: state.months.contains(month),
                                      onTap: () {
                                        context.read<RegularityEditBloc>().add(
                                          RegularityEditEvent.monthToggled(
                                            month: month,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              heroTag: 'regularity-save',
              tooltip: 'Save payment',
              backgroundColor: colors.primaryAction,
              foregroundColor: colors.primaryActionForeground,
              onPressed: state.isLoading || state.isSaving
                  ? null
                  : () {
                      context.read<RegularityEditBloc>().add(
                        const RegularityEditEvent.saveTapped(),
                      );
                    },
              child: state.isSaving
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.primaryActionForeground,
                      ),
                    )
                  : const Icon(Icons.check),
            ),
          ),
        );
      },
    );
  }

  void _syncController(TextEditingController controller, String value) {
    if (controller.text == value) return;
    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  Future<void> _confirmDelete(BuildContext context) {
    return showAppDialog<void>(
      context: context,
      title: 'Delete payment?',
      content: 'This regular payment will be permanently deleted.',
      confirmLabel: 'Delete',
      isDestructive: true,
      onConfirm: () {
        context.read<RegularityEditBloc>().add(
          const RegularityEditEvent.deleteConfirmed(),
        );
      },
    );
  }
}

class _MonthSelectCell extends StatelessWidget {
  const _MonthSelectCell({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: isSelected ? colors.primaryLight : colors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? colors.primaryAction : colors.border,
            ),
          ),
          child: Text(
            label,
            style: textTheme.labelLarge?.copyWith(color: colors.onScaffold),
          ),
        ),
      ),
    );
  }
}

class _DecimalTextInputFormatter extends TextInputFormatter {
  static final _pattern = RegExp(r'^\d*([.,]\d{0,2})?$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return _pattern.hasMatch(newValue.text) ? newValue : oldValue;
  }
}
