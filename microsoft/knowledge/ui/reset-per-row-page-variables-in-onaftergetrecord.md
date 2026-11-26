---
bc-version: [all]
domain: ui
keywords: [onaftergetrecord, page-variable, global-variable, computed-field, stale-value, api-page, clear, control-flow]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Define per-record page outputs on every control-flow path

## Description

A global page variable belongs to the page instance, whereas `Rec` changes as `OnAfterGetRecord` processes records. Page variables are initialized when the page is loaded; do not assume that each retrieved record clears them. If an output is assigned only after a successful lookup or in one branch, a later record processed by that instance can retain an earlier record's value. This affects per-record fields in list and part pages and in API page output; it is not a claim that values persist between independent requests or sessions.

## Best Practice

Define every per-record output for the current record on every path that returns normally from `OnAfterGetRecord`. Reset those outputs before any conditional computation or early `exit`, or assign them in every applicable branch. A helper that initializes all outputs, an unconditional assignment or a function returning a value for every path is equally valid; an explicit `Clear` is not mandatory. Preserve intentional page-wide state, caches and accumulators. Do not clear `Rec` or call `ClearAll` as a substitute for initializing the outputs.

Trace helper calls and `var` parameters before reporting an unassigned path. Keep current-selection action state separate from per-record field values; the distinction between `OnAfterGetCurrRecord` and `OnAfterGetRecord` is covered by the existing page-lifecycle guidance.

See sample: [`reset-per-row-page-variables-in-onaftergetrecord.good.al`](reset-per-row-page-variables-in-onaftergetrecord.good.al). It includes both explicit clearing and complete conditional assignment.

## Anti Pattern

A field is bound to a global page variable, and a normal path through `OnAfterGetRecord` leaves that variable unchanged even though it describes the current record. Require evidence of both a prior value and a reachable path that can expose it for another record. An `if Lookup.Get(...) then Output := ...` without a default or complete alternative is a typical signal. The absence of `Clear` alone is not a defect. CodeCop AA0205 checks unassigned-variable usage; passing that check is not proof that a conditional global output has been defined for the current record.

See sample: [`reset-per-row-page-variables-in-onaftergetrecord.bad.al`](reset-per-row-page-variables-in-onaftergetrecord.bad.al).

## References

- [OnInit initializes page variables when the page is loaded](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/triggers-auto/page/devenv-oninit-page-trigger)
- [OnAfterGetRecord runs for each fetched record and Rec is that record](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/triggers-auto/page/devenv-onaftergetrecord-page-trigger)
- [Microsoft API page clears AppName before a conditional assignment](https://github.com/microsoft/BCApps/blob/e51c552efbeb6821db450b199aae6b015371866c/src/Apps/W1/APIV2/app/src/pages/APIV2ExpandedPermissionSets.Page.al)
- [Microsoft API page clears Status and ErrorMessage for each record](https://github.com/microsoft/BCApps/blob/e51c552efbeb6821db450b199aae6b015371866c/src/Apps/W1/APIV2/app/src/pages/APIV2AutScheduledJobs.Page.al)
- [Microsoft ListPart assigns StyleTxt in both branches of its SetStyle helper](https://github.com/microsoft/BCApps/blob/e51c552efbeb6821db450b199aae6b015371866c/src/Layers/W1/BaseApp/System/DataExchange/DataExchSetupSubform.Page.al)
- [CodeCop AA0205](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/analyzers/codecop-aa0205)
