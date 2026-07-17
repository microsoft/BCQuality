---
bc-version: [all]
domain: performance
keywords: [filter, drilldown, lookup, sourcetableview, tablerelation, setrange, false-positive]
technologies: [al]
countries: [w1]
application-area: [all]
---

# A page or lookup's effective filter may be defined outside the changed hunk

## Description

The effective filter on a drill-down, lookup, or list result set is frequently defined outside any single changed hunk — on the table via a `SourceTableView` property or a `TableRelation`, or through `SetRange`/`SetFilter` calls in unchanged code that runs before the result is shown. The absence of a filter within the changed lines of a diff is therefore not evidence that the result set is unfiltered or that it will load an entire table.

## Best Practice

Do not assert that a drill-down, lookup, or list is "unfiltered" based only on the changed hunk. Confirm the effective filter by checking the page's `SourceTableView`, the field's `TableRelation`, and any `SetRange`/`SetFilter` in the surrounding (possibly unchanged) code before raising a finding about an unbounded result set.

## Anti Pattern

Concluding that a lookup or drill-down loads an unfiltered, full-table result set solely because no `SetRange`/`SetFilter` appears in the changed lines, when the filter is defined on the table, in a `TableRelation`, or in unchanged setup code.
