# UI & theme — Design & Layout Specification

<!--
  AGENT METADATA — parse before implementing
  feature_id: ui-theme
  product_name: Budget Manager
  source: docs/DESIGN_SYSTEM.md + docs/UI_IMPLEMENTATION_GUIDE.md
  target_platform: Flutter (Android-focused mobile)
  status: shipped
-->

> **Purpose:** Agent entry point for UI/theme work. **Does not duplicate tokens** —
> the sources of truth are linked below.
> **Audience:** Coding agents and contributors. Follow `AGENTS.md` and
> `docs/architecture.md` before writing code.

---

## Document map

| § | Section |
|---|---------|
| 0 | [Repo conventions](#0-repo-conventions) |
| 1 | [Feature overview](#1-feature-overview) |
| 2 | [Data model](#2-data-model) |
| 3 | [Component reuse](#3-component-reuse) |
| 4 | [Screens](#4-screens) |
| 5 | [Navigation & state](#5-navigation--state) |
| 6 | [Interaction & tokens](#6-interaction--tokens) |
| 7 | [Out of scope](#7-out-of-scope) |
| A | [Implementation checklist](#appendix-a-implementation-checklist) |

---

## 0. Repo conventions

| Rule | This feature |
|------|--------------|
| Presentation-only | Prefer changes in `lib/theme/` and `lib/screens/` unless the task needs data-layer work |
| Tokens | `context.appColors` (`AppThemeColors`); typography via `Theme.of(context).textTheme` |
| No hardcoded colors/sizes | No raw `Color(0x…)`, `Colors.red`, or one-off font sizes in views |
| Components | Reuse `lib/screens/components/` before creating new widgets |
| Themes | All **6** `AppThemeId` palettes must remain functional |
| Borders | 1px `border` (or elevation) — **no 3px borders** |
| Emojis | None — use Material `Icons.*` |

**Sources of truth (read before UI work):**

1. [`UI_IMPLEMENTATION_GUIDE.md`](UI_IMPLEMENTATION_GUIDE.md) — workflow, components, verification
2. [`DESIGN_SYSTEM.md`](DESIGN_SYSTEM.md) — token values, typography, component visuals, screen mapping

**Code:**

- `lib/theme/app_theme_colors.dart`
- `lib/theme/app_text_styles.dart`
- `lib/theme/app_themes.dart`
- `lib/theme/app_theme_id.dart`
- `lib/theme/theme_cubit.dart`
- `lib/repo/theme_repository.dart` (persisted theme choice)

**Replaces:** N/A — this spec indexes the guides above.

**Reference implementations:** `home_view.dart`, `index_view.dart`, `nav_card.dart`.

---

## 1. Feature overview

### 1.1 Visual identity (summary)

- Minimalist fintech: clean cards, generous whitespace, no thick borders, no emojis
- Fonts: Nunito (display), Inter (body), DM Mono (currency)
- Radii: 16px cards/sheets, 12px buttons/inputs, 8px progress bars
- Phone target: 393×852 Android portrait

### 1.2 Themes

Six themes (3 light + 3 dark), selectable from Settings theme picker. Adding a
semantic color requires updating `AppThemeColors` (`copyWith` / `lerp`) and
**every** palette in `app_themes.dart`, then documenting in `DESIGN_SYSTEM.md`.

### 1.3 Screens

Screen layout patterns: [DESIGN_SYSTEM.md § Screen Mapping](DESIGN_SYSTEM.md#screen-mapping).
Routes: [`screens-navigation-design-spec.md`](screens-navigation-design-spec.md).

---

## 2. Data model

Theme persistence via `ThemeRepository` / `ThemeCubit` — not envelope entities.
Envelope data: [`budgeting-core-design-spec.md`](budgeting-core-design-spec.md).

---

## 3. Component reuse

See the component table in [`UI_IMPLEMENTATION_GUIDE.md`](UI_IMPLEMENTATION_GUIDE.md)
and patterns in [`DESIGN_SYSTEM.md`](DESIGN_SYSTEM.md). Create a shared widget when
the same layout appears on 2+ screens or is listed in the design system but not
extracted yet.

---

## 4. Screens

Do not restate full screen trees here. Follow:

- [`screens-navigation-design-spec.md`](screens-navigation-design-spec.md)
- [`UI_IMPLEMENTATION_GUIDE.md`](UI_IMPLEMENTATION_GUIDE.md) (shell, padding, FABs, forms)

---

## 5. Navigation & state

Theme picker is a modal bottom sheet from Settings (local overlay). Route-level
navigation remains BLoC-only — see screens-navigation spec.

---

## 6. Interaction & tokens

- Access: `final colors = context.appColors;` /
  `final textTheme = Theme.of(context).textTheme;`
- Use `color.readableForeground` for text on arbitrary fills.
- Full token tables: [`DESIGN_SYSTEM.md`](DESIGN_SYSTEM.md).

---

## 7. Out of scope

- Inventing a seventh theme without updating all token plumbing
- Hardcoding Legacy-only colors into shared widgets
- Replacing the design system with Figma archive typography (archive may show
  older sizes — **prefer DESIGN_SYSTEM + code**)

---

## Appendix A. Implementation checklist

```
[ ] Reused existing components or added under screens/components/
[ ] Colors from context.appColors; text from textTheme
[ ] All 6 themes updated if new tokens added; DESIGN_SYSTEM.md updated
[ ] No emojis; no 3px borders
[ ] Spot-check Light Plain + Dark Plain (and Legacy/Colorful if colors touched)
[ ] flutter analyze
```
