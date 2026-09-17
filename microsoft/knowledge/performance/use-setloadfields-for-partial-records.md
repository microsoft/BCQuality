---
bc-version: [all]
domain: performance
keywords: [setloadfields, partial-record, normal-field, flowfield, get, findset, statement-order]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use SetLoadFields to load only the fields the code reads

## Description

`SetLoadFields(...)` declares the subset of normal fields the next read should materialize. Microsoft's partial-record guidance explains how loading fewer fields reduces work, particularly for read loops and tables with extensions. Primary-key fields, `SystemId`, system audit fields, and fields being filtered on are loaded automatically; those do not need to appear in the selection. Only `FieldClass = Normal` fields can be selected, not FlowFields or FlowFilters.

Its position relative to `SetRange`/`SetFilter` does not change the projection: filtered fields are included at read time either way. Projection-changing operations are separate: `AddLoadFields(...)` expands the selection, a later `SetLoadFields(...)` or `SetBaseLoadFields()` overwrites it, and `Reset()` or a fieldless `SetLoadFields()` restores all readable normal fields. The Microsoft Learn references below document the selection and reset behavior.

## Best Practice

Before a `Get`, `FindSet`, or `FindFirst` that the procedure follows by reading only a handful of the table's fields, call `SetLoadFields` listing exactly those fields. For example, `SetLoadFields(...); if Record.Get(...) then ...` selects fields before the read. Place the call immediately before the read, after any `SetRange`/`SetFilter`, so a reader can see at a glance which read the selection governs and any projection-changing operation is easy to spot. Skip `SetLoadFields` when the table has few fields (under ten), when the code reads most of them (above 60 %), when the loop runs ten or fewer iterations, or when the table is exempt for other reasons ([singleton setup tables](singleton-setup-tables-need-no-access-optimization.md), [temporary tables](temporary-tables-have-no-database-cost.md)). The numeric cutoffs are BCQuality review heuristics, not Microsoft platform thresholds. For report dataitems, use `AddLoadFields` in `OnPreDataItem` instead (see [report partial loads](addloadfields-in-report-onpredataitem.md)).

See sample: [`use-setloadfields-for-partial-records.good.al`](use-setloadfields-for-partial-records.good.al).

## Anti Pattern

Loading a wide table and reading one field per row in a loop. The bytes transferred per row are dominated by the columns the procedure does not touch; the SQL query selects them anyway. The same applies to a single `Get` on a wide table — the platform reads the whole row when a single field would have sufficed.

Statement order is not part of this anti pattern. `SetLoadFields` placed ahead of `SetRange`/`SetFilter` materializes exactly the same columns as the reverse order, so a reviewer reports it as a readability observation at most — never as a performance defect.

See sample: [`use-setloadfields-for-partial-records.bad.al`](use-setloadfields-for-partial-records.bad.al).

## References

- [Record.SetLoadFields remarks](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-setloadfields-method#remarks): automatically loaded fields, normal-field restrictions, and resetting the selection.
- [Using partial records](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-partial-records): performance rationale, load-selection APIs, reset behavior, and report guidance.
