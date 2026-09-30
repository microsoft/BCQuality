---
bc-version: [all]
domain: performance
keywords: [setcurrentkey, sort, order-by, index, key, query-optimizer, hint]
technologies: [al]
countries: [w1]
application-area: [all]
---

# SetCurrentKey is not a SQL index hint for record reads

## Description

A common misconception is that `SetCurrentKey` tells SQL Server which index to use for a filtered `FindSet`/`FindFirst` query. It does not. For record iteration, `SetCurrentKey` changes the `ORDER BY` clause of the generated SQL statement; it does not add an index hint, and the SQL Server query optimizer is free to ignore the named key entirely. A distinct use is selecting an appropriate key with `SumIndexFields` before `CalcSums` so the platform can use a compatible SIFT aggregate (see [SIFT and SQL Server](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-sift-and-sql-server)).

The optimizer picks the index from the `WHERE` clause (your `SetRange`/`SetFilter`) together with table statistics and estimated cost. In practice it almost never chooses an index just because that key appears in `ORDER BY`. So calling `SetCurrentKey` to "steer" the plan toward an index is a no-op for index selection — and can make things worse: an `ORDER BY` that the query does not otherwise need can push the optimizer toward a less selective index or add a Sort operator to the plan.

Selectivity comes from having the right index available (a key on the table whose leading fields cover the filter) and from filtering on those fields — not from `SetCurrentKey`.

## Best Practice

For a record-iteration read, decide `SetCurrentKey` on one question: **do I need the result set in a specific order?**

- If yes — you iterate rows in a defined sequence, or rely on `FindFirst`/`FindLast`/`Next` returning a particular row — call `SetCurrentKey` for that sort. The order is a functional requirement, and the `ORDER BY` is justified.
- If no — omit `SetCurrentKey`. Let the optimizer choose the cheapest plan for your filters; it may pick a better index and skip a sort.

To make a filtered read fast, ensure a key (index) exists on the table whose leading fields cover the filter, and filter on those fields with `SetRange`/`SetFilter`. That is what lets the optimizer seek. Defining the key creates the index; `SetCurrentKey` is not required to make the optimizer use it.

For a stored-field `CalcSums` instead of iteration, consider a matching current key with the summed field in `SumIndexFields`, as documented for SIFT; do not classify that call as an unnecessary `ORDER BY` on a row iterator (see [stored-field totals](calcsums-instead-of-calcfields-in-loop.md)).

See sample: [`setcurrentkey-sets-sort-order-not-index-hint.good.al`](setcurrentkey-sets-sort-order-not-index-hint.good.al).

## Anti Pattern

Adding `SetCurrentKey` to a filtered read purely in the belief that it forces SQL Server to seek a particular index, when the code never uses the resulting order. This does nothing for index selection and only appends an `ORDER BY` the query does not need, risking an unnecessary sort. Remove the `SetCurrentKey`; rely on the filters and an existing covering key instead.

See sample: [`setcurrentkey-sets-sort-order-not-index-hint.bad.al`](setcurrentkey-sets-sort-order-not-index-hint.bad.al).
