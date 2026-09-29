import 'package:budgetmanager/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

class NavCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool isAi;

  const NavCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.isAi = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: isAi ? colors.aiBackground : colors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isAi ? colors.aiAccent : colors.border,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isAi)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            'AI INSIGHTS',
                            style: textTheme.labelMedium?.copyWith(
                              color: colors.aiAccent,
                            ),
                          ),
                        ),
                      Text(title, style: textTheme.titleLarge),
                      const SizedBox(height: 2),
                      Text(subtitle, style: textTheme.bodyMedium),
                    ],
                  ),
                ),
                Icon(icon, color: isAi ? colors.aiAccent : colors.mutedText),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
