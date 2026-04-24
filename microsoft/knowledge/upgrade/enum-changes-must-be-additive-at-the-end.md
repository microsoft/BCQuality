---
bc-version: [all]
domain: upgrade
keywords: [enum, ordinal, obsolete, backward-compatibility, breaking-change]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Enum changes must be additive at the end; never insert or remove values

## Description

AL enums store their ordinal on disk. Inserting a new value in the middle of an existing enum shifts every following ordinal by one: every row whose field holds the old ordinal N now resolves to the value that used to be N+1. Removing a value without obsoletion has the same effect. Both changes are data corruption disguised as a code edit and are effectively irreversible once a tenant has upgraded. Adding values at the end is safe — existing ordinals keep their meaning.

## Best Practice

Append new enum values at the end, taking the next free ordinal. Renaming the caption on an existing ordinal is fine.

When a value must be retired, follow the two-stage obsoletion workflow:

1. **First release:** Mark the value with `ObsoleteState = Pending`, `ObsoleteReason`, and `ObsoleteTag`. This gives callers at least one release cycle to migrate.
2. **Later release:** Advance to `ObsoleteState = Removed` once all callers have been updated.

Never skip straight to `ObsoleteState = Removed` without first going through `Pending` — doing so removes the warning cycle that callers depend on. Do not reclaim the ordinal in either stage. See also: `use-obsolete-pending-before-removed.md`.

See sample: `enum-changes-must-be-additive-at-the-end.good.al`.

## Anti Pattern

Inserting `value(1; "NewMiddleValue")` between existing `value(0; "First")` and the original `value(1; "Second")`. Every row that stored ordinal 1 before the change now reads as `NewMiddleValue`. The same applies to removing a value outright without obsoletion.

See sample: `enum-changes-must-be-additive-at-the-end.bad.al`.
