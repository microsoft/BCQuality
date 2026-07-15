---
bc-version: [all]
domain: query
keywords: [query, setfilter, setrange, open, read, dataset, filter-order]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Set Query filters before Open

## Description

`Query.SetFilter` and `Query.SetRange` automatically close an open query dataset. A call placed after `Open()` therefore does not refine the rows already being read; it ends that dataset. The next `Read()` has no open dataset unless the code explicitly calls `Open()` again, so a plausible filter change can turn a working loop into an empty or failing read sequence without a compiler diagnostic.

## Best Practice

Apply every filter before `Open()`, then read the dataset to completion and call `Close()`. When a later branch needs different filters, close or clear the query, set the new filters, and open a new dataset deliberately.

See sample: `set-query-filters-before-open.good.al`.

## Anti Pattern

`Query.Open()` followed by `SetFilter` or `SetRange` and then `Read()` under the assumption that the filter updates the open cursor. Refiltering after `Open()` is valid only when the code intentionally opens a fresh dataset afterward.

See sample: `set-query-filters-before-open.bad.al`.
