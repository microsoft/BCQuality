---
bc-version: [all]
domain: performance
keywords: [insert, modify, delete, trigger, run-trigger, write-parameters]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Pass false to Insert/Modify/Delete when the table triggers do not need to fire

## Description

`Insert(true)`, `Modify(true)`, and `Delete(true)` run the table's `OnInsert`/`OnModify`/`OnDelete` trigger; the `(false)` form skips it. Per the upstream guidance, the trigger form should be used "only when needed" — every row whose write fires a trigger pays that cost, even when the trigger has nothing useful to add for the current call site. For tight bulk write paths the difference compounds linearly with row count.

## Best Practice

Reach for the `(false)` form when the calling code already enforces the invariants the trigger would, or when the trigger is empty for the current table/extension. Use `(true)` when the trigger does work the caller depends on (number-series allocation, validation, cascading writes). Decide per call, not by code style: a default of "always `true`" makes bulk writes pay for triggers they did not need, and a default of "always `false`" silently skips validation the trigger was put there to enforce.

See sample: [`pass-false-to-insert-when-trigger-not-needed.good.al`](pass-false-to-insert-when-trigger-not-needed.good.al).

## Anti Pattern

Looping over thousands of rows and calling `Modify(true)` on each, when the table's `OnModify` trigger does nothing relevant for the operation. The trigger cost is paid per row; the user-visible behavior is identical to the `(false)` form. The mirror is using `(false)` for an operation that depends on trigger-side defaulting and silently producing rows that fail downstream validation.
