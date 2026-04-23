---
bc-version: [all]
domain: performance
keywords: [commit, transaction, implicit-commit, write-transaction, runtime, boundary]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL auto-commits when code execution completes

## Description

In AL, write transactions are managed by the runtime, not by the developer. When AL code begins executing from an entry point — an outermost trigger, a codeunit invoked via `Codeunit.Run`, a report, a page action — the runtime opens a write transaction on the first database write. When that execution completes without error, the runtime commits automatically; if that execution errors, uncommitted writes are rolled back. Explicit `Commit()` is not how write transactions are *started*; it is how a single execution is *split* into multiple transactions. Per the platform reference, "The Commit method separates write transactions in an AL code module."

## Best Practice

Default to no explicit `Commit()`. Let the runtime open and close the transaction around the execution. Reach for `Commit()` only when the execution has a real reason to persist partial progress — for example, a long batch that must release locks between checkpoints (see `avoid-commit-inside-loops.md`), or work that calls an external service and must persist the resulting handle before continuing with operations that may fail independently. If a stretch of work needs to either complete fully or have no effect, prefer `Codeunit.Run` over manual Commit choreography (see `codeunit-run-as-atomic-sub-operation.md`).

## Anti Pattern

Sprinkling `Commit()` defensively — at the end of a procedure, after every Modify, or "just to be safe" — reflects a SQL-style mental model that does not apply here. Every stray Commit shortens the rollback window: work before the Commit survives later errors the developer almost certainly intended to unwind. A Commit without a specific reason is a bug waiting to surface.
