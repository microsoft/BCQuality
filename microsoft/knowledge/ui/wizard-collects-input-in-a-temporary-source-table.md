---
bc-version: [all]
domain: ui
keywords: [navigatepage, wizard, sourcetabletemporary, assisted-setup, temporary-record, finish, cancel]
technologies: [al]
countries: [w1]
application-area: [all]
---

# A wizard collects its input in a temporary source table and saves on Finish

## Description

An assisted setup guide is a `NavigatePage` that the user can leave at any step. If the page is bound directly to a database table, every field the user fills in is written as they move through the steps, and closing the guide halfway leaves a partly configured record behind. The documented structure avoids this: set `SourceTableTemporary = true` so the page's source-record changes are collected in temporary records, and transfer the data to the persistent table explicitly when the user chooses **Finish**.

`SourceTableTemporary` covers only the page's own source record. It does not prevent database writes made by other logic on the page, such as a trigger or action that modifies another table directly.

## Best Practice

Declare the wizard with `SourceTableTemporary = true`, initialize the temporary record when the page opens, and write to the real table in the procedure that the **Finish** action calls, before closing the page. Keep any other database writes in that same finishing step, so that leaving the guide early changes nothing.

See sample: [`wizard-collects-input-in-a-temporary-source-table.good.al`](wizard-collects-input-in-a-temporary-source-table.good.al).

## Anti Pattern

A `NavigatePage` whose `SourceTable` is the live setup table without `SourceTableTemporary`, or a temporary wizard whose **Next** action or field triggers already modify persistent tables. An abandoned guide then leaves setup data that later code treats as complete. Reviewer signal: a `NavigatePage` with a `SourceTable` and no `SourceTableTemporary = true`, or `Insert`/`Modify` calls on non-temporary records outside the finishing procedure.

Do not report the temporary source table as lost data or as a missing save: the explicit transfer on **Finish** is the save. A wizard with no `SourceTable`, which keeps its input in page variables until **Finish**, follows the same principle.

See sample: [`wizard-collects-input-in-a-temporary-source-table.bad.al`](wizard-collects-input-in-a-temporary-source-table.bad.al).

## References

[Designing assisted setup guides: Build the assisted setup](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-designing-navigate-pages#build-the-assisted-setup) and [SourceTableTemporary property](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-sourcetabletemporary-property).
