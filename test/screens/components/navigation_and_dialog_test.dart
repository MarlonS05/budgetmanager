import 'package:budgetmanager/screens/components/app_dialog.dart';
import 'package:budgetmanager/screens/components/layout/title_bar.dart';
import 'package:budgetmanager/theme/app_theme_id.dart';
import 'package:budgetmanager/theme/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ScreenHeader delegates back to its callback', (tester) async {
    var backTapped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemes.themeFor(AppThemeId.lightPlain),
        home: Scaffold(
          body: ScreenHeader(
            title: 'Calendar',
            onBack: () => backTapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));

    expect(backTapped, isTrue);
  });

  testWidgets('ScreenHeader disables back without Navigator fallback', (
    tester,
  ) async {
    var backTapped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemes.themeFor(AppThemeId.lightPlain),
        home: Scaffold(
          body: ScreenHeader(
            title: 'Loading payment',
            backEnabled: false,
            onBack: () => backTapped = true,
          ),
        ),
      ),
    );

    final button = tester.widget<IconButton>(find.byType(IconButton));
    expect(button.onPressed, isNull);
    await tester.tap(
      find.byIcon(Icons.arrow_back_ios_new),
      warnIfMissed: false,
    );
    expect(backTapped, isFalse);
  });

  testWidgets('ScreenHeader omits a null trailing child', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemes.themeFor(AppThemeId.lightPlain),
        home: const Scaffold(
          body: ScreenHeader(title: 'Calendar', trailing: null),
        ),
      ),
    );

    expect(find.text('Calendar'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsNothing);
  });

  testWidgets('ScreenHeader shows an optional trailing child', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemes.themeFor(AppThemeId.lightPlain),
        home: const Scaffold(
          body: ScreenHeader(title: 'Calendar', trailing: Icon(Icons.add)),
        ),
      ),
    );

    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('showAppDialog renders rich content without actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppThemes.themeFor(AppThemeId.lightPlain),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () {
              showAppDialog<void>(
                context: context,
                title: 'March',
                contentWidget: const Text('Payment list'),
                cancelLabel: null,
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('March'), findsOneWidget);
    expect(find.text('Payment list'), findsOneWidget);
    expect(find.text('Cancel'), findsNothing);
  });
}
