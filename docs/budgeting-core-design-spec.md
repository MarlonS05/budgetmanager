# Budgeting core — Design & Layout Specification

<!--
  AGENT METADATA — parse before implementing
  feature_id: budgeting-core
  product_name: Budget Manager
  source: docs/FIGMA_AI_DESIGN_BRIEF.md (archive) + codebase
  target_platform: Flutter (Android-focused mobile)
  status: shipped
-->

> **Purpose:** Machine-readable design spec for envelope budgeting domain rules,
> entities, and schema.
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
| BLoC + Freezed codegen | Screen BLoCs under `lib/screens/`; after Freezed edits run `dart run build_runner build --delete-conflicting-outputs` |
| All screens registered in `AppRouter` | See `docs/screens-navigation-design-spec.md` |
| All navigation in BLoCs | Views dispatch events; BLoC calls `AppRouter` |
| Widget classes | Shared under `screens/components/`; private widgets in `*_view.*` |
| Infra I/O | Domain repository interfaces only; no HTTP |
| Persistence | `MonthRepository`, `BudgetRepository`, `BudgetByMonthRepository` → `DatabaseHelper` |
| Writes | Via repositories today; `CloseMonthUseCase` handles close + snapshot (see regularity-budget-integration spec). Prefer use cases under `domain/use_cases/<group>/` for new non-trivial write logic |
| Errors | `SnackBar` / `showAppDialog` / BLoC error states |
| Theme | `context.appColors` + text theme — see `docs/ui-theme-design-spec.md` |

**Replaces:** N/A (core product).

**Reference implementations:** `lib/repo/month_repository_impl.dart`,
`lib/db/database_helper.dart` (visibility SQL), `lib/screens/live/`.

---

## 1. Feature overview

### 1.1 Product rules

**Budget Manager** is a local-first envelope-budgeting app. Users allocate
monthly income across named budget buckets and track spending as **running
totals** — there are **no individual transactions**.

- One **open month** at a time (e.g. "July 2026").
- User sets **monthly income** (€).
- User creates **budget categories** with spending limits.
- User adjusts spend with +/- presets or custom amounts.
- At month end, user **closes the month** (irreversible); a new month
  auto-starts when needed.
- **History** shows past months; **AI Insights** analyzes on-device.

**Currency:** Euro (€) only. **Locale:** English only.
**Local-only:** no auth, cloud sync, export/import, or notifications.

### 1.2 Screens

Domain behavior surfaces on Live, History, Settings (manage budgets / income),
and AI Insights — routes and UI flows live in
[`screens-navigation-design-spec.md`](screens-navigation-design-spec.md).

### 1.3 Flows

- **Open month:** If no open month exists, create one from **visible** budgets
  and last month’s income.
- **Spend:** Adjust `BudgetByMonth.currentUsed` (never below 0); save immediately.
- **Fill to max:** Set `currentUsed` to the month’s limit for that budget.
- **Close month:** Set `closedOn`; irreversible. Confirmation required.
  `CloseMonthUseCase` saves `RegularPaymentSnapshot` first, then awaits
  `closeMonth`.
- **Hide budget:** Soft-delete via `hiddenOn`; not a hard delete.
- **Visibility in month lists:** see §2.

---

## 2. Data model

### Entities (`lib/domain/entities/`)

| Entity | Fields | Notes |
|--------|--------|-------|
| `Budget` | `id`, `name`, `limit`, `hiddenOn` | Template category; `hiddenOn == null` → visible |
| `BudgetByMonth` | `id`, `name`, `currentUsed`, `limit` | Monthly snapshot of spend vs limit |
| `Month` | `id`, `income`, `name`, `budgets`, `date`, `closedOn` | `name` derived from `date` in model→entity; getters: `totalUsed`, `budgetedIncomeAmount` |

### Models (`lib/domain/models/`)

| Model | Maps to | Notes |
|-------|---------|-------|
| `BudgetModel` | `budgets` | DB column `max_amount` ↔ `limit` |
| `BudgetByMonthModel` | `budget_by_month` | `monthId`, `budgetId`, `budgetName`, `currentUsed`, `oldLimit` |
| `MonthModel` | `months` | `name` not stored; derived in `toEntity()` |

