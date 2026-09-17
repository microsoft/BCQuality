---
bc-version: [all]
domain: performance
keywords: [findset, findfirst, findlast, get, next, repeat-until, aa0181, aa0233]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use FindSet with repeat..Next; do not pair FindFirst/FindLast/Get with Next

## Description

Two CodeCop rules carve out the loop pattern. AA0181 says `FindSet()`/`Find()` "must be used with `Next()` method" — these are the multi-row APIs that the runtime sets up for forward iteration. AA0233 says do "NOT use `FindFirst()`/`FindLast()`/`Get()` with `Next()`" — these are single-row APIs, and iterating from them "wastes CPU and bandwidth." Both rules together define one boundary: choose `FindSet` when the body iterates; choose `FindFirst`, `FindLast`, or `Get` when the body uses exactly one record.

## Best Practice

When the body executes `repeat ... until Next() = 0;`, open the iteration with `FindSet()`. When the body needs one record and does not call `Next`, use `FindFirst`, `FindLast`, or — if the full primary key is known — `Get` (see `use-get-instead-of-findfirst-on-full-primary-key.md`). The choice is per call site, not a global preference.

See sample: [`pair-findset-with-next-loop.good.al`](pair-findset-with-next-loop.good.al).

## Anti Pattern

`if Customer.FindFirst() then repeat ... until Customer.Next() = 0;` — AA0233 flags this. The single-row API does not prepare the runtime for iteration, so the loop pays a cost the FindSet path does not. The mirror anti-pattern is calling `FindSet` to read a single record (see `use-isempty-for-existence-check.md` when only existence is required).

See sample: [`pair-findset-with-next-loop.bad.al`](pair-findset-with-next-loop.bad.al).
