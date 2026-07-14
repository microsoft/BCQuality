---
bc-version: [all]
domain: performance
keywords: [commit, commit-in-loop, per-row-commit, checkpoint, bounded-checkpoint, watermark, topnumberofrows]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not Commit inside loops

> Contributions welcome — open a PR to refine or extend this article.

## Description

Commit ends the current write transaction. Calling it inside a per-row loop produces one transaction per iteration and loses the ability to roll back the whole operation atomically; it also interferes with the platform's ability to batch write operations. Most loops need no explicit Commit at all — AL auto-commits the enclosing code module on successful completion (see `understand-implicit-transaction-boundary.md`). When the batch is too large for one transaction, the fix is not a per-row Commit but bounded checkpoints that select an exact list of at most N keys and process only those rows.

## Best Practice

If the batch is large enough that a single transaction is untenable, use an ordered primary-key watermark and retrieve a bounded next-N key list. `FindSet` is optimized for reading the complete filtered set and isn't implemented as `TOP X`, so calling it over the remaining tail and breaking after N rows does not bound retrieval. The sample uses a query capped by [`TopNumberOfRows`](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/query/queryinstance-topnumberofrows-method) to fill a temporary key buffer, then takes update locks and modifies only those exact keys. It does not reconstruct an inclusive first-to-last range that concurrent inserts could expand. Commit after the bounded inner loop returns and persist its last selected key as the next watermark. Use a stable key and define how a later run handles records inserted at or below an already committed watermark. A `Codeunit.Run` boundary can also own a chunk when its implicit commit and error behavior fit the caller — see `codeunit-run-as-atomic-sub-operation.md`.

See sample: `avoid-commit-inside-loops.good.al`.

## Anti Pattern

Placing Commit inside `repeat ... until Next() = 0` is almost always a mistake: it is unusual for the correctness of the operation to depend on per-row commits, and the cost of starting a new transaction on every row dominates the work. A capped query that discovers only an upper key and then re-reads an inclusive key range is not exact batching either; concurrent inserts inside that range can enlarge the checkpoint.

See sample: `avoid-commit-inside-loops.bad.al`.
