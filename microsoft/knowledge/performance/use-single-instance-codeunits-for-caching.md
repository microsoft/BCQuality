---
bc-version: [all]
domain: performance
keywords: [singleinstance, cache, codeunit, session]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use SingleInstance codeunits for session caching

> Contributions welcome — open a PR to refine or extend this article.

## Description

A SingleInstance codeunit lives once per session. Variables on it survive across calls, which makes it the natural home for data that is expensive to compute, read often, and stable for the duration of the session — feature flags, configuration snapshots, setup records. Each cached value avoids a SQL read per subsequent call site.

## Best Practice

Store long-lived, read-often, rarely-changing data on a SingleInstance codeunit, populated lazily on first access. Keep the cached footprint small: a handful of booleans, a setup record, a few derived values. Be explicit about invalidation if the source can change during the session.

See sample: `use-single-instance-codeunits-for-caching.good.al`.

## Anti Pattern

Reading the same setup record on every call from every caller, instead of caching it, repeats a SQL round-trip that has no business happening more than once per session.

