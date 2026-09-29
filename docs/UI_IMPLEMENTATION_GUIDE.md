# UI Implementation Guide

How to add or change UI in Budget Manager. Read this before touching screens, components, or theme files.

Agent entry point: [ui-theme-design-spec.md](ui-theme-design-spec.md). Also follow root [AGENTS.md](../AGENTS.md).

For token values, typography, and component visuals, see [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md).

---

## Architecture

UI changes are **presentation-only**. Do not alter navigation, BLoC contracts, repositories, or database schema unless the feature explicitly requires it.

```
lib/theme/          → colors, typography, ThemeData
lib/screens/components/ → shared widgets
lib/screens/*/*_view.dart → screen layouts (compose components + BLoC)
lib/router/         → routes (add route here for new screens)
```

Screens use **BLoC** for state and **go_router** (via `AppRouter`) for navigation. Views should read state from `BlocBuilder` / `BlocConsumer` and dispatch events — never call repositories directly from widgets, and never use `context.go` / `context.push` for route navigation (BLoCs call `AppRouter` only).

---

## Before You Build

1. **Check existing components** in `lib/screens/components/`. Reuse before creating new widgets.
2. **Match a screen pattern** from [DESIGN_SYSTEM.md § Screen Mapping](DESIGN_SYSTEM.md#screen-mapping).
3. **Use semantic tokens** via `context.appColors` — never hardcode hex colors in views.
4. **Use the text theme** via `Theme.of(context).textTheme` — never invent one-off font sizes unless extending the design system.

---

## Theme & Colors

### Accessing tokens

```dart
final colors = context.appColors;       // AppThemeColors extension
final textTheme = Theme.of(context).textTheme;
```

Defined in:
- `lib/theme/app_theme_colors.dart` — semantic color tokens
- `lib/theme/app_text_styles.dart` — Nunito / Inter / DM Mono scale
- `lib/theme/app_themes.dart` — `ThemeData` per `AppThemeId`

### Rules

- **Always** use `context.appColors` for backgrounds, borders, progress fills, button colors, and text accents.
- **Never** use raw `Colors.red`, `Color(0xFF...)`, or `Theme.of(context).colorScheme` directly in screen widgets (colorScheme is seeded but not the source of truth).
- **All 6 themes must work.** When adding a new token, add it to `AppThemeColors`, `copyWith`, `lerp`, and every palette in `app_themes.dart`.
- Use `color.readableForeground` when placing text on arbitrary fill colors (e.g. progress pill text).

### Adding a new semantic color

1. Add field to `AppThemeColors` in `app_theme_colors.dart`
2. Update `copyWith` and `lerp`
3. Set values for all 6 palettes in `app_themes.dart`
4. Document the token in `DESIGN_SYSTEM.md`

---

## Typography

Use the pre-defined `TextTheme` roles — do not set `fontFamily` inline.

| Need | Use |
|---|---|
| Screen title | `textTheme.headlineLarge` |
| Modal / section title | `textTheme.headlineMedium` |
| Card row title | `textTheme.titleLarge` |
| Button label | `textTheme.labelLarge` |
| Section heading (`BUDGETS`) | `textTheme.labelMedium` + `.toUpperCase()` on string |
| Body / subtitle | `textTheme.bodyMedium` or `bodyLarge` |
| Hero currency amount | `textTheme.displayLarge` |
| Progress pill amount | `textTheme.labelSmall` |

For uppercase section labels, prefer the `SectionLabel` widget over duplicating styles.

---

## Shared Components

Location: `lib/screens/components/`

| Widget | Use when |
|---|---|
| `ScreenHeader` (`layout/title_bar.dart`) | Any sub-screen with a back button and title |
| `NavCard` | Tappable card with title, subtitle, trailing icon (Home, Settings) |
| `SummaryStatCard` | Key metric with label, value, optional % badge |
| `ProgressPill` (`box_used_of_max.dart`) | Budget or month spend progress (full-width bar) |
| `BudgetByMonthListTile` | Budget row in live/history lists |
| `MonthListTile` | Month row in history index |
| `CustomListTile` | Generic settings-style card row with chevron |
| `CustomListView` | Scrollable list with 12px gaps between card children |
| `SectionLabel` | Uppercase section divider (`BUDGETS`, `QUICK ADJUST`) |
| `AddAdjustButton` / `SubtractAdjustButton` | Budget amount adjustments (+ indigo, − red) |
| `CustomSwitch` | Boolean toggle in modals |
| `AppDialog` / `showAppDialog()` | Confirmation and alert dialogs |
| `NavCard` (isAi: true) | AI-feature entry points |

### When to create a new component

Create a shared widget when:
- The same layout appears on **2+ screens**, or
- The pattern is listed in `DESIGN_SYSTEM.md` and not yet extracted

Keep screen-specific layout inline in `*_view.dart` when it is unique to one screen.

### Component checklist

- [ ] Colors from `context.appColors` only
- [ ] Typography from `Theme.of(context).textTheme`
- [ ] Card radius 16px, button/input radius 12px, progress bar radius 8px
- [ ] Card borders: 1px `colors.border` (not 2px or 3px)
- [ ] No emojis — use Material `Icons.*` for trailing/decorative icons
- [ ] Works in all 6 themes (spot-check light + dark at minimum)

---

## Screen Layout Conventions

### Standard sub-screen shell

```dart
Scaffold(
  body: SafeArea(
    child: Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScreenHeader(title: 'Screen Name'),
          // content with horizontal padding 20
        ],
      ),
    ),
  ),
)
```

### Padding

| Area | Value |
|---|---|
| Horizontal content inset | 20–24px |
| Top (inside SafeArea) | 32px for header area |
| Bottom | 32px |
| Gap between cards | 12px (`CustomListView` handles this) |

### Home screen exception

Home has no `ScreenHeader` or back button. Use the branding block (`BUDGET MANAGER` label + title) followed by hero card + `NavCard` list.

---

## Adding a New Screen

1. **BLoC** — create `*_bloc.dart` + `*_state.dart` + `*_event.dart` in the screen folder (follow existing freezed/bloc patterns).
2. **View** — create `*_view.dart`; compose shared components; keep layout thin.
3. **Router** — register route in `lib/router/app_router.dart`.
4. **DI** — register BLoC in `lib/di/di.dart` if needed.
5. **Navigation** — dispatch a BLoC navigation-intent event; the BLoC calls `AppRouter` for a registered route. Do not navigate from views; do not add bottom navigation.

Pick the closest existing screen as a template:

| Feature type | Template screen |
|---|---|
| Hub / menu list | `settings_view.dart` |
| Data list with progress | `history_index_view.dart` |
| Detail with stats + list | `index_view.dart` |
| Form with save action | `update_income_view.dart` |
| Modal form | `create_budget_modal.dart` |
| AI / accent feature | `ai_insights_view.dart` |
| Regularity Calendar | See `docs/regularity-calendar-design-spec.md`; calendar grid + `ScreenHeader`; month details `AlertDialog`; edit FAB save like Manage Budgets FAB |

---

## Modals & Dialogs

### Bottom sheets

- Use `showModalBottomSheet` — `BottomSheetTheme` already sets 16px top radius.
- Include a drag handle (40×4px pill, `colors.borderMuted`).
- Title: `textTheme.headlineMedium`
- Actions: `OutlinedButton` (Cancel) + `ElevatedButton` (primary), 12px radius, side by side.
- Pad for keyboard: `MediaQuery.of(context).viewInsets.bottom`

### Dialogs

Use `showAppDialog()` from `lib/screens/components/app_dialog.dart` instead of
raw `AlertDialog` with default styling. For scrollable or otherwise rich dialog
bodies, pass `contentWidget` (and optional `barrierColor`); keep screen-private
content widgets in that screen's `*_view.dart`.

---

## FABs

| Type | Style |
|---|---|
| Primary action (add, edit) | `colors.primaryAction` circle FAB |
| Refresh | `FloatingActionButton.small`, `colors.surfaceSecondary` background |
| Destructive (close month) | `colors.error` background, rounded square (14px radius) |

Stack FABs bottom-right with 12px spacing. Use unique `heroTag` when multiple FABs share a screen.

---

## Forms & Inputs

- Rely on `InputDecorationTheme` from `app_themes.dart` (filled, 12px radius, 1px border).
- Show currency with `suffixText: '€'` — do not hardcode into field labels.
- Validate in the view or BLoC; show errors via `SnackBar` (existing pattern) or inline red text (`colors.error`).
- Primary submit: full-width `ElevatedButton`, `colors.primaryAction`, 12px radius, 16px vertical padding.

---

## Do / Don't

| Do | Don't |
|---|---|
| `context.appColors.primaryAction` | `Colors.indigo` |
| `textTheme.headlineLarge` | `TextStyle(fontSize: 28, fontWeight: FontWeight.bold)` |
| `ScreenHeader` for sub-screens | Custom back button with thick border |
| `ProgressPill` full-width below name | Fixed 120×30 inline pill |
| Material icons (`Icons.history_rounded`) | Emojis |
| 1px `colors.border` on cards | 3px borders |
| Test light + dark theme | Assume one theme |
| Extend `DESIGN_SYSTEM.md` for new patterns | Leave design docs stale |

---

## Verification Checklist

Before opening a PR with UI changes:

1. `flutter analyze` — no new errors or warnings
2. Visually check **Light Plain** and **Dark Plain** themes
3. Spot-check at least one Legacy and one Colorful theme if colors were touched
4. Confirm no emojis, no hardcoded colors, no 3px borders
5. New shared widgets live in `lib/screens/components/`
6. New tokens documented in `DESIGN_SYSTEM.md`

---

## Related Docs

- [ui-theme-design-spec.md](ui-theme-design-spec.md) — agent index for UI/theme
- [DESIGN_SYSTEM.md](DESIGN_SYSTEM.md) — tokens, typography, component visuals
- [screens-navigation-design-spec.md](screens-navigation-design-spec.md) — routes and screen map
- [budgeting-core-design-spec.md](budgeting-core-design-spec.md) — domain rules
- [regularity-calendar-design-spec.md](regularity-calendar-design-spec.md) — regular payments
- [regularity-calendar-review-fix-design-spec.md](regularity-calendar-review-fix-design-spec.md) — convention-review fixes
- [FIGMA_AI_DESIGN_BRIEF.md](FIGMA_AI_DESIGN_BRIEF.md) — archive stub (not SoT)
- [Figma Make preview](https://www.figma.com/make/fcbjpPvOWeP9YfTsyQVCju/Mobile-Budgeting-App-Design) — visual reference for core screens
