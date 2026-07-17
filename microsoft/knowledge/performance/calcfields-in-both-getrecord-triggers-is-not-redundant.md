---
bc-version: [all]
domain: performance
keywords: [calcfields, onaftergetrecord, onaftergetcurrrecord, page-lifecycle, flowfield, false-positive]
technologies: [al]
countries: [w1]
application-area: [all]
---

# CalcFields in both OnAfterGetRecord and OnAfterGetCurrRecord is not redundant

## Description

`OnAfterGetRecord` fires once per row as the page loads records into the view; `OnAfterGetCurrRecord` fires when a record becomes the active/current record. Calling `CalcFields` in both triggers is not duplicate or redundant work: the two triggers run at different points in the page lifecycle and serve different purposes — populating FlowFields for every displayed row versus refreshing them for the record the user has selected. The same `CalcFields` call appearing in both places is an intentional pattern, not copy-paste waste.

## Best Practice

Do not flag `CalcFields` appearing in both `OnAfterGetRecord` and `OnAfterGetCurrRecord` as duplicate, redundant, or removable. Treat each trigger's `CalcFields` on its own lifecycle merits.

## Anti Pattern

Recommending that a developer delete one of the two `CalcFields` calls because "the field is already calculated in the other trigger". The genuine per-row FlowField cost is addressed by the separate guidance on FlowField calculation in loops and on hidden FlowFields; it is not addressed by removing a lifecycle-correct `CalcFields`.
