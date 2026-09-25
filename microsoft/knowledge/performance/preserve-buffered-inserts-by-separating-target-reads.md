---
bc-version: [all]
domain: performance
keywords: [buffered-inserts, bulk-inserts, findlast, insert, target-table, commit, staging]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Keep eligible inserts together instead of re-reading their target

## Description

Business Central can automatically buffer eligible `Insert` calls. `Find`/`Calc` on the **target** table, `Modify`/`Delete` on it, or `Commit` flushes pending inserts; consuming the `Insert` return value, or BLOB/AutoIncrement fields on the target, prevents buffering. A source-table read is not itself a target-table flush. There is no general `InsertAll` replacement for an AL loop.

## Best Practice

When writing completed rows to an application-owned data-only table, allocate a collision-free run or range once, prepare every field before each `Insert`, and keep the insert sequence free of intervening target-table reads and writes. Let the owning business transaction determine the commit point. Trace called procedures and events as well as the visible loop; inspect actual SQL batches and writes, then test failures, retries, and any concurrent writers. The sample assumes an exclusive new run ID and no required trigger, validation, number-series, or subscriber effects. See sample: [`preserve-buffered-inserts-by-separating-target-reads.good.al`](preserve-buffered-inserts-by-separating-target-reads.good.al).

## Anti Pattern

Calling `FindLast` on the target for every row to allocate its next line number, inserting an incomplete row and immediately modifying it, or committing each iteration of an otherwise eligible insert sequence. Moving a shared `FindLast` out of the loop without concurrency-safe allocation is **not** a valid fix. Do not recommend skipping required triggers or persistence steps in sales documents, journals, or posting ledgers just to obtain buffering; repeated `Modify` calls do not automatically batch like eligible inserts. See sample: [`preserve-buffered-inserts-by-separating-target-reads.bad.al`](preserve-buffered-inserts-by-separating-target-reads.bad.al).

## References

- [Bulk inserts and flush/non-buffering conditions](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/administration/optimize-sql-bulk-inserts).
- [Transaction checkpoints and restart safety](avoid-commit-inside-loops.md).
