---
bc-version: [26..28]
domain: performance
keywords: [setloadfields, placement, filter, setrange, query-plan]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Call SetLoadFields before filters

## Description

`SetLoadFields` is folded into the database query that the subsequent `Find`, `FindSet`, or `FindFirst` executes. When it is called after filters have already been applied, the platform either ignores the specification or is forced into an extra round-trip to reload the narrower column set — negating the optimization. The placement rule is simple and absolute: `SetLoadFields` must come first.

## Best Practice

Use a consistent order on every record variable that participates in `SetLoadFields` optimization: declare the record, call `SetLoadFields` with the processing fields, apply `SetRange`/`SetFilter`, then `FindSet` and iterate. The order makes the optimization visible in code review and prevents accidental regressions when filters are refactored.

See sample: `call-setloadfields-before-filters.good.al`.

## Anti Pattern

Setting filters first — because the filter logic is what the reviewer is thinking about — and then adding `SetLoadFields` just before the `FindSet`. The platform has already planned the query with the full column set; the `SetLoadFields` call is paid for without delivering any of the benefit.

See sample: `call-setloadfields-before-filters.bad.al`.
