---
bc-version: [21..]
domain: upgrade
keywords: [datatransfer, validate, onvalidate, onmodify, event-subscriber, derived-data, copyfields, business-logic]
technologies: [al]
countries: [w1]
application-area: [all]
---

# `DataTransfer` does not fire validation triggers or event subscribers

## Description

`DataTransfer` writes sets directly at the database layer, so row-based triggers and events do not run. `CopyFields` skips the table `OnModify` trigger and modification events; `CopyRows` skips the corresponding insert trigger and events. Direct field assignment does not call field `OnValidate` or its validation events: `Record.Validate(Field, Value)` runs field validation, while `Record.Modify(true)` separately runs the table `OnModify` trigger.

A field or table being newly introduced does not by itself prove that bypassing logic is safe. A new field can have validation logic that maintains derived data, and an existing table can already have triggers and subscribers that must observe writes, including subscribers in other extensions.

## Best Practice

Use `DataTransfer` when set-based transfer preserves the required result and row-level business logic can safely be skipped. Establish which field-validation, insert/modify, and subscriber logic is bypassed and verify that affected invariants and derived data remain correct or are populated explicitly by the migration. For existing load-bearing logic, record the specific bypass and how correctness was verified; intent or a comment alone is not proof of safety.

When field validation must run, loop through records and call `Validate(Field, Value)`. If the table's `OnModify` trigger must also run, follow with `Modify(true)`; `Modify(true)` does not retroactively validate assigned fields. The required business effects, not record count or field newness, determine whether a record loop is needed.

See sample: [`datatransfer-skips-triggers-and-subscribers.good.al`](datatransfer-skips-triggers-and-subscribers.good.al).

## Anti Pattern

Using `DataTransfer` when skipped validation, table triggers, or subscribers are required to keep related or derived data correct, including when the field being written is new. Replacing it with only `Modify(true)` is also incomplete when field validation is required. Missing documentation alone is not evidence of a functional defect; identify the required effect that would be lost.

See sample: [`datatransfer-skips-triggers-and-subscribers.bad.al`](datatransfer-skips-triggers-and-subscribers.bad.al).

## References

- [Microsoft Learn: Transferring data between tables using DataTransfer](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-data-transfer) — row-based triggers and events are not executed.
- [Microsoft Learn: Record.Validate](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-validate-method) — runs field validation.
- [Microsoft Learn: Record.Modify](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-modify-method) — `RunTrigger` controls the table `OnModify` trigger.
