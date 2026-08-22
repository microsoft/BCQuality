---
bc-version: [all]
domain: performance
keywords: [setrange, setfilter, filter, loop, early, dataset]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Apply SetRange/SetFilter before iterating, not as an if-test inside the loop

## Description

A `SetRange` or `SetFilter` placed before `FindSet` narrows the result set at the database. The same condition expressed as an `if` inside the loop body filters in AL, after every row has crossed the boundary. Per the upstream guidance, "apply `SetRange`/`SetFilter` as early as possible to reduce dataset" and "more specific filters = better performance." On a production-scale table the difference is the difference between scanning a subset and scanning the whole table.

## Best Practice

Move every predicate that can be expressed as an equality or range filter into a `SetRange` or `SetFilter` ahead of the find. Make sure a key (index) exists whose leading fields cover the filter so the optimizer can seek; note that `SetCurrentKey` only sets sort order and is not an index hint (see `setcurrentkey-sets-sort-order-not-index-hint.md`). The loop body should then contain only the work that depends on per-row state.

See sample: `apply-filters-before-iterating.good.al`.

## Anti Pattern

`if Customer.FindSet() then repeat if Customer."Country/Region Code" = 'US' then ProcessCustomer(Customer); until Customer.Next() = 0;` — the loop pays for every row in the table and discards the non-matching ones in AL. The intent is the same as a `SetRange("Country/Region Code", 'US')` ahead of the find, but the cost is not.

See sample: `apply-filters-before-iterating.bad.al`.
