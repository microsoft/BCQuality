---
bc-version: [all]
domain: performance
keywords: [get, findfirst, primary-key, lookup]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Prefer Get for primary-key lookups

> Contributions welcome — open a PR to refine or extend this article.

## Description

Get is a direct primary-key lookup: one index seek, one row, done. FindFirst with SetRange on the primary key fields reaches the same row through a more general code path and carries the overhead of filter setup and a broader optimizer decision.

## Best Practice

When the complete primary key is known, call Get. Use FindFirst only for non-primary-key lookups or when the filter is a partial prefix of the key.

See sample: `prefer-get-for-primary-key-lookups.good.al`.

## Anti Pattern

Setting one SetRange per primary-key field and then calling FindFirst reproduces Get with more typing and slightly worse performance.

See sample: `prefer-get-for-primary-key-lookups.bad.al`.

