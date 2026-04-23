---
bc-version: [all]
domain: upgrade
keywords: [obsolete, obsoletestate, obsoletereason, obsoletetag, deprecation]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Deprecate via ObsoleteState Pending first; move to Removed only after the grace window

## Description

AL's obsolete workflow is two-stage by design. `ObsoleteState = Pending` keeps the object or member compilable and callable but emits warnings and records the deprecation in metadata. `ObsoleteState = Removed` makes it a compile error for callers. Jumping straight to Removed — or marking Pending without `ObsoleteReason` and `ObsoleteTag` — breaks dependents who had no signal to migrate, and loses the tooling's ability to surface the planned removal in sandbox builds before the production tenant upgrades.

## Best Practice

Mark the element `ObsoleteState = Pending` with a concrete `ObsoleteReason` naming the replacement and an `ObsoleteTag` identifying the version the deprecation started. Keep it Pending through at least one major release so dependents have a cycle to migrate. Move to `ObsoleteState = Removed` only in a later release, with the same Reason and Tag retained or updated.

See sample: `use-obsolete-pending-before-removed.good.al`.

## Anti Pattern

`[Obsolete('', '')]` or `ObsoleteState = Removed` applied directly on an element that was public and callable in the previous release, with no preceding Pending phase. Dependents get a hard compile error with no migration signal in the previous version.

See sample: `use-obsolete-pending-before-removed.bad.al`.