Each model has `fromMap` / `toMap` / `toEntity` (and `fromEntity` / `empty` as applicable).

### Screen view model

- `BudgetDisplay` (`lib/screens/models/`) — combines `Month` + `Budget` for display.

### Schema (sqflite, `budget_manager.db`, version **4**)

| Table | Columns |
|-------|---------|
| `months` | `id` PK, `date` TEXT, `closedOn` TEXT NULL, `income` REAL |
| `budgets` | `id` PK, `name` TEXT, `max_amount` REAL, `hiddenOn` TEXT NULL |
| `budget_by_month` | `id` PK, `month_id` FK→months CASCADE, `budget_id` FK→budgets CASCADE, `old_limit` REAL, `current_used` REAL |
| `regular_payments` | `id` PK, `name` TEXT, `amount` REAL, `months_mask` INTEGER; independent of budget tables |
| `regular_payment_snapshots` | `id` PK, `month_id` FK→months CASCADE UNIQUE, `amount` REAL, `items_json` TEXT |

Migrations: map in `DatabaseHelper._migrations` (v2 added `closedOn`, `hiddenOn`;
v3 added `regular_payments`; v4 added `regular_payment_snapshots`).
Bump `_databaseVersion` and add an entry when changing schema.

### Budget visibility (SQL)

A `budget_by_month` row is shown for a month when **any** of:

1. Budget is not hidden (`hiddenOn IS NULL`), or
2. It has spending (`current_used > 0`), or
3. Month is closed **and** budget was hidden **after** `closedOn`

Hidden budgets with zero spend hidden on/before close are omitted.

### Soft-delete / hide

- Setting visibility off sets `hiddenOn` to now; turning visible clears it.
- Do not hard-delete budgets that appear in history unless explicitly required.

**Persistence:** repository methods on `MonthRepository`, `BudgetRepository`,
`BudgetByMonthRepository` (implementations in `lib/repo/`).

---

## 3. Component reuse

UI for these rules uses shared progress/list widgets — see
[`ui-theme-design-spec.md`](ui-theme-design-spec.md) and
[`UI_IMPLEMENTATION_GUIDE.md`](UI_IMPLEMENTATION_GUIDE.md). Do not invent a
transaction list UI.

---

## 4. Screens

Screen trees, routes, and FABs: [`screens-navigation-design-spec.md`](screens-navigation-design-spec.md).

---

## 5. Navigation & state

Hub-and-spoke from Home. Month open/close and spend edits are BLoC-driven.
Full route table: [`screens-navigation-design-spec.md`](screens-navigation-design-spec.md).

---

## 6. Interaction & tokens

- Amounts always in €; use `suffixText: '€'` on inputs.
- Spending cannot go below 0.
- Close month: confirmation dialog (`showAppDialog`); irreversible.
- Stale month: when calendar advanced but month still open, show warning banner
  on Live Index.
- Tokens: [`DESIGN_SYSTEM.md`](DESIGN_SYSTEM.md).

---

## 7. Out of scope

- Per-transaction ledger / categories separate from budgets
- Multi-currency, auth, cloud sync, export/import
- Notifications (do not add `flutter_local_notifications` without explicit request)
- Web / desktop support
- Charts/graphs beyond progress pills

**Planned (not implemented):** notifications for budget limits.

Regularity Calendar (`RegularPayment` table, schema v3) — see
[`regularity-calendar-design-spec.md`](regularity-calendar-design-spec.md).
That feature must **not** write to `budgets` / `budget_by_month`.

Live-month display + `RegularPaymentSnapshot` on close (schema v4) —
[`regularity-budget-integration-design-spec.md`](regularity-budget-integration-design-spec.md).
Regulars stay a separate list and a per-month snapshot; they are not envelope
rows.

**AI:** on-device via `flutter_local_ai` — see screens spec; results ephemeral.

---

## Appendix A. Implementation checklist

```
[ ] Domain entities/models + repository methods match schema
[ ] Visibility SQL preserved when changing month/budget queries
[ ] Migrations when schema changes
[ ] BLoCs use domain repos (or use cases); no DatabaseHelper in UI
[ ] Routes + DI for any new screen
[ ] Verify: flutter analyze (+ architecture test when present)
```
