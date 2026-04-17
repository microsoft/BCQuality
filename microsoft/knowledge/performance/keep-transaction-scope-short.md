---
bc-version: [26..28]
domain: performance
keywords: [transaction, lock, scope, contention]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Keep transaction scope short

> **Seed article.** Converted from an existing performance-review prompt to bootstrap the BCQuality performance corpus. Domain stewards should expand, restructure, and refine as needed.

## Description

Every write operation runs inside a transaction that holds locks until the transaction ends. Long transactions increase blocking, deadlocks, and timeouts for other sessions. The same work split across narrower transactions typically completes faster under load because it holds locks for less time.

## Best Practice

Perform data reads, calculations, and external integrations outside the transaction whenever possible. Enter the writing phase with all inputs computed, execute the minimum set of Insert, Modify, and Delete calls, and exit. If you have a long-running batch, split it into checkpoints at safe boundaries (see avoid-commit-inside-loops).

See sample: `samples/performance/keep-transaction-scope-short/good.al`.

## Anti Pattern

Opening a transaction, then performing external web-service calls, heavy report runs, or user-facing dialogs while the locks are held, suspends every other session that needs the same rows for as long as the external operation takes.

See sample: `samples/performance/keep-transaction-scope-short/bad.al`.

