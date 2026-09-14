---
bc-version: [all]
domain: performance
keywords: [commit, commit-in-loop, checkpoint, watermark, retry, idempotent, elapsed-time, batch, topnumberofrows]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Commit batches at restart-safe business boundaries

> Contributions welcome — open a PR to refine or extend this article.

## Description

[Commit ends the current write transaction](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/database/database-commit-method). Committing every row can add transaction overhead and prevent whole-operation rollback, but deliberate commits after N completed business units or an elapsed-time threshold can be valid for long-running work. Most loops need no explicit Commit at all; see [implicit transaction boundaries](understand-implicit-transaction-boundary.md).

Restart safety concerns business effects, not whether a retry revisits a row. A durable checkpoint or processed state can exclude completed work, while demonstrably idempotent replay or durable deduplication can make revisiting it safe. For example, repeating a pure uppercase-name assignment wastes work but does not by itself demonstrate data corruption; repeating an increment can apply it twice.

## Best Practice

Choose the commit cadence separately from the retry strategy. Check the row count or elapsed time only after a complete business unit, and commit any final partial batch. A time threshold checked between units is not a fixed-duration guarantee: retrieval, locking, or a single slow unit can exceed it. Let errors propagate so uncommitted work rolls back.

When correctness depends on excluding completed work, persist its checkpoint or processed state in the same transaction as the corresponding business changes. Resume from that committed state, never from a key merely selected for future processing. Alternatively, establish that replay is idempotent or deduplicated for all effects, including external effects; a missing watermark alone is not a correctness finding.

Bounded retrieval is a separate performance requirement. Periodic commits do not cap a full-tail `FindSet`, because [`FindSet` is not implemented as `TOP X`](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/administration/optimize-sql-al-database-methods-and-performance-on-server#get-find-findset-and-next). When a bounded next-N batch is needed, a query capped by [`TopNumberOfRows`](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/query/queryinstance-topnumberofrows-method) can fill a temporary key buffer; process only those keys, not an inclusive range that concurrent inserts could expand. Use a stable ordering key and define how to handle records inserted at or below a committed watermark. Do not require bounded retrieval solely because a loop commits.

The paired samples apply a one-time credit-limit increase with one worker over a stable customer set. Both select at most 500 exact keys and finish a chunk after processing them or reaching a one-minute elapsed-time threshold, whichever is observed first. The good sample commits the last processed key with the increases; the bad sample keeps that key only in memory, so a retry can increase already committed limits again. AL DateTime subtraction produces a [Duration in milliseconds](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/duration/duration-data-type).

See sample: [`avoid-commit-inside-loops.good.al`](avoid-commit-inside-loops.good.al).

## Anti Pattern

Committing an incomplete business unit, persisting a checkpoint ahead of its business changes, or replaying committed non-idempotent effects with only an in-memory progress variable and no deduplication. In the last case, identify the effect a retry duplicates rather than treating all repeated work as corruption. Committing every row without a reason can also waste transaction overhead; this is distinct from deliberate row-count or elapsed-time batching.

See sample: [`avoid-commit-inside-loops.bad.al`](avoid-commit-inside-loops.bad.al).
