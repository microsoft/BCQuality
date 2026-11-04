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

`FindSet(true)` reads using `UpdLock`, expressing the intent to update the selected rows. The distinction below concerns `FindSet()` and `FindSet(false)`: they do not request that intent, but do not guarantee either no locking or a shared lock. Their reads depend on the transaction's table state and the record's `ReadIsolation`; post-write defaults also differ between legacy and tri-state locking. These default-read qualifications do not negate the explicit `FindSet(true)` update-lock request. Acquiring update locks at the read can reduce later lock-conversion work, but cannot guarantee freedom from deadlocks. The older two-parameter form `FindSet(ForUpdate, UpdateKey)` is obsolete — only the single-parameter signature should appear in new code.

## Best Practice

Use `FindSet(true)` when the loop updates the selected rows and use `FindSet()` (or `FindSet(false)`) for ordinary read-only iteration. Before alleging missing update locks on a bare/false call, inspect existing locking and record isolation: for example, subsequent reads after `LockTable` use `UpdLock` in a read-write session with default record isolation. Do not write `FindSet(true, true)` or `FindSet(true, false)` — the two-parameter form is the obsolete signature.

See sample: [`findset-true-applies-updlock-on-read.good.al`](findset-true-applies-updlock-on-read.good.al).

## Anti Pattern

`FindSet(true)` on an ordinary read-only loop takes update locks the work does not need, increasing contention with conflicting operations. Conversely, a read-modify loop can benefit from update locks at the read, but a bare/false argument alone does not establish that they are missing. Do not describe every such loop as a necessary shared-to-update lock conversion or promise that changing the argument eliminates deadlocks.

See sample: [`findset-true-applies-updlock-on-read.bad.al`](findset-true-applies-updlock-on-read.bad.al).

References: [Record.FindSet](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-findset-boolean-method), [Read isolation](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-read-isolation), [Tri-state locking](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-tri-state-locking).
