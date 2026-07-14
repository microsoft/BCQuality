---
bc-version: [21..]
domain: upgrade
keywords: [datatransfer, validate-trigger, event-subscriber, side-effects, business-logic]
technologies: [al]
countries: [w1]
application-area: [all]
---

# `DataTransfer` does not fire validation triggers or event subscribers

## Description

`DataTransfer` writes sets directly at the database layer, so row-based triggers and events do not run. For `CopyFields`, that includes the table `OnModify` trigger and `OnBeforeModifyEvent`/`OnAfterModifyEvent`; direct field assignment also does not call field `OnValidate` or its validation events. These are separate behaviors: `Record.Validate(Field, Value)` runs field validation, while `Record.Modify(true)` runs the table `OnModify` trigger. Calling `Modify(true)` does not retroactively validate assigned fields.

For *new fields and tables added in the same change* this is fine: nothing yet depends on the validation. For *pre-existing fields with validation logic*, `DataTransfer` quietly bypasses business logic that may be load-bearing for posting, calculation, or integration scenarios.

## Best Practice

Use `DataTransfer` when set-based transfer is safe and row-level business logic is intentionally unnecessary — initial population of a new field is the canonical case. When an existing field's validation must run, loop through records and call `Validate(Field, Value)`; if the table's modify trigger must also run, follow with `Modify(true)`. If performance requires `DataTransfer`, document exactly which field-validation and row-modification triggers or subscribers are intentionally bypassed and verify that derived data remains correct.

See sample: `datatransfer-skips-triggers-and-subscribers.good.al`.

## Anti Pattern

Reaching for `DataTransfer` to update an existing field with non-trivial `OnValidate` or `OnModify` logic, without confirming that both validation and row-modification subscribers can be skipped. Replacing it with only `Modify(true)` is also incomplete when field validation is required; call `Validate` for that field first.

See sample: `datatransfer-skips-triggers-and-subscribers.bad.al`.
