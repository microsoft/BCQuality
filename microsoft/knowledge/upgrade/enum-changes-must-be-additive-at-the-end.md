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

Append new enum values at the end, taking the next free ordinal. When a value must be retired, mark it with `ObsoleteState = Removed`, `ObsoleteReason`, and `ObsoleteTag` so tooling and downstream code can detect the deprecation; do not reclaim the ordinal. Renaming the caption on an existing ordinal is fine.

See sample: `enum-changes-must-be-additive-at-the-end.good.al`.

## Anti Pattern

Inserting `value(1; "NewMiddleValue")` between existing `value(0; "First")` and the original `value(1; "Second")`. Every row that stored ordinal 1 before the change now reads as `NewMiddleValue`. The same applies to removing a value outright without obsoletion.

See sample: `enum-changes-must-be-additive-at-the-end.bad.al`.
