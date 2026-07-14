---
bc-version: [all]
domain: performance
keywords: [setloadfields, case, conditional, branch, field-loading]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Load common fields before branching on case

> Contributions welcome — open a PR to refine or extend this article.

## Description

When a known input determines which fields a subsequent record read will use, a single `SetLoadFields` containing every branch's fields loads unnecessary columns. Build the selection before `Get`, `FindFirst`, or `FindSet`: use `SetLoadFields` for fields common to every branch, then `AddLoadFields` for the selected branch. `SetLoadFields` replaces the current selection, while `AddLoadFields` preserves it.

## Best Practice

Call `SetLoadFields` with the common fields. In each branch, call `AddLoadFields` with that branch's normal fields and then perform the record read. This applies only when the discriminator is known before the read; branching on a field from an already-loaded row is too late to tailor that row's initial SQL projection.

See sample: `load-common-fields-before-branching-on-case.good.al`.

## Anti Pattern

A single top-level `SetLoadFields` enumerating every branch's fields, or a branch-local `SetLoadFields` that accidentally discards the common selection. Both make the declared load plan differ from the fields the selected path actually uses.

See sample: `load-common-fields-before-branching-on-case.bad.al`.
