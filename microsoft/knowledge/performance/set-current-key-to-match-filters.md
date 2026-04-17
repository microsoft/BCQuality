---
bc-version: [26..28]
domain: performance
keywords: [setcurrentkey, key, index, sort, filter]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Set the current key to match your filters

> **Seed article.** Converted from an existing performance-review prompt to bootstrap the BCQuality performance corpus. Domain stewards should expand, restructure, and refine as needed.

## Description

AL chooses a key for a Find call based on the current SetCurrentKey selection. When filters do not align with any key, the platform either scans or falls back to a less selective index. On tables with production-scale row counts, this is the difference between an index seek and a table scan.

## Best Practice

Call SetCurrentKey with the fields you filter and sort on, in the order they appear in a table key. If no suitable key exists, add one via a table extension rather than relying on an unsupported filter pattern.

See sample: `set-current-key-to-match-filters.good.al`.

## Anti Pattern

Setting many filters on fields that no key covers, and leaving the key selection to the platform's heuristics, produces non-deterministic performance that degrades as the table grows.

