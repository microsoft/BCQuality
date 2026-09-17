---
bc-version: [all]
domain: performance
keywords: [get, findfirst, primary-key, setrange, lookup]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use Get when the full primary key is known; FindFirst is the wrong tool

## Description

`Get(...)` is the direct primary-key lookup. `FindFirst()` walks an index — even when narrowed by `SetRange` on every primary-key field. The upstream review guidance treats `Customer.SetRange("No.", CustomerNo); if Customer.FindFirst() then ...` as a bad pattern and `if Customer.Get(CustomerNo) then ...` as the correction. The two reach the same record; only `Get` expresses the lookup as a primary-key seek.

## Best Practice

When all primary-key fields are available at the call site, call `Get` (or `GetBySystemId`) with them. Reserve `FindFirst` for cases where the filter is on something other than the full primary key — a unique secondary field, a partial composite key, a sort that the caller cares about.

See sample: [`use-get-instead-of-findfirst-on-full-primary-key.good.al`](use-get-instead-of-findfirst-on-full-primary-key.good.al).

## Anti Pattern

Composing `SetRange` calls that exactly cover the primary key and then calling `FindFirst`. The result is correct but the call site reads as "search the table" rather than "look up by key", which obscures both the intent and the access pattern from later reviewers.

See sample: [`use-get-instead-of-findfirst-on-full-primary-key.bad.al`](use-get-instead-of-findfirst-on-full-primary-key.bad.al).
