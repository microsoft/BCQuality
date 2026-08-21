---
bc-version: [all]
domain: performance
keywords: [reset, setloadfields, partial-record, load-selection, findset]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Reset and empty SetLoadFields restore a full-row load

> Contributions welcome — open a PR to refine or extend this article.

## Description

`SetLoadFields(...)` sticks to the record variable until something clears it. `Reset()` "changes fields select for loading back to all", and `SetLoadFields()` with no arguments does the same. A later `FindSet` or `Get` then materializes every normal field. Agents often place `SetLoadFields` first, then `Reset` to apply new filters, and assume the partial selection survives. It does not.

## Best Practice

Call `Reset` (or empty `SetLoadFields()`) first when the variable must be reused, then call `SetLoadFields` with the fields the next read actually uses, then apply filters and read. After `Reset`, a new `SetLoadFields` is required; the previous list is gone.

See sample: `reset-clears-partial-record-selection.good.al`.

## Anti Pattern

`SetLoadFields(...)` followed by `Reset()` (or by parameterless `SetLoadFields()`) and then `FindSet` without restoring the load list. The filters look correct; the SQL still selects every column.

See sample: `reset-clears-partial-record-selection.bad.al`.
