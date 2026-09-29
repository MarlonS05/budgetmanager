# Enforcement — making import boundaries real

Prose in `docs/architecture.md` rots unless something fails the build when it's
violated. The **intended** pattern for this Flutter repo is to enforce the
**strict import table** with two artifacts:

1. A **rules class** that, given a file path, returns the list of import
   prefixes that file may not contain.
2. A **test** that walks every source file, extracts its imports, and asserts
   none match a denied prefix.

Together with the table in `docs/architecture.md`, these are the **three
sources that must stay in sync**. Change a boundary → change all three in the
same commit.

## Current state (Budget Manager)

| Artifact | Status |
|----------|--------|
| Strict import table in `docs/architecture.md` | **Present** — source of truth |
| Lint-rules / deny-list package | **Not implemented** |
| Architecture import test (`test/architecture/`) | **Not implemented** |
| CI check for layer imports | **Not implemented** |

Until those exist, **agents and reviewers enforce boundaries by reading
`docs/architecture.md`**. Do not claim automated enforcement in PRs. When
adding the package and test, mirror the table exactly and update this doc.

## 1. The rules class (path-keyed deny-lists) — target

Shape (Dart-oriented pseudocode):

```
denyListForDomain      = [ flutter, screens, repo, db, services, router, di, theme, bloc, go_router, sqflite ]
denyListForDataAccess  = [ screens, router, di, bloc, go_router ]
denyListForPersistence = [ flutter, screens, repo, router, di, bloc, go_router ]
denyListForInfra       = [ screens, repo, db, router, di, bloc, go_router ]
denyListForView        = [ repo, db, router, di, go_router ]
denyListForController  = [ repo, db, sqflite ]  # AppRouter OK; avoid raw go_router
denyListForComponent   = [ repo, db, router, di, bloc, go_router ]

function denialsForFile(path):
    if path under lib/domain/:            return denyListForDomain
    if path under lib/repo/:              return denyListForDataAccess
    if path under lib/db/:                return denyListForPersistence
    if path under lib/services/:          return denyListForInfra
    if path under lib/screens/components/: return denyListForComponent
    if path is a presentation file:
        if path ends with _view:       return denyListForView
        if path ends with _bloc/_event/_state: return denyListForController
    return []   # no restrictions

function importMatchesDenial(importUri, denialPrefix):
    return importUri startsWith denialPrefix   # plus package:budgetmanager/... handling
```

Suggested homes when implemented:

- Rules class: e.g. a small package `budgetmanager_lint_rules/` or
  `tool/layer_import_rules.dart` under the repo
- Test: `test/architecture/layer_import_test.dart`

## 2. The test (walk sources, assert no denied imports) — target

Pseudocode:

```
for each .dart file under lib/:
    denials = denialsForFile(file.path)
    if denials is empty: continue
    for each import/export directive:
        if importMatchesDenial(uri, denial):
            record violation
assert violations is empty
```

Run via `flutter test` locally and in CI.

## 3. The sync rule

The `docs/architecture.md` strict import table, the rules-class deny-lists, and
the test must agree. If they disagree, **the table is the spec** and the other
two are bugs. Make boundary changes as one commit touching all three (when the
latter two exist).

## Adapting to other ecosystems

| Ecosystem | Mechanism |
|-----------|-----------|
| Dart / Flutter | Custom rules class + a `flutter test` that walks `lib/` (**this project’s target**). |
| TypeScript / JS | `eslint-plugin-boundaries` or `eslint-plugin-import` `no-restricted-paths` |
| Python | `import-linter` contracts |
| Java / Kotlin | ArchUnit |
| Go | `depguard` / `go-arch-lint` |

Whatever the tool, keep the source of truth human-readable in
`docs/architecture.md` and mechanically checked in CI once implemented.
