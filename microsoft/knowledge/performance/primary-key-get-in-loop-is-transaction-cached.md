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

Reviewers sometimes see two `Get` calls inside a routine that runs once per row and recommend wrapping them in a `Dictionary` cache. Without evidence of a material additional cost, that duplicates the server's built-in record cache and adds state that must be invalidated. Filtered, non-keyed reads are a different case (see [repeated filtered results](cache-repeated-filtered-results-with-explicit-scope.md)).

## Best Practice

Treat a primary-key `Get()` — especially a guarded `if not Rec.Get(...) then exit;` — as a transaction-cached read, not as proof of N+1 SQL. Do not recommend a manual cache solely from source-level call counts. If profiling shows repeated AL work or cache misses are material and the complete result can be reused safely, assess an explicitly scoped cache on its own merits. Investigate genuinely repeated non-keyed queries (`FindSet`/`FindFirst` with filters, `Count`) separately.

## Anti Pattern

Reporting repeated primary-key `Get` calls (such as `Bin.Get` and `BinType.Get`) inside a per-row helper as one SQL round trip per call, or recommending a `Dictionary` without measuring reuse and cost. Per-row keys often differ, and the server can satisfy repeated keys from its transaction cache.
