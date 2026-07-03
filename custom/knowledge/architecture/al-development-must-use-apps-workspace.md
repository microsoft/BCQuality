---
bc-version: [all]
domain: architecture
keywords: [workspace, apps-workspace, vscode, docs, al-go, development-environment]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL development must use the apps workspace — with docs included

## Description

CURABIS AL-Go repos carry two VS Code workspace files: one at repo root
(`al.code-workspace`) and one under the apps folder
(`.apps/.apps.code-workspace`). Developers observed working in the ROOT
workspace lose the standard development context: the apps workspace is the
one that scopes VS Code to the app projects plus `.AL-Go`, carries the
project-level settings (e.g. `powershell.cwd` pointing at the test app), and
— per this rule — includes the repo's `docs/` folder, so Columbo specs,
decision records and cleanup checklists are visible and editable exactly
where development happens. The root workspace opens repo plumbing (workflows,
git internals) and none of that context.

## Rule

Each repo has **exactly ONE workspace file** — in the apps folder (`.apps/`
is the reference name; `Apps/`/`apps/` variants are cosmetic and accepted).
That workspace file must contain, as folder entries:

1. every AL app project folder (main + test)
2. `.AL-Go`
3. the repo's docs folder, added as a relative entry: `"path": "../docs"`

Reference layout (Jernpladsen): folders = Jernpladsen, Jernpladsen.Test,
.AL-Go, docs (`../docs`), with `powershell.cwd` set to the test app.

**All other `*.code-workspace` files — including the root
`al.code-workspace` — are deleted.** They are noise: wrong entry points that
open the repo without the development context. Repo-plumbing work (workflow
edits, AL-Go settings) is done by opening the repo folder directly, not
through a dedicated workspace. Note: an AL-Go template update may re-scaffold
the root workspace file — the inspection round removes it again.

## What NOT to do

- Do not keep the root `al.code-workspace` "for plumbing" — open the repo
  folder directly for that; a second workspace is a second entry point, and
  the wrong one will be used
- Do not add `docs` by copying files into the apps folder — it is ONE folder
  at repo root, referenced relatively, so specs stay single-sourced
- Do not put machine-absolute paths in the workspace file — it is
  git-committed and shared (same principle as
  `mcp-config-must-not-hardcode-developer-paths`)

## Signal to watch for

Rømer's inspection round, two checks: (1) the apps folder contains a
workspace file whose `folders` include all app projects, `.AL-Go` and a
relative `docs` entry; (2) NO other `*.code-workspace` exists anywhere else
in the repo. The standard authorizes both corrections silently: create or
complete the apps workspace to the reference layout, and delete every other
workspace file — report both afterwards.

## Message to developer

When the apps workspace is missing/incomplete or extra workspace files exist,
tell the developer: the standard is exactly one workspace —
`.apps/.apps.code-workspace` with app projects, `.AL-Go` and `../docs`; the
extra workspace files are noise and have been removed (list them).
