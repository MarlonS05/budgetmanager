# Copilot Instructions — Budget Manager

Follow the repo’s agent docs — do **not** treat this file as a second architecture
or schema source of truth.

1. Root **[`AGENTS.md`](../AGENTS.md)** — terse rules every change must respect
2. **[`docs/architecture.md`](../docs/architecture.md)** — layers + import table
3. **[`docs/project-structure.md`](../docs/project-structure.md)** — folders
4. **[`docs/agent-guidelines/`](../docs/agent-guidelines/)** — Dart/Flutter practices
5. Design specs: [`docs/budgeting-core-design-spec.md`](../docs/budgeting-core-design-spec.md),
   [`docs/screens-navigation-design-spec.md`](../docs/screens-navigation-design-spec.md),
   [`docs/ui-theme-design-spec.md`](../docs/ui-theme-design-spec.md)
6. UI SoT: [`docs/UI_IMPLEMENTATION_GUIDE.md`](../docs/UI_IMPLEMENTATION_GUIDE.md),
   [`docs/DESIGN_SYSTEM.md`](../docs/DESIGN_SYSTEM.md)

## Copilot-only extras

- Focus only on the task requested. Do not refactor unrelated files unless asked.
- Prefer read/search tools (`view`, `glob`, `grep`) over shell for exploring code.
- Use only dependencies already in `pubspec.yaml`; if a package is missing, ask
  before adding it.
- After structural/feature changes that affect docs, update the **primary** doc
  for that fact (architecture, design spec, or UI guide) — not this pointer file.
