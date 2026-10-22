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

`FindSet(true)` reads for update using `UpdLock`, which is useful when the loop will update the selected rows. `FindSet()` and `FindSet(false)` do not request that update intent, but neither guarantees an unlocked read nor a shared lock. In a read-write session with default record isolation, initial reads normally use `ReadUncommitted`; `LockTable` raises subsequent reads on that table to `UpdLock`. Under legacy locking, writes also raise subsequent reads to `UpdLock`; with tri-state locking they normally use `ReadCommitted` instead. An explicit record `ReadIsolation` can override the transaction's default isolation. With read scale-out, `LockTable` requests `RepeatableRead` instead of `UpdLock`. The older two-parameter form `FindSet(ForUpdate, UpdateKey)` is obsolete.

## Best Practice

Use `FindSet(true)` for a bounded read-modify loop when acquiring update locks at the read is appropriate; use `FindSet()` or `FindSet(false)` for ordinary read-only iteration. Inspect existing `LockTable`, record `ReadIsolation`, earlier writes and called helpers before alleging missing update locking. A bare `FindSet` after `LockTable` with default record isolation in a read-write session, or with explicit `ReadIsolation := IsolationLevel::UpdLock`, already has update-lock intent. Tri-state locking applies from BC 23 and can be disabled in versions 23-25; later versions always use it. Do not assume one version's post-write default for every target.

Consider lock ordering and duration across recursion, external calls and the full transaction before widening the locked set. `FindSet(true)` can reduce later lock-conversion work, but is not a guarantee against deadlocks. Do not write `FindSet(true, true)` or `FindSet(true, false)`; use the single-parameter signature.

See sample: [`findset-true-applies-updlock-on-read.good.al`](findset-true-applies-updlock-on-read.good.al).

## Anti Pattern

Requesting `UpdLock` for a read-only loop with no consistency requirement adds unnecessary contention with conflicting operations. Conversely, a read-modify path may benefit from update locks, but the Boolean argument alone does not prove that they are missing. Do not report a necessary shared-lock conversion or promise to eliminate deadlocks without establishing the actual isolation and transaction path.

See sample: [`findset-true-applies-updlock-on-read.bad.al`](findset-true-applies-updlock-on-read.bad.al).

## References

[FindSet(Boolean)](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-findset-boolean-method), [LockTable](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-locktable-method), [record instance isolation](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-read-isolation), and [tri-state locking](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-tri-state-locking) describe the update intent, transaction defaults, overrides and version conditions.
