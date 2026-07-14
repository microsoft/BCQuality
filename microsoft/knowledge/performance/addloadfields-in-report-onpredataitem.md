---
bc-version: [all]
domain: performance
keywords: [report, addloadfields, onpredataitem, dataitem, partial-record, layout]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Add trigger-only report fields in OnPreDataItem

## Description

Report dataitem field selection is calculated at compile time and once per dataitem type during execution. Fields referenced by dataset columns are selected automatically; fields used only in triggers are not. Use `AddLoadFields` in `OnPreDataItem` to supplement the automatic selection with normal fields that trigger code needs.

## Best Practice

When a dataitem trigger needs an extra field, add that field in `OnPreDataItem` before iteration starts. This supplements the compiler-selected fields and avoids the first just-in-time load and enumerator update when the trigger reads the extra field.

See sample: `addloadfields-in-report-onpredataitem.good.al`.

## Anti Pattern

Listing every dataset column in `AddLoadFields`, or omitting a known trigger-only field because the dataset already uses other fields. The former is redundant; the latter causes a just-in-time load on first access and can cause repeated loads when the record is copied or passed by value.

See sample: `addloadfields-in-report-onpredataitem.bad.al`.
