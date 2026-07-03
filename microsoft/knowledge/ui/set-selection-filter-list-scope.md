---
bc-version: [all]
domain: ui
keywords: [set-selection-filter, marked-only, list-page, bulk-action, batch-action, selection-scope, copy-rec]
technologies: [al]
countries: [w1]
application-area: [all]
---

## Description

`CurrPage.SetSelectionFilter(Rec)` behaves differently depending on whether the user explicitly multi-selected rows. When no rows are marked — the cursor is simply positioned on a row — the method writes a primary key filter for that single row and leaves `MarkedOnly` as false. When the user explicitly selected multiple rows, the method marks those records and sets `MarkedOnly` to true. A batch action that calls `SetSelectionFilter` and then passes the record directly to a processing codeunit will therefore silently restrict to one row whenever the user has not made an explicit selection, which is almost never the intended behaviour for an action labelled "Verify All" or "Post All".

The base platform avoids this ambiguity by routing batch list actions through Reports: the Report request page shows the derived filter and lets the user correct it before running. A direct codeunit call has no such safety net and must resolve the scope explicitly.

## Best Practice

After calling `SetSelectionFilter`, test `MarkedOnly`. When it is false — meaning the user made no explicit selection, or selected all rows with Ctrl+A — discard the single-row primary key filter by copying the page source record (`Copy(Rec)`), which carries the full page view including all active filter groups. When `MarkedOnly` is true the user made a deliberate selection and that filter should be respected as-is. Refer to `set-selection-filter-list-scope.good.al` for the pattern.

## Anti Pattern

Passing the result of `SetSelectionFilter` directly to a processing codeunit without checking `MarkedOnly`. When the user runs the action with the cursor on row three and no rows highlighted, the codeunit receives a filter that matches only row three. The action appears to succeed but processes a fraction of the intended scope. The defect is hard to notice because no error is raised and the single-row run completes without complaint. See `set-selection-filter-list-scope.bad.al`.

## See also

`Page.SetSelectionFilter` — https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/methods-auto/page/page-setselectionfilter-method
