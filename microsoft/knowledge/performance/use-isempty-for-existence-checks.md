---
bc-version: [all]
domain: performance
keywords: [isempty, count, findfirst, existence]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use IsEmpty for existence checks

> Contributions welcome — open a PR to refine or extend this article.

## Description

IsEmpty is the cheapest way to answer whether at least one row matches the current filters. It short-circuits at the first match and never hydrates a record. Count() scans and counts the entire set; FindFirst fetches a full row just to be discarded.

## Best Practice

Use `if not Rec.IsEmpty() then ...` for existence checks. Reserve Count for cases where the exact number of rows is needed, and FindFirst for cases where you actually want the row's field values.

See sample: `use-isempty-for-existence-checks.good.al`.

## Anti Pattern

`if Rec.Count() > 0` iterates the whole set just to answer a yes/no question. `if Rec.FindFirst() then` loads an entire row of data the caller never reads.

See sample: `use-isempty-for-existence-checks.bad.al`.

