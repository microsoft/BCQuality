---
bc-version: [all]
domain: performance
keywords: [setloadfields, primary-key, reference, existence-check, memory]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Load only primary key fields for reference work

> **Seed article.** Ported from BC Code Intelligence to seed the community corpus. Community contributors are invited to expand or refine.

## Description

Work that uses a record only for its identity — passing it to another procedure that will re-fetch what it needs, queueing a key for later processing, running existence checks, or building a reference collection — does not need non-key payload fields. `SetLoadFields` with only the primary key fields loads the minimum that preserves record identity while skipping everything else. On wide tables with large text, BLOB, or media fields the difference in memory and transfer is substantial.

## Best Practice

When the iterating code's body touches only primary key fields (or passes the record to another procedure that will apply its own `SetLoadFields`), declare `SetLoadFields` with just the primary key fields before applying filters and calling `FindSet`. Callers downstream that need more fields issue their own `Get` or extend the load explicitly.

See sample: `load-only-primary-key-fields-for-reference-work.good.al`.

## Anti Pattern

Using the default full-record load in loops whose body only reads the primary key, or forwards the record to another codeunit that immediately re-queries. The non-key payload is fetched across the wire and held in memory for the duration of the loop, then discarded unread.

See sample: `load-only-primary-key-fields-for-reference-work.bad.al`.
