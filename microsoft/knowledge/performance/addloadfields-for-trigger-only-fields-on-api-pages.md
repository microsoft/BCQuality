---
bc-version: [17..]
domain: performance
keywords: [api-page, odata, addloadfields, onopenpage, onaftergetrecord, partial-record, jit, global-variable]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Add trigger-only fields to API pages with AddLoadFields in OnOpenPage

## Description

API and OData pages load only the fields bound to page controls, so a field read only in trigger code costs a JIT load per row.

The platform applies partial records to pages opened through OData: the fields referenced in the page layout are loaded, plus any the platform needs for subpage linking. Fields that only trigger code reads are not selected. A common case is an API field bound to a global variable that `OnAfterGetRecord` fills from `Rec` (to convert a currency code, combine address fields, or look up a related id). The `Rec` fields it reads are not bound to any control, so each row's first access issues an implicit `Get`. On a collection request that is one extra database round trip per returned row. A JIT load can also fail with "Inconsistent read of field(s)" or "JIT loading of field(s) ... failed" when another session changes or deletes the row in between.

The compiler and analyzers do not flag this, and the page returns correct data, so the cost only shows in telemetry and SQL load.

## Best Practice

In `OnOpenPage`, call `Rec.AddLoadFields(...)` with the normal fields that page triggers read but no control binds. `AddLoadFields` adds to the platform's layout-based selection, so all needed fields arrive with the first read. Microsoft's own API pages use this pattern; see References. Microsoft Learn also names `OnFindRecord` as a place to add the fields for OData pages.

Fields bound directly to a control (`field(name; Rec."Field")`) need no entry. FlowFields are not covered by load fields; calculate them with `SetAutoCalcFields` or `CalcFields`. A page with `SourceTableTemporary = true` has no database cost to save.

See sample: [`addloadfields-for-trigger-only-fields-on-api-pages.good.al`](addloadfields-for-trigger-only-fields-on-api-pages.good.al).

## Anti Pattern

An API page whose `OnAfterGetRecord` (or a procedure it calls) reads `Rec` fields that no control binds, with no matching `Rec.AddLoadFields` in `OnOpenPage`. Typical tell: global variables bound to API fields and assigned from `Rec."..."` in `OnAfterGetRecord`.

Calling `Rec.SetLoadFields(...)` in `OnOpenPage` instead is also wrong: `SetLoadFields` replaces the selection, so layout fields that are not listed become JIT loads.

See sample: [`addloadfields-for-trigger-only-fields-on-api-pages.bad.al`](addloadfields-for-trigger-only-fields-on-api-pages.bad.al).

## References

- [Using partial records](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-partial-records): sections "OData pages", "Just-in-time (JIT) loading" and "Preventing inconsistent read and JIT loading errors".
- [Record.AddLoadFields method](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-addloadfields-method).
- BCApps `Expense Rules API`, `OnOpenPage` adds `"Currency Code"` for the variable-bound `currencyCode` field: [ExpenseRulesAPI.Page.al](https://github.com/microsoft/BCApps/blob/90a3a39be4a51c82ca01ab262607af0ac559ecfe/src/Apps/W1/ExpenseAgent/app/src/APIs/ExpenseRulesAPI.Page.al#L95-L104).
- BCApps `Expenses API`, `OnOpenPage` adds four fields read in `OnAfterGetRecord`: [ExpensesAPI.Page.al](https://github.com/microsoft/BCApps/blob/90a3a39be4a51c82ca01ab262607af0ac559ecfe/src/Apps/W1/ExpenseAgent/app/src/APIs/ExpensesAPI.Page.al#L360-L376).
- Report counterpart: [`addloadfields-in-report-onpredataitem.md`](addloadfields-in-report-onpredataitem.md).
