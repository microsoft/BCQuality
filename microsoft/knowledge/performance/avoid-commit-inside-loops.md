---
bc-version: [26..28]
domain: performance
keywords: [commit, loop, transaction, lock]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not Commit inside loops

> **Seed article.** Converted from an existing performance-review prompt to bootstrap the BCQuality performance corpus. Domain stewards should expand, restructure, and refine as needed.

## Description

Commit ends the current transaction. Calling it inside a loop produces one transaction per iteration and loses the ability to roll back the whole operation atomically. It also interferes with the platform's ability to batch write operations. The original motivation — releasing locks during a long batch — is better served by splitting the batch into explicit checkpoints that each process a bounded number of rows.

## Best Practice

If the batch is large enough that a single transaction is untenable, process it in checkpoints driven by an outer loop that each time picks up the next N rows. Commit once per checkpoint at a clearly defined safe boundary, not inside the per-row loop.

## Anti Pattern

Placing Commit inside `repeat ... until Next() = 0` is almost always a mistake: it is unusual for the correctness of the operation to depend on per-row commits, and the cost of starting a new transaction on every row dominates the work.

See sample: `avoid-commit-inside-loops.bad.al`.

