import 'package:budgetmanager/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool silent;

  const CustomListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.silent = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: silent ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: textTheme.titleLarge),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!, style: textTheme.bodyMedium),
                    ],
                  ],
                ),
              ),
              if (trailing != null)
                trailing!
              else if (!silent)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: colors.mutedTextLight,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
