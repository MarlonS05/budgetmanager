import 'package:budgetmanager/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

class AddAdjustButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const AddAdjustButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primaryAction,
        foregroundColor: colors.primaryActionForeground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Text(label, style: textTheme.labelLarge),
    );
  }
}

class SubtractAdjustButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const SubtractAdjustButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.error,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Text(label, style: textTheme.labelLarge),
    );
  }
}

/// Backwards-compatible adjust button — positive adjustments only.
class AdjustButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isSubtract;

  const AdjustButton({
    required this.label,
    required this.onPressed,
    this.isSubtract = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (isSubtract) {
      return SubtractAdjustButton(label: label, onPressed: onPressed);
    }
    return AddAdjustButton(label: label, onPressed: onPressed);
  }
}
