---
bc-version: [all]
domain: security
keywords: [permissionset, includedpermissionsets, assignable, composition, role]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Compose permission sets with IncludedPermissionSets

> Contributions welcome — open a PR to refine or extend this article.

## Description

The `IncludedPermissionSets` property lets one AL permission set reference another, composing rights out of smaller building blocks. Combined with `Assignable = false` on the building blocks, an extension can ship focused per-module units (a table-data cluster, an API-access cluster) and assemble role-shaped sets that include them. Adding an object updates one building block, and every role-shaped set that includes it inherits the change automatically — instead of drifting apart across duplicated definitions.

## Best Practice

Break permission grants into small, focused building blocks, one per cohesive concern. Mark the building blocks `Assignable = false` so administrators do not accidentally assign a fragment. Build role-shaped, `Assignable = true` sets that reference the relevant building blocks through `IncludedPermissionSets`. When the extension grows, the structure absorbs the growth without duplicated edits.

See sample: `compose-permission-sets-with-included-sets.good.al`.

## Anti Pattern

Declaring several role-shaped permission sets that each re-enumerate the same object lists. Adding a new table means touching every set by hand; the sets drift apart over time, and subtle authorization bugs appear where one role was updated and a sibling role was not.

See sample: `compose-permission-sets-with-included-sets.bad.al`.
