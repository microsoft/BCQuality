---
bc-version: [26..28]
domain: performance
keywords: [findset, lock, locktable, readonly, update]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use FindSet in read-only mode by default

> **Seed article.** Converted from an existing performance-review prompt to bootstrap the BCQuality performance corpus. Domain stewards should expand, restructure, and refine as needed.

## Description

FindSet has two modes: FindSet() and FindSet(false) are read-only and take no write lock; FindSet(true) calls LockTable before fetching. Write locks are expensive and hold for the remainder of the transaction, so passing `true` when you do not intend to modify the records increases contention under load.

## Best Practice

Call FindSet with no arguments when the loop only reads field values. Pass `true` only when the same loop is expected to call Modify, Delete, or Rename on the record, and the correctness of the operation depends on the table being locked for the full iteration.

See sample: `use-findset-readonly-by-default.good.al`.

## Anti Pattern

Writing FindSet(true) reflexively for every iteration forces the platform to take a LockTable on every call, even when the loop only reads values. The older two-parameter signature `FindSet(ForUpdate, UpdateKey)` is obsolete and must not be used.

See sample: `use-findset-readonly-by-default.bad.al`.

