---
bc-version: [all]
domain: performance
keywords: [isempty, findset, extra-round-trip, existence-check, false-positive]
technologies: [al]
countries: [w1]
application-area: [all]
---

# IsEmpty immediately before FindSet is an extra round-trip

> Contributions welcome — open a PR to refine or extend this article.

## Description

`IsEmpty` is the right API when the caller only needs existence — see `microsoft/knowledge/performance/use-isempty-for-existence-check.md`. It is not a cheap guard in front of a loop that will `FindSet` anyway. Both calls hit the database; `FindSet` already returns false when the filter matches nothing. Agents and reviewers often insert `if not Rec.IsEmpty() then` "for performance" and pay a second query for a result the iterator already provides.

## Best Practice

When the body iterates, open with `if Rec.FindSet() then repeat ... until Next() = 0`. Do not flag a bare `FindSet` loop as missing an `IsEmpty` precondition. Reserve `IsEmpty` for branches that never materialize the row set.

See sample: `isempty-before-findset-is-extra-round-trip.good.al`.

## Anti Pattern

`if not Rec.IsEmpty() then if Rec.FindSet() then repeat`. Also a false-positive review comment that asks to add that guard. The second read does not avoid the first; it duplicates it.

See sample: `isempty-before-findset-is-extra-round-trip.bad.al`.
