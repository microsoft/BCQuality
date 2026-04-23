---
bc-version: [all]
domain: performance
keywords: [codeunit-run, atomic, rollback, transaction, sub-transaction, try-pattern, implicit-commit]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use Codeunit.Run to bound an atomic sub-operation

## Description

`Codeunit.Run(ID)` is the AL-idiomatic way to run a unit of work as an atomic sub-operation with its own transactional boundary. When the return value is captured — `if Codeunit.Run(MyCodeunit) then ...` — the runtime treats the codeunit as a unit: on successful completion it performs an implicit commit of the codeunit's database changes; on error it rolls those changes back and the caller receives `false`. Per the platform reference, "any changes done to the database will be committed at the end of the codeunit, unless an error occurs." The caller decides how to react — compensate, surface an error, continue — without having to manage transactions by hand.

## Best Practice

When a piece of work must either complete fully or have no effect, put it in its own codeunit and invoke it via `Codeunit.Run`, capturing the return. Use `if not Codeunit.Run(X) then Error(...)` to abort and unwind; use the plain boolean branch to react to failure without aborting the caller. This replaces the SQL-style `BEGIN TRAN / COMMIT / ROLLBACK` habit with a pattern the AL runtime implements natively. Do not confuse `Codeunit.Run` with `[TryFunction]` — both catch errors, but only `Codeunit.Run` rolls back database changes on failure (see `use-tryfunction-for-error-catching-not-rollback.md`). Note that if the caller is already in a write transaction, the platform requires a `Commit()` before `Codeunit.Run` — the sub-operation cannot nest inside an open transaction (see `codeunit-run-requires-prior-commit-inside-transaction.md`).

See sample: `codeunit-run-as-atomic-sub-operation.good.al`.

## Anti Pattern

Inlining the work in the caller and sprinkling `Commit()` to simulate sub-transaction boundaries. The caller's enclosing transaction is fused to the sub-work; any Commit between checkpoints survives subsequent errors, and any errors after a Commit cannot be cleanly unwound. Per-row Commits (see `avoid-commit-inside-loops.md`) are a frequent symptom.

See sample: `codeunit-run-as-atomic-sub-operation.bad.al`.
