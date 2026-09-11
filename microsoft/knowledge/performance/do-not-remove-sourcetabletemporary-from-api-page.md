---
bc-version: [all]
domain: performance
keywords: [sourcetabletemporary, api-page, temporary, persistent, in-memory]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Removing SourceTableTemporary on an API page switches it from in-memory to persistent

## Description

`SourceTableTemporary = true` on a page makes the page's record buffer in-memory only — reads and writes do not touch SQL. The same applies to `TableType = Temporary` on a record. Removing either turns operations that were memory accesses into database round-trips. Per the upstream guidance, the change is "potentially increasing DB load for high-volume paths (API pages, background tasks)" — and on API pages especially, the change is invisible at the page definition but visible at production scale.

## Best Practice

If a page or record was declared temporary on purpose — to buffer payloads, accept synthetic rows, or expose computed data through an API surface without persisting it — keep it temporary. When removing the property looks necessary, audit the call sites first: a temporary API page is often consumed by integrations that issue many calls per minute, and the round-trip cost is paid per call. If persistence is genuinely required, weigh storage and lock cost against alternatives (a regular table the API page reads from, an event-driven write).

See sample: [`do-not-remove-sourcetabletemporary-from-api-page.good.al`](do-not-remove-sourcetabletemporary-from-api-page.good.al).

## Anti Pattern

Dropping `SourceTableTemporary = true` from an API page to "simplify" it, without revisiting the access pattern. The page begins issuing real SQL on every request; locks now contend with other writers; bulk integrations slow proportionally. The same trap exists for a record that was `TableType = Temporary` and gets demoted to a persistent table to make a debugger view easier.

See sample: [`do-not-remove-sourcetabletemporary-from-api-page.bad.al`](do-not-remove-sourcetabletemporary-from-api-page.bad.al).
