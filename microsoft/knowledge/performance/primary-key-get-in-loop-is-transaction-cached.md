---
bc-version: [all]
domain: performance
keywords: [get, primary-key, record-cache, transaction, n-plus-one, dictionary-cache, over-engineering, false-positive]
technologies: [al]
countries: [w1]
application-area: [all]
---

# A primary-key Get() in a per-row helper is not an N+1 to cache manually

## Description

The Business Central server caches primary-key reads within a transaction. Repeated `Record.Get(<primary key>)` calls for the same key are served from that cache rather than re-queried, so a guarded `if not Rec.Get(...) then exit;` inside a per-row helper is not a genuine N+1 pattern. When each row legitimately carries a distinct key — for example one `Bin Content` row per bin, so `Bin.Get` and `BinType.Get` see a different bin each iteration — the `Get` must run per row regardless, and there is nothing to hoist.

Reviewers sometimes see two `Get` calls inside a routine that runs once per row and recommend wrapping them in a `Dictionary` cache. That is over-engineering: it duplicates the server's built-in record cache, adds state that must be invalidated, and breaks the surrounding extension's established pattern of direct guarded `Get` calls.

## Best Practice

Treat a primary-key `Get()` — especially a guarded `if not Rec.Get(...) then exit;` — as a cheap, transaction-cached read. Do not recommend a manual `Dictionary` cache around per-row primary-key `Get` calls. Reserve N+1 concerns for genuinely repeated non-keyed queries (`FindSet`/`FindFirst` with filters, `Count`) that re-hit the database each iteration.

## Anti Pattern

Reporting repeated primary-key `Get` calls (such as `Bin.Get` and `BinType.Get`) inside a per-row helper as a performance defect, or recommending they be cached in a `Dictionary`. The reads are already cached by the server within the transaction, and per-row keys often differ so the calls cannot be hoisted.
