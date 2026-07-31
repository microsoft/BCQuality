---
bc-version: [all]
domain: architecture
keywords: [dependency, source, reference-repos, clone, github, curabis, closed-source, test, symbol, black-box]
technologies: [al]
countries: [w1]
application-area: [all]
---

## Description

CURABIS develops and maintains several AL apps that are consumed as dependencies
across many customer projects (Danelec, Jernpladsen, Wareco, KLB, etc.). When a
customer project imports one of these apps, it typically arrives as a compiled
`.app` symbol package in `.alpackages/` — not as source code.

This makes the app look like a closed external dependency. It is not.

Before treating any CURABIS-owned dependency app as a black box, the agent
must check whether its source is available on GitHub and read it directly.
Reverse-engineering compiled symbol packages (`SymbolReference.json`, `.app`
manifest inspection) is always an inferior substitute for reading the actual
production source, and produces lower-confidence tests and code reviews.

**How to actually get the source (2026-07-30 — was previously the underspecified
`add_repo <repo>`, which is not a real tool in most Claude Code sessions):**

- **Claude Code CLI** (this is the common case): maintain a persistent,
  periodically-refreshed clone at `~/.claude/reference-repos/<org>/<repo>/` —
  same pattern as BCQuality's own channel clone. Before reading, check if it
  exists:
  - Missing: `git clone --depth 1 <url> "$env:USERPROFILE\.claude\reference-repos\<org>\<repo>"`
    (shallow — you need current source, not history)
  - Exists: `git -C "$env:USERPROFILE\.claude\reference-repos\<org>\<repo>" pull --depth 1`
    (refresh before trusting it — a stale clone from a prior session is a
    silent source of wrong answers)
  - Then `Read`/`Grep`/`Glob` it like any other local path.
- **Claude Code on web** (claude.ai/code): use the session's repo picker /
  "add repository" action instead, if the UI offers one — there is no shell
  to clone into in that environment.

Verify which of these your actual session supports before assuming either
works — do not silently fall back to symbol inspection if neither succeeds;
flag the limitation explicitly instead (see "When cloning fails" below).

## Known CURABIS app repos

| App name | GitHub repo | Notes |
|---|---|---|
| Contract Management 365 app | https://github.com/Curabis/ContractMgmt365app.git | Main contract engine; depended on by most CURABIS customer projects |
| Project Management 365 app | https://github.com/Curabis/ProjectMgmt365app.git | |
| Cross Channel Management 365 app | https://github.com/Curabis/WebStore.git | |
| Summatim | https://github.com/MichaelDieringer/-summatim.git | Currently restricted — only mid has access; the clone will fail for other team members |

*Expand this table when new CURABIS apps are created. If an app is not listed here,
ask `mid` whether source is available before reverting to symbol inspection.*

## Microsoft BCApps

Microsoft's own standard objects (Base Application, System Application, test
framework libraries: Library-Sales, Library-ERM, Library-Purchase, etc.) are
available at:

- https://github.com/microsoft/BCApps

Clone it to `~/.claude/reference-repos/microsoft/BCApps/` (see the mechanism
above) when you need to understand internals of Microsoft standard codeunits
(e.g. Sales-Post, Gen. Jnl.-Post Line, Copy Document Mgt.) that are referenced
by event subscribers but whose source is not visible in the current project.
It is a large public monorepo — a shallow clone is still the right call, and
worth refreshing rather than re-cloning once it exists.

## Anti Pattern

    // WRONG: reverse-engineering the compiled symbol package instead of reading source
    // Agent parses SymbolReference.json from .alpackages/*.app to learn
    // Contract Management table fields and public procedure signatures.
    // Result: incomplete picture, missed validation logic, excluded feature from tests.

## Best Practice

    // CORRECT: clone the source repo and read it directly
    git clone --depth 1 https://github.com/Curabis/ContractMgmt365app.git `
      "$env:USERPROFILE\.claude\reference-repos\Curabis\ContractMgmt365app"

    // Then read the actual table definitions, codeunits, and any Test Library
    // codeunits that may already exist in the repo's own test app.

    // If no Test Library exists in the dependency's test app:
    // build GIVEN helpers in the consuming project's own Test Library codeunit
    // based on the REAL table field definitions and trigger logic you can now read.

## When to apply this rule

Apply at the start of any task involving:
- Writing tests for production code that uses event subscribers on CURABIS-owned
  codeunits or tables
- Calling public procedures from a CURABIS-owned app's codeunits
- Building GIVEN helpers for a CURABIS-owned app's tables
- Code-reviewing changes to codeunits that extend CURABIS-owned apps

## When cloning fails

If the clone fails due to access restrictions (see table above) or your
session has no shell to clone into, flag the limitation explicitly rather
than silently falling back to symbol inspection.
