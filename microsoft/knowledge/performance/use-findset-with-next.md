---
bc-version: [all]
domain: performance
keywords: [findset, next, repeat, iteration, aa0181]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use FindSet with Next for iteration

> **Seed article.** Converted from an existing performance-review prompt to bootstrap the BCQuality performance corpus. Domain stewards should expand, restructure, and refine as needed.

## Description

When iterating over a filtered set of records with repeat-until, use FindSet together with Next. CodeCop rule AA0181 requires FindSet or Find to be paired with Next; using FindFirst or FindLast as the loop starter misrepresents intent and leads to rule AA0233.

## Best Practice

Call FindSet to start the iteration and Next to advance. Guard the loop with the standard `if FindSet() then ... until Next() = 0` idiom so callers can still handle the empty-set case.

See sample: `use-findset-with-next.good.al`.

## Anti Pattern

Starting a repeat-until loop with FindFirst or FindLast reads only one row and then calls Next on an iterator that was not intended for full-set traversal. The platform pays extra work to fetch the single row and the loop silhouette is misleading to reviewers.

See sample: `use-findset-with-next.bad.al`.

