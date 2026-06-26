---
bc-version: [all]
domain: architecture
keywords: [workspace, compile, diagnostics, refresh, al-language, multi-project, new-file, mcp, alpackages, cross-project]
technologies: [al]
countries: [w1]
application-area: [all]
---

## Description

When Claude Code creates a new AL file in a multi-project workspace
(e.g. `AppName` + `AppName.Test`), the AL Language Server in VS Code
may temporarily assign the new file to the wrong project. This causes false
compilation errors such as:

- Missing references to test codeunits (e.g. `Library Assert`)
- Object ID out of range for the main app
- Missing `app.json` dependencies

These errors are **not real** — they disappear after VS Code refreshes its
project context. Claude Code must not attempt to fix them.

In **MCP sessions**, a parallel issue occurs: when a new object is added to
a dependency project (e.g. the main app), the MCP AL server for the dependent
project (e.g. the test app) cannot resolve the new object — even after
`al_addproject` — because the MCP server resolves cross-project dependencies
from `.alpackages` (compiled symbols), not from workspace source. The false
errors persist until the dependency is rebuilt and re-linked.

## Rule

**VS Code context:** After creating a new AL file, Claude Code must:

1. Stop all compilation and diagnostic activity immediately
2. Instruct the developer to refresh VS Code:
   `Ctrl+Shift+P → AL: Reload Extension`
3. Wait for explicit confirmation from the developer that the refresh is done
4. Only then run `al_getdiagnostics` or `al_compile` to check for real errors

**MCP context:** After adding a new object to a dependency project (main app),
if the dependent project (test app) cannot resolve the new object, Claude Code must:

1. Run `al_build` on the dependency project to generate a fresh `.app`
2. Copy the generated `.app` to the dependent project's `.alpackages/` folder
3. Run `al_addproject` on the dependent project to reload its symbol context
4. Only then run `al_build` or `al_getdiagnostics` on the dependent project

## What NOT to do

- Do not investigate namespace errors that appear immediately after file creation
- Do not modify `using` statements based on errors seen before a refresh
- Do not move or rename the file based on pre-refresh diagnostics
- Do not run `al_compile` or `al_build` immediately after creating a new file (VS Code)
- Do not report "compilation failed" based on pre-refresh diagnostics
- Do not interpret `AL0185 — object 'X' is missing` in the test app as a code error
  before first rebuilding the dependency and updating `.alpackages/`

## Signal to watch for

**VS Code:** If `al_getdiagnostics` returns errors referencing objects that clearly
belong to the other project (e.g. `Library Assert` errors in a main app context,
or ID range errors for a test codeunit), this is a pre-refresh false positive.

**MCP:** If `al_getdiagnostics` on the test app returns `AL0185 — Codeunit 'X' is
missing` for a codeunit that was just created in the main app source, this is a
stale symbol cache issue — not a missing implementation.

## Message to developer (VS Code context)

When this situation occurs, output exactly this message before stopping:

```
WARNING: VS Code needs a refresh before I can check for real compilation errors.

Please run: Ctrl+Shift+P -> AL: Reload Extension

Let me know when the refresh is done and I will re-check diagnostics.
```

Do not continue with any other activity until the developer confirms the refresh.
