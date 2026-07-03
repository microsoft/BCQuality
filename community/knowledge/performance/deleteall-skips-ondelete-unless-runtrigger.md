---
bc-version: [all]
domain: performance
keywords: [deleteall, ondelete, run-trigger, set-based-delete, bulk-delete, triggers, validation]
technologies: [al]
countries: [w1]
application-area: [all]
---

# DeleteAll skips OnDelete unless you pass RunTrigger

> Contributions welcome — open a PR to refine or extend this article.

## Description

`Record.DeleteAll()` — equivalently `DeleteAll(false)` — translates to a single set-based SQL `DELETE` and **does not** run AL `OnDelete` triggers or field/table validations. Only database-level referential constraints still apply. To run `OnDelete` logic you must call `DeleteAll(true)`, which then deletes record-by-record and forfeits the set-based performance, making it equivalent to a `FindSet` loop calling `Delete(true)`. The common misconception, which training data reproduces, is that `DeleteAll` iterates and fires `OnDelete` per record; it does not. (Parameterless `Delete()` likewise defaults to `Delete(false)` and skips `OnDelete`.)

## Best Practice

Use `DeleteAll()` / `DeleteAll(false)` for bulk deletion only when no AL `OnDelete` cleanup is required — it is the fast, set-based form. When `OnDelete` logic must run (cascading deletes, ledger cleanup, integration events), pass `DeleteAll(true)` and accept the row-by-row cost, or refactor the cleanup to run explicitly before the bulk delete.

## Anti Pattern

Calling `DeleteAll()` and assuming dependent records, integration events, or validation side effects are handled by `OnDelete`. The deletion succeeds but the AL-side cleanup never runs, leaving orphaned data — and adding a manual `FindSet`/`Delete` loop "for safety" reintroduces the per-record cost the set-based form was chosen to avoid.
