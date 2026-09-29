import 'package:budgetmanager/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

/// Shows the app-styled alert dialog with text or rich widget content.
///
/// Exactly one of [content] or [contentWidget] must be provided.
Future<T?> showAppDialog<T>({
  required BuildContext context,
  required String title,
  String? content,
  Widget? contentWidget,
  String? cancelLabel = 'Cancel',
  String? confirmLabel,
  VoidCallback? onConfirm,
  bool isDestructive = false,
  Color? barrierColor,
}) {
  assert(
    (content == null) != (contentWidget == null),
    'Provide exactly one of content or contentWidget.',
  );
  final colors = context.appColors;
  final textTheme = Theme.of(context).textTheme;

  return showDialog<T>(
    context: context,
    barrierColor: barrierColor,
    builder: (dialogContext) => AlertDialog(
      title: Text(title, style: textTheme.headlineMedium),
      content: contentWidget ?? Text(content!, style: textTheme.bodyLarge),
      actions: [
        if (cancelLabel != null)
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(cancelLabel),
          ),
        if (confirmLabel != null)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive
                  ? colors.error
                  : colors.primaryAction,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              onConfirm?.call();
              Navigator.of(dialogContext).pop();
            },
            child: Text(confirmLabel),
          ),
      ],
    ),
  );
}
