---
bc-version: [all]
domain: upgrade
keywords: [enum, ordinal, additive, append, backward-compatible, breaking-change]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Add new enum values only at the end

## Description

An AL `enum` is a fixed list of ordinal-named values. Persisted rows reference enum members by ordinal, not by name. The only enum mutation that preserves the meaning of every existing row is **appending a new value at the end** — every previously valid ordinal still maps to the same member. Inserting a new value in the middle, renumbering existing values, or removing a value without obsoletion all shift ordinals: rows written with the old layout silently take on the new member at their saved ordinal.

## Best Practice

When adding an enum value, place it after the last existing `value(N; ...)` entry, with an ordinal strictly greater than every existing one. Never renumber existing entries. To retire a value, do not delete it: mark it `ObsoleteState = Pending` (and later `Removed`) with `ObsoleteReason` and `ObsoleteTag` so the ordinal remains taken.

See sample: [`enum-values-additive-at-end.good.al`](enum-values-additive-at-end.good.al).

## Anti Pattern

Inserting a value between existing entries ("just put `NewMiddleValue` between `First` and `Second`"), or removing a value from the enum without first going through `ObsoleteState = Pending` → `Removed`. Every row whose persisted ordinal matched the removed or shifted value now reads as a different member.

See sample: [`enum-values-additive-at-end.bad.al`](enum-values-additive-at-end.bad.al).

## See also

- `obsoletion-requires-reason-and-tag.md` — how to retire an enum member correctly.
- `obsolete-pending-to-removed-staging.md` — the `Pending → Removed` lifecycle.
