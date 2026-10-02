---
bc-version: [all]
domain: error-handling
keywords: [confirm, onvalidate, xrec, abort, revert, side-effect, consistency]
technologies: [al]
countries: [w1]
application-area: [all]
---

# A declined `Confirm` in `OnValidate` must abort or revert, not skip a required side effect

## Description

By the time a field's `OnValidate` body runs, the field already holds its new value. When the trigger asks the user to confirm a side effect that the new value makes **required for consistency** — releasing or replacing state that is tied to the old value and that nothing will reference any more once the change commits — the shape `if Confirm(...) then <side effect>;` with nothing on the `false` branch lets the new value commit while silently skipping that effect. No error is raised, the user sees no indication that anything was declined, and the record is left inconsistent with its own dependents.

Not every confirmed follow-up is required. When the confirmed effect is a convenience the user may legitimately decline, skipping it is correct: `"Sales Header"`'s `UpdateSalesLinesByFieldNo` asks whether to update the lines after a header field changes and, on "no", simply `exit`s — the header keeps its new value and the lines stay as they were, by design. A `Confirm` at the top of an action procedure, before anything has been written, may also just `exit` on "no" (for example the delete action in `"Test Input Groups"`). Neither shape is this anti-pattern. Nor is a declined update whose old state stays valid: `Opportunity`'s `"Campaign No."` `OnValidate` asks before moving open tasks filtered on `xRec."Campaign No."` to the new campaign and does nothing on "no" — the tasks keep pointing at a campaign that still exists.

## Best Practice

Make the declined branch match what "no" means:

- **Cancel the whole change** — raise an error before the side effect. The usual BCApps form inside `OnValidate` is the silent abort `if not Confirm(...) then Error('');` (for example `"Bank Account"`, field `"Disable Bank Rec. Optimization"`, and `"Interaction Template"`, field `"Language Code (Default)"`, which ends `if Confirm(...) then begin ... end else Error('');`). The field trigger documentation states that in case of an error "the user entry is not written to the database."
- **Keep the old value but let the rest of the edit continue** — assign the field back in code. In the `"To-do"` table, field `"Team Code"`, declining the reassignment runs `"Team Code" := xRec."Team Code"`; on a page, `"Upload And Deploy Extension"` resets its sync-mode value to `Add` when the user declines `Force Sync`.

Ask before the side effect runs, and before taking locks the prompt would hold open (see [`avoid-user-prompts-inside-transactions`](../performance/avoid-user-prompts-inside-transactions.md)). When the same validation can run without a UI, a required confirmation must not be silently skipped behind `GuiAllowed`; decide the non-interactive outcome explicitly (see [`job-queue-handlers-must-not-require-ui`](../performance/job-queue-handlers-must-not-require-ui.md)).

See sample: [`declined-confirm-must-abort-not-partially-apply.good.al`](declined-confirm-must-abort-not-partially-apply.good.al).

## Anti Pattern

Inside a field `OnValidate` (or a procedure it calls), a `Confirm` gates a side effect that releases, cancels, or replaces state belonging to the old value (`xRec`), the `false` branch neither errors nor restores the field, and code after it proceeds as if the change were accepted — for example overwriting the only field that tracks the old state. Flag it only when, after the change, nothing references the old state any more, so declining leaves it orphaned. Do not flag declined updates whose old state remains valid and referenced, optional follow-ups whose skipping leaves every record consistent, or `exit` on "no" in an action before any write.

See sample: [`declined-confirm-must-abort-not-partially-apply.bad.al`](declined-confirm-must-abort-not-partially-apply.bad.al).

## References

- [OnValidate (Field) trigger](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/triggers-auto/field/devenv-onvalidate-field-trigger).
- BCApps `src/Layers/W1/BaseApp/Bank/BankAccount/BankAccount.Table.al`, lines 980-988 (silent abort in `OnValidate`).
- BCApps `src/Layers/W1/BaseApp/CRM/Interaction/InteractionTemplate.Table.al`, lines 157-165 (`else Error('')` in `OnValidate`).
- BCApps `src/Layers/W1/BaseApp/CRM/Task/Todo.Table.al`, lines 80-90 (table-field revert to `xRec`).
- BCApps `src/System Application/App/Extension Management/src/UploadAndDeployExtension.Page.al`, lines 78-83 (explicit revert on a page).
- BCApps `src/Layers/W1/BaseApp/CRM/Opportunity/Opportunity.Table.al`, lines 142-157 (declined update; old campaign still valid).
- BCApps `src/Layers/W1/BaseApp/Sales/Document/SalesHeader.Table.al`, `UpdateSalesLinesByFieldNo`, lines 4997-5014 (optional follow-up; `end else exit`).
- BCApps `src/Tools/Test Framework/Test Runner/src/DataDrivenTest/DataInputs/TestInputGroups.Page.al`, lines 85-86 (`exit` before any write).
