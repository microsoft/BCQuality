---
bc-version: [all]
domain: query
keywords: [query, dataitemtablefilter, setfilter, setrange, static-filter, filter-precedence]
technologies: [al]
countries: [w1]
application-area: [all]
---

# DataItemTableFilter cannot be overwritten at runtime

## Description

`DataItemTableFilter` defines a static filter on a Query dataitem. A runtime `SetFilter` or `SetRange` on the same source field does not replace that filter. The static and runtime filters are combined with AND, so contradictory values produce an empty dataset instead of broadening or replacing the query definition.

## Best Practice

Keep only invariant restrictions in `DataItemTableFilter`. Expose caller-selectable fields through a column or filter row and apply their values with `SetFilter` or `SetRange` before `Open()`. When both filter types intentionally target the same field, ensure their intersection represents the required dataset.

See sample: [`dataitemtablefilter-cannot-be-overwritten-at-runtime.good.al`](dataitemtablefilter-cannot-be-overwritten-at-runtime.good.al).

## Anti Pattern

Define a static filter in `DataItemTableFilter`, then apply a contradictory runtime filter to the same source field while expecting the runtime filter to replace the static one. Both filters remain effective and the query returns no rows.

See sample: [`dataitemtablefilter-cannot-be-overwritten-at-runtime.bad.al`](dataitemtablefilter-cannot-be-overwritten-at-runtime.bad.al).

## References

Filtering in Query objects — https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-query-filters