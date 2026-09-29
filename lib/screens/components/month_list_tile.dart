import 'package:budgetmanager/domain/entities/month.dart';
import 'package:budgetmanager/screens/components/box_used_of_max.dart';
import 'package:budgetmanager/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

class MonthListTile extends StatelessWidget {
  final Month month;
  final VoidCallback onTap;
  final double? spentOverride;

  const MonthListTile(this.month, this.onTap, {super.key, this.spentOverride});

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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(month.name, style: textTheme.titleLarge),
              const SizedBox(height: 10),
              ProgressPill(spentOverride ?? month.totalUsed, month.income),
            ],
          ),
        ),
      ),
    );
  }
}
