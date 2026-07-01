---
bc-version: [all]
domain: data-modeling
keywords: [blocked-field, testfield, referencing-code, point-of-use, enforcement, journal-line]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Enforce `Blocked` where the master is used, not in the master itself

## Description

The `Blocked` field on a master record (`Item`, `Customer`, `Resource`, or a custom master) is inert data. The master table holds **no** logic that acts on it. Enforcement belongs in the **consuming** code: when a journal line, document line, or posting routine references the master by its `No.`, that referencing object tests the flag at the point of use, e.g. `LoyaltyMember.Get("Member No."); LoyaltyMember.TestField(Blocked, false);` in the line's `OnValidate` and again before posting.

Putting the block check inside the master's own `OnInsert`/`OnModify` does nothing to stop transactional use: a blocked master is edited rarely, but it is *referenced* constantly, and those references never touch the master's own triggers. Base BC follows this split — `Item.Blocked` is checked by sales/purchase/journal code, not by the `Item` table. A boolean `Blocked` uses `TestField(Blocked, false)`; an option-style block (e.g. `Sales`/`All`) needs the specific option compared at each relevant path.

## Best Practice

The referencing line validates `Master.TestField(Blocked, false)` in `OnValidate` of the reference field and re-checks before posting. The master table stays logic-free on `Blocked`.

See sample: `check-blocked-in-referencing-code-not-in-master.good.al`.

## Anti Pattern

The block check sits in the master's own `OnModify`/`OnInsert` (so referencing and posting proceed unchecked), or there is no check at all on the referencing side.

See sample: `check-blocked-in-referencing-code-not-in-master.bad.al`.
