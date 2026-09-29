# AGENTS.md — Budget Manager

Local-first envelope budgeting (Flutter); BLoC + go_router; SQLite via
sqflite. Read `docs/architecture.md` and the relevant
`docs/*-design-spec.md` before making changes. For Dart/Flutter practices, see
`docs/agent-guidelines/`.

## Architecture & layers

- **Layers:** Domain (`lib/domain/` — entities, models, repository interfaces);
  data-access (`lib/repo/`); persistence (`lib/db/`); presentation
  (`lib/screens/` — BLoC + views); cross-cutting (`lib/router/`, `lib/di/`,
  `lib/theme/`, `lib/logger/`). No HTTP API. `lib/services/` is reserved
  (empty); there is no `platform/` folder today.
- **BLoCs** talk to **repository interfaces** for reads and writes today.
  Prefer introducing **use cases** under `domain/use_cases/<group>/` for
  writes/deletes when adding non-trivial write logic. First use case
  (implemented first): `CloseMonthUseCase` — see
  `docs/regularity-budget-integration-design-spec.md`.
- **All navigation happens in BLoCs** — views only dispatch events; never
  call `GoRouter` / `context.go` / `context.push` from a view/widget.
  Dialog/sheet dismiss may use `Navigator.pop` for local overlays only —
  never route-level navigation from a view.
- **Register every screen in `lib/router/`** — each screen has a route
  entry; BLoCs navigate only via those registered routes (never ad-hoc paths
  or view-level navigation).
- **No sqflite / `DatabaseHelper` in BLoCs or views** (reach DB only through
  domain repository interfaces implemented in `lib/repo/`).
- **`lib/domain/` must not import** Flutter, `screens/`, `repo/`, `db/`,
  `router/`, `di/`, `theme/`, or bloc/go_router.
- Import boundaries are documented in `docs/architecture.md`. There is **no**
  lint-rules package or architecture test yet — see `docs/enforcement.md`.
  Update the architecture table (and enforcement artifacts when they exist)
  if boundaries change.

## Conventions

- **One directory per screen** under `screens/<feature>/<screen>/` — BLoC,
  Freezed event/state, and UI (`*_view`) live together; never share a folder
  across screens (see `docs/project-structure.md`).
- **Widget classes.** Prefer `Widget` classes over helper methods that return
  a `Widget`. Screen-specific private widgets live in the same `*_view.*`
  file; shared widgets live under `screens/components/` (see
  `docs/project-structure.md`). Prefer `StatelessWidget` before `StatefulWidget`.
- **Dart/Flutter practices.** Interaction, tooling, style, serialization,
  testing, layout/assets, and dartdoc — see `docs/agent-guidelines/`.
- **Use cases** (when added) are grouped by entity/function under
  `domain/use_cases/<group>/` — do not dump all use cases in one flat folder.
- **DI registration split by kind** in `di/` — e.g. database, repos, screens
  (and use cases when they exist), with comment-marked sections; call them
  from one startup method in `main` (see `docs/project-structure.md`).
- **Routes + navigation.** Register every new screen and its route in
  `router/`. Views dispatch navigation-intent events; the BLoC calls
  `AppRouter` for that registered route. No `context.go` / `context.push` /
  router imports in `*_view.*` or shared components.
- **Keep docs in sync.** When you add or change functionality, structure, or
  layer boundaries, update the relevant docs in the same change — especially
  `docs/architecture.md`, affected `docs/*-design-spec.md`, and enforcement
  artifacts when they exist.
- After editing Freezed event/state sources, run
  `dart run build_runner build --delete-conflicting-outputs`.
- UI uses `context.appColors` and `Theme.of(context).textTheme` — see
  `docs/ui-theme-design-spec.md`, `docs/DESIGN_SYSTEM.md`, and
  `docs/UI_IMPLEMENTATION_GUIDE.md`. Errors via existing patterns (`SnackBar`,
  `showAppDialog`, BLoC error state).
- Persistence is local SQLite (`DatabaseHelper`); bump version and add a
  migration entry when changing schema.
- No shared HTTP client — API completion logging is N/A.
- Configure the shared logger in `lib/logger/` — see `docs/architecture.md`
  (Logger setup) for `PrettyPrinter` options.
- Temporary diagnostic logs while investigating: `logger.d` only — remove before
  considering work done.

### UI constraints (do not violate)

- Presentation-only changes in `lib/theme/` and `lib/screens/` unless the task
  needs data-layer work.
- Reuse widgets in `lib/screens/components/` before creating new ones.
- No emojis. No 3px borders (use 1px `border` or elevation). All 6 themes must
  remain functional.

## Envelope budgeting

No per-transaction ledger — only running totals per budget. One open month at
a time; close month is irreversible; hidden budgets are soft-deleted with
visibility rules in SQL. Euro (€) and English only; local-only (no auth/cloud).
On-device AI insights via `flutter_local_ai`. Details:
`docs/budgeting-core-design-spec.md`, `docs/screens-navigation-design-spec.md`.

## Commits

Use this format for commit messages:

```
[<type>] <short description>
```

Choose `type` from:

| Type | Use for |
|------|---------|
| `feat` | Feature |
| `fix` | Bugfix |
| `style` | Styling |
| `refrac` | Verbesserung des Codes |
| `test` | Automatisierte Tests |
| `docs` | Dokumentation |
| `project` | Änderungen der Projektkonfiguration |
| `perf` | Verbesserung der Performance |
| `wip` | Work in Progress / Zwischenstände |

Example: `[feat] Add order export to CSV`

## Verify

```bash
flutter analyze
# when tests exist:
# flutter test
```
