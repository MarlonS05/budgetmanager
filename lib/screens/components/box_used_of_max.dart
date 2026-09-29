import 'package:budgetmanager/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

class ProgressPill extends StatelessWidget {
  final double used;
  final double max;

  const ProgressPill(this.used, this.max, {super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;
    final ratio = max > 0 ? (used / max).clamp(0.0, double.infinity) : 0.0;
    final fillRatio = ratio.clamp(0.0, 1.0);
    final fillColor = colors.progressFillFor(used, max);
    final trackColor = used <= 0
        ? colors.surfaceSecondary
        : colors.budgetRemaining;

    final label = '${_format(used)} / ${_format(max)} €';
    final labelStyle = textTheme.labelSmall;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 32,
        width: double.infinity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;

            return Stack(
              children: [
                Container(color: trackColor),
                FractionallySizedBox(
                  widthFactor: fillRatio,
                  child: Container(color: fillColor),
                ),
                Center(
                  child: Text(
                    label,
                    style: labelStyle?.copyWith(
                      color: trackColor.readableForeground,
                    ),
                  ),
                ),
                ClipRect(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: fillRatio,
                    child: SizedBox(
                      width: totalWidth,
                      child: Center(
                        child: Text(
                          label,
                          style: labelStyle?.copyWith(
                            color: fillColor.readableForeground,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _format(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }
}

/// Backwards-compatible alias.
typedef BoxUsedOfMax = ProgressPill;
