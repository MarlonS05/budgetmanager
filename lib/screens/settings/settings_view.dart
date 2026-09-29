import 'package:budgetmanager/screens/components/layout/title_bar.dart';
import 'package:budgetmanager/screens/components/nav_card.dart';
import 'package:budgetmanager/screens/settings/settings_bloc.dart';
import 'package:budgetmanager/screens/settings/theme_picker_sheet.dart';
import 'package:budgetmanager/theme/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeId = context.watch<ThemeCubit>().state;

    return Scaffold(
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ScreenHeader(title: 'Settings'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        NavCard(
                          title: 'Manage Budgets',
                          subtitle: 'Create and edit budget categories',
                          icon: Icons.account_balance_wallet_outlined,
                          onTap: () => context.read<SettingsBloc>().add(
                            SettingsEvent.openManageBudgets(),
                          ),
                        ),
                        NavCard(
                          title: 'Update Income',
                          subtitle: 'Set monthly income',
                          icon: Icons.payments_outlined,
                          onTap: () => context.read<SettingsBloc>().add(
                            SettingsEvent.openUpdateMonthlyIncome(),
                          ),
                        ),
                        NavCard(
                          title: 'Color Theme',
                          subtitle: themeId.displayName,
                          icon: Icons.palette_outlined,
                          onTap: () => showThemePickerSheet(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
