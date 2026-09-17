---
bc-version: [all]
domain: upgrade
keywords: [obsolete-state, pending, removed, lifecycle, clean-flag, upgrade-code-timing]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Stage obsoletion `Pending → Removed`; write upgrade code on removal

## Description

`ObsoleteState` has a deliberate two-step lifecycle. `Pending` keeps the element compilable and present — callers still find it but receive a deprecation warning. `Removed` marks the element as gone from the contract; the body may be empty or wrapped in `#if not CLEAN<version>` so the symbol survives only for binary compatibility. Upgrade code that migrates persisted data away from the obsolete element is normally written when the element moves to `Removed`, not when it goes `Pending`. `ObsoleteState = Pending` without accompanying upgrade code is the expected steady state during the deprecation window; reviewers should not flag that combination as missing migration.

## Best Practice

Stage the deprecation across releases. Step 1: mark `Pending` with reason and tag; consumers are warned but data and code keep working. Step 2: in a later release, transition to `Removed` and (if persisted data references the element) ship an upgrade procedure that migrates that data — gated by an upgrade tag. The standard mechanic for retiring the actual implementation body is to remove the `#if not CLEAN<version>` block in the same release that flips the state to `Removed`.

See sample: [`obsolete-pending-to-removed-staging.good.al`](obsolete-pending-to-removed-staging.good.al).

## Anti Pattern

Jumping straight to `ObsoleteState = Removed` without a prior `Pending` release. Consumers have no deprecation window to migrate and any data still referencing the element is stranded. Equally wrong: leaving an element `Pending` indefinitely and never staging its removal — the deprecation never completes.

See sample: [`obsolete-pending-to-removed-staging.bad.al`](obsolete-pending-to-removed-staging.bad.al).
