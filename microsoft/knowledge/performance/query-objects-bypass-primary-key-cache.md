---
bc-version: [all]
domain: performance
keywords: [query, cache, primary-key-cache, record-api, sql]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Query objects bypass the primary-key cache and always hit SQL

## Description

The Record API reuses a server-side primary-key cache: repeated reads of the same rows within a session or request can be served from memory without going to SQL. Query objects do not participate in that cache. Every execution of a query goes to the database, even when the same rows were just read through a Record variable in the same transaction.

This inverts the usual intuition that queries are always faster than record loops. Queries win when they exploit a covering index, aggregate, or join multiple tables in SQL that AL would otherwise loop. They lose when the data is small, already cached, or read repeatedly in a short window — the per-call SQL round-trip dominates.

Query objects also cannot write, cannot be backed by a page, and do not see the records a temp-table-backed AL flow has inserted but not committed. Choose them for set-based reads over indexed data, not as a generic replacement for the Record API.

## Best Practice

Use a query object when the shape of the work is genuinely set-based: aggregation, multi-table join, or a large read that benefits from a covering index. For hot single-record or small-result reads — especially lookups that will repeat in the same request — prefer the Record API so the primary-key cache does its job.

## Anti Pattern

Replacing a `Get` or a short filtered `FindSet` inside a frequently-called helper with a query object "for performance". Every caller now pays a SQL round-trip that the Record API cache had been absorbing, and the helper gets slower under load, not faster.
