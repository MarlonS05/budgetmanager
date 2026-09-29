# Budget Manager — Design System

Agent-readable reference derived from the [Figma Make preview](https://www.figma.com/make/fcbjpPvOWeP9YfTsyQVCju/Mobile-Budgeting-App-Design). Use this document when implementing or restyling UI without re-opening Figma.

For how to apply these tokens in code (components, screens, theme files), see [UI_IMPLEMENTATION_GUIDE.md](UI_IMPLEMENTATION_GUIDE.md). Agent index: [ui-theme-design-spec.md](ui-theme-design-spec.md). Routes/screens: [screens-navigation-design-spec.md](screens-navigation-design-spec.md).

## Visual Identity

- **Aesthetic:** Minimalist fintech — clean cards, generous whitespace, no thick borders, no emojis
- **Fonts:** Nunito (display/headings), Inter (body/labels), DM Mono (currency figures)
- **Corner radius:** 16px cards/sheets, 12px buttons/inputs, 8px progress bars
- **Screen padding:** 20–24px horizontal, 48px top safe area, 32px bottom
- **Phone target:** 393×852 Android portrait

## Color Tokens (Light — reference palette)

Map to `AppThemeColors` in `lib/theme/app_theme_colors.dart`. All 6 themes keep distinct personalities but share this structure.

| Token | Light value | Usage |
|---|---|---|
| `scaffoldBackground` | `#F4F5FF` | Full-screen lavender-white bg |
| `surface` | `#FFFFFF` | Card backgrounds |
| `surfaceSecondary` | `#ECEEFF` | Secondary cards, input fills |
| `primaryAction` | `#4338CA` | Primary buttons, +adjust, FABs |
| `primaryActionForeground` | `#FFFFFF` | Text on primary |
| `primaryLight` | `#EEF2FF` | Tinted card backgrounds |
| `accent` / `aiAccent` | `#7C3AED` | AI features, high-progress pills |
| `aiBackground` | `#F5F3FF` | AI card tinted background |
| `budgetUsed` | `#4338CA` | Progress fill (partial spend) |
| `budgetRemaining` | `#DDE1FF` | Progress empty portion |
| `success` | `#059669` | 100% budget |
| `error` | `#DC2626` | Subtract buttons, over-budget, warnings |
| `errorBackground` | `#FEE2E2` | Warning banner background |
| `onScaffold` | `#0C0D20` | Headings, amounts |
| `mutedText` | `#4A4D6E` | Subtitles, section labels |
| `mutedTextLight` | `#9396B5` | Tertiary labels |
| `border` | `#D8DBEF` | Card borders (1px) |

**Dark reference:** bg `#090B1A`, surface `#10132B`, primary `#6366F1`, accent `#A78BFA`, success `#34D399`, error `#F87171`.

## Typography Scale

| Role | Font | Size | Weight | Example |
|---|---|---|---|---|
| App label | Inter | 11px | w600, letter-spacing 1.2 | `BUDGET MANAGER` |
| Screen title | Nunito | 28px | Bold | `Budget Managed`, `July 2025` |
| Hero amount | DM Mono | 56px | Bold | `400` |
| Amount suffix | Inter | 20px | Regular, muted | `of 500 €` |
| Section label | Inter | 11px | w600, uppercase | `BUDGETS`, `QUICK ADJUST` |
| Card title | Nunito | 17px | w600 | `History`, `Groceries` |
| Card subtitle | Inter | 14px | Regular, muted | `Past months overview` |
| Progress pill text | DM Mono | 13px | w500 | `400 / 500 €` |
| Button label | Inter | 16px | w600 | `Add`, `Subtract` |

## Component Patterns

### ProgressPill

- Full-width, height 32px, radius 8px
- Text centered inside bar using DM Mono
- Color by fill %: 0% grey, 1–49% indigo, 50–79% purple, 100% green, >100% red
- Layout: budget name above pill (not side-by-side)

### ScreenHeader

- Back: simple chevron (no bordered circle)
- Title: Nunito 28px bold, left-aligned
- Optional trailing action

### NavCard (Home secondary buttons)

- White `surface` card, 16px radius, 1px `border`
- Title + muted subtitle stacked left; Material icon right
- AI variant: `aiAccent` 1px border + `aiBackground` tint + `AI INSIGHTS` uppercase label

### SummaryStatCard

- Uppercase label, large value, percentage badge right-aligned

### Adjust buttons

- `+N`: `primaryAction` fill, white text, 12px radius
- `-N`: `error` fill, white text, 12px radius
- Grid: 4 columns × 2 rows

### FABs

- Refresh: small dark circle, white icon
- Close month: larger square-rounded red button

## Screen Mapping

| Screen | Pattern |
|---|---|
| Home | Hero card + NavCards + AI card |
| Current Month | SummaryStatCards + budget rows + FABs |
| Budget Detail | Hero amount + progress bar + adjust grid |
| History | Month rows with ProgressPill |
| Settings | NavCard list |
| Manage Budgets | Card list rows + FAB |
| Update Income | Form card + Save button |
| AI Insights | Purple AI styling + result card |
| Modals | 16px top-radius sheet, drag handle |
| Regularity Calendar | 3×4 month cells (`surface` + 1px `border`) + full-width rectangular `primaryAction` + button; month details = `AlertDialog` over faded calendar; month-select cells use `primaryLight` + `primaryAction` border when selected |

## Constraints

- No emojis anywhere
- No 3px borders — use 1px `border` or elevation
- Keep 6 themes — update palettes to new token roles
