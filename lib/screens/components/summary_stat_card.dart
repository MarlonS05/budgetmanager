import 'package:budgetmanager/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

class SummaryStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? badge;

  const SummaryStatCard({
    super.key,
    required this.label,
    required this.value,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: textTheme.titleLarge?.copyWith(fontSize: 15),
                  ),
                ),
                if (badge != null)
                  Text(
                    badge!,
                    style: textTheme.headlineLarge?.copyWith(fontSize: 22),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
