---
bc-version: [all]
domain: error-handling
keywords: [table-events, oninsert, onmodify, ondelete, transaction, rollback, commit, batch, subscriber]
technologies: [al]
countries: [w1]
application-area: [all]
---

# A throw in a table-event subscriber rolls back the whole batch

> Contributions welcome — open a PR to refine or extend this article.

## Description

Table-trigger event subscribers (`OnAfterInsertEvent`, `OnAfterModifyEvent`, `OnAfterDeleteEvent`, and their `OnBefore` counterparts) execute synchronously inside the transaction of the write that fired them. Because AL runs on a single implicit transaction with no per-record savepoint, an error raised in such a subscriber rolls back **all work since the last `COMMIT`** — not just the record that triggered it. In a batch loop with no intermediate `COMMIT`s, a single failing record discards the entire batch. The intuition that subscriber validation fails only the current record is wrong on the BC platform.

## Best Practice

Decide the failure granularity deliberately. If a batch must continue past individual failures, do not throw from the table-event subscriber — collect the error (for example via `ErrorInfo`/collectible errors) and let the loop continue, or isolate each record's work behind a `Codeunit.Run` / `if Codeunit.Run() then` boundary so its failure rolls back only that record. Insert intermediate `COMMIT`s only with full awareness of the durability trade-off.

## Anti Pattern

Putting `Error`/`TestField`/`FieldError` validation inside a table-event subscriber and assuming it rejects just the offending record during bulk processing. The first failure unwinds every uncommitted record in the run, turning a one-row data problem into a whole-batch rollback.
