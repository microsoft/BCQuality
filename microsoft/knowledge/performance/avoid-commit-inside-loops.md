---
bc-version: [all]
domain: performance
keywords: [commit, loop, transaction, lock, checkpoint, codeunit-run]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not Commit inside loops

> Contributions welcome — open a PR to refine or extend this article.

## Description

Commit ends the current write transaction. Calling it inside a per-row loop produces one transaction per iteration and loses the ability to roll back the whole operation atomically; it also interferes with the platform's ability to batch write operations. Most loops need no explicit Commit at all — AL auto-commits the enclosing code module on successful completion (see `understand-implicit-transaction-boundary.md`). When the batch is too large for one transaction, the fix is not a per-row Commit but bounded checkpoints that each process N rows.

## Best Practice

If the batch is large enough that a single transaction is untenable, process it in checkpoints driven by an outer loop that each time picks up the next N rows. Commit once per checkpoint at a clearly defined safe boundary, not inside the per-row loop. Wrapping each chunk in `Codeunit.Run` gives the same effect with native rollback on failure — see `codeunit-run-as-atomic-sub-operation.md`.

See sample: `avoid-commit-inside-loops.good.al`.

## Anti Pattern

Placing Commit inside `repeat ... until Next() = 0` is almost always a mistake: it is unusual for the correctness of the operation to depend on per-row commits, and the cost of starting a new transaction on every row dominates the work.

See sample: `avoid-commit-inside-loops.bad.al`.

