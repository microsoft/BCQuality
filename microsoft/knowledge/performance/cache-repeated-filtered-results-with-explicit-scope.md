---
bc-version: [all]
domain: performance
keywords: [cache, dictionary, filtered-lookup, isempty, repeated-query, invalidation, scope]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Reuse repeated filtered results within a correct cache scope

## Description

A loop can ask the same filtered existence or calculation question for many rows sharing a business key, or two phases can ask it for the same rows. Unlike repeated primary-key `Get` calls, non-keyed filtered lookups are not automatically answered by the primary-key record cache. Memoization can remove repeated AL and data-access work, but a cache keyed by too few inputs or kept past a data change returns the wrong answer. A single pass over lines with unknown, possibly distinct item numbers does not establish reuse.

## Best Practice

First reuse an already-loaded result if valid. Require evidence that complete lookup keys actually repeat, such as repeated queries for the same item in two passes over an unchanged line set (as in the sample), or measured cache hits. For a repeated, stable filtered lookup, keep a local dictionary for one operation, keyed by every input that affects the result (including company, filters, date, unit, currency, and quantity where applicable). Cache negative results as well as positive ones; distinguish a missing dictionary entry from an entry whose value is `false`. If underlying records can change during the run, update or invalidate the entry, or do not cache it. Bound entries or process in chunks when key cardinality is large. Check distinct complete keys, hits/misses, SQL work, AL time, and memory before adding a cache to a low-reuse workload. Use a temporary table for record-shaped values or multiple keys. See sample: [`cache-repeated-filtered-results-with-explicit-scope.good.al`](cache-repeated-filtered-results-with-explicit-scope.good.al).

## Anti Pattern

Running the same filtered `IsEmpty` in two passes over the same unchanged lines (even when every item number is distinct within a pass), or caching a price by item alone when customer, variant, date, and quantity affect it. Do **not** infer a cache opportunity from a single pass with no established key reuse, such as visiting each distinct Item once; the [good sample](cache-repeated-filtered-results-with-explicit-scope.good.al) also shows this valid direct lookup. Do not equate each `Get` with a SQL round trip or automatically wrap a cached primary-key read in another dictionary; see [primary-key cache exceptions](primary-key-get-in-loop-is-transaction-cached.md). See sample: [`cache-repeated-filtered-results-with-explicit-scope.bad.al`](cache-repeated-filtered-results-with-explicit-scope.bad.al).

## References

- [Data access and caching](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/administration/optimize-sql-data-access).
- [Dictionary type and `Get`](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/dictionary/dictionary-data-type).
