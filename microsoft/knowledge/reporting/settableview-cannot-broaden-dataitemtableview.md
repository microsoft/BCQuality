---
bc-version: [all]
domain: reporting
keywords: [report, settableview, dataitemtableview, filter, view, narrowing]
technologies: [al]
countries: [w1]
application-area: [all]
---

# SetTableView cannot broaden DataItemTableView

## Description

`Report.SetTableView()` applies the supplied record view by narrowing the view already defined by the report dataitem's `DataItemTableView`. It cannot remove or broaden a static dataitem filter. A caller that requests records excluded by `DataItemTableView` therefore produces an empty dataset rather than overriding the report filter.

## Best Practice

Keep only invariant restrictions in `DataItemTableView`. When callers must select among values, leave that dimension open in the static view and pass the required filter through `SetTableView`. Review this as a defect only when the report definition and caller together show a contradictory filter.

See sample: [`settableview-cannot-broaden-dataitemtableview.good.al`](settableview-cannot-broaden-dataitemtableview.good.al).

## Anti Pattern

Define a static filter in `DataItemTableView` and call `SetTableView` with a mutually exclusive filter while expecting the runtime view to replace the static one. The filters are intersected and no records are selected.

See sample: [`settableview-cannot-broaden-dataitemtableview.bad.al`](settableview-cannot-broaden-dataitemtableview.bad.al).

## References

`Report.SetTableView()` method — https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/methods-auto/report/reportinstance-settableview-method