---
bc-version: [all]
domain: performance
keywords: [query, primary-key-cache, get, false-positive, n-plus-one, record-cache]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Query results bypass the primary-key cache

> Contributions welcome — open a PR to refine or extend this article.

## Description

The Business Central server caches primary-key `Get` calls within a transaction. Query objects do not use that primary-key cache: reopening a Query per lookup executes the query again; `Read` consumes rows from an open query, not a new query for each row. `avoid-get-inside-loop-on-large-table.md` is right when an unbounded inner `Get`/`FindFirst` joins two large sets. It is wrong as a blanket rewrite of repeated `Get` on the same keys. Replacing a cached `Get` with a Query reopened per call can be slower.

## Best Practice

Keep `Record.Get` for repeated lookups of the same primary keys in one transaction. Use a Query when the work is a true join or aggregation that the record API would express as nested scans. Do not flag a guarded `Get` on a repeating key as an N+1 solely because a Query could express the same columns.

See sample: [`query-results-bypass-primary-key-cache.good.al`](query-results-bypass-primary-key-cache.good.al).

## Anti Pattern

Rewriting a helper that `Get`s Customer by `No.` on every sales line into a Query opened inside that helper. Distinct line customers still need a lookup; repeating customers were already served from the PK cache. The Query pays SQL every time.

See sample: [`query-results-bypass-primary-key-cache.bad.al`](query-results-bypass-primary-key-cache.bad.al).
