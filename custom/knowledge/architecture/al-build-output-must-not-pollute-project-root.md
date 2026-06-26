---
bc-version: [all]
domain: architecture
keywords: [build, output, alpackages, duplicate, language-server, app-package, project-root, AL0197]
technologies: [al]
countries: [w1]
application-area: [all]
---

## Description

When `al_build` or the VS Code AL extension builds an AL project, the generated `.app` file is placed in the project root folder by default. Over successive builds, multiple `.app` files accumulate (e.g. `Publisher_AppName_28.0.0.1.app`, `28.0.0.4.app`, `28.0.0.7.app`). The AL language server — both in VS Code and in the MCP AL server — scans the project folder for symbol packages and may load these compiled artefacts alongside the live source files. This causes `AL0197` duplicate object errors for every object in the project, with error messages pointing to source lines rather than to the packaged artefact as the duplicate source.

The errors are not real. They disappear when the stale `.app` files are removed from the root.

## Rule

AL build output (`.app` files) **must not** accumulate in the project root folder.

Configure the build output path to a dedicated subfolder that is excluded from language server scanning.

In `.vscode/settings.json`:
```json
{
  "al.outputPath": ".output"
}
```

When using the MCP `al_build` tool, pass `outputPath` explicitly:
```
al_build projectPath="..." outputPath=".output/AppName.app"
```

Add `.output/` to `.gitignore` if not already excluded.

## What NOT to do

- Do not allow `.app` files to accumulate in the project root without cleanup
- Do not interpret `AL0197` ("already declared by extension") as a source code error before first checking for stale `.app` files in the project root
- Do not add root `.app` files to `.gitignore` as a substitute for proper output path configuration — removal is required, not concealment

## Signal to watch for

If `al_build` or `al_getdiagnostics` reports `AL0197 — An application object ... is already declared by the extension '...'` for objects that exist only in source, inspect the project root for `.app` files before investigating source code.

## How to recover

1. Delete all `.app` files from the project root
2. Re-add the project: `al_addproject projectPath="..."`
3. Re-run `al_build` with an explicit `outputPath`
