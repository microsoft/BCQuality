---
bc-version: [all]
domain: architecture
keywords: [workspace, compile, diagnostics, refresh, al-language, multi-project, new-file]
technologies: [al]
countries: [w1]
application-area: [all]
---

## Description

When Claude Code creates a new AL file in a multi-project workspace
(e.g. `Jernpladsen` + `Jernpladsen.Test`), the AL Language Server in VS Code
may temporarily assign the new file to the wrong project. This causes false
compilation errors such as:

- Missing references to test codeunits (e.g. `Library Assert`)
- Object ID out of range for the main app
- Missing `app.json` dependencies

These errors are **not real** — they disappear after VS Code refreshes its
project context. Claude Code must not attempt to fix them.

## Rule

After creating a new AL file, Claude Code must:

1. Stop all compilation and diagnostic activity immediately
2. Instruct the developer to refresh VS Code:
   `Ctrl+Shift+P → AL: Reload Extension`
3. Wait for explicit confirmation from the developer that the refresh is done
4. Only then run `al_getdiagnostics` or `al_compile` to check for real errors

## What NOT to do

- Do not investigate namespace errors that appear immediately after file creation
- Do not modify `using` statements based on errors seen before a refresh
- Do not move or rename the file based on pre-refresh diagnostics
- Do not run `al_compile` or `al_build` immediately after creating a new file
- Do not report "compilation failed" based on pre-refresh diagnostics

## Signal to watch for

If `al_getdiagnostics` returns errors referencing objects that clearly belong
to the other project (e.g. `Library Assert` errors in a main app context,
or ID range errors for a test codeunit), this is a pre-refresh false positive.

Stop. Instruct the developer to refresh. Wait. Then re-run diagnostics.

## Message to developer

When this situation occurs, output exactly this message before stopping:

```
⚠️ VS Code needs a refresh before I can check for real compilation errors.

Please run: Ctrl+Shift+P → AL: Reload Extension

Let me know when the refresh is done and I will re-check diagnostics.
```

Do not continue with any other activity until the developer confirms the refresh.
