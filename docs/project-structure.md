# Project structure

Folder layout for Budget Manager. Conventions that still apply from the agent
blueprint: **one directory per layer**, **one directory per screen** in
presentation (BLoC + Freezed event/state + UI together), shared widgets under
`screens/components/`, and DI split by kind.

Automated import enforcement (lint-rules package + architecture test) is the
**intended** pattern — not present yet. See [enforcement.md](enforcement.md).

## Tree (as implemented)

```
budgetmanager/
├── AGENTS.md
├── docs/
│   ├── architecture.md
│   ├── project-structure.md
│   ├── enforcement.md
│   ├── agent-guidelines/          # 01–06 Dart/Flutter practices
│   ├── *-design-spec.md           # feature specs for agents (incl. regularity × budgets plan)
│   ├── DESIGN_SYSTEM.md           # tokens / component visuals
│   └── UI_IMPLEMENTATION_GUIDE.md # how to apply UI tokens in code
├── lib/
│   ├── domain/
│   │   ├── entities/              # Budget, Month, RegularPayment, snapshot
│   │   ├── models/                # DB map ↔ entity models
│   │   ├── repositories/          # interfaces only
│   │   └── use_cases/month/       # CloseMonthUseCase (regularity × budgets)
│   ├── repo/                      # *RepositoryImpl + ThemeRepository
│   ├── db/
│   │   └── database_helper.dart   # connection, migrations, SQL CRUD
│   ├── services/                  # reserved (navigation_service empty)
│   ├── screens/
│   │   ├── components/            # shared widgets (+ layout/)
│   │   ├── constants/             # presentation constants (e.g. month labels)
│   │   ├── models/                # screen view models (e.g. BudgetDisplay)
│   │   ├── home/
│   │   ├── live/
│   │   │   ├── index/             # current month overview
│   │   │   └── show/              # budget spend detail
│   │   ├── history/
│   │   │   ├── history_index/
│   │   │   └── history_show/
│   │   ├── settings/
│   │   │   ├── manage_budgets/
│   │   │   ├── update_income/
│   │   │   ├── settings_*.dart    # top-level settings screen files
│   │   │   └── theme_picker_sheet.dart
│   │   ├── ai_insights/
│   │   └── regularity/            # calendar / edit (+ month dialog on calendar)
│   ├── router/
│   │   └── app_router.dart
│   ├── di/
│   │   └── di.dart
│   ├── theme/                     # AppThemeColors, AppTextStyles, AppThemes, ThemeCubit
│   ├── logger/
│   │   └── logger.dart
│   └── main.dart
└── test/                          # currently empty — add unit/widget/architecture tests here
```

## Folder purposes

| Folder | Contains | Never contains |
|--------|----------|----------------|
| `domain/` | Pure business types, interfaces (and use cases when added) | Flutter, UI, DB, router imports |
| `repo/` | Repository implementations | UI, routing, DI, BLoC |
| `db/` | `DatabaseHelper` (and future DAOs) | UI, router, DI |
| `services/` | Future infra adapters / ports | UI, business rules in widgets |
| `screens/<feature>/<screen>/` | One screen’s view + BLoC + Freezed event/state (+ generated) | Other screens; direct DB access |
| `screens/components/` | Shared / reusable UI widgets (subdirs OK) | Data-access, routing, DI, BLoC files |
| `screens/constants/` | Presentation-only shared constants | Domain/persistence logic |
| `router/` | Route table — every screen registered here | Business logic; unregistered ad-hoc routes |
| `di/`, `theme/`, `logger/` | Wiring, tokens, logging | Business logic |

## Naming conventions

- **One directory per screen.** Prefer `screens/<feature>/<screen>/` holding
  only `*_view`, `*_bloc`, `*_event`, `*_state`, and generated Freezed parts.

  ```
  screens/live/show/
  ├── show_view.dart
  ├── show_bloc.dart
  ├── show_event.dart
  ├── show_state.dart
  └── show_bloc.freezed.dart
  ```

  **Current exceptions:** some screen folders include helper widget files
  (e.g. `create_budget_modal.dart`, `show_anjustment_row.dart`). Prefer
  private widgets in `*_view.*` or shared components for new work; migrate
  when touching those files.

- **Widget classes:** Prefer small `Widget` subclasses over methods returning
  `Widget`. Shared widgets → `screens/components/` only.

- **Presentation suffixes** (used by future enforcement):
  - `*_view.*` — UI; dispatch events only; **no route navigation**
  - `*_bloc.*` — logic + **all route navigation** via `AppRouter`
  - `*_event.*` / `*_state.*` — Freezed inputs/outputs
  - `*.freezed.dart` — generated; never hand-edit

- **Navigation & routes:** register every screen in `lib/router/app_router.dart`.
  Only BLoCs navigate with `AppRouter`. Never navigate from `*_view.*` or
  `screens/components/` (overlay `Navigator.pop` for dialogs/sheets is OK).

- **Use cases:** one class per write/delete, named `<Verb><Noun>UseCase`,
  under `domain/use_cases/<entity|function>/`. The first is
  `CloseMonthUseCase` at `domain/use_cases/month/close_month_use_case.dart`
  (close + regular-payment snapshot). Do not dump all use cases in one flat
  folder.

- **Repository interfaces** in `domain/repositories/`; `...Impl` in `repo/`.

- **Persistence:** today all SQL is in `DatabaseHelper`. Target: one
  `<Entity>Dao` per table under `db/daos/`.

## Wiring (DI)

`lib/di/di.dart` — `setupDependencies()` called from `main` before `runApp`.
Helpers already split roughly by kind: `registerDatabase`, `registerRouter`,
`registerTheme`, `registerRepositories`, `registerScreens`. Keep that
pattern; add `registerUseCases()` with this integration (`CloseMonthUseCase`).
Group with section comments (e.g. `// History`, `// AI Insights`).

## Logger setup

Import `lib/logger/logger.dart` everywhere — do not create ad-hoc `Logger`
instances. See [architecture.md — Logger setup](architecture.md#logger-setup).

## Android Gradle toolchain

Pins must stay at or above Flutter's warn floors (Gradle 9.1.0, AGP 9.0.1,
Kotlin 2.3.20). Match the Flutter 3.47 template unless a plugin forces a
newer compatible set:

| Tool | File | Current pin |
|------|------|-------------|
| Gradle | `android/gradle/wrapper/gradle-wrapper.properties` | 9.3.1 |
| Android Gradle Plugin | `android/settings.gradle.kts` (`com.android.application`) | 9.1.0 |
| Kotlin Gradle Plugin | `android/settings.gradle.kts` (`org.jetbrains.kotlin.android`) | 2.4.0 |

Keep `android.newDsl=false` and `android.builtInKotlin=false` in
`android/gradle.properties` until the Android Gradle files are migrated to
AGP 9's built-in Kotlin and new DSL. AGP 9.1.x requires Gradle 9.3.1+.
