---
bc-version: [all]
domain: performance
keywords: [get, guard, early-exit, conditional, lookup, wasted-query]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Apply early-exit guards before calling Get

## Description

A `Get` (or any other database call) executed before a guard that may exit the procedure does a round-trip the procedure never uses. Per the upstream guidance, "Flag `Get()` calls that execute before a guard condition that may exit early — the DB lookup is wasted." The fix is structural: order the procedure body so cheap checks (parameter validation, in-memory field comparisons, enum tests) run first, and the database call runs only after the guards pass.

## Best Practice

Read the procedure top-to-bottom and place every condition that can short-circuit ahead of every database call. The check `if SomeNo = '' then exit;` belongs above `Header.Get(...)`, not below. Each guard moved upward saves one wasted query on the path that exits.

See sample: [`apply-guards-before-get.good.al`](apply-guards-before-get.good.al).

## Anti Pattern

`Record.Get(...)` at the top of a procedure followed by `if SomeField = '' then exit;`. The code reads top-down as "load the record, then decide whether we needed it" — exactly the order that wastes the query. The pattern is easy to introduce when guards are added later, defensively, without re-checking call ordering.

See sample: [`apply-guards-before-get.bad.al`](apply-guards-before-get.bad.al).
