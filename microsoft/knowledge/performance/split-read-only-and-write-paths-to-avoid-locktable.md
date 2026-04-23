---
bc-version: [all]
domain: performance
keywords: [locktable, read-only, write-path, contention, helper]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Split read-only and write paths so LockTable runs only when needed

## Description

LockTable takes an exclusive write lock on the affected table for the remainder of the transaction. In a helper that is called from many read-only sites and a few write sites, placing LockTable unconditionally at the top serializes every reader on every other reader's lock — the helper becomes a system-wide contention point. The correct shape is a conditional structure: try the read-only path first, and only fall through to LockTable when the code genuinely needs to modify the table.

## Best Practice

Factor the helper so readers return immediately without a lock and only writers reach the LockTable call. A common pattern: attempt `Rec.Get()` first; if it returns the row, exit with the value; otherwise LockTable and proceed with the Insert. Document the pattern in a comment on the helper so callers understand why the LockTable is inside a branch.

See sample: `split-read-only-and-write-paths-to-avoid-locktable.good.al`.

## Anti Pattern

A `GetOrCreate` helper that unconditionally calls `Rec.LockTable()` at the top, then Gets the row, then returns it. Every reader now blocks every other reader even though none of them intend to write. Under load the helper becomes the dominant bottleneck.

See sample: `split-read-only-and-write-paths-to-avoid-locktable.bad.al`.
