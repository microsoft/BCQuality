---
bc-version: [all]
domain: performance
keywords: [codeunit-run, commit, write-transaction, nesting, loop, runtime-error]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Commit before Codeunit.Run when the caller already holds a write transaction

## Description

`Codeunit.Run` cannot nest inside an open write transaction. Per the platform reference, "If you're already in a transaction you must commit first before calling `Codeunit.Run`." The platform enforces this at runtime: the first call dies with an error, not at compile time. The rule most often surfaces in a loop that pairs outer-scope writes — progress records, audit log entries, failure markers — with a per-item `Codeunit.Run`: the first outer write opens a transaction, the subsequent `Codeunit.Run` throws. `[CommitBehavior]` does not silence this, because the implicit commit inside `Codeunit.Run` is exempt from the attribute: "The `CommitBehavior` only applies to explicit commits, not implicit commits done as part of [Codeunit.Run]." `[TryFunction]` is not a substitute either: a try method catches errors but does not open its own rollback boundary (see `use-tryfunction-for-error-catching-not-rollback.md`).

## Best Practice

For the `Codeunit.Run` atomic-sub-operation pattern (see `codeunit-run-as-atomic-sub-operation.md`) to work in a loop, keep the outer scope **read-only**. Move per-iteration writes — progress updates, logging, audit entries — into the sub-codeunit so they commit or roll back together with the per-item work. If logging must live outside the atomic boundary, defer it: collect failure info in memory during the loop (a `List of [Text]`, a temporary record, local variables) and write it in one pass after the loop ends, when no outer write transaction is open.

See sample: `codeunit-run-requires-prior-commit-inside-transaction.good.al`.

## Anti Pattern

Inserting `Commit()` before each `Codeunit.Run` to silence the runtime error. The error goes away, but the outer scope now commits per iteration — the behavior `avoid-commit-inside-loops.md` exists to warn against. Attempting to silence the implicit commit inside the sub-codeunit with `[CommitBehavior(CommitBehavior::Ignore)]` also fails: the attribute does not apply to `Codeunit.Run`'s implicit commit. Conditioning the Commit on `Database.IsInWriteTransaction()` (runtime 11.0+) is another version of the same trap — the method has legitimate uses for diagnostics and library code that genuinely cannot control its caller, but branching production flow on runtime transaction state typically signals unclear ownership that would be better fixed by restructuring the caller so transaction state is predictable.

See sample: `codeunit-run-requires-prior-commit-inside-transaction.bad.al`.
