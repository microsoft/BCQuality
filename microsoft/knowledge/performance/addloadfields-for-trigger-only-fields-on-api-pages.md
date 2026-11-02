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

API and OData pages load only the fields bound to page controls, so a field read only in trigger code triggers JIT loads.

The platform applies partial records to pages opened through OData: the fields referenced in the page layout are loaded, plus any the platform needs for subpage linking. Fields that only trigger code reads are not selected. A common case is an API field bound to a global variable that `OnAfterGetRecord` fills from `Rec` (to convert a currency code, combine address fields, or look up a related id). Reading such a field causes a just-in-time load, an implicit `Get` and an extra access to the data source. The platform then updates the enumerator, and server caching can serve the `Get`, so the number of extra SQL round trips is not fixed. Do not state a per-row count without telemetry or SQL evidence. A JIT load can also fail with "Inconsistent read of field(s)" or "JIT loading of field(s) ... failed" when another session changes or deletes the row in between.

The compiler and analyzers do not flag this, and the page returns correct data, so the cost only shows in telemetry and SQL load.

## Best Practice

Before iteration starts, add the normal fields that page triggers read but that are not otherwise selected. Use `Rec.AddLoadFields(...)` in `OnOpenPage`, as Microsoft's own API pages do (see References); Microsoft Learn also names `OnFindRecord` for OData pages. `AddLoadFields` adds to the platform's layout-based selection, so all needed fields arrive with the first read.

No entry is needed for a field that is already selected:

- a field bound directly to a control (`field(name; Rec."Field")`);
- primary-key fields, `SystemId` and the audit fields (`SystemCreatedAt`, `SystemCreatedBy`, `SystemModifiedAt`, `SystemModifiedBy`), which are always loaded;
- fields that the page filters on, which are always loaded.

FlowFields are not covered by load fields; calculate them with `SetAutoCalcFields` or `CalcFields`. A page with `SourceTableTemporary = true` has no database cost to save.

See sample: [`addloadfields-for-trigger-only-fields-on-api-pages.good.al`](addloadfields-for-trigger-only-fields-on-api-pages.good.al).

## Anti Pattern

An API page whose `OnAfterGetRecord`, or a procedure it calls, reads a normal `Rec` field that no part of the effective selection covers. That means no bound control, not always loaded (primary key, `SystemId`, audit field, filtered field), and no `AddLoadFields` for it in `OnOpenPage` or `OnFindRecord`. Typical tell: global variables bound to API fields and assigned from such `Rec` fields in `OnAfterGetRecord`.

`Rec.SetLoadFields(...)` with a field list in those triggers replaces the platform's selection. Flag it only when the resulting projection drops a field that the layout or the triggers read. `SetLoadFields()` without fields loads all readable normal fields, so it causes no JIT load (but gives up the partial-record benefit).

See sample: [`addloadfields-for-trigger-only-fields-on-api-pages.bad.al`](addloadfields-for-trigger-only-fields-on-api-pages.bad.al).

## References

- [Using partial records](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-partial-records): sections "OData pages", "Just-in-time (JIT) loading", "Iterating over records" and "Preventing inconsistent read and JIT loading errors".
- [Record.AddLoadFields method](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-addloadfields-method): lists the fields that are always loaded. [Record.SetLoadFields method](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-setloadfields-method): explains calling it without fields.
- BCApps `Expense Rules API`, `OnOpenPage` adds `"Currency Code"` for the variable-bound `currencyCode` field: [ExpenseRulesAPI.Page.al](https://github.com/microsoft/BCApps/blob/90a3a39be4a51c82ca01ab262607af0ac559ecfe/src/Apps/W1/ExpenseAgent/app/src/APIs/ExpenseRulesAPI.Page.al#L95-L104).
- BCApps `Expenses API`, `OnOpenPage` adds four fields read in `OnAfterGetRecord`: [ExpensesAPI.Page.al](https://github.com/microsoft/BCApps/blob/90a3a39be4a51c82ca01ab262607af0ac559ecfe/src/Apps/W1/ExpenseAgent/app/src/APIs/ExpensesAPI.Page.al#L360-L376).
- Report counterpart: [`addloadfields-in-report-onpredataitem.md`](addloadfields-in-report-onpredataitem.md).
