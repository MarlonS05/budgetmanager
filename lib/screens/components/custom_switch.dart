import 'package:budgetmanager/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

/// A custom toggle switch that matches the project's styling.
/// Uses the theme accent when active and a dark border/knob consistent
/// with other components in the app.
class CustomSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomSwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 28,
        decoration: BoxDecoration(
          color: value ? colors.accent : colors.switchInactive,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border, width: 1),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: colors.border,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
