---
bc-version: [all]
domain: performance
keywords: [findset, updlock, readisolation, locking, modify, obsolete-syntax]
technologies: [al]
countries: [w1]
application-area: [all]
---

# FindSet(true) applies UpdLock on the read; the two-parameter form is obsolete

## Description

`FindSet()` and `FindSet(false)` are read-only — no locking. Per the upstream guidance, `FindSet(true)` "signifies the intent is to modify records" and "sets `ReadIsolation::UpdLock` on the record before finding rows." That is exactly the right shape when the loop body modifies each row: the read takes the same lock the modification will need, avoiding the deadlock window between an unlocked read and a later upgrade. The older two-parameter form `FindSet(ForUpdate, UpdateKey)` is obsolete — only the single-parameter signature should appear in new code.

## Best Practice

Use `FindSet(true)` only when the loop body genuinely modifies the iterated rows; use `FindSet()` (or `FindSet(false)`) when the loop only reads. Do not write `FindSet(true, true)` or `FindSet(true, false)` — the two-parameter form is the obsolete signature.

See sample: [`findset-true-applies-updlock-on-read.good.al`](findset-true-applies-updlock-on-read.good.al).

## Anti Pattern

`FindSet(true)` on a loop that does not modify the iterated rows takes an `UpdLock` the work does not need; competing readers and writers stall against a lock the loop never uses. The mirror anti-pattern is `FindSet()` (no parameter) on a loop that *does* modify each row — the read takes a shared lock, the `Modify` then needs to upgrade, and the gap between them is a deadlock candidate.

See sample: [`findset-true-applies-updlock-on-read.bad.al`](findset-true-applies-updlock-on-read.bad.al).
