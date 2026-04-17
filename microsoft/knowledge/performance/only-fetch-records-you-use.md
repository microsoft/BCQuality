---
bc-version: [26..28]
domain: performance
keywords: [findset, get, aa0175, wasted-fetch, read]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Only fetch records you use

> **Seed article.** Converted from an existing performance-review prompt to bootstrap the BCQuality performance corpus. Domain stewards should expand, restructure, and refine as needed.

## Description

CodeCop rule AA0175 flags code that retrieves a record and then does not use it. Every Find, FindSet, FindFirst, FindLast, or Get has a cost: the platform reads rows from SQL, materializes them, and transports them to the AL runtime. A call whose result is never read is wasted work, and on hot tables that work is never free.

## Best Practice

Retrieve a record only when you need one or more of its field values. When you only need to know whether at least one row matches a filter, use IsEmpty (see use-isempty-for-existence-checks). When you only need a subset of fields, use SetLoadFields (see use-setloadfields-for-partial-records).

See sample: `only-fetch-records-you-use.good.al`.

## Anti Pattern

Calling FindSet or Get and then ignoring the result, or using it only as a boolean existence test, performs the full fetch and throws the data away.

See sample: `only-fetch-records-you-use.bad.al`.

