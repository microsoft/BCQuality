---
bc-version: [all]
domain: query
keywords: [query, open, close, clear, cursor, filters, reuse]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Reopening a Query resets its cursor but keeps its filters

## Description

Calling `Open()` on an already open query first closes the current dataset and opens it again. The next `Read()` starts at the first row; it does not continue from the previous cursor. Reopening also retains filters previously applied to the query variable. Only `Clear(QueryVariable)` resets those filters, so reuse can unexpectedly reread the first row or carry an old filter into a logically separate operation.

## Best Practice

Open once for one read pass. Close after the pass, and call `Clear(QueryVariable)` before reusing the variable for a logically independent query whose filters must start empty. Set the next pass's filters explicitly before reopening.

See sample: `reopening-query-resets-cursor-but-keeps-filters.good.al`.

## Anti Pattern

Calling `Open()` inside or between reads to "advance" or "start fresh", or reusing the same query variable for a new operation while assuming `Open()` cleared old filters. The code compiles but can repeatedly process the first row or silently omit rows behind a retained filter.

See sample: `reopening-query-resets-cursor-but-keeps-filters.bad.al`.
