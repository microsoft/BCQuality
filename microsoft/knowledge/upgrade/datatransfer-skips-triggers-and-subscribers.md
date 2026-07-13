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

`DataTransfer` writes directly at the database layer. It does not invoke field `OnValidate` triggers, table `OnModify` triggers, or any `OnAfterModifyEvent` / `OnBeforeValidate...` event subscribers that a normal `Record.Modify(true)` would. This is precisely what makes it fast — and precisely what makes it a footgun when the field being updated has validation logic that other code relies on. The receiving code never gets the signal that a row changed, derived fields stay stale, audit hooks do not run.

For *new fields and tables added in the same change* this is fine: nothing yet depends on the validation. For *pre-existing fields with validation logic*, `DataTransfer` quietly bypasses business logic that may be load-bearing for posting, calculation, or integration scenarios.

## Best Practice

Use `DataTransfer` only when the field or table is new in the same change — initial population is the canonical safe case. When updating a pre-existing field that has validation logic, either use `Modify(true)` to honour the triggers, or, if `DataTransfer` is still required for performance reasons, leave a comment that explicitly states "validation triggers and event subscribers are intentionally not raised" and verify with the field's owner that this is safe.

See sample: `datatransfer-skips-triggers-and-subscribers.good.al`.

## Anti Pattern

Reaching for `DataTransfer` to update an existing field with non-trivial `OnValidate` logic, without a comment and without confirming that subscribers can be skipped. The upgrade succeeds; runtime behaviour drifts silently.

See sample: `datatransfer-skips-triggers-and-subscribers.bad.al`.
