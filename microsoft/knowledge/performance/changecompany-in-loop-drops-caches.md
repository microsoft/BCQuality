---
bc-version: [all]
domain: performance
keywords: [changecompany, loop, cache, multi-company, isolation]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not call ChangeCompany inside a per-row loop

> Contributions welcome — open a PR to refine or extend this article.

## Description

`ChangeCompany` retargets a record variable to another company's data and drops the in-memory caches bound to the previous company. Calling it once per row in a multi-company scan therefore pays a cache reset on every iteration, even when consecutive rows share a company. Agents treat `ChangeCompany` like a filter. It is an isolation switch.

## Best Practice

Group work by company. Call `ChangeCompany` once per distinct company, then `FindSet`/`Get` that company's rows. If the record variable is reused afterward, call `ChangeCompany()` without a company name to redirect it back to the current company.

See sample: `changecompany-in-loop-drops-caches.good.al`.

## Anti Pattern

`repeat Rec.ChangeCompany(Buffer.Company); Rec.Get(Buffer."No."); until Buffer.Next() = 0` when `Buffer` is not ordered by company, or even when it is — if `ChangeCompany` still runs every row. The signal is `ChangeCompany` inside `repeat`/`while` keyed by a document line rather than by a company loop.

See sample: `changecompany-in-loop-drops-caches.bad.al`.
