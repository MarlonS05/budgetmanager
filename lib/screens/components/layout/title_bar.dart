import 'package:budgetmanager/theme/app_theme_colors.dart';
import 'package:flutter/material.dart';

class ScreenHeader extends StatelessWidget {
  final String title;
  final bool showBackButton;

  /// Whether the back control accepts interaction.
  final bool backEnabled;

  /// Handles route-level back navigation when supplied by the owning BLoC.
  ///
  /// Falls back to `Navigator.pop` for existing callers and local overlays.
  final VoidCallback? onBack;
  final Widget? trailing;

  const ScreenHeader({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.backEnabled = true,
    this.onBack,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
      child: Row(
        children: [
          if (showBackButton)
            IconButton(
              onPressed: backEnabled
                  ? onBack ?? () => Navigator.pop(context)
                  : null,
              icon: Icon(Icons.arrow_back_ios_new, color: colors.onScaffold),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            )
          else
            const SizedBox(width: 32),
          Expanded(child: Text(title, style: textTheme.headlineLarge)),
          ?trailing,
        ],
      ),
    );
  }
}

/// Backwards-compatible alias.
typedef TitleBar = ScreenHeader;
